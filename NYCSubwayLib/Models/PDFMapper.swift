//
//  PDFMapper.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/25/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import UIKit
import PDFKit
import LithoOperators

public protocol PDFMapper {
    var pdfView: PDFView! { get set }
}
func setupPdfMap(for mapper: PDFMapper) { mapper.setupPdfMap() }
func zoomFunction(for mapper: PDFMapper) -> (UITapGestureRecognizer) -> Void { return mapper.zoomIn(_:) }
func disableLongPresses(for mapper: PDFMapper) { mapper.disableLongPresses() }
func clearTapGestureRecognizers(on mapper: PDFMapper) { mapper.clearTapGestureRecognizers() }

extension PDFMapper {
    var isZoomedOut: Bool {
        get {
            return pdfView.scaleFactor <= pdfView.scaleFactorForSizeToFit
        }
    }
    
    func setupPdfMap() {
        pdfView.autoScales = true
        pdfView.maxScaleFactor = 3.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
    }
    
    func disableLongPresses() {
        if let recognizers = pdfView.gestureRecognizers {
            for recognizer in recognizers where recognizer is UILongPressGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
    }
    
    func clearTapGestureRecognizers() {
        pdfView.documentView?.gestureRecognizers?.forEach(~>pdfView.documentView!.removeGestureRecognizer)
    }
    
    func zoomIn(_ recognizer: UITapGestureRecognizer) {
        let touch = recognizer.location(in: pdfView.documentView)
        pdfView.scaleFactor = isZoomedOut ? pdfView.maxScaleFactor : pdfView.scaleFactorForSizeToFit
        
        let scaledWindowWidth = pdfView.bounds.size.width * pdfView.scaleFactorForSizeToFit / 2
        let x = touch.x - scaledWindowWidth
        
        let scaledWindowHeight = pdfView.bounds.size.height * pdfView.scaleFactorForSizeToFit / 2
        let centeredY = touch.y - scaledWindowHeight
        let pdfYCoord = (pdfView.documentView?.bounds.size.height ?? 0) - centeredY
        
        pdfView.go(to: CGRect(x: x, y: pdfYCoord, width: 1, height: 1), on: pdfView.currentPage!)
    }
}

extension UIView {
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "ViewAssociatedObjectKey_tapGestureRecognizer"
    }
    
    fileprivate var tapGestureRecognizerAction: ((UITapGestureRecognizer) -> Void)? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get { return objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? (UITapGestureRecognizer) -> Void }
    }
    
    public func addTapGestureRecognizer(numberOfTaps: Int, action: ((UITapGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.numberOfTapsRequired = numberOfTaps
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action(sender)
        }
    }
}
