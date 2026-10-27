#!/usr/bin/env swift
// asc.swift — zero-dependency App Store Connect CLI for the TestFlight loop.
// Runs with the Swift that ships in Xcode: `swift scripts/asc.swift <command>`.
//
// Env (same names as ship.sh's .env.ship):
//   ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH (path to AuthKey_XXXX.p8), BUNDLE_ID
//
// Commands:
//   builds                         latest 5 builds + processing state
//   groups                         beta groups, internal/external, public link
//   invite <email> <group> [first] [last]
//                                  add a tester to a group (creates the tester if new)
//   public-link <group> on|off     toggle a group's public TestFlight link (external groups)
//   feedback [limit]               screenshot feedback → feedback/<date>-screenshots.md
//   crashes [limit]                crash feedback + crash logs → feedback/<date>-crashes.md

import CryptoKit
import Foundation

// MARK: - Config

let env = ProcessInfo.processInfo.environment
func need(_ key: String) -> String {
    guard let value = env[key], !value.isEmpty else {
        FileHandle.standardError.write(Data("✗ missing env \(key)\n".utf8))
        exit(1)
    }
    return value
}

let keyID = need("ASC_KEY_ID")
let issuerID = need("ASC_ISSUER_ID")
let keyPath = (need("ASC_KEY_PATH") as NSString).expandingTildeInPath
let bundleID = need("BUNDLE_ID")
let base = URL(string: "https://api.appstoreconnect.apple.com")!

// MARK: - JWT (ES256, 20-minute max lifetime)

func base64URL(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func makeToken() throws -> String {
    let pem = try String(contentsOfFile: keyPath, encoding: .utf8)
    let key = try P256.Signing.PrivateKey(pemRepresentation: pem)
    let now = Int(Date().timeIntervalSince1970)
    let header = try JSONSerialization.data(withJSONObject: ["alg": "ES256", "kid": keyID, "typ": "JWT"])
    let claims = try JSONSerialization.data(withJSONObject: [
        "iss": issuerID, "iat": now, "exp": now + 1_200, "aud": "appstoreconnect-v1",
    ])
    let signingInput = base64URL(header) + "." + base64URL(claims)
    // rawRepresentation is r‖s (64 bytes) — exactly the JWS ES256 encoding.
    let signature = try key.signature(for: Data(signingInput.utf8)).rawRepresentation
    return signingInput + "." + base64URL(signature)
}

let token = try makeToken()

// MARK: - HTTP

typealias JSON = [String: Any]

func call(_ method: String, _ path: String, query: [String: String] = [:], body: JSON? = nil) async throws -> JSON {
    var components = URLComponents(url: base.appending(path: path), resolvingAgainstBaseURL: false)!
    if !query.isEmpty { components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) } }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    if let body {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
    }
    let (data, response) = try await URLSession.shared.data(for: request)
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard (200..<300).contains(status) else {
        let detail = String(data: data, encoding: .utf8) ?? ""
        throw NSError(domain: "ASC", code: status, userInfo: [NSLocalizedDescriptionKey: "HTTP \(status) \(method) \(path)\n\(detail)"])
    }
    if data.isEmpty { return [:] }
    return (try JSONSerialization.jsonObject(with: data)) as? JSON ?? [:]
}

func items(_ json: JSON) -> [JSON] { json["data"] as? [JSON] ?? [] }
func attrs(_ item: JSON) -> JSON { item["attributes"] as? JSON ?? [:] }
func str(_ value: Any?) -> String { value.map { "\($0)" } ?? "—" }

func appID() async throws -> String {
    let apps = items(try await call("GET", "/v1/apps", query: ["filter[bundleId]": bundleID, "limit": "1"]))
    guard let id = apps.first?["id"] as? String else { throw NSError(domain: "ASC", code: 404, userInfo: [NSLocalizedDescriptionKey: "no app with bundle id \(bundleID) — create the app record in App Store Connect first"]) }
    return id
}

func group(named name: String, app: String) async throws -> JSON {
    let groups = items(try await call("GET", "/v1/apps/\(app)/betaGroups", query: ["limit": "200"]))
    guard let match = groups.first(where: { str(attrs($0)["name"]).caseInsensitiveCompare(name) == .orderedSame }) else {
        let names = groups.map { str(attrs($0)["name"]) }.joined(separator: ", ")
        throw NSError(domain: "ASC", code: 404, userInfo: [NSLocalizedDescriptionKey: "no beta group '\(name)'. Groups: \(names)"])
    }
    return match
}

func writeReport(_ name: String, _ text: String) throws -> String {
    let dir = URL(fileURLWithPath: "feedback", isDirectory: true)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let day = Date().formatted(.iso8601.year().month().day())
    let file = dir.appending(path: "\(day)-\(name).md")
    try text.write(to: file, atomically: true, encoding: .utf8)
    return file.path
}

// MARK: - Commands

func builds() async throws {
    let app = try await appID()
    let list = items(try await call("GET", "/v1/builds", query: [
        "filter[app]": app, "sort": "-uploadedDate", "limit": "5",
    ]))
    for build in list {
        let a = attrs(build)
        print("\(str(a["version"]))\t\(str(a["processingState"]))\t\(str(a["uploadedDate"]))\texpired=\(str(a["expired"]))")
    }
}

func groups() async throws {
    let app = try await appID()
    for g in items(try await call("GET", "/v1/apps/\(app)/betaGroups", query: ["limit": "200"])) {
        let a = attrs(g)
        let kind = (a["isInternalGroup"] as? Bool) == true ? "internal" : "external"
        let link = (a["publicLinkEnabled"] as? Bool) == true ? str(a["publicLink"]) : "(no public link)"
        print("\(str(a["name"]))\t\(kind)\t\(link)")
    }
}

func invite(email: String, groupName: String, first: String?, last: String?) async throws {
    let app = try await appID()
    let g = try await group(named: groupName, app: app)
    var attributes: JSON = ["email": email]
    if let first { attributes["firstName"] = first }
    if let last { attributes["lastName"] = last }
    _ = try await call("POST", "/v1/betaTesters", body: [
        "data": [
            "type": "betaTesters",
            "attributes": attributes,
            "relationships": ["betaGroups": ["data": [["type": "betaGroups", "id": g["id"]!]]]],
        ],
    ])
    print("✓ invited \(email) to \(groupName) — they get an email with a TestFlight redeem link")
}

func publicLink(groupName: String, enabled: Bool) async throws {
    let app = try await appID()
    let g = try await group(named: groupName, app: app)
    let updated = try await call("PATCH", "/v1/betaGroups/\(g["id"]!)", body: [
        "data": ["type": "betaGroups", "id": g["id"]!, "attributes": ["publicLinkEnabled": enabled]],
    ])
    let a = (updated["data"] as? JSON).map(attrs) ?? [:]
    print(enabled ? "✓ public link: \(str(a["publicLink"]))" : "✓ public link disabled")
}

func feedback(limit: Int) async throws {
    let app = try await appID()
    let list = items(try await call("GET", "/v1/apps/\(app)/betaFeedbackScreenshotSubmissions", query: [
        "sort": "-createdDate", "limit": String(limit),
    ]))
    var md = "# TestFlight screenshot feedback (\(list.count))\n\n"
    for item in list {
        let a = attrs(item)
        md += "## \(str(a["createdDate"])) — \(str(a["email"]))\n"
        md += "- Device: \(str(a["deviceModel"])) · iOS \(str(a["osVersion"])) · \(str(a["locale"])) · battery \(str(a["batteryPercentage"]))%\n"
        md += "- Comment: \(str(a["comment"]))\n"
        for shot in a["screenshots"] as? [JSON] ?? [] {
            // Signed URLs expire (see `expirationDate`) — download now if you need to keep them.
            md += "- Screenshot: \(str(shot["url"]))\n"
        }
        md += "\n"
    }
    print("✓ \(list.count) items → \(try writeReport("screenshots", md))")
}

func crashes(limit: Int) async throws {
    let app = try await appID()
    let list = items(try await call("GET", "/v1/apps/\(app)/betaFeedbackCrashSubmissions", query: [
        "sort": "-createdDate", "limit": String(limit),
    ]))
    var md = "# TestFlight crash feedback (\(list.count))\n\n"
    for item in list {
        let a = attrs(item)
        let id = str(item["id"])
        md += "## \(str(a["createdDate"])) — \(str(a["email"]))\n"
        md += "- Device: \(str(a["deviceModel"])) · iOS \(str(a["osVersion"])) · uptime \(str(a["appUptimeInMilliseconds"]))ms\n"
        md += "- Comment: \(str(a["comment"]))\n\n"
        if let log = try? await call("GET", "/v1/betaFeedbackCrashSubmissions/\(id)/crashLog"),
           let text = (log["data"] as? JSON).map(attrs)?["logText"] as? String {
            md += "```\n\(text.prefix(6_000))\n```\n\n"
        }
    }
    print("✓ \(list.count) crashes → \(try writeReport("crashes", md))")
}

// MARK: - Main

let args = Array(CommandLine.arguments.dropFirst())
do {
    switch args.first {
    case "builds": try await builds()
    case "groups": try await groups()
    case "invite" where args.count >= 3:
        try await invite(email: args[1], groupName: args[2],
                         first: args.count > 3 ? args[3] : nil, last: args.count > 4 ? args[4] : nil)
    case "public-link" where args.count == 3:
        try await publicLink(groupName: args[1], enabled: args[2] == "on")
    case "feedback": try await feedback(limit: Int(args.dropFirst().first ?? "") ?? 50)
    case "crashes": try await crashes(limit: Int(args.dropFirst().first ?? "") ?? 20)
    default:
        print("usage: swift asc.swift builds | groups | invite <email> <group> [first] [last] | public-link <group> on|off | feedback [n] | crashes [n]")
        exit(2)
    }
} catch {
    FileHandle.standardError.write(Data("✗ \(error.localizedDescription)\n".utf8))
    exit(1)
}
