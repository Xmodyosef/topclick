import SwiftUI
import Translation
import UIKit
import AudioToolbox

final class ClipboardHistory {
    static let shared = ClipboardHistory()
    private let key = "clipboardHistory"
    private let max = 20

    var items: [String] {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false else { return [] }
        return ThemeIO.string(key)?.split(separator: "\u{1F}").map(String.init) ?? []
    }

    func ensurePrivacyDefault() {
        guard ThemeIO.bool("clipboardHistoryEnabled") == nil else { return }
        ThemeIO.set("clipboardHistoryEnabled", value: false)
        ThemeIO.set(key, value: "")
    }

    func clear() { ThemeIO.set(key, value: "") }

    func add(_ text: String) {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false, !text.isEmpty else { return }
        var list = items
        list.removeAll { $0 == text }
        list.insert(text, at: 0)
        if list.count > max { list = Array(list.prefix(max)) }
        ThemeIO.set(key, value: list.joined(separator: "\u{1F}"))
    }
}

