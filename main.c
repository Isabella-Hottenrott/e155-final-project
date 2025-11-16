// Uncomment this line to use long range mode. This
// increases the sensitivity of the sensor and extends its
// potential range, but increases the likelihood of getting
// an inaccurate reading because of reflections from objects
// other than the intended target. It works best in dark
// conditions.

#define LONG_RANGE


// Uncomment ONE of these two lines to get
// - higher speed at the cost of lower accuracy OR
// - higher accuracy at the cost of lower speed

#define HIGH_SPEED
//#define HIGH_ACCURACY


#include <stm32l432xx.h>  // CMSIS device library include
#include "STM32L432KC.h"
#include "init.h"
#include "VL53L0X.h"
#include <stdio.h>
#include "i2c.h"

//uint32_t SystemCoreClock = 7200000;

char strbuf[25]; // for UART output via sprintf()
char testchar[500] = "testing VL53L0X\n--------------\n";
char successchar[30] = "init successful\n";
char errorchar[10] = "init error";
char step1char[10] = "step1\n";
char timeout[10] = "TIMEOUT\n";

struct VL53L0X myTOFsensor = {.io_2v8 = true, .address = 0b0101001, .io_timeout = 500, .did_timeout = false};

int main(void){
        configureFlash();
        configureClock();
	// Initialize system timer for 1ms ticks (else divide by 1e6 for µs ticks)
	SysTick_Config(SystemCoreClock / 1000);
	// init the USART1 peripheral to print to serial terminal
        USART_TypeDef * USART = initUSART(USART1_ID, 125000);



	// init the I2C1 peripheral and the SDA/SCL GPIO pins
	init_i2c1();

	sendString(USART, testchar);

	// GPIO pin PB5 connected to XSHUT pin of sensor
        gpioEnable(GPIO_PORT_B);
        // PB5 FOR VL53L0X
        pinMode(PB5, GPIO_OUTPUT);   //TIM1_CH1
	digitalWrite(PB5, PIO_LOW);
	delay(1000);
	digitalWrite(PB5, PIO_HIGH);
	delay(2000);
        
        uint8_t data[2] = {3,4};
        while(1){
        i2c_write(0x55, data, 2);
        }

        printf("%d addr \n",&myTOFsensor);
	//if( VL53L0X_init(&myTOFsensor) ){
        if( VL53L0X_init(&myTOFsensor) ){
		sendString(USART, successchar);
	}else{
		sendString(USART, errorchar);
		return 0;
	}

#ifdef LONG_RANGE
	// lower the return signal rate limit (default is 0.25 MCPS)
	VL53L0X_setSignalRateLimit(&myTOFsensor, 0.1);
	// increase laser pulse periods (defaults are 14 and 10 PCLKs)
	VL53L0X_setVcselPulsePeriod(&myTOFsensor, VcselPeriodPreRange, 18);
	VL53L0X_setVcselPulsePeriod(&myTOFsensor, VcselPeriodFinalRange, 14);
#endif
#ifdef HIGH_SPEED
	// reduce timing budget to 20 ms (default is about 33 ms)
	VL53L0X_setMeasurementTimingBudget(&myTOFsensor, 20000);
	sendString(USART, step1char);
#else //HIGH_ACCURACY
	// increase timing budget to 200 ms
	VL53L0X_setMeasurementTimingBudget(&myTOFsensor, 200000);
#endif

	VL53L0X_startContinuous(&myTOFsensor, 0);

	while(1){
		uint16_t value = VL53L0X_readRangeContinuousMillimeters(&myTOFsensor);
		sprintf(strbuf, "\t%d\tmm\n", value);
		sendString(USART, strbuf);
		 if ( VL53L0X_timeoutOccurred(&myTOFsensor) ) {
			 sendString(USART, timeout);
		 }
	}

return 1;
}
