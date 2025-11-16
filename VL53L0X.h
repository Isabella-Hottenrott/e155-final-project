// Wava Chan + Bella Hottentrot 
// Nov 2025
// Interfacing between VL53L0X sensor 7 STM32L432KC through I2C

#ifndef STM32L4_VL53L0X_H
#define STM32L4_VL53L0X_H

#include "STM32L432KC_I2C.h"

// DEFINE ANY MACROS?

void vl53l0x_write16(uint16_t reg, uint16_t val, uint8_t addr);
void vl53l0x_write8(uint16_t reg, uint8_t val, uint8_t addr);

uint16_t vl53l0x_read16(uint16_t reg, uint8_t addr);
uint8_t vl53l0x_read8(uint16_t reg, uint8_t addr);

void vl53l0x_init(void);
void vl53l0x_setaddress(uint16_t newAddr);
uint16_t vl53l0x_read_distance_mm(void);

#endif