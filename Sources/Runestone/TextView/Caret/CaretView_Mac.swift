#if os(macOS)
import AppKit

final class CaretView: NSView {
    var color: NSColor = .label {
        didSet {
            if color != oldValue {
                setNeedsDisplay()
            }
        }
    }
    var isBlinkingEnabled = false {
        didSet {
            if isBlinkingEnabled != oldValue {
                blinkTimer?.invalidate()
                if isBlinkingEnabled {
                    blinkTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blink), userInfo: nil, repeats: true)
                }
            }
        }
    }

    private var blinkTimer: Timer?
    private var isVisible = true {
        didSet {
            if isVisible != oldValue {
                setNeedsDisplay()
            }
        }
    }

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        context.clear(bounds)
        if isVisible {
            let rect = CGRect(origin: .zero, size: bounds.size)
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
    }

    func delayBlink() {
        let wasBlinking = isBlinkingEnabled
        isBlinkingEnabled = false
        isVisible = true
        isBlinkingEnabled = wasBlinking
    }
}

private extension CaretView {
    @objc private func blink() {
        isVisible.toggle()
    }
}
#endif