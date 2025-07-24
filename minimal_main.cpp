#include <iostream>
#include <string>
#include "core.h"

int main(int argc, char** argv) {
    std::cout << "NooDS ARM64 - Minimal Console Build" << std::endl;
    std::cout << "=====================================" << std::endl;
    
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <nds_rom_file>" << std::endl;
        std::cout << "This is a minimal console build for testing ARM64 compatibility." << std::endl;
        return 1;
    }
    
    std::string romPath = argv[1];
    std::cout << "Attempting to load: " << romPath << std::endl;
    
    try {
        // Create core instance
        Core core(romPath);
        std::cout << "✅ Core initialized successfully!" << std::endl;
        std::cout << "✅ ROM loaded successfully!" << std::endl;
        std::cout << "✅ ARM64 build is working!" << std::endl;
        
        // Just test initialization, don't run a full emulation loop
        std::cout << "Note: This is a minimal build for compatibility testing." << std::endl;
        std::cout << "For full emulation, use the desktop build with GUI." << std::endl;
        
        return 0;
    } catch (const std::exception& e) {
        std::cout << "❌ Error: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cout << "❌ Unknown error occurred" << std::endl;
        return 1;
    }
} 