#include <stdio.h>
#include "hal.h"
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/pwm.h"

#include "pins.h"

#define todo(msg) print(msg); while (true) {};

#define ESC_MAX_PWM 6547 //2 ms pulses
#define ESC_MIN_PWM 3273 //1 ms pulses

void init() {
    gpio_set_function(PIN_FAN_CTRL, GPIO_FUNC_PWM);
    uint slice_num = pwm_gpio_to_slice_num(PIN_FAN_CTRL);
    uint channel = pwm_gpio_to_channel(PIN_FAN_CTRL);
    //Set the frequency divider to 38.1875, yielding a frequency of 3.273 MHz
    pwm_set_clkdiv_int_frac(slice_num, 38, 3); 
    //This results in a required wrap value of 65466 for a 50 Hz PWM signal
    pwm_set_wrap(slice_num, 65466);
    //Arm the ESC by reducing the level gradually from max
    pwm_set_chan_level(slice_num, channel, ESC_MAX_PWM);
    pwm_set_enabled(slice_num, true);
    printf("\nArming ESC... ");
    for (int i = ESC_MAX_PWM; i > ESC_MIN_PWM; --i) {
        pwm_set_chan_level(slice_num, channel, i);
        sleep_us(500);
    }
    printf("Done\n");

    //Set up the mux select GPIOs
    for (int i = 0; i < 6; i++) {
        gpio_init(MUX_SELS[i]);
        gpio_set_dir(MUX_SELS[i], GPIO_OUT);
    }
}
 
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

void print_f32(float val) {
    printf("%.6f", val);
}

uint64_t get_time() {
    return time_us_64();
}

struct TcData read_thermocouple(uint8_t thermocouple) {
    //Set the multiplexer select inputs
    thermocouple &= 0x3f;
    for (int i = 0; i < 6; i++) {
        bool bit = ((thermocouple >> i) & 1) == 1;
        gpio_put(MUX_SELS[i], bit);
    }

    // Set CS low and wait for a small period
    gpio_put(PIN_TC_CS, 0);
    sleep_ms(1);

    // Read 32 bits from the thermocouple amp
    uint8_t buffer[4];
    spi_read_blocking(SPI_PORT, 0x00, buffer, 4);
    gpio_put(PIN_TC_CS, 1);
    uint32_t tc_bits = ((uint32_t)buffer[0] << 24) | ((uint32_t)buffer[1] << 16) | ((uint32_t)buffer[2] << 8) | (uint32_t)buffer[3];

    struct TcData data;
    data.oc_fault = (tc_bits & 1) == 1;
    data.scg_fault = ((tc_bits >> 1) & 1) == 1;
    data.scv_fault = ((tc_bits >> 2) & 1)  == 1;
    data.int_temp = (tc_bits >> 4) & 0xfff;
    data.fault = ((tc_bits >> 16) & 1) == 1;
    data.tc_temp = tc_bits >> 18;
    return data;
}

uint16_t get_char() {
    return stdio_getchar_timeout_us(0);
}

void set_fan_speed(uint16_t speed) {
    //TODO: PWM control of ESC
}