import UIKit

extension KeyboardViewController {
    /// Non-interactive strip sitting in the existing top inset. Does not join `rootStack`.
    func installThemeTraceStrip() {
        guard ThemeTrace.isEnabled else { return }
        if themeTraceLabel != nil { return }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.45
        label.font = .monospacedSystemFont(ofSize: 8, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        label.textColor = .white
        label.text = "build=…"
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 12)
        ])
        themeTraceLabel = label
    }

    /// Reads the current palette and theme id. Does not write prefs or recolor keys.
    func refreshThemeTraceStrip() {
        guard ThemeTrace.isEnabled else {
            themeTraceLabel?.isHidden = true
            return
        }
        installThemeTraceStrip()
        guard let label = themeTraceLabel else { return }
        label.isHidden = false
        label.isUserInteractionEnabled = false
        let raw = ThemeIO.string("naqra.themeId") ?? "-"
        let id = NaqraPalette.normalizeThemeId(raw)
        let legacy = NaqraPalette.isLegacyTheme(id)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        palette.key.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = String(format: "%.2f,%.2f,%.2f", r, g, b)
        label.text = "build=\(NaqraBuildStamp.short) | read=\(raw) | legacy=\(legacy) | RGB=\(rgb)"
        view.bringSubviewToFront(label)
    }
}
