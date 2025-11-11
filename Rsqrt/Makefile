CC = riscv-none-elf-gcc
EMU = ../../../../build/rv32emu

CFLAGS = -march=rv32i_zicsr_zifencei -mabi=ilp32 -Os -Wall

TARGET = rsqrt.elf
OBJS = \
	fast_rsqrt.o \
	clz.o \
	mul32.o \
	print_q16.o \
	getcycles.o \
	get_instret.o \
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
	

