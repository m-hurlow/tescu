#ifndef HAL_H
#define HAL_H

#include <stdint.h>
#include <stdbool.h>

struct TcData {
    uint16_t tc_temp;
    bool fault;
    uint16_t int_temp;
    bool scv_fault;
    bool scg_fault;
    bool oc_fault;
};

void init();
void sleep(uint64_t time);
void set_led(bool state);
void print(const char* msg);
void print_u64(uint64_t val);
void print_f32(float val);
uint64_t get_time();

struct TcData read_thermocouple(uint8_t thermocouple);

int32_t get_char();

void set_fan_speed(uint16_t speed);

#endif
