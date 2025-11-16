// Wava Chan + Bella Hottentrot 
// Nov 2025
// Interfacing between VL53L0X sensor 7 STM32L432KC through I2C

#include "VL53L0X.h"

// WRITE is to 0x52
// READ is to 0x53

void vl53l0x_write16(uint16_t reg, uint16_t val, uint8_t addr){
    uint8_t buf[4];
    buf[0] = (reg >> 8) & 0xFF;
    buf[1] = reg & 0xFF;
    buf[2] = (val >> 8) & 0xFF;
    buf[3] = val & 0xFF;
    i2c1_write(addr, buf, 4);
}
void vl53l0x_write8(uint16_t reg, uint8_t val, uint8_t addr){
    uint8_t buf[3];
    buf[0] = (reg >> 8) & 0xFF;   // high byte
    buf[1] = reg & 0xFF;          // low byte
    buf[2] = val;
    i2c1_write(addr, buf, 3);
}

uint16_t vl53l0x_read16(uint16_t reg, uint8_t addr){
    uint8_t regbuf[2] = { reg >> 8, reg & 0xFF };
    uint8_t data[2];
    i2c1_write(addr, regbuf, 2);
    i2c1_read(addr, data, 2);
    return (data[0] << 8) | data[1];
}
uint8_t vl53l0x_read8(uint16_t reg, uint8_t addr){
    uint8_t regbuf[2] = { reg >> 8, reg & 0xFF };
    uint8_t value;
    i2c1_write(addr, regbuf, 2);   // set register pointer
    i2c1_read(addr, &value, 1);
    return value;
}

void vl53l0x_init(void){
    uint8_t addr = 0x29; //TODO: change this
    // optional: check model ID
    uint8_t id = vl53l0x_read8(0x0000, addr);
    if (id != 0xEE) {
        // sensor not responding
    }

    // clear fresh-out-of-reset
    uint8_t reset = vl53l0x_read8(0x000C, addr);
    if (reset) {
        vl53l0x_write8(0x000C, 0x00, addr);
    }
}

void vl53l0x_setaddress(uint16_t newAddr){
    
}

uint16_t vl53l0x_read_distance_mm(void) {

    uint8_t addr = 0x29; //TODO: change this

    // Start one measurement
    vl53l0x_write8(0x0100, 0x01, addr);

    // Poll for measurement ready
    while ((vl53l0x_read8(0x013E, addr) & 0x01) == 0) {
        ; // wait
    }

    // Read range result
    return vl53l0x_read16(0x014E, addr);
}
