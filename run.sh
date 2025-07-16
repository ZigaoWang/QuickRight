#!/bin/bash

# QuickRight Build and Run Script
# This script builds and runs the QuickRight app with proper error handling

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XCODE_PROJECT="$PROJECT_DIR/QuickRight/QuickRight.xcodeproj"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="QuickRight"

# Functions
print_header() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}         QuickRight Build Script          ${NC}"
    echo -e "${BLUE}===========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_requirements() {
    print_info "Checking requirements..."
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode command line tools are not installed."
        print_info "Install with: xcode-select --install"
        exit 1
    fi
    
    # Check if project exists
    if [ ! -f "$XCODE_PROJECT/project.pbxproj" ]; then
        print_error "Xcode project not found at: $XCODE_PROJECT"
        exit 1
    fi
    
    print_success "Requirements check passed"
}

clean_build() {
    print_info "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    print_success "Build directory cleaned"
}

build_app() {
    print_info "Building QuickRight..."
    
    cd "$PROJECT_DIR/QuickRight"
    
    # Build the app
    xcodebuild -project QuickRight.xcodeproj \
               -scheme QuickRight \
               -configuration Debug \
               -derivedDataPath "$BUILD_DIR" \
               build
    
    if [ $? -eq 0 ]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

run_app() {
    print_info "Launching QuickRight..."
    
    # Find the built app
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        print_error "Built app not found"
        exit 1
    fi
    
    # Kill existing instance if running
    pkill -f "$APP_NAME" 2>/dev/null || true
    
    # Launch the app
    open "$APP_PATH"
    
    print_success "QuickRight launched"
    print_info "Check your menu bar for the QuickRight icon"
}

show_instructions() {
    echo -e "${YELLOW}===========================================${NC}"
    echo -e "${YELLOW}         Setup Instructions               ${NC}"
    echo -e "${YELLOW}===========================================${NC}"
    echo -e "${GREEN}1. Enable the Finder Extension:${NC}"
    echo "   • Open System Preferences → Extensions"
    echo "   • Select 'Finder Extensions'"
    echo "   • Enable 'QuickRight Extension'"
    echo ""
    echo -e "${GREEN}2. Test the Extension:${NC}"
    echo "   • Right-click on any file or folder in Finder"
    echo "   • You should see QuickRight options"
    echo ""
    echo -e "${GREEN}3. Configure Actions:${NC}"
    echo "   • Click the QuickRight icon in your menu bar"
    echo "   • Toggle actions on/off as needed"
    echo ""
    echo -e "${GREEN}4. Troubleshooting:${NC}"
    echo "   • If context menu doesn't appear, restart Finder:"
    echo "     killall Finder"
    echo "   • Check Console.app for error messages"
    echo "   • Ensure required apps are installed (VS Code, iTerm, etc.)"
}

# Main execution
main() {
    print_header
    
    case "${1:-build}" in
        "clean")
            clean_build
            ;;
        "build")
            check_requirements
            clean_build
            build_app
            ;;
        "run")
            check_requirements
            clean_build
            build_app
            run_app
            show_instructions
            ;;
        "help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  build    - Build the app (default)"
            echo "  run      - Build and run the app"
            echo "  clean    - Clean build directory"
            echo "  help     - Show this help message"
            ;;
        *)
            print_error "Unknown command: $1"
            print_info "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 