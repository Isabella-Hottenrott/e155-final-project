#ifndef VL53L0X_H
#define VL53L0X_H

#include <stdint.h>
#include <stdbool.h>

// VL53L0X Register addresses
#define VL53L0X_REG_IDENTIFICATION_MODEL_ID         0xC0
#define VL53L0X_REG_SYSTEM_INTERRUPT_CONFIG_GPIO    0x0A
#define VL53L0X_REG_SYSTEM_INTERRUPT_CLEAR          0x0B
#define VL53L0X_REG_SYSTEM_MODE_START               0x00
#define VL53L0X_REG_RESULT_INTERRUPT_STATUS         0x13
#define VL53L0X_REG_RESULT_RANGE_STATUS             0x14
#define VL53L0X_REG_RESULT_SPAD_NUM                 0x12
#define VL53L0X_REG_SYSRANGE_START                  0x00

// I2C Address
#define VL53L0X_DEFAULT_ADDRESS 0x52

// Function prototypes
bool VL53L0X_Init(void);
bool VL53L0X_StartMeasurement(void);
bool VL53L0X_WaitForMeasurement(uint32_t timeout);
bool VL53L0X_ReadMeasurement(uint16_t* distance);
uint16_t VL53L0X_ReadSingleMeasurement(void);

#endif