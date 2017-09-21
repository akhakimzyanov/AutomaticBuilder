//
//  AppDelegate.swift
//  AutomaticBuilder
//
//  Created by Aidar on 14.09.17.
//  Copyright © 2017 Aidar Khakimzyanov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    fileprivate let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    fileprivate let popover = NSPopover()
    fileprivate var eventMonitor: EventMonitor?

    
    // MARK: - Application Methods
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "builder")
            button.action = #selector(togglePopover)
        }
        
        popover.contentViewController = ViewController.controller()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover()
            }
        }
        
        eventMonitor?.start()
    }
    
    // MARK: - Popover Action Methods
    @objc fileprivate func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    fileprivate func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        
        eventMonitor?.start()
    }
    
    fileprivate func closePopover() {
        popover.performClose(nil)
        
        eventMonitor?.stop()
    }
}
