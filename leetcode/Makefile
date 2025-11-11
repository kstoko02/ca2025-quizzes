CC = riscv-none-elf-gcc
EMU = ../../../build/rv32emu

CFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32 -O0 -Wall

TARGET = leetcode.elf
OBJS = \
	maxproduct.o \
	highest_bit.o \
	global.o \
	leetcode.o


%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

all: $(TARGET)
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

clean:
	rm -f $(OBJS) $(TARGET)
run: $(TARGET)
	$(EMU) $(TARGET)
	

