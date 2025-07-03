# Compiler and tools
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = i686-elf-objcopy

# Directories
BUILD_DIR = /workspaces/codespaces-blank/os/bootloader/build
BIN_DIR = /workspaces/codespaces-blank/os/bootloader/bin

# Flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -m32 -march=i686 -fno-pie -fno-stack-protector -nostdlib -nostartfiles
LDFLAGS = -T linker.ld --oformat elf32-i386 -m elf_i386
ASMFLAGS = -f elf32

# Source files
BOOT_SRC = boot.asm
KERNEL_ASM = kernel.asm
KERNEL_C = ../kernel/kernel.c ../kernel/kprint.c ../kernel/terminal.c

# Output files
BOOT_BIN = $(BIN_DIR)/boot.bin
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BIN_DIR)/kernel.bin
KERNEL_ASM_O = $(BUILD_DIR)/kernel_asm.o
KERNEL_C_O = $(patsubst ../kernel/%.c,$(BUILD_DIR)/%.o,$(KERNEL_C))
DISK_IMG = $(BIN_DIR)/disk.img

# Default target
all: $(DISK_IMG)

# Create necessary directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Build bootloader binary
$(BOOT_BIN): $(BOOT_SRC) | $(BIN_DIR)
	$(ASM) -f bin $(BOOT_SRC) -o $(BOOT_BIN)

# Build kernel assembly object
$(KERNEL_ASM_O): $(KERNEL_ASM) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $(KERNEL_ASM) -o $@

# Build kernel C object files
$(BUILD_DIR)/%.o: ../kernel/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I kernel/include -c $< -o $@
	@echo "Built C object: $@"

# Link kernel ELF
$(KERNEL_ELF): $(KERNEL_ASM_O) $(KERNEL_C_O)
	$(LD) $(LDFLAGS) $^ -o $@

# Convert ELF to flat binary
$(KERNEL_BIN): $(KERNEL_ELF) | $(BIN_DIR)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

# Create bootable disk image
$(DISK_IMG): $(BOOT_BIN) $(KERNEL_BIN) | $(BIN_DIR)
	rm -f $(DISK_IMG)
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=20
	dd if=$(BOOT_BIN)   of=$(DISK_IMG) conv=notrunc bs=512 seek=0
	dd if=$(KERNEL_BIN) of=$(DISK_IMG) conv=notrunc bs=512 seek=1

# Run in QEMU
run: $(DISK_IMG)
	qemu-system-i386 -drive format=raw,file=$(DISK_IMG)

# Run with GDB debug info
debug: $(DISK_IMG)
	qemu-system-i386 -drive format=raw,file=$(DISK_IMG) -s -S

# Edit source files
boot:
	micro boot.asm

kernel:
	micro kernel.asm

kernelc:
	micro ../kernel/kernel.c

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

# Show build info
info:
	@echo "Build directory: $(BUILD_DIR)"
	@echo "Binary directory: $(BIN_DIR)"
	@echo "Bootloader: sector 0 ($(BOOT_BIN))"
	@echo "Kernel: sectors 1+ ($(KERNEL_BIN))"
	@ls -la $(BUILD_DIR)/* 2>/dev/null || echo "No build files"
	@ls -la $(BIN_DIR)/* 2>/dev/null || echo "No binary files"

.PHONY: all run debug boot kernel kernelc clean info
