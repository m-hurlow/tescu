#include "hal.h"
#include "pico/stdlib.h"

void sleep(uint32_t time) {
    sleep_ms(time);
}

void set_led(bool state) {
    gpio_put(PICO_DEFAULT_LED_PIN, state);
}
