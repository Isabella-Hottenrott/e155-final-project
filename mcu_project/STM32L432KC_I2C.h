// STM32L432KC_GPIO.h
// Isabella Hottenrott
// ihottenrott@g.hmc.edu
// 30/10/25

#ifndef STM32L4_I2C_H
#define STM32L4_I2c_H

#include <stdint.h> // Include stdint header
#include <stm32l432xx.h> 
///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void init_i2c1();

//uint8_t i2c1_read(uint8_t slaveaddr, uint8_t wordAddr);
void i2c1_write(uint8_t addr, uint8_t *data, uint8_t nbytes);
void i2c1_read(uint8_t addr, uint8_t *data, uint8_t nbytes);
#endif