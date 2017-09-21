//
//  EventMonitor.swift
//  AutomaticBuilder
//
//  Created by Aidar on 14.09.17.
//  Copyright © 2017 Aidar Khakimzyanov. All rights reserved.
//

import Cocoa

class EventMonitor {
    
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> ()
    
    
    // MARK: - Init Methods
    init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Action Methods
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject
    }
    
    func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
