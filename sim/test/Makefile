PREFIX  ?= riscv32-unknown-elf-
CC       = $(PREFIX)gcc
OBJCOPY  = $(PREFIX)objcopy
OBJDUMP  = $(PREFIX)objdump

CFLAGS  := -march=rv32im -mabi=ilp32 -nostdlib -nostartfiles -T link.ld

TARGET  := firmware
SRC     := /work/import_from_hw_sw_fuzzer/input_0_a.pp.S

.PHONY: all clean

all: $(TARGET).hex $(TARGET).dump

$(TARGET).elf: $(SRC) link.ld
	$(CC) $(CFLAGS) -o $@ $(SRC)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin
	python3 -c "\
import struct; \
data = open('$<','rb').read(); \
data += b'\x00' * ((4 - len(data) % 4) % 4); \
f = open('$@','w'); \
[f.write('%08x\n' % struct.unpack('<I', data[i:i+4])[0]) for i in range(0, len(data), 4)]; \
f.close()"

$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) --disassemble-all \
	--disassemble-zeroes \
	-M no-aliases,numeric $< > $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).dump
