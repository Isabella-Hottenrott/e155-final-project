
#include "vl53l0x.h"
#include "C:\Users\wchan\Documents\GitHub\e155-final-project\STM32L432KC.h"  // Your I2C driver header
//#include "delay.h" // Your delay functions

// Private function prototypes
static bool VL53L0X_WriteByte(uint8_t reg, uint8_t data);
static bool VL53L0X_WriteWord(uint8_t reg, uint16_t data);
static bool VL53L0X_ReadByte(uint8_t reg, uint8_t* data);
static bool VL53L0X_ReadWord(uint8_t reg, uint16_t* data);

bool VL53L0X_Init(void) {
    uint8_t model_id;
   
    // Check device model ID
    if (!VL53L0X_ReadByte(VL53L0X_REG_IDENTIFICATION_MODEL_ID, &model_id)) {
        return false;
    }
   
    if (model_id != 0xEE) {
        return false; // Not a VL53L0X
    }
   
    // Configure GPIO interrupt (optional, but recommended)
    if (!VL53L0X_WriteByte(VL53L0X_REG_SYSTEM_INTERRUPT_CONFIG_GPIO, 0x04)) {
        return false;
    }
   
    // Clear interrupt
    if (!VL53L0X_WriteByte(VL53L0X_REG_SYSTEM_INTERRUPT_CLEAR, 0x01)) {
        return false;
    }
   
    return true;
}

bool VL53L0X_StartMeasurement(void) {
    // Start single measurement mode
    return VL53L0X_WriteByte(VL53L0X_REG_SYSRANGE_START, 0x01);
}

bool VL53L0X_WaitForMeasurement(uint32_t timeout) {
    uint8_t status;
    uint32_t start_time = HAL_GetTick(); // Use your timing function
   
    while ((HAL_GetTick() - start_time) < timeout) {
        if (!VL53L0X_ReadByte(VL53L0X_REG_RESULT_INTERRUPT_STATUS, &status)) {
            return false;
        }
       
        if (status & 0x07) { // Measurement ready
            return true;
        }
       
        Delay_ms(1); // Small delay between checks
    }
   
    return false; // Timeout
}

bool VL53L0X_ReadMeasurement(uint16_t* distance) {
    uint8_t range_status;
    uint16_t range_mm;
   
    // Read range status
    if (!VL53L0X_ReadByte(VL53L0X_REG_RESULT_RANGE_STATUS, &range_status)) {
        return false;
    }
   
    // Check if measurement is valid
    if ((range_status & 0x78) != 0x09) { // Check specific bits for valid measurement
        return false;
    }
   
    // Read distance (2 bytes)
    if (!VL53L0X_ReadWord(0x14, &range_mm)) { // Result register
        return false;
    }
   
    *distance = range_mm;
   
    // Clear interrupt
    if (!VL53L0X_WriteByte(VL53L0X_REG_SYSTEM_INTERRUPT_CLEAR, 0x01)) {
        return false;
    }
   
    return true;
}

uint16_t VL53L0X_ReadSingleMeasurement(void) {
    uint16_t distance = 0;
   
    if (VL53L0X_StartMeasurement() &&
        VL53L0X_WaitForMeasurement(100) &&
        VL53L0X_ReadMeasurement(&distance)) {
        return distance;
    }
   
    return 0xFFFF; // Error value
}

// Private I2C communication functions
static bool VL53L0X_WriteByte(uint8_t reg, uint8_t data) {
    uint8_t buffer[2] = {reg, data};
    return I2C_Write(VL53L0X_DEFAULT_ADDRESS, buffer, 2);
}

static bool VL53L0X_WriteWord(uint8_t reg, uint16_t data) {
    uint8_t buffer[3] = {reg, (uint8_t)(data >> 8), (uint8_t)(data & 0xFF)};
    return I2C_Write(VL53L0X_DEFAULT_ADDRESS, buffer, 3);
}

static bool VL53L0X_ReadByte(uint8_t reg, uint8_t* data) {
    if (!I2C_Write(VL53L0X_DEFAULT_ADDRESS, &reg, 1)) {
        return false;
    }
    return I2C_Read(VL53L0X_DEFAULT_ADDRESS, data, 1);
}

static bool VL53L0X_ReadWord(uint8_t reg, uint16_t* data) {
    uint8_t buffer[2];
   
    if (!I2C_Write(VL53L0X_DEFAULT_ADDRESS, &reg, 1)) {
        return false;
    }
   
    if (!I2C_Read(VL53L0X_DEFAULT_ADDRESS, buffer, 2)) {
        return false;
    }
   
    *data = (buffer[0] << 8) | buffer[1];
    return true;
}