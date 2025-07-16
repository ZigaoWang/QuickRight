//
//  QuickRightApp.swift
//  QuickRight
//
//  Created by Zigao Wang on 7/16/25.
//

import SwiftUI
import UserNotifications

@main
struct QuickRightApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Use a more reliable icon
            if let image = NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "QuickRight") {
                button.image = image
            } else {
                // Fallback to a basic icon
                button.title = "QR"
            }
            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "QuickRight - Right-click menu enhancer"
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 450, height: 600)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Hide dock icon - this makes it a true menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar context menu
        setupStatusBarMenu()
        
        // Register for notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }
    
    private func setupStatusBarMenu() {
        guard let button = statusItem?.button else { return }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open QuickRight", action: #selector(openMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About QuickRight", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit QuickRight", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Set targets
        for item in menu.items {
            if item.action != #selector(NSApplication.terminate(_:)) {
                item.target = self
            }
        }
        
        // Add right-click menu
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc func togglePopover() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        guard let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    private func showContextMenu() {
        guard let button = statusItem?.button else { return }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open QuickRight", action: #selector(openMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Restart Finder", action: #selector(restartFinder), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open System Preferences", action: #selector(openSystemPreferences), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About QuickRight", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit QuickRight", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Set targets
        for item in menu.items {
            if item.action != #selector(NSApplication.terminate(_:)) {
                item.target = self
            }
        }
        
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
    }
    
    @objc func openMainWindow() {
        showPopover()
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "QuickRight"
        alert.informativeText = "Version 1.0.0\n\nA free, minimal macOS right-click menu enhancer that brings Windows-style functionality to Finder.\n\nMade with ❤️ for Mac power users"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func restartFinder() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["Finder"]
        
        do {
            try task.run()
            
            // Show notification
            showNotification("QuickRight", "Finder restarted")
        } catch {
            NSLog("Failed to restart Finder: \(error)")
        }
    }
    
    @objc func openSystemPreferences() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-b", "com.apple.systempreferences", "/System/Library/PreferencePanes/Extensions.prefPane"]
        
        do {
            try task.run()
        } catch {
            NSLog("Failed to open System Preferences: \(error)")
        }
    }
    
    @objc func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window.contentViewController is NSHostingController<ContentView> {
            self.window = window
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showPopover()
        }
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up
        statusItem = nil
        popover = nil
        window = nil
    }
    
    private func showNotification(_ title: String, _ message: String) {
        let center = UNUserNotificationCenter.current()
        
        // Request permission if not already granted
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil
                )
                
                center.add(request) { error in
                    if let error = error {
                        NSLog("QuickRight: Failed to show notification: \(error)")
                    }
                }
            }
        }
    }
}
