#!/bin/bash

echo "Creating minimal BIOS files for NooDS..."

# Create minimal dummy BIOS files
# These are not real BIOS files, just empty files to prevent segfaults

# ARM9 BIOS (4KB)
dd if=/dev/zero of=bios9.bin bs=4096 count=1 2>/dev/null
echo "Created bios9.bin (4KB)"

# ARM7 BIOS (16KB) 
dd if=/dev/zero of=bios7.bin bs=16384 count=1 2>/dev/null
echo "Created bios7.bin (16KB)"

# Firmware (256KB)
dd if=/dev/zero of=firmware.bin bs=262144 count=1 2>/dev/null
echo "Created firmware.bin (256KB)"

echo ""
echo "Dummy BIOS files created!"
echo "Note: These are empty files. For proper DS emulation you need real BIOS files."
echo "But this should prevent the segfault and let you test if the ARM64 build works."
echo ""
echo "Copy these files to your ARM64 device in the same directory as noods:"
echo "- bios9.bin"
echo "- bios7.bin" 
echo "- firmware.bin"
echo "- noods (the ARM64 binary)" 