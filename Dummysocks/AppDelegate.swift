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
    let originEnvironment = NSProcessInfo().environment
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start", action: Selector("startSocks:"), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Stop", action: Selector("stopSocks:"), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Restart", action: Selector("restartSocks:"), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Edit Config", action: Selector("editConfig:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit Dummysocks", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func getHome() -> String{
        let home: AnyObject = originEnvironment["HOME"]!
        return home as! String
    }
    
    func getConfigDirectory() -> String{
        let home = getHome()
        let configDirectory = "\(home)/.dummysocks"
        return configDirectory
    }
    
    func getConfigFilePath() -> String{
        let configDirectory = getConfigDirectory()
        let configFilePath: AnyObject = configDirectory + "/config"
        return configFilePath as! String
    }
    
    func getConfig() -> NSDictionary{
        let configFilePath = getConfigFilePath()
        let config = NSDictionary(contentsOfFile: configFilePath)
        return config!
    }

    func setupConfig() {
        
        let configDirectory = getConfigDirectory()
        if (!NSFileManager.defaultManager().fileExistsAtPath(configDirectory)){
            NSFileManager.defaultManager().createDirectoryAtPath(configDirectory, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        
        let configFilePath = getConfigFilePath()
        if (!NSFileManager.defaultManager().fileExistsAtPath(configFilePath)){
            let srcPath = NSBundle.mainBundle().URLForResource("config.example", withExtension: nil)?.path
            NSFileManager.defaultManager().copyItemAtPath(srcPath!, toPath: configFilePath, error: nil)
        }
        let fileURLs = [NSURL.fileURLWithPath(configFilePath)!]
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs(fileURLs)
        
    }
    
    func editConfig(sender: AnyObject){
        setupConfig()
    }
    
    func startSocks(sender: AnyObject) {
        println("in setup")
        let config = getConfig()
        let user: AnyObject = config["user"]!
        let host: AnyObject = config["host"]!
        let private_key: AnyObject = config["private_key"]!
        for i in 1...5 {
            let task = NSTask()
            task.launchPath = "/usr/bin/screen"
            task.environment = originEnvironment
            let home: AnyObject = getHome()
            let port = 7000 + i
            // screen -d -m ssh -D 127.0.0.1:7001 huoxy@diablo
            task.arguments = ["-d", "-m", "/usr/bin/ssh", "-D", "127.0.0.1:\(port)", "-i", "\(private_key)", "\(user)@\(host)"]
            task.launch()
            
        }
        
        let task = NSTask()
        let balancePath = NSBundle.mainBundle().URLForResource("balance", withExtension: nil)?.path
        task.launchPath = balancePath!
        task.environment = originEnvironment
        task.arguments = ["-b", "127.0.0.1", "8118", "127.0.0.1:7001", "127.0.0.1:7002", "127.0.0.1:7003", "127.0.0.1:7004", "127.0.0.1:7005"]
        task.launch()
    }
    
    func stopSocks(sender: AnyObject) {
        println("in close")
        let task = NSTask()
        task.launchPath = "/usr/bin/pkill"
        task.arguments = ["-9", "-f", "ssh -D|balance -b"]
        task.environment = originEnvironment
        task.launch()
    }
    
    func restartSocks(sender: AnyObject){
        stopSocks(sender)
        startSocks(sender)
    }
        
    func applicationWillTerminate(aNotification: NSNotification) {
        stopSocks(aNotification.object!)
    }
    
}

