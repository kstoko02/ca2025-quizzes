#include <stdint.h>
#include <stdio.h>

int clz(uint32_t x){
  if(!x) return 32;
  int n = 0;
  if(!(x & 0xFFFF0000)) {n += 16; x <<= 16;}
  if(!(x & 0xFF000000)) {n += 8; x <<= 8;}
  if(!(x & 0xF0000000)) {n += 4; x <<= 4;}
  if(!(x & 0xC0000000)) {n += 2; x <<= 2;}
  if(!(x & 0x80000000)) {n += 1;}
  return n;
}
