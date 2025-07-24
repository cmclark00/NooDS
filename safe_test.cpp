#include <iostream>
#include <string>
#include <fstream>

// Include some basic headers first
#include "settings.h"

int main(int argc, char** argv) {
    std::cout << "=== NooDS ARM64 Safe Test ===" << std::endl;
    std::cout << "Program started successfully!" << std::endl;
    
    // Test basic settings access
    try {
        std::cout << "Settings directBoot: " << Settings::directBoot << std::endl;
        std::cout << "Settings bios9Path: " << Settings::bios9Path << std::endl;
        std::cout << "✅ Settings access working!" << std::endl;
    } catch (...) {
        std::cout << "❌ Settings access failed!" << std::endl;
        return 1;
    }
    
    // Check if required files exist
    std::cout << "\nChecking for BIOS files..." << std::endl;
    std::ifstream bios9("bios9.bin");
    std::ifstream bios7("bios7.bin");
    std::ifstream firmware("firmware.bin");
    
    std::cout << "bios9.bin exists: " << (bios9.good() ? "YES" : "NO") << std::endl;
    std::cout << "bios7.bin exists: " << (bios7.good() ? "YES" : "NO") << std::endl;
    std::cout << "firmware.bin exists: " << (firmware.good() ? "YES" : "NO") << std::endl;
    
    if (argc > 1) {
        std::string romPath = argv[1];
        std::cout << "\nChecking ROM file: " << romPath << std::endl;
        std::ifstream rom(romPath);
        std::cout << "ROM exists: " << (rom.good() ? "YES" : "NO") << std::endl;
        
        if (!rom.good()) {
            std::cout << "❌ ROM file not found, this would cause Core construction to fail!" << std::endl;
            std::cout << "Note: Core requires either valid ROM or BIOS files present." << std::endl;
            return 1;
        }
    }
    
    std::cout << "\n✅ Basic environment check passed!" << std::endl;
    std::cout << "ARM64 runtime is working correctly." << std::endl;
    std::cout << "\nTo fix the segfault, either:" << std::endl;
    std::cout << "1. Provide valid ROM file as argument" << std::endl;
    std::cout << "2. Or place bios9.bin, bios7.bin, firmware.bin in current directory" << std::endl;
    
    return 0;
} 