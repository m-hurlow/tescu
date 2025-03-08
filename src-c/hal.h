#ifndef HAL_H
#define HAL_H

#include <stdint.h>
#include <stdbool.h>

void sleep(uint32_t time);
void set_led(bool state);

#endif
