#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "VL53L0X.h"
#include <stdlib.h>
#include <time.h>
#include <stdio.h>


#define Lidar1 PA11
#define Lidar2 PA12
#define Lidar3 PA3
#define Lidar4 PA2
#define Lidar5 PA1
#define CS     PB7

int main(){

    struct VL53L0X myTOFsensor1;
    myTOFsensor1.io_2v8 = false;
    myTOFsensor1.address = 0b0101001;
    myTOFsensor1.io_timeout = 500;
    myTOFsensor1.did_timeout = false;

    struct VL53L0X myTOFsensor2;
    myTOFsensor2.io_2v8 = false;
    myTOFsensor2.address = 0b0101001;
    myTOFsensor2.io_timeout = 500;
    myTOFsensor2.did_timeout = false;


    struct VL53L0X myTOFsensor3;
    myTOFsensor3.io_2v8 = false;
    myTOFsensor3.address = 0b0101001;
    myTOFsensor3.io_timeout = 500;
    myTOFsensor3.did_timeout = false;

    struct VL53L0X myTOFsensor4;
    myTOFsensor4.io_2v8 = false;
    myTOFsensor4.address = 0b0101001;
    myTOFsensor4.io_timeout = 500;
    myTOFsensor4.did_timeout = false;

    struct VL53L0X myTOFsensor5;
    myTOFsensor5.io_2v8 = false;
    myTOFsensor5.address = 0b0101001;
    myTOFsensor5.io_timeout = 500;
    myTOFsensor5.did_timeout = false;

    configurePLL();
    configureFlash();
    configureHSIasClk();
    gpioEnable(GPIO_PORT_A);
    gpioEnable(GPIO_PORT_B);
    pinMode(PB3, GPIO_OUTPUT);
    init_i2c1();
    RCC->APB2ENR |= (1<<16);
    initTIM(TIM15);
    initSPI(1, 0, 0);


    pinMode(Lidar1, GPIO_OUTPUT);
    pinMode(Lidar2, GPIO_OUTPUT);
    pinMode(Lidar3, GPIO_OUTPUT);
    pinMode(Lidar4, GPIO_OUTPUT);
    pinMode(Lidar5, GPIO_OUTPUT);
    pinMode(CS, GPIO_OUTPUT);

    digitalWrite(Lidar1, PIO_LOW);
    digitalWrite(Lidar2, PIO_LOW);
    digitalWrite(Lidar3, PIO_LOW);
    digitalWrite(Lidar4, PIO_LOW);
    digitalWrite(Lidar5, PIO_LOW);
    digitalWrite(CS, PIO_LOW);

    
    

    
    digitalWrite(Lidar1, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF1addr = %d\n", myTOFsensor1.address);
    VL53L0X_init(&myTOFsensor1);
    VL53L0X_setAddress(&myTOFsensor1, 0b0000001);
    myTOFsensor1.address = 0b0000001;
    printf("secondTOF1addr = %d\n", myTOFsensor1.address);
    
    digitalWrite(Lidar2, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF2addr = %d\n", myTOFsensor2.address);
    VL53L0X_init(&myTOFsensor2);
    VL53L0X_setAddress(&myTOFsensor2, 0b0000010);
    myTOFsensor2.address = 0b0000010;
    printf("secondTOF2addr = %d\n", myTOFsensor2.address);

    digitalWrite(Lidar3, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF3addr = %d\n", myTOFsensor3.address);
    VL53L0X_init(&myTOFsensor3);
    VL53L0X_setAddress(&myTOFsensor3, 0b0000011);
    myTOFsensor3.address = 0b0000011;
    printf("secondTOF3addr = %d\n", myTOFsensor3.address);

    digitalWrite(Lidar4, PIO_HIGH);
    delay_millis(TIM15, 1);
    VL53L0X_init(&myTOFsensor4);
    printf("initTOF4addr = %d\n", myTOFsensor4.address);
    VL53L0X_setAddress(&myTOFsensor4, 0b0000100);
    myTOFsensor4.address = 0b0000100;
    printf("secondTOF4addr = %d\n", myTOFsensor4.address);

    digitalWrite(Lidar5, PIO_HIGH);
    delay_millis(TIM15, 1);
    VL53L0X_init(&myTOFsensor5);
    printf("initTOF5addr = %d\n", myTOFsensor5.address);
    VL53L0X_setAddress(&myTOFsensor5, 0b0000101);
    myTOFsensor5.address = 0b0000101;
    printf("secondTOF5addr = %d\n", myTOFsensor5.address);
    
    delay_millis(TIM15, 100);

    float dist1 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor1);
    float dist2 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor2);
    float dist3 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor3);

    float dist4 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor4);
    printf("dist4 = %f \n", dist4);
  
    float dist5 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor5);

    
    printf("dist1 = %f \n", dist1);
    printf("dist2 = %f \n", dist2);
    printf("dist3 = %f \n", dist3);
  
    printf("dist5 = %f \n", dist5);
    printf("done!");

    float dist2cont, dist3cont;


    int count = 0;
    uint8_t RPS = 0;


      count = 0;
      delay_millis(TIM15, 2);
      dist2 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor1);
      delay_millis(TIM15, 2);
      dist3 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor3);
      delay_millis(TIM15, 2);
      dist4 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor5); 
      delay_millis(TIM15, 2);

      if(dist2 < 500){
        count++;
      }
      if(dist3 < 500){
        count++;
      }
      if(dist4 < 500){
        count++;
      }

      if(count == 0){
        RPS = 128;      // 8'b10000000
        printf("rock!\n");
      }
      if(count == 1){
        RPS = 32;      // 8'b00100000
        printf("scissors!\n");
      }
      if(count == 2){
        RPS = 32;      // 8'b00100000
        printf("scissors!\n");
      }
      if(count == 3){
        RPS = 64;      // 8'b01000000
        printf("paper!\n");
      }



      digitalWrite(CS, PIO_HIGH);
      spiSend(RPS);
      digitalWrite(CS, PIO_LOW);



      while(1);



}