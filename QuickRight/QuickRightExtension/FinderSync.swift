import Cocoa
import FinderSync
import AppKit
import UserNotifications

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        
        // Monitor the entire file system - this is the key to making it work everywhere
        let rootURL = URL(fileURLWithPath: "/")
        FIFinderSyncController.default().directoryURLs = Set([rootURL])
        
        NSLog("QuickRight: FinderSync initialized, monitoring: %@", rootURL.path)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                NSLog("QuickRight: Notification permission error: %@", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Primary Finder Sync Protocol Methods
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        NSLog("QuickRight: menu(for:) called with menuKind: %@", String(describing: menuKind))
        
        switch menuKind {
        case .contextualMenuForItems:
            return contextualMenuForItems()
        case .contextualMenuForContainer:
            return contextualMenuForContainer()
        case .contextualMenuForSidebar:
            return contextualMenuForSidebar()
        default:
            return nil
        }
    }
    
    // MARK: - Menu Creation Methods
    
    private func contextualMenuForItems() -> NSMenu {
        let menu = NSMenu(title: "QuickRight")
        
        // Copy Full Path
        let copyPathItem = NSMenuItem(title: "Copy Full Path", action: #selector(copyFullPath(_:)), keyEquivalent: "")
        copyPathItem.target = self
        menu.addItem(copyPathItem)
        
        // Cut File
        let cutItem = NSMenuItem(title: "Cut", action: #selector(cutFile(_:)), keyEquivalent: "")
        cutItem.target = self
        menu.addItem(cutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Open in Terminal
        let terminalItem = NSMenuItem(title: "Open in Terminal", action: #selector(openInTerminal(_:)), keyEquivalent: "")
        terminalItem.target = self
        menu.addItem(terminalItem)
        
        // Open in VS Code
        let vscodeItem = NSMenuItem(title: "Open in VS Code", action: #selector(openInVSCode(_:)), keyEquivalent: "")
        vscodeItem.target = self
        menu.addItem(vscodeItem)
        
        return menu
    }
    
    private func contextualMenuForContainer() -> NSMenu {
        let menu = NSMenu(title: "QuickRight")
        
        // New File submenu
        let newFileItem = NSMenuItem(title: "New File", action: nil, keyEquivalent: "")
        let newFileSubmenu = NSMenu(title: "New File")
        
        let fileTypes = [
            ("Text File", "txt"),
            ("Markdown File", "md"),
            ("Python File", "py"),
            ("JavaScript File", "js"),
            ("JSON File", "json"),
            ("Swift File", "swift"),
            ("HTML File", "html"),
            ("CSS File", "css")
        ]
        
        for (title, ext) in fileTypes {
            let item = NSMenuItem(title: title, action: #selector(createNewFile(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = ext
            newFileSubmenu.addItem(item)
        }
        
        newFileItem.submenu = newFileSubmenu
        menu.addItem(newFileItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Open in Terminal
        let terminalItem = NSMenuItem(title: "Open in Terminal", action: #selector(openInTerminal(_:)), keyEquivalent: "")
        terminalItem.target = self
        menu.addItem(terminalItem)
        
        // Open in VS Code
        let vscodeItem = NSMenuItem(title: "Open in VS Code", action: #selector(openInVSCode(_:)), keyEquivalent: "")
        vscodeItem.target = self
        menu.addItem(vscodeItem)
        
        return menu
    }
    
    private func contextualMenuForSidebar() -> NSMenu {
        return contextualMenuForContainer()
    }
    
    // MARK: - Action Methods
    
    @objc private func copyFullPath(_ sender: NSMenuItem) {
        NSLog("QuickRight: copyFullPath called")
        
        let targetURL = getTargetURL()
        guard let target = targetURL else {
            NSLog("QuickRight: No target URL found")
            showNotification("QuickRight", "No file selected")
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(target.path, forType: .string)
        
        NSLog("QuickRight: Copied path: %@", target.path)
        showNotification("QuickRight", "Path copied to clipboard")
    }
    
    @objc private func cutFile(_ sender: NSMenuItem) {
        NSLog("QuickRight: cutFile called")
        
        let targetURL = getTargetURL()
        guard let target = targetURL else {
            NSLog("QuickRight: No target URL found")
            showNotification("QuickRight", "No file selected")
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Write the file URLs to the pasteboard
        let fileURLs = [target]
        pasteboard.writeObjects(fileURLs as [NSPasteboardWriting])
        
        // Add the cut operation marker
        pasteboard.setString("cut", forType: NSPasteboard.PasteboardType("com.apple.finder.cut"))
        
        NSLog("QuickRight: File cut to clipboard: %@", target.path)
        showNotification("QuickRight", "File cut to clipboard")
    }
    
    @objc private func createNewFile(_ sender: NSMenuItem) {
        NSLog("QuickRight: createNewFile called")
        
        guard let fileExtension = sender.representedObject as? String else {
            NSLog("QuickRight: No file extension found")
            return
        }
        
        let targetURL = getTargetURL()
        guard let target = targetURL else {
            NSLog("QuickRight: No target URL found")
            showNotification("QuickRight", "No folder selected")
            return
        }
        
        // Ensure we have a directory
        let directoryURL = target.hasDirectoryPath ? target : target.deletingLastPathComponent()
        
        // Create the file using a more robust method
        createFile(withExtension: fileExtension, in: directoryURL)
    }
    
    private func createFile(withExtension fileExtension: String, in directory: URL) {
        let baseFileName = fileExtension.isEmpty ? "New File" : "New File.\(fileExtension)"
        var fileName = baseFileName
        var fileURL = directory.appendingPathComponent(fileName)
        var counter = 1
        
        // Handle file name conflicts
        while FileManager.default.fileExists(atPath: fileURL.path) {
            let nameWithoutExtension = (baseFileName as NSString).deletingPathExtension
            let ext = (baseFileName as NSString).pathExtension
            fileName = ext.isEmpty ? "\(nameWithoutExtension) \(counter)" : "\(nameWithoutExtension) \(counter).\(ext)"
            fileURL = directory.appendingPathComponent(fileName)
            counter += 1
        }
        
        // Request access to the directory
        let accessed = directory.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                directory.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            // Create the file with appropriate content
            let content = getDefaultContent(for: fileExtension)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            NSLog("QuickRight: Created file: %@", fileURL.path)
            showNotification("QuickRight", "Created: \(fileName)")
            
            // Try to reveal the file in Finder
            DispatchQueue.main.async {
                NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: directory.path)
            }
            
        } catch {
            NSLog("QuickRight: Error creating file: %@", error.localizedDescription)
            showNotification("QuickRight", "Failed to create file: \(error.localizedDescription)")
        }
    }
    
    private func getDefaultContent(for fileExtension: String) -> String {
        switch fileExtension {
        case "py":
            return "#!/usr/bin/env python3\n# -*- coding: utf-8 -*-\n\n"
        case "js":
            return "// JavaScript file\n\n"
        case "html":
            return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
</body>
</html>
"""
        case "css":
            return "/* CSS file */\n\n"
        case "md":
            return "# New Document\n\n"
        case "swift":
            return "import Foundation\n\n"
        case "json":
            return "{\n    \n}\n"
        default:
            return ""
        }
    }
    
    @objc private func openInTerminal(_ sender: NSMenuItem) {
        NSLog("QuickRight: openInTerminal called")
        
        let targetURL = getTargetURL()
        guard let target = targetURL else {
            NSLog("QuickRight: No target URL found")
            showNotification("QuickRight", "No folder selected")
            return
        }
        
        let directoryPath = target.hasDirectoryPath ? target.path : target.deletingLastPathComponent().path
        NSLog("QuickRight: Opening terminal at path: %@", directoryPath)
        
        // Try iTerm first, then Terminal
        if isITermInstalled() {
            openInITerm(path: directoryPath)
        } else {
            openInSystemTerminal(path: directoryPath)
        }
    }
    
    private func isITermInstalled() -> Bool {
        let iTerm2Path = "/Applications/iTerm.app"
        return FileManager.default.fileExists(atPath: iTerm2Path)
    }
    
    private func openInITerm(path: String) {
        let script = """
        tell application "iTerm"
            activate
            create window with default profile
            tell current session of current window
                write text "cd '\(path)'"
            end tell
        end tell
        """
        
        executeAppleScript(script, successMessage: "Opened in iTerm")
    }
    
    private func openInSystemTerminal(path: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(path)'"
        end tell
        """
        
        executeAppleScript(script, successMessage: "Opened in Terminal")
    }
    
    @objc private func openInVSCode(_ sender: NSMenuItem) {
        NSLog("QuickRight: openInVSCode called")
        
        let targetURL = getTargetURL()
        guard let target = targetURL else {
            NSLog("QuickRight: No target URL found")
            showNotification("QuickRight", "No file selected")
            return
        }
        
        // Try command line VS Code first
        if isCommandLineVSCodeAvailable() {
            openWithCommandLineVSCode(path: target.path)
        } else {
            // Try to find VS Code application
            openVSCodeWithWorkspace(path: target.path)
        }
    }
    
    private func isCommandLineVSCodeAvailable() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/which"
        task.arguments = ["code"]
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    private func openWithCommandLineVSCode(path: String) {
        let task = Process()
        task.launchPath = "/usr/local/bin/code"
        task.arguments = [path]
        
        do {
            try task.run()
            NSLog("QuickRight: VS Code opened successfully via command line")
            showNotification("QuickRight", "Opened in VS Code")
        } catch {
            NSLog("QuickRight: Error opening VS Code with command line: %@", error.localizedDescription)
            // Fallback to opening the application directly
            openVSCodeWithWorkspace(path: path)
        }
    }
    
    private func openVSCodeWithWorkspace(path: String) {
        // Try to find VS Code (not Cursor)
        let vscodeApps = [
            "/Applications/Visual Studio Code.app",
            "/Applications/Visual Studio Code - Insiders.app",
            "/System/Applications/Visual Studio Code.app"
        ]
        
        for appPath in vscodeApps {
            if FileManager.default.fileExists(atPath: appPath) {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["-a", appPath, path]
                
                do {
                    try task.run()
                    NSLog("QuickRight: VS Code opened successfully")
                    showNotification("QuickRight", "Opened in VS Code")
                    return
                } catch {
                    NSLog("QuickRight: Error opening VS Code: %@", error.localizedDescription)
                }
            }
        }
        
        NSLog("QuickRight: VS Code not found")
        showNotification("QuickRight", "VS Code not found. Please install VS Code or add 'code' to your PATH.")
    }
    
    // MARK: - Helper Methods
    
    private func getTargetURL() -> URL? {
        // Try to get the selected item first
        if let selectedItems = FIFinderSyncController.default().selectedItemURLs(),
           let item = selectedItems.first {
            return item
        }
        
        // Fall back to the targeted URL (the folder being browsed)
        return FIFinderSyncController.default().targetedURL()
    }
    
    private func executeAppleScript(_ script: String, successMessage: String) {
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            
            if let error = error {
                NSLog("QuickRight: AppleScript error: %@", error.description)
                showNotification("QuickRight", "Failed to execute command")
            } else {
                NSLog("QuickRight: AppleScript executed successfully")
                showNotification("QuickRight", successMessage)
            }
        } else {
            showNotification("QuickRight", "Failed to create AppleScript")
        }
    }
    
    // MARK: - Utility Methods
    
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
                        NSLog("QuickRight: Notification error: %@", error.localizedDescription)
                    }
                }
            }
        }
    }
} 