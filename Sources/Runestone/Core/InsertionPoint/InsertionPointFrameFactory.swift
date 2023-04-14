import Combine
import CoreText
import Foundation

struct InsertionPointFrameFactory {
    let stringView: CurrentValueSubject<StringView, Never>
    let lineManager: CurrentValueSubject<LineManager, Never>
    let characterBoundsProvider: CharacterBoundsProvider
    let shape: CurrentValueSubject<InsertionPointShape, Never>
    let contentArea: CurrentValueSubject<CGRect, Never>
    let estimatedLineHeight: EstimatedLineHeight
    let estimatedCharacterWidth: CurrentValueSubject<CGFloat, Never>

    func frameOfInsertionPoint(at location: Int) -> CGRect {
        switch shape.value {
        case .verticalBar:
            return verticalBarInsertionPointFrame(at: location)
        case .underline:
            return underlineInsertionPointFrame(at: location)
        case .block:
            return blockInsertionPointFrame(at: location)
        }
    }
}

extension InsertionPointFrameFactory {
    private var fixedLength: CGFloat {
        #if os(iOS)
        return 2
        #else
        return 1
        #endif
    }

    private func verticalBarInsertionPointFrame(at location: Int) -> CGRect {
        if let bounds = characterBoundsProvider.boundsOfComposedCharacterSequence(atLocation: location, moveToToNextLineFragmentIfNeeded: true) {
            let originY = bounds.minY + (bounds.height - estimatedLineHeight.rawValue.value) / 2
            return CGRect(x: bounds.minX, y: originY, width: fixedLength, height: estimatedLineHeight.rawValue.value)
        } else {
            let originY = contentArea.value.minY + (estimatedLineHeight.scaledValue.value - estimatedLineHeight.rawValue.value) / 2
            return CGRect(x: contentArea.value.minX, y: originY, width: fixedLength, height: estimatedLineHeight.rawValue.value)
        }
    }

    private func underlineInsertionPointFrame(at location: Int) -> CGRect {
        if let bounds = characterBoundsProvider.boundsOfComposedCharacterSequence(atLocation: location, moveToToNextLineFragmentIfNeeded: true) {
            let width = displayableCharacterWidth(forCharacterAtLocation: location, widthActualWidth: bounds.width)
            return CGRect(x: bounds.minX, y: bounds.maxY - fixedLength, width: width, height: fixedLength)
        } else {
            return CGRect(
                x: contentArea.value.minX,
                y: estimatedLineHeight.rawValue.value - fixedLength,
                width: estimatedCharacterWidth.value,
                height: fixedLength
            )
        }
    }

    private func blockInsertionPointFrame(at location: Int) -> CGRect {
        if let bounds = characterBoundsProvider.boundsOfComposedCharacterSequence(atLocation: location, moveToToNextLineFragmentIfNeeded: true) {
            let width = displayableCharacterWidth(forCharacterAtLocation: location, widthActualWidth: bounds.width)
            return CGRect(x: bounds.minX, y: bounds.minY, width: width, height: bounds.height)
        } else {
            return CGRect(
                x: contentArea.value.minX,
                y: contentArea.value.minY,
                width: estimatedCharacterWidth.value,
                height: estimatedLineHeight.rawValue.value
            )
        }
    }

    private func displayableCharacterWidth(forCharacterAtLocation location: Int, widthActualWidth actualWidth: CGFloat) -> CGFloat {
        guard let line = lineManager.value.line(containingCharacterAt: location) else {
            return actualWidth
        }
        // If the insertion point is placed at the last character in a line,
        // i.e. berfore a line break, then we make sure to return the estimated
        // character width.
        let lineLocalLocation = location - line.location
        if lineLocalLocation == line.data.length {
            return estimatedCharacterWidth.value
        } else {
            return actualWidth
        }
    }
}
