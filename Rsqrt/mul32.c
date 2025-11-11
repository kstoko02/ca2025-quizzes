#include <stdint.h>
#include <stdio.h>

uint64_t mul32(uint32_t a, uint32_t b){
  uint64_t r = 0;
  for(int i=0; i < 32; i++){
    if(b & (1U << i))
      r+=(uint64_t)a << i;
  }
  return r;
}
