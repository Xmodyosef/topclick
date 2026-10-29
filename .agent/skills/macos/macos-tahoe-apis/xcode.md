# Xcode 27 for macOS Projects

What changed in the toolchain that affects how Mac code is written and built. Everything here
was checked against Xcode 27.0 (27A266a). General Swift guidance lives in `swift/concurrency`
and `swift/concurrency-patterns`.

## Concurrency defaults

New projects (since Xcode 26) set two build settings that change how code compiles:

| Setting | New-project value | Effect |
|---|---|---|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` | Unannotated types and functions are `@MainActor` |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | Async functions run on the caller's actor unless marked `@concurrent` |

✅ Opt types out explicitly when they must run off the main actor: `nonisolated final class Parser { … }`.
❌ Assuming a subclass of an AppKit/Foundation class is nonisolated. Under MainActor default, overriding
a nonisolated method (e.g. `URLProtocol.startLoading()`) is a compile error until the class is marked `nonisolated`.

Code that must build in *both* old and new projects should compile in plain Swift 6 mode **and** with
`-default-isolation MainActor`. This repo's `scripts/check-swift-typecheck.sh` checks both.

## Export methods renamed

`xcodebuild -exportArchive` options (`xcodebuild -help`):

| Deprecated | Use |
|---|---|
| `app-store` | `app-store-connect` |
| `ad-hoc` | `release-testing` |
| `development` | `debugging` |
| — | `developer-id` (notarized distribution outside the Mac App Store) |

`destination = upload` with `-authenticationKeyPath/-ID/-IssuerID` exports and uploads in one step.
See `generators/testflight-ship` (iOS) and `generators/ci-cd-setup` (notarization).

## Previews

```swift
#Preview("Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
```

❌ `PreviewProvider` structs in new code. `#Preview` is the current form.

## References

- [Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes)
- [Swift migration guide](https://www.swift.org/migration/)
