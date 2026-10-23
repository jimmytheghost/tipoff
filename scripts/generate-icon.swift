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
        NSColor(calibratedRed: CGFloat(32) / 255, green: CGFloat(37) / 255, blue: CGFloat(38) / 255, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: p, height: p)).fill()
        NSGraphicsContext.current?.compositingOperation = .clear
        let seam = NSBezierPath()
        seam.lineWidth = max(1, p * 0.055)
        seam.lineCapStyle = .round
        seam.move(to: NSPoint(x: p * 0.5, y: 0)); seam.line(to: NSPoint(x: p * 0.5, y: p))
        seam.move(to: NSPoint(x: p * 0.08, y: 0)); seam.curve(to: NSPoint(x: p, y: p * 0.59), controlPoint1: NSPoint(x: p * 0.06, y: p * 0.25), controlPoint2: NSPoint(x: p * 0.33, y: p * 0.49))
        seam.move(to: NSPoint(x: p * 0.92, y: 0)); seam.curve(to: NSPoint(x: 0, y: p * 0.59), controlPoint1: NSPoint(x: p * 0.94, y: p * 0.25), controlPoint2: NSPoint(x: p * 0.67, y: p * 0.49))
        seam.move(to: NSPoint(x: p * 0.06, y: p * 0.18)); seam.line(to: NSPoint(x: p * 0.94, y: p * 0.82))
        seam.stroke()
        image.unlockFocus()
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let filename = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: iconset.appendingPathComponent(filename))
    }
}
