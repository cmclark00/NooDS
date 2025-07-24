#include <iostream>
#include <string>

int main(int argc, char** argv) {
    std::cout << "=== ARM64 Runtime Test ===" << std::endl;
    std::cout << "Program started successfully!" << std::endl;
    std::cout << "Arguments received: " << argc << std::endl;
    
    for (int i = 0; i < argc; i++) {
        std::cout << "  arg[" << i << "]: " << argv[i] << std::endl;
    }
    
    std::cout << "Basic C++ features working!" << std::endl;
    std::cout << "Test completed successfully!" << std::endl;
    
    return 0;
} 