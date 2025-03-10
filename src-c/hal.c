#include <stdio.h>
#include "hal.h"
#include "pico/stdlib.h"

#define todo(msg) print(msg); while (true) {};
 
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

float read_thermocouple(uint8_t thermocouple) {
    todo("Thermocouple read not implemented");
    return 0.0;
}
