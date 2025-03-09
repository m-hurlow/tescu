#include <stdio.h>
#include "hal.h"
#include "pico/stdlib.h"

void sleep(uint64_t time) {
    sleep_us(time);
}

void set_led(bool state) {
    gpio_put(PICO_DEFAULT_LED_PIN, state);
}

void print(const char* msg) {
    printf(msg);
}

void print_u64(uint64_t val) {
    printf("%lld", val);
}

uint64_t get_time() {
    return time_us_64();
}
