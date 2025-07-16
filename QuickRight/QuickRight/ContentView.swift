//
//  ContentView.swift
//  QuickRight
//
//  Created by Zigao Wang on 7/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var enabledActions: Set<String> = []
    @State private var showingAbout = false
    @State private var extensionStatus = "Checking..."
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
            
            // Main Content
            ScrollView {
                VStack(spacing: 20) {
                    // Extension Status
                    statusSection
                    
                    // Actions Configuration
                    actionsSection
                    
                    // Additional Features
                    additionalFeaturesSection
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            footerSection
        }
        .frame(minWidth: 450, minHeight: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadSettings()
            checkExtensionStatus()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 15) {
            Image(systemName: "cursorarrow.click.2")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("QuickRight")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Enhanced right-click menu for macOS")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showingAbout = true }) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .help("About QuickRight")
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.blue)
                Text("Extension Status")
                    .font(.headline)
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(extensionStatus == "Active" ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(extensionStatus)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            if extensionStatus != "Active" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("To enable QuickRight:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("1. Open System Preferences → Extensions")
                        Text("2. Select 'Finder Extensions'")
                        Text("3. Enable 'QuickRight Extension'")
                        Text("4. Restart Finder if needed")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                Text("Available Actions")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionToggle(
                    title: "New File",
                    subtitle: "Create text, markdown, Python, JS, JSON files",
                    icon: "doc.badge.plus",
                    isEnabled: enabledActions.contains("newFile")
                ) {
                    toggleAction("newFile")
                }
                
                ActionToggle(
                    title: "Open in Terminal",
                    subtitle: "Open folder in Terminal or iTerm",
                    icon: "terminal",
                    isEnabled: enabledActions.contains("openTerminal")
                ) {
                    toggleAction("openTerminal")
                }
                
                ActionToggle(
                    title: "Open in VS Code",
                    subtitle: "Open file/folder in VS Code",
                    icon: "chevron.left.forwardslash.chevron.right",
                    isEnabled: enabledActions.contains("openVSCode")
                ) {
                    toggleAction("openVSCode")
                }
                
                ActionToggle(
                    title: "Copy Full Path",
                    subtitle: "Copy file path to clipboard",
                    icon: "doc.on.clipboard",
                    isEnabled: enabledActions.contains("copyPath")
                ) {
                    toggleAction("copyPath")
                }
                
                ActionToggle(
                    title: "Cut File",
                    subtitle: "Cut file for moving (not just copy)",
                    icon: "scissors",
                    isEnabled: enabledActions.contains("cutFile")
                ) {
                    toggleAction("cutFile")
                }
                
                ActionToggle(
                    title: "Toggle Hidden Files",
                    subtitle: "Show/hide hidden files in Finder",
                    icon: "eye.slash",
                    isEnabled: enabledActions.contains("toggleHidden")
                ) {
                    toggleAction("toggleHidden")
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var additionalFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text("Features")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Native macOS Integration",
                    description: "Uses official Finder Sync Extension API"
                )
                
                FeatureRow(
                    icon: "bolt.fill",
                    title: "Lightweight & Fast",
                    description: "No background processes, minimal memory usage"
                )
                
                FeatureRow(
                    icon: "lock.fill",
                    title: "Privacy Focused",
                    description: "No data collection, works completely offline"
                )
                
                FeatureRow(
                    icon: "gear.2",
                    title: "Customizable",
                    description: "Enable only the features you need"
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var footerSection: some View {
        HStack {
            Button("Reset to Defaults") {
                resetToDefaults()
            }
            .buttonStyle(.link)
            
            Spacer()
            
            Text("Made with ❤️ for Mac power users")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func loadSettings() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.quickright.shared") ?? UserDefaults.standard
        let savedActions = sharedDefaults.array(forKey: "QuickRightEnabledActions") as? [String] ?? [
            "newFile", "openTerminal", "openVSCode", "copyPath", "cutFile", "toggleHidden"
        ]
        enabledActions = Set(savedActions)
    }
    
    private func toggleAction(_ action: String) {
        if enabledActions.contains(action) {
            enabledActions.remove(action)
        } else {
            enabledActions.insert(action)
        }
        
        // Save to shared UserDefaults for the extension to read
        let sharedDefaults = UserDefaults(suiteName: "group.com.quickright.shared") ?? UserDefaults.standard
        sharedDefaults.set(Array(enabledActions), forKey: "QuickRightEnabledActions")
    }
    
    private func resetToDefaults() {
        enabledActions = ["newFile", "openTerminal", "openVSCode", "copyPath", "cutFile", "toggleHidden"]
        let sharedDefaults = UserDefaults(suiteName: "group.com.quickright.shared") ?? UserDefaults.standard
        sharedDefaults.set(Array(enabledActions), forKey: "QuickRightEnabledActions")
    }
    
    private func checkExtensionStatus() {
        // In a real implementation, you'd check if the extension is enabled
        // For now, we'll assume it's active
        extensionStatus = "Active"
    }
}

struct ActionToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isEnabled ? .blue : .gray)
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isEnabled ? .blue : .gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 100)
            .background(isEnabled ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEnabled ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "cursorarrow.click.2")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("QuickRight")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Description
            VStack(spacing: 15) {
                Text("A free, minimal macOS right-click menu enhancer")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("Add power-user actions to your Finder context menu with native macOS integration. QuickRight brings Windows-style right-click functionality to macOS without the bloat.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                Text("Features:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Create new files instantly")
                    Text("• Open folders in Terminal/iTerm")
                    Text("• Launch VS Code from Finder")
                    Text("• Copy full file paths")
                    Text("• Cut files (real cut, not copy)")
                    Text("• Toggle hidden files visibility")
                }
                .font(.body)
            }
            
            Spacer()
            
            // Footer
            VStack(spacing: 10) {
                Text("Made with ❤️ for Mac power users")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 400, height: 550)
    }
}

#Preview {
    ContentView()
}
