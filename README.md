# 🧠 QuickRight

A **free, minimal macOS right-click menu enhancer** that gives you power-user actions like Windows users have always enjoyed.

![QuickRight Demo](https://img.shields.io/badge/macOS-13.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.9+-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🗂️ **New File Creation**
- Create `.txt`, `.md`, `.py`, `.js`, `.json` files instantly
- Right-click in any folder → "New File" → Choose type
- Files are created and automatically selected
- Smart file naming with conflict resolution

### 🔗 **Open in Terminal/iTerm**
- Right-click any folder → "Open in Terminal"
- Automatically detects iTerm vs Terminal
- Works from Finder sidebar, desktop, and folder views
- Enhanced AppleScript integration

### 💻 **Open in VS Code**
- Right-click files/folders → "Open in VS Code"
- Supports VS Code and VS Code Insiders
- Works with files and entire directories
- Robust path detection

### ✂️ **Cut File (Real Cut)**
- Right-click → "Cut File" for actual cut behavior
- Unlike macOS default copy-paste, this is true cut-paste
- Files are marked for moving, not copying
- Improved pasteboard integration

### 📝 **Copy Full Path**
- Right-click any file → "Copy Full Path"
- Copies the complete file path to clipboard
- Perfect for terminal commands and scripts
- Instant notification feedback

### 👁️ **Toggle Hidden Files**
- Right-click → "Toggle Hidden Files"
- Show/hide hidden files in Finder instantly
- No need to use terminal commands
- Automatic Finder refresh

## 🚀 Installation

### Quick Start
```bash
# Clone and run
git clone https://github.com/your-username/QuickRight.git
cd QuickRight
./run.sh run
```

### Manual Installation
1. Clone this repository
2. Open `QuickRight.xcodeproj` in Xcode
3. Build and run (⌘+R)
4. The app will appear in your menu bar

### Enable the Extension
1. Run the app once
2. Open **System Preferences** → **Extensions** → **Finder Extensions**
3. Enable "QuickRight Extension"
4. Right-click in Finder to see the new menu items

## 🖥️ How It Works

QuickRight consists of two parts:

1. **Menu Bar App**: Professional UI for configuring actions
2. **Finder Extension**: Adds context menu items with emoji icons

The menu bar app provides:
- ✅ Toggle actions on/off with visual feedback
- 📊 Extension status monitoring
- 🔄 Quick Finder restart
- ⚙️ Direct access to System Preferences
- 📱 Modern, native macOS interface

## ⚙️ Configuration

Click the QuickRight icon in your menu bar to access:

- **Action Toggles**: Enable/disable specific features
- **Extension Status**: Real-time monitoring
- **Quick Actions**: Restart Finder, open System Preferences
- **Professional UI**: Grid layout with visual indicators

All settings are automatically saved using App Groups for seamless sync between the main app and Finder extension.

## 🛠 Technical Details

- **Language**: Swift 5.9+
- **Framework**: SwiftUI + AppKit + FinderSync
- **Extension Type**: Finder Sync Extension
- **Minimum macOS**: 13.0+
- **Architecture**: Native macOS (no Electron bloat)
- **Storage**: App Groups for shared preferences
- **Notifications**: Native macOS notifications

## 🔧 Supported Actions

| Action | Description | Context | Status |
|--------|-------------|---------|--------|
| 📁 New File | Create text/markdown/python/js/json files | Empty space | ✅ Enhanced |
| 🖥️ Open in Terminal | Launch Terminal/iTerm in folder | Folders | ✅ Enhanced |
| 💻 Open in VS Code | Open files/folders in VS Code | Files & Folders | ✅ Enhanced |
| 📋 Copy Full Path | Copy file path to clipboard | Files & Folders | ✅ Enhanced |
| ✂️ Cut File | Real cut operation (not copy) | Files & Folders | ✅ Enhanced |
| 👁️ Toggle Hidden Files | Show/hide hidden files in Finder | Anywhere | ✅ New |

## 🎨 Professional UI

- **Modern Design**: Native macOS styling with proper spacing
- **Visual Feedback**: Color-coded status indicators
- **Grid Layout**: Organized action toggles
- **Status Monitoring**: Real-time extension status
- **Context Menus**: Right-click menu bar icon for quick actions
- **Notifications**: Native macOS notifications for all actions

## 🐛 Troubleshooting

### Extension Not Showing
1. Check **System Preferences** → **Extensions** → **Finder Extensions**
2. Make sure "QuickRight Extension" is enabled
3. Restart Finder: Right-click menu bar icon → "Restart Finder"
4. Check Console.app for error messages

### Actions Not Working
1. Open the menu bar app and check action toggles
2. Verify required apps are installed (VS Code, iTerm, etc.)
3. Check permissions in **System Preferences** → **Security & Privacy**
4. Use the enhanced build script: `./run.sh run`

### Build Issues
```bash
# Clean build
./run.sh clean

# Build only
./run.sh build

# Build and run with instructions
./run.sh run
```

## 🎯 Why QuickRight?

Existing solutions are either:
- 💰 **Paid** (Right Click Booster, Path Finder)
- 🗿 **Outdated** (XtraFinder, discontinued)
- 🐌 **Bloated** (Heavy file managers)

QuickRight is:
- ✨ **Free** and open source
- ⚡ **Fast** native implementation
- 👶 **Simple** to use and configure
- 🔧 **Hackable** for developers
- 🎨 **Professional** UI/UX
- 🔔 **Notification** feedback
- 🛡️ **Privacy** focused

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./run.sh run`
5. Submit a pull request

## 🔮 Roadmap

- [ ] Support for more editors (Cursor, IntelliJ, Sublime)
- [ ] Image conversion (JPG/PNG/WebP)
- [ ] Custom script support
- [ ] Compress/extract archives
- [ ] Clean hidden files (.DS_Store, etc.)
- [ ] Folder size calculation
- [ ] Quick file preview
- [ ] Batch file operations

## 🚀 Build Script

The enhanced build script provides:

```bash
./run.sh help     # Show usage
./run.sh build    # Build only
./run.sh run      # Build and run with setup instructions
./run.sh clean    # Clean build directory
```

Features:
- ✅ Requirements checking
- 🧹 Clean build process
- 🎨 Colorized output
- 📋 Setup instructions
- ❌ Error handling

---

**Made with ❤️ for Mac power users who miss Windows right-click menus**

