import CoreGraphics
import LineManager
import MultiPlatform
import StringView

final class CaretRectFactory {
    private let stringView: StringView
    private let lineManager: LineManager
    private let lineControllerStorage: LineControllerStorage
    private let textContainerInset: MultiPlatformEdgeInsets

    init(
        stringView: StringView,
        lineManager: LineManager,
        lineControllerStorage: LineControllerStorage,
        textContainerInset: MultiPlatformEdgeInsets
    ) {
        self.stringView = stringView
        self.lineManager = lineManager
        self.lineControllerStorage = lineControllerStorage
        self.textContainerInset = textContainerInset
    }

    func caretRect(at location: Int, allowMovingCaretToNextLineFragment: Bool) -> CGRect {
        let leadingLineSpacing = textContainerInset.left
        let safeLocation = min(max(location, 0), stringView.string.length)
        let line = lineManager.line(containingCharacterAt: safeLocation)!
        let lineController = lineControllerStorage.getOrCreateLineController(for: line)
        let lineLocalLocation = safeLocation - line.location
        if allowMovingCaretToNextLineFragment && shouldMoveCaretToNextLineFragment(forLocation: lineLocalLocation, in: line) {
            let rect = caretRect(at: location + 1, allowMovingCaretToNextLineFragment: false)
            return CGRect(x: leadingLineSpacing, y: rect.minY, width: rect.width, height: rect.height)
        } else {
            let localCaretRect = lineController.caretRect(atIndex: lineLocalLocation)
            let globalYPosition = line.yPosition + localCaretRect.minY
            let globalRect = CGRect(x: localCaretRect.minX, y: globalYPosition, width: localCaretRect.width, height: localCaretRect.height)
            return globalRect.offsetBy(dx: leadingLineSpacing, dy: textContainerInset.top)
        }
    }
}

private extension CaretRectFactory {
    private func shouldMoveCaretToNextLineFragment(forLocation location: Int, in line: LineNode) -> Bool {
        let lineController = lineControllerStorage.getOrCreateLineController(for: line)
        guard lineController.numberOfLineFragments > 0 else {
            return false
        }
        guard let lineFragmentNode = lineController.lineFragmentNode(containingCharacterAt: location) else {
            return false
        }
        guard lineFragmentNode.index > 0 else {
            return false
        }
        return location == lineFragmentNode.data.lineFragment?.range.location
    }
}
