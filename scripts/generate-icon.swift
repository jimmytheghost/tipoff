import AppKit

let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let iconset = root.appendingPathComponent("Tipoff.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let image = NSImage(size: NSSize(width: pixels, height: pixels))
        image.lockFocus()
        let p = CGFloat(pixels)
        if let symbol = NSImage(systemSymbolName: "basketball.fill", accessibilityDescription: "Tipoff") {
            let config = NSImage.SymbolConfiguration(pointSize: p, weight: .medium)
                .applying(NSImage.SymbolConfiguration(paletteColors: [NSColor(calibratedWhite: 0.13, alpha: 1)]))
            symbol.withSymbolConfiguration(config)?.draw(in: NSRect(x: 0, y: 0, width: p, height: p))
        }
        image.unlockFocus()
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let filename = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: iconset.appendingPathComponent(filename))
    }
}
