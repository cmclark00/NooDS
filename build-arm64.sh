#!/bin/bash

# Build script for NooDS on ARM64 devices
# Specifically tested for Allwinner H700 with Cortex-A53

set -e

echo "NooDS ARM64 Build Script"
echo "========================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check pkg-config packages
check_pkg_config() {
    if ! pkg-config --exists "$1"; then
        echo "❌ Package '$1' not found via pkg-config"
        return 1
    else
        echo "✅ Found $1: $(pkg-config --modversion "$1")"
        return 0
    fi
}

# Function to check wx-config
check_wx_config() {
    if ! command_exists wx-config; then
        echo "❌ wx-config not found. wxWidgets not installed or not in PATH."
        return 1
    else
        echo "✅ Found wxWidgets: $(wx-config --version)"
        return 0
    fi
}

# Function to detect correct wxWidgets package
detect_wx_package() {
    # Try to find the correct wxWidgets package name
    for pkg in libwxgtk3.2-dev libwxgtk3.0-gtk3-dev libwxgtk-dev libwxgtk3.0-dev libwxbase3.0-dev; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            echo "$pkg"
            return 0
        fi
    done
    echo "libwxgtk-dev"  # fallback
}

# Function to detect correct PortAudio package
detect_portaudio_package() {
    # Try to find the correct PortAudio package name
    for pkg in portaudio19-dev libportaudio-dev libportaudio2-dev; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            echo "$pkg"
            return 0
        fi
    done
    echo "portaudio19-dev"  # fallback
}

echo "Checking build dependencies..."
echo

# Check basic build tools
MISSING_DEPS=()

if ! command_exists g++; then
    echo "❌ g++ not found"
    MISSING_DEPS+=("g++")
else
    echo "✅ Found g++: $(g++ --version | head -n1)"
fi

if ! command_exists make; then
    echo "❌ make not found"
    MISSING_DEPS+=("make")
else
    echo "✅ Found make: $(make --version | head -n1)"
fi

if ! command_exists pkg-config; then
    echo "❌ pkg-config not found"
    MISSING_DEPS+=("pkg-config")
else
    echo "✅ Found pkg-config: $(pkg-config --version)"
fi

# Check required libraries
echo
echo "Checking required libraries..."

PORTAUDIO_OK=false
WXWIDGETS_OK=false
OPENGL_OK=false

if check_pkg_config "portaudio-2.0"; then
    PORTAUDIO_OK=true
fi

if check_wx_config; then
    WXWIDGETS_OK=true
fi

# Check for OpenGL headers
if [ -f "/usr/include/GL/gl.h" ] || [ -f "/usr/include/GL/GL.h" ]; then
    echo "✅ Found OpenGL headers"
    OPENGL_OK=true
else
    echo "❌ OpenGL headers not found"
fi

echo

# Report status and provide installation suggestions
if [ ${#MISSING_DEPS[@]} -ne 0 ] || [ "$PORTAUDIO_OK" = false ] || [ "$WXWIDGETS_OK" = false ] || [ "$OPENGL_OK" = false ]; then
    echo "Missing dependencies detected. Install suggestions:"
    echo
    
    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo "Basic build tools:"
        echo "  Ubuntu/Debian: sudo apt-get install build-essential pkg-config"
        echo "  CentOS/RHEL:   sudo yum groupinstall \"Development Tools\" && sudo yum install pkgconfig"
        echo "  Alpine:        sudo apk add build-base pkgconfig"
        echo
    fi
    
    if [ "$PORTAUDIO_OK" = false ]; then
        echo "PortAudio:"
        if command_exists apt-cache; then
            PA_PACKAGE=$(detect_portaudio_package)
            echo "  Ubuntu/Debian: sudo apt-get install libportaudio2 $PA_PACKAGE"
        else
            echo "  Ubuntu/Debian: sudo apt-get install libportaudio2 portaudio19-dev (or libportaudio-dev)"
        fi
        echo "  CentOS/RHEL:   sudo yum install portaudio portaudio-devel"
        echo "  Alpine:        sudo apk add portaudio portaudio-dev"
        echo
    fi
    
    if [ "$WXWIDGETS_OK" = false ]; then
        echo "wxWidgets:"
        if command_exists apt-cache; then
            WX_PACKAGE=$(detect_wx_package)
            echo "  Ubuntu/Debian: sudo apt-get install $WX_PACKAGE"
        else
            echo "  Ubuntu/Debian: sudo apt-get install libwxgtk3.2-dev (or libwxgtk3.0-gtk3-dev)"
        fi
        echo "  CentOS/RHEL:   sudo yum install wxGTK3-devel"
        echo "  Alpine:        sudo apk add wxgtk3-dev"
        echo
    fi
    
    if [ "$OPENGL_OK" = false ]; then
        echo "OpenGL:"
        echo "  Ubuntu/Debian: sudo apt-get install libgl1-mesa-dev libglu1-mesa-dev"
        echo "  CentOS/RHEL:   sudo yum install mesa-libGL-devel mesa-libGLU-devel"
        echo "  Alpine:        sudo apk add mesa-dev glu-dev"
        echo
    fi
    
    echo "After installing dependencies, run this script again."
    exit 1
fi

echo "All dependencies found! ✅"
echo

# Check GCC version and provide warnings for known issues
GCC_VERSION=$(g++ -dumpversion | cut -d. -f1)
echo "Detected GCC version: $GCC_VERSION"

if [ "$GCC_VERSION" -lt 5 ]; then
    echo "⚠️  Warning: GCC version < 5 detected. Some C++11 features may not work correctly."
    echo "   Consider using more conservative compiler flags."
fi

echo

# Detect architecture and CPU info
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "✅ ARM64 architecture detected"
    if [ -f "/proc/cpuinfo" ]; then
        CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | xargs)
        echo "Detected CPU: $CPU_MODEL"
        
        if echo "$CPU_MODEL" | grep -qi "cortex-a53"; then
            echo "✅ Cortex-A53 detected - using optimized flags"
        else
            echo "ℹ️  Different ARM64 CPU detected - using generic ARM64 flags"
        fi
    fi
else
    echo "⚠️  Non-ARM64 architecture detected ($ARCH)"
    echo "   Building with generic flags for testing/cross-compilation"
    echo "   For actual ARM64 device deployment, run this on the target device"
fi

echo

# Start the build
echo "Starting NooDS build..."
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "Using Makefile.arm64 with ARM64 optimizations"
elif [ -n "$CXX" ] && [[ "$CXX" == *"aarch64"* ]]; then
    echo "Cross-compilation detected: CXX=$CXX"
    echo "Using Makefile.arm64 with cross-compilation"
else
    echo "Using Makefile.arm64 with generic flags (cross-compilation/testing)"
fi

if make -f Makefile.arm64 -j$(nproc); then
    echo
    echo "🎉 Build successful!"
    echo "Binary location: ./noods"
    echo
    echo "To install system-wide:"
    echo "  sudo make -f Makefile.arm64 install"
    echo
    echo "To run locally:"
    echo "  ./noods"
else
    echo
    echo "❌ Build failed. Common fixes:"
    echo
    echo "1. If you get linker errors, try:"
    echo "   make -f Makefile.arm64 clean && make -f Makefile.arm64 ARGS='-O1 -std=c++11 -DUSE_GL_CANVAS -DLOG_LEVEL=0'"
    echo
    echo "2. If you get 'undefined reference' errors, try:"
    echo "   export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:\$PKG_CONFIG_PATH"
    echo
    echo "3. For old GCC versions, try:"
    echo "   make -f Makefile.arm64 ARGS='-O1 -std=c++0x -DUSE_GL_CANVAS -DLOG_LEVEL=0' clean all"
    echo
    exit 1
fi 