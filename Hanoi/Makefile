CC = riscv-none-elf-gcc
EMU = ../../../../build/rv32emu

CFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32 -Os -Wall

TARGET = hanoi.elf
OBJS = \
	hanoi.o \
	hanoi_init.o \
	getcycles.o \
	get_instret.o \
	global.o \
	main.o

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
	

