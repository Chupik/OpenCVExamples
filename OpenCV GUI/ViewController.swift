//
//  ViewController.swift
//  OpenCV GUI
//
//  Created by Alexander on 25.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {
    @IBOutlet weak var imageView: IKImageView!
    
    var processor = ImageProcessor()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.imageView.hasVerticalScroller = true
        //self.imageView.hasHorizontalScroller = true
        self.imageView.editable = false
        self.imageView.doubleClickOpensImageEditPanel = false
        self.imageView.backgroundColor = NSColor.clear
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func openButtonClicked(_ sender: AnyObject) {
        let openDialog = NSOpenPanel()
        openDialog.allowsMultipleSelection = false
        openDialog.canChooseDirectories = false
        
        openDialog.begin(completionHandler: { (res: Int) in
            if openDialog.urls.first != nil {
                let image = NSImage(contentsOf: openDialog.urls.first!)
                self.processor.sourceImage = image
                self.imageView.setImage(self.processor.sourceImage.CGImage(), imageProperties: nil)
            }
        })
    }
    
    @IBAction func saveButtonClicked(_ sender: AnyObject) {
        let saveDialog = NSSavePanel()
        saveDialog.allowedFileTypes = ["PNG"]
        
        saveDialog.begin(completionHandler: { (res: Int) in
            if saveDialog.url != nil {
                let image = NSImage(cgImage: self.imageView.image().takeUnretainedValue(), size: self.imageView.imageSize())
                image.saveAsPNGWithName(saveDialog.url!.path)
            }
        })
    }
    
    @IBAction func cleanImageButtonPushed(_ sender: AnyObject) {
        let cgImage = self.processor.sourceImage.CGImage()
        self.imageView.setImage(cgImage, imageProperties: nil)
    }
    
    @IBAction func bordersSearchingButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateImageBounds().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func linearFiltrationButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateFilter2DImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func antiAliasingButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateAntiAlliasedImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func morphOperationsButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateMorphImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func sobelOperatorButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateSobelImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func laplasOperatorButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateLaplasImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func kanniDetectorButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateKanniImage().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func histogramButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateHistogram().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func histogramImprovementButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.calculateImproveHistogram().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }
    
    @IBAction func SVMButtonPushed(_ sender: AnyObject) {
        let computedImage = self.processor.caclulateSVMTree().CGImage()
        self.imageView.setImage(computedImage, imageProperties: nil)
    }

}

