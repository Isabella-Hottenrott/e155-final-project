// Wava Chan + Bella Hottentrot 
// Nov 2025
// Interfacing between VL53L0X sensor 7 STM32L432KC through I2C

#include "VL53L0X.h"

#define WRITE 0x52
#define READ 0x53

uint8_t g_stopVariable; // read by init and used when starting measurement; is StopVariable field of VL53L0X_DevData_t structure in API

void vl53l0x_write16(uint8_t reg, uint16_t val, uint8_t addr){
    uint8_t buf[4];
    buf[0] = (reg >> 8) & 0xFF;
    buf[1] = reg & 0xFF;
    buf[2] = (val >> 8) & 0xFF;
    buf[3] = val & 0xFF;
    i2c1_write(addr, buf, 4);
}
void vl53l0x_write8(uint8_t reg, uint8_t val, uint8_t addr){
    uint8_t buf[3];
    buf[0] = (reg >> 8) & 0xFF;   // high byte
    buf[1] = reg & 0xFF;          // low byte
    buf[2] = val;
    i2c1_write(addr, buf, 3);
}

uint16_t vl53l0x_read16(uint8_t reg, uint8_t addr){
    uint8_t regbuf[2] = { reg >> 8, reg & 0xFF };
    uint8_t data[2];
    i2c1_write(addr, regbuf, 2);
    i2c1_read(addr, data, 2);
    return (data[0] << 8) | data[1];
}
uint8_t vl53l0x_read8(uint8_t reg, uint8_t addr){
    uint8_t regbuf[2] = { reg >> 8, reg & 0xFF };
    uint8_t value;
    i2c1_write(addr, regbuf, 2);   // set register pointer
    i2c1_read(addr, &value, 1);
    return value;
}

void vl53l0x_init(void){
    //START DATAINIT() from api
    //should we switch the mode to 2V8? ie is it necessary to do so?
    if (0) {
        vl53l0x_write8(0x89, //magic numbers from API
            vl53l0x_read8(0x89) | 0x01); // set bit 0
    }
    //set I2C standard mode
    vl53l0x_write8(0x88, 0x00); //write 0 to register 0x88
    vl53l0x_write8(0x80, 0x01); //write 1 to register 0x80
    vl53l0x_write8(0xFF, 0x01); 
    vl53l0x_write8(0x00, 0x00);

    g_stopVariable = vl53l0x_read8(0x91);
    //g_stopVariable = (g_stopVariable & 0xFE) | 0x01; // set bit 0

    vl53l0x_write8(0x00, 0x01);
    vl53l0x_write8(0xFF, 0x00);
    vl53l0x_write8(0x80, 0x00);

    uint8_t addr = 0x29; // Default I2C address for VL53L0X
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
    //0x008a

    //vl53l0x_write8(deviceHandle, 0x008a, newAddre/2);
    //TODO:  trying to emulate code SetDeviceAddress from API. perhaps not correct...
}

uint16_t vl53l0x_read_distance_mm(void) {

    uint8_t addr = READ; //TODO: change this

    // Start one measurement
    vl53l0x_write8(0x0100, 0x01, addr);

    // Poll for measurement ready
    while ((vl53l0x_read8(0x013E, addr) & 0x01) == 0) {
        ; // wait
    }

    // Read range result
    return vl53l0x_read16(0x014E, addr);
}