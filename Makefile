ARMGNU ?= aarch64-linux-gnu

BUILD_DIR = zig-out/bin
SRC_DIR = src

all : kernel8.img
	@echo Building kernel image...

kernel8.img: $(BUILD_DIR)/kernel8.elf
	@$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
	@echo Done

$(BUILD_DIR)/kernel8.elf :
	@echo Building kernel8.elf...
	@zig build
	@echo Done

clean :
	@echo Cleaning obj files...
	@rm -rf $(BUILD_DIR)/*.img $(BUILD_DIR)/*.elf
	@echo Done

qemu : kernel8.img
	@echo Emulating on QEMU...
	@qemu-system-aarch64 \
		-M raspi3b \
		-kernel kernel8.img \
		-serial null \
		-serial stdio \
		-display default

.PHONY: qemu clean all
