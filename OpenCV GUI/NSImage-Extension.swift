//
//  NSImageExtension.swift
//  OpenCV Labs
//
//  Created by Alexander on 26.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

import Foundation
import Cocoa
import Quartz

extension NSImage {
    
    func CGImage() -> CGImage {
        var rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
    }
    
    func saveAsPNGWithName(_ fileName: String) {
        let bitmapImg = NSBitmapImageRep(data: (self.tiffRepresentation)!)
        let dataToSave = bitmapImg?.representation(using: NSBitmapImageFileType.PNG, properties: [NSImageCompressionFactor : 1])
        try? dataToSave?.write(to: URL(fileURLWithPath: fileName), options: [.atomic])

    }
}
