# Building NooDS for ARM64 Devices

This guide specifically covers building NooDS for ARM64 devices like the Allwinner H700 with Cortex-A53 processors.

## Quick Start

The easiest way to build for your device is to use the provided build script:

```bash
./build-arm64.sh
```

This script will:
- Check all required dependencies
- Provide installation instructions for missing packages
- Auto-detect your architecture (ARM64 vs x86_64)
- Use appropriate compiler flags for your CPU
- Build NooDS with optimizations for your platform

**Note**: The script automatically detects if you're running on ARM64 or testing on x86_64. On ARM64 devices, it uses ARM-specific optimizations. On other architectures, it builds with generic flags for testing/cross-compilation.

## Manual Building

If you prefer to build manually:

```bash
# Build for ARM64
make arm64

# Or use the specific Makefile
make -f Makefile.arm64

# Clean ARM64 build
make -f Makefile.arm64 clean
```

## Dependencies

You'll need these packages installed:

### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install build-essential pkg-config
# wxWidgets (package name varies by Ubuntu version)
sudo apt-get install libwxgtk3.2-dev 
# If libwxgtk3.2-dev is not found, try: libwxgtk3.0-gtk3-dev or libwxgtk-dev

# PortAudio (package name varies by Ubuntu version)
sudo apt-get install libportaudio2 portaudio19-dev
# If portaudio19-dev is not found, try: libportaudio-dev

# OpenGL
sudo apt-get install libgl1-mesa-dev libglu1-mesa-dev
```

### CentOS/RHEL:
```bash
sudo yum groupinstall "Development Tools"
sudo yum install pkgconfig wxGTK3-devel portaudio portaudio-devel
sudo yum install mesa-libGL-devel mesa-libGLU-devel
```

### Alpine Linux:
```bash
sudo apk add build-base pkgconfig
sudo apk add wxgtk3-dev portaudio portaudio-dev
sudo apk add mesa-dev glu-dev
```

## Optimizations for ARM64

The `Makefile.arm64` includes several optimizations specifically for ARM64 devices:

- **Conservative optimization**: Uses `-O2` instead of `-Ofast` for better compatibility
- **ARM64 targeting**: Uses `-march=armv8-a -mtune=cortex-a53` for your specific CPU
- **No PIE issues**: Avoids the `-no-pie` flag that can cause problems on ARM64
- **Link-time optimization**: Uses `-ffunction-sections -fdata-sections` with `--gc-sections`

## Troubleshooting

### Package name issues:
Different Ubuntu/Debian versions use different package names:

**wxWidgets:**
```bash
# Try in this order:
sudo apt-get install libwxgtk3.2-dev
# or
sudo apt-get install libwxgtk3.0-gtk3-dev  
# or
sudo apt-get install libwxgtk-dev

# To find available packages:
apt-cache search "libwx.*-dev" | grep wx
```

**PortAudio:**
```bash
# Try in this order:
sudo apt-get install portaudio19-dev
# or  
sudo apt-get install libportaudio-dev

# To find available packages:
apt-cache search "portaudio.*dev"
```

### Build fails with "undefined reference" errors:
```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
make -f Makefile.arm64 clean
make -f Makefile.arm64
```

### GCC version too old (< 5.0):
```bash
make -f Makefile.arm64 ARGS="-O1 -std=c++0x -DUSE_GL_CANVAS -DLOG_LEVEL=0" clean all
```

### Link-time optimization issues:
```bash
make -f Makefile.arm64 ARGS="-O2 -std=c++11 -DUSE_GL_CANVAS -DLOG_LEVEL=0" clean all
```

### Performance issues:
For maximum performance on your Allwinner H700, you can try:
```bash
make -f Makefile.arm64 ARGS="-O3 -std=c++11 -DUSE_GL_CANVAS -DLOG_LEVEL=0 -march=armv8-a -mtune=cortex-a53 -flto" clean all
```

## Cross-compilation

If you're building on a different architecture, you can cross-compile:

```bash
# Install ARM64 cross-compiler
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# Set cross-compilation variables
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

# Build
make -f Makefile.arm64
```

## Installation

After successful build:

```bash
# Install system-wide (requires root)
sudo make -f Makefile.arm64 install

# Or run locally
./noods
```

## Notes for Allwinner H700

- Your device uses the Cortex-A53 processor, which is well-supported
- Linux 4.9.170 should work fine with the conservative build flags
- If you experience graphics issues, ensure your Mali GPU drivers are properly installed
- For best performance, consider enabling GPU hardware acceleration if available

## Performance Tips

1. **CPU Governor**: Set to `performance` for better emulation speed:
   ```bash
   echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

2. **Memory**: Ensure you have adequate RAM. DS emulation can be memory-intensive.

3. **Display**: Use the built-in screen layout options to optimize for your display resolution.

## Getting Help

If you encounter issues:
1. Run `./build-arm64.sh` to check dependencies
2. Check the console output for specific error messages
3. Try the troubleshooting steps above
4. Consider building with more conservative flags if problems persist 