#ifndef HAL_H
#define HAL_H

#include <stdint.h>
#include <stdbool.h>

void sleep(uint64_t time);
void set_led(bool state);
void print(const char* msg);
void print_u64(uint64_t val);
uint64_t get_time();

#endif
