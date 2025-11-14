/*	minimalist library for using the I2C1 on the STM32F103C8T6 µC
 *  in polling mode and standard speed(100kHz) mode
 *
 *  written in 2018 by Marcel Meyer-Garcia
 *  see LICENCE.txt
 */
#include "i2c.h"
#include "init.h" // for SysTick_Time
#include "STM32L432KC_GPIO.h"

#define ToF_sclk      9 // SCLK = PA9
#define ToF_sda      10 // SDA = PA10


// check the error flag and set the corresponding error code,
// then clear the corresponding flag

/* initialize the I2C1 peripheral in fast mode with f_SCL=360kHz assuming an APB1/PCLK1 clock of 36MHz
   note: 400kHz can only be achieved when PCLK1 is a multiple of 10MHz */
void init_i2c1(){
	// enable alternate function and port B I/O peripheral clock
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;
	// enable the peripheral clock for the I2C1 module
	RCC->APB1ENR1 |= RCC_APB1ENR1_I2C1EN;

        pinMode(ToF_sclk, GPIO_ALT);                             // PA9 = SCLK want AF4
        GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL9, 4);     //AF4
        pinMode(ToF_sda, GPIO_ALT);                             // PA10 = SDA want AF4
        GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL10, 4);  

        //disable i2c
        I2C1->CR1 &= ~I2C_CR1_PE;
	// set the APB1 clock value so the I2C peripheral can derive the correct timings
	// APB1 clock is 36MHz since SysCoreClock==72E6 and RCC_CFGR_PPRE1_DIV2==1

	I2C1->TIMINGR = 0x00A08CCD;
        //but cuz of this change N = 8 R = 2 to get 

	//enable the I2C1 peripheral
	I2C1->CR1 |= I2C_CR1_PE;
}


/*	read N bytes from the I2C slave
	returns 0 if no error occured
	returns an error code > 0 if an error occured	*/
uint8_t i2c_read( uint8_t slave_address, uint8_t* data, uint8_t N ){
	I2C1->ICR = I2C_ICR_STOPCF;
        //maybe dont need above?? ^

	// send slave address
        I2C1->CR2 |= (N << I2C_CR2_NBYTES_Pos);
	I2C1->CR2 |= (slave_address <<1);
        I2C1->CR2 |= (1 << I2C_CR2_RD_WRN_Pos);

        I2C1->CR2 |= I2C_CR2_AUTOEND;
        I2C1->CR2 |= I2C_CR2_START;

	// wait until slave address has been sent
	while( !(I2C1->ISR & I2C_ISR_ADDR) ){}
        // if get stuck here, try while( !(I2C1->ISR & I2C_ISR_RXNE) ){}
        // or dont need anything here?

	while( N > 0 ){
        /* wait until RXNE (receive register not empty) */
        while( !(I2C1->ISR & I2C_ISR_RXNE) ){}

        /* read one byte */
        *data = (uint8_t)I2C1->RXDR;
        ++data;
        --N;
        }
        while( !(I2C1->ISR & I2C_ISR_STOPF) ){}
        I2C1->ICR |= I2C_ICR_STOPCF;
        return 0;
}





/*	write N bytes to the I2C slave
	returns 0 if no error occured
	returns an error code > 0 if an error occured	*/
uint8_t i2c_write( uint8_t slave_address, uint8_t* data, uint8_t N ){

	I2C1->CR2 |= (slave_address <<1);
        I2C1->CR2 &= ~(1 << I2C_CR2_RD_WRN_Pos);

        I2C1->CR2 |= I2C_CR2_START;

	while( N > 0 ){
        /* wait until RXNE (receive register not empty) */
        while( !(I2C1->ISR & I2C_ISR_RXNE) ){}

        /* read one byte */
        I2C1->TXDR = *data;
        ++data;
        --N;
        }
        while( !(I2C1->ISR & I2C_ISR_STOPF) ){}
        I2C1->ICR |= I2C_ICR_STOPCF;
        return 0;
}