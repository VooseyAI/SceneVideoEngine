//
//  UIImage+VideoRender.swift
//  SceneVideoEngine
//
//  Created by Lacy Rhoades on 9/29/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

#if !os(Linux)
import Foundation
#if os(macOS)
import AppKit
#endif
#if os(iOS)
import UIKit
#endif

#if canImport(UIKit)
public typealias NSUIImage = UIImage
#elseif canImport(AppKit)
public typealias NSUIImage = NSImage
#endif
#endif


import VooseyBridge
#if !os(macOS)
import UIKit

extension NSUIImage {
    func imageByOverlaying(_ overlay: UIImage) -> UIImage {
        let size = self.size
        let overlaySize = overlay.size

        var scale: CGFloat
        if size.height > size.width {
            scale = size.width / overlaySize.width
        } else {
            scale = size.height / overlaySize.height
        }

        let scaledSize = CGSize(width: overlaySize.width * scale, height: overlaySize.height * scale)

        let xOffset = (size.width - scaledSize.width) / 2.0
        let yOffset = (size.height - scaledSize.height) / 2.0

        let selfRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let scaledOverlayRect = CGRect(x: xOffset, y: yOffset, width: scaledSize.width, height: scaledSize.height)

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale);
        self.draw(in: selfRect)
        overlay.draw(in: scaledOverlayRect)
        let maybeResult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let result = maybeResult else {
            assert(false, "Unable to create overlayed image")
            return self
        }

        return result
    }
}

#else
import AppKit

extension NSUIImage {
	func imageByOverlaying(_ overlay: NSUIImage) -> NSUIImage {
		let background = self
		let newImage = NSImage(size: background.size)
		var newImageRect: CGRect = .zero
		newImageRect.size = newImage.size
		
		newImage.lockFocus()
		background.draw(in: newImageRect)
		overlay.draw(in: newImageRect)
		newImage.unlockFocus()
		
		return newImage
	}
	
	func addTextToImage(drawText text: String) -> NSImage {
		
		let targetImage = NSImage(size: self.size, flipped: false) { (dstRect: CGRect) -> Bool in
			
			self.draw(in: dstRect)
			let textColor = NSColor.white
			let textFont = NSFont(name: "Helvetica Bold", size: 36)! //Helvetica Bold
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = NSTextAlignment.center
			
			var textFontAttributes = [
				NSAttributedString.Key.font: textFont,
				NSAttributedString.Key.foregroundColor: textColor,
			] as [NSAttributedString.Key : Any]
			
			let textOrigin = CGPoint(x: self.size.height/3, y: -self.size.width/4)
			let rect = CGRect(origin: textOrigin, size: self.size)
			text.draw(in: rect, withAttributes: textFontAttributes)
			return true
		}
		return targetImage
	}
}
#endif
