#include "include/kprint.h"
#include "include/terminal.h"

// Add these to your kernel.c

// Simple random number generator
static unsigned long rand_seed = 12345;

unsigned long simple_rand(void) {
    rand_seed = rand_seed * 1103515245 + 12345;
    return rand_seed;
}

char random_char(void) {
    // Generate printable ASCII chars (33-126)
    // Includes: !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
    return (char)(33 + (simple_rand() % 94));
}

// Simple delay function (CPU-based, very approximate)
void delay(unsigned int milliseconds) {
    volatile unsigned int i;
    // This is very rough - actual timing depends on CPU speed
    for (i = 0; i < milliseconds * 1000; i++) {
        // Busy wait
    }
}

void kprint_random_chars(void) {
    char random_str[5]; // 4 chars + null terminator
    
    for (int i = 0; i < 4; i++) {
        random_str[i] = random_char();
    }
    random_str[4] = '\0';
    
    kprint(random_str);
    kprint(" "); // Space between groups
}

// Modified kmain function
void kmain(void) {
    // Your existing initialization
   kprint_init();
    kprint("Kernel started! Random chars every 0.2s:\n");
    
    // Seed random with some value (you could use RDTSC if available)
    rand_seed = 54321;
    
    // Main loop with random printing
    while (1) {
        kprint_random_chars();
        delay(200); // Roughly 0.2 seconds
        
        // Optional: Add newline every 10 groups
        static int count = 0;
        if (++count % 10 == 0) {
            kprint("\n");
        }
    }
}

// Alternative: Use counter for more predictable timing
void kmain_with_counter(void) {
    kprint_init();
    kprint("Kernel started! Random chars:\n");
    
    unsigned long counter = 0;
    while (1) {
        // Print random chars every N iterations
        if (counter % 100000 == 0) {  // Adjust this value
            kprint_random_chars();
        }
        counter++;
    }
}
