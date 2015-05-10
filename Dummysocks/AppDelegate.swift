//
//  AppDelegate.swift
//  Dummysocks
//
//  Created by huoxy on 15/5/9.
//  Copyright (c) 2015年 huoxy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Start", action: Selector("startSocks:"), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Stop", action: Selector("stopSocks:"), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Restart Socks", action: Selector("restartSocks:"), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit Dummysocks", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        stopSocks(aNotification.object!)
    }
    
    func startSocks(sender: AnyObject) {
        println("in setup")
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["/Users/huoxy/.dummysocks/setup"]
        task.environment = NSProcessInfo().environment
        task.launch()
    }
    
    func stopSocks(sender: AnyObject) {
        println("in close")
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["/Users/huoxy/.dummysocks/close"]
        task.environment = NSProcessInfo().environment
        task.launch()
    }
    
    func restartSocks(sender: AnyObject){
        stopSocks(sender)
        startSocks(sender)
    }
    
}

