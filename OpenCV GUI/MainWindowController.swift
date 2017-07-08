//
//  MainWindowController.swift
//  OpenCV Labs
//
//  Created by Alexander on 25.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return ["ToolBarOpenItem"]
    }
    
    override func validateToolbarItem(_ theItem: NSToolbarItem) -> Bool {
        return true
    }

}
