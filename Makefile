ARMGNU ?= aarch64-linux-gnu

BUILD_DIR = zig-out/bin
SRC_DIR = src

all : kernel8.img
	@echo Done

kernel8.img: $(BUILD_DIR)/kernel8.elf
	@echo Building kernel8.img...
	@$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img

$(BUILD_DIR)/kernel8.elf :
	@echo Building kernel8.elf...
	@zig build
	@echo Done

clean :
	@echo Cleaning obj files...
	@rm -rf *.img $(BUILD_DIR)/*.elf
	@echo Done

qemu: kernel8.img
	@echo Emulating on QEMU...
	@qemu-system-aarch64 \
		-M raspi3b \
		-kernel kernel8.img \
		-serial stdio \
		-display none

qemu-nd : kernel8.img
	@echo Emulating on QEMU...
	@qemu-system-aarch64 \
		-M raspi3b \
		-kernel kernel8.img \
		-serial null \
		-serial stdio \
		-display none

qemu-d : kernel8.img
	@echo Emulating on QEMU...
	@qemu-system-aarch64 \
		-M raspi3b \
		-kernel kernel8.img \
		-serial null \
		-serial stdio \
		-display gtk

.PHONY: qemu clean all
