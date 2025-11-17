// STM32L432KC_GPIO.h
// Isabella Hottenrott
// ihottenrott@g.hmc.edu
// 30/10/25

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdint.h> // Include stdint header
#include <stm32l432xx.h> 
///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

// Initialize I2C1 peripheral
void init_i2c1(void);

// Write nbytes from data to I2C device with given 7-bit address
void i2c1_write(uint8_t addr, uint8_t *data, uint8_t nbytes);

// Read nbytes from I2C device with given 7-bit address into data
void i2c1_read(uint8_t addr, uint8_t *data, uint8_t nbytes);

// Acknowledge and Not Acknowledge functions
unsigned char i2c1_ack(void);
unsigned char i2c1_nack(void);

#endif