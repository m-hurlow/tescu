#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/i2c.h"
#include "hardware/timer.h"

// SPI Defines
// We are going to use SPI 0, and allocate it to the following GPIO pins
// Pins can be changed, see the GPIO function select table in the datasheet for information on GPIO assignments
#define SPI_PORT spi0
#define PIN_MISO 0
#define PIN_CS   5
#define PIN_SCK  2 
#define PIN_MOSI 3
#define PIN_DISP_DC 4
#define PIN_RST 28

// I2C defines
// This example will use I2C0 on GPIO8 (SDA) and GPIO9 (SCL) running at 400KHz.
// Pins can be changed, see the GPIO function select table in the datasheet for information on GPIO assignments
#define I2C_PORT i2c0
#define I2C_SDA 8
#define I2C_SCL 9

int64_t alarm_callback(alarm_id_t id, void *user_data) {
    // Put your timeout handler code in here
    return 0;
}

extern int32_t add(int32_t a, int32_t b);
extern void mainLoop();

void disp_send_command(uint8_t command) {
    gpio_put(PIN_DISP_DC, 0);
    spi_write_blocking(SPI_PORT, &command, 1);
}

void disp_send_byte(uint8_t byte) {
    gpio_put(PIN_DISP_DC, 1);
    spi_write_blocking(SPI_PORT, &byte, 1);
}

void disp_draw_pixel(int x, int y) {

}

int main()
{
    stdio_init_all();
    // SPI initialisation. This example will use SPI at 1MHz.
    uint baud = spi_init(SPI_PORT, 1000*1000);
    printf("SPI baud: %d\n", baud);
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    spi_set_format(SPI_PORT, 8, 0, 0, SPI_MSB_FIRST);
    
    // Chip select is active-low, so we'll initialise it to a driven-high state
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1);
    gpio_set_dir(PIN_DISP_DC, GPIO_OUT);
    // For more examples of SPI use see https://github.com/raspberrypi/pico-examples/tree/master/spi
    //Initialize the display chip
    gpio_set_dir(PIN_RST, GPIO_OUT);
    gpio_put(PIN_RST, 0);
    sleep_ms(200);
    gpio_put(PIN_RST, 1);
    sleep_ms(200);
    gpio_put(PIN_CS, 0);
    disp_send_command(0x01);
    sleep_ms(200);
    disp_send_command(0x3a);
    disp_send_byte(0x55);

    sleep_ms(10);
    disp_send_command(0x2a);
    disp_send_byte(0);
    disp_send_byte(0);
    disp_send_byte(0);
    disp_send_byte(0xff);
    sleep_ms(10);
    disp_send_command(0x2b);
    disp_send_byte(0);
    disp_send_byte(0);
    disp_send_byte(0);
    disp_send_byte(0xff);

    sleep_ms(10);
    disp_send_command(0x2c);
    for (int i = 0; i < 0xff*0xff; i++) {
        disp_send_byte(0);
        disp_send_byte(0);
    }

    // I2C Initialisation. Using it at 400Khz.
    i2c_init(I2C_PORT, 400*1000);
    
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);
    // For more examples of I2C use see https://github.com/raspberrypi/pico-examples/tree/master/i2c

    // Timer example code - This example fires off the callback after 2000ms
    add_alarm_in_ms(2000, alarm_callback, NULL, false);
    // For more examples of timer use see https://github.com/raspberrypi/pico-examples/tree/master/timer
   
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    mainLoop();
}
