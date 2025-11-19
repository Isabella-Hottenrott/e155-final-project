/*

#include "vl53l0x_api.h"
#include "vl53l0x_platform.h"
#include "required_version.h"
#include "get_nucleo_serial_comm.h"
#include <malloc.h>


void print_pal_error(VL53L0X_Error Status){
    char buf[VL53L0X_MAX_STRING_LENGTH];
    VL53L0X_GetPalErrorString(Status, buf);
    printf("API Status: %i : %s\n", Status, buf);
}

void print_range_status(VL53L0X_RangingMeasurementData_t* pRangingMeasurementData){
    char buf[VL53L0X_MAX_STRING_LENGTH];
    uint8_t RangeStatus;

    //
     / New Range Status: data is valid when pRangingMeasurementData->RangeStatus = 0
     //

    RangeStatus = pRangingMeasurementData->RangeStatus;

    VL53L0X_GetRangeStatusString(RangeStatus, buf);
    printf("Range Status: %i : %s\n", RangeStatus, buf);

}


VL53L0X_Error rangingTest(VL53L0X_Dev_t *pMyDevice)
{
    VL53L0X_Error Status = VL53L0X_ERROR_NONE;
    VL53L0X_RangingMeasurementData_t    RangingMeasurementData;
    int i;
    FixPoint1616_t LimitCheckCurrent;
    uint32_t refSpadCount;
    uint8_t isApertureSpads;
    uint8_t VhvSettings;
    uint8_t PhaseCal;

    if(Status == VL53L0X_ERROR_NONE)
    {
        printf ("Call of VL53L0X_StaticInit\n");
        Status = VL53L0X_StaticInit(pMyDevice); // Device Initialization
        print_pal_error(Status);
    }
    
    if(Status == VL53L0X_ERROR_NONE)
    {
        printf ("Call of VL53L0X_PerformRefCalibration\n");
        Status = VL53L0X_PerformRefCalibration(pMyDevice,
        		&VhvSettings, &PhaseCal); // Device Initialization
        print_pal_error(Status);
    }

    if(Status == VL53L0X_ERROR_NONE)
    {
        printf ("Call of VL53L0X_PerformRefSpadManagement\n");
        Status = VL53L0X_PerformRefSpadManagement(pMyDevice,
        		&refSpadCount, &isApertureSpads); // Device Initialization
        printf ("refSpadCount = %d, isApertureSpads = %d\n", refSpadCount, isApertureSpads);
        print_pal_error(Status);
    }

    if(Status == VL53L0X_ERROR_NONE)
    {

        // no need to do this when we use VL53L0X_PerformSingleRangingMeasurement
        printf ("Call of VL53L0X_SetDeviceMode\n");
        Status = VL53L0X_SetDeviceMode(pMyDevice, VL53L0X_DEVICEMODE_SINGLE_RANGING); // Setup in single ranging mode
        print_pal_error(Status);
    }

    // Enable/Disable Sigma and Signal check
    if (Status == VL53L0X_ERROR_NONE) {
        Status = VL53L0X_SetLimitCheckEnable(pMyDevice,
        		VL53L0X_CHECKENABLE_SIGMA_FINAL_RANGE, 1);
    }
    if (Status == VL53L0X_ERROR_NONE) {
        Status = VL53L0X_SetLimitCheckEnable(pMyDevice,
        		VL53L0X_CHECKENABLE_SIGNAL_RATE_FINAL_RANGE, 1);
    }

    if (Status == VL53L0X_ERROR_NONE) {
        Status = VL53L0X_SetLimitCheckEnable(pMyDevice,
        		VL53L0X_CHECKENABLE_RANGE_IGNORE_THRESHOLD, 1);
    }

    if (Status == VL53L0X_ERROR_NONE) {
        Status = VL53L0X_SetLimitCheckValue(pMyDevice,
        		VL53L0X_CHECKENABLE_RANGE_IGNORE_THRESHOLD,
        		(FixPoint1616_t)(1.5*0.023*65536));
    }


    //
     /  Step  4 : Test ranging mode
     //

    if(Status == VL53L0X_ERROR_NONE)
    {
        for(i=0;i<10;i++){
            printf ("Call of VL53L0X_PerformSingleRangingMeasurement\n");
            Status = VL53L0X_PerformSingleRangingMeasurement(pMyDevice,
            		&RangingMeasurementData);

            print_pal_error(Status);
            print_range_status(&RangingMeasurementData);

            VL53L0X_GetLimitCheckCurrent(pMyDevice,
            		VL53L0X_CHECKENABLE_RANGE_IGNORE_THRESHOLD, &LimitCheckCurrent);

            printf("RANGE IGNORE THRESHOLD: %f\n\n", (float)LimitCheckCurrent/65536.0);


            if (Status != VL53L0X_ERROR_NONE) break;

            printf("Measured distance: %i\n\n", RangingMeasurementData.RangeMilliMeter);


        }
    }
    return Status;
}

int main(int argc, char **argv)
{
    VL53L0X_Error Status = VL53L0X_ERROR_NONE;
    VL53L0X_Dev_t MyDevice;
    VL53L0X_Dev_t *pMyDevice = &MyDevice;
    VL53L0X_Version_t                   Version;
    VL53L0X_Version_t                  *pVersion   = &Version;
    VL53L0X_DeviceInfo_t                DeviceInfo;

    int32_t status_int;
    int32_t init_done = 0;
    int NecleoComStatus = 0;
    int NecleoAutoCom = 1;
    TCHAR SerialCommStr[MAX_VALUE_NAME];

    if (argc == 1 ) {
	   printf("Nucleo Automatic detection selected!\n");	
	   printf("To Specify a COM use: %s <yourCOM> \n", argv[0]);
    } else if (argc == 2 ) {
	   printf("Nucleo Manual COM selected!\n");
	   strcpy(SerialCommStr,argv[1]);	   
	   printf("You have specified %s \n", SerialCommStr);
	   NecleoAutoCom = 0;
    } else {
	   printf("ERROR: wrong parameters !\n");	
           printf("USAGE : %s <yourCOM> \n", argv[0]);
	   return(1);
    }

    
    
    printf ("VL53L0X API Simple Ranging example\n\n");
//    printf ("Press a Key to continue!\n\n");
//    getchar();

    if (NecleoAutoCom == 1) {
	    // Get the number of the COM attached to the Nucleo
	    // Note that the following function will look for the 
	    // Nucleo with name USBSER000 so be careful if you have 2 Nucleo 
	    // inserted

	    printf("Detect Nucleo Board ...");
	    NecleoComStatus = GetNucleoSerialComm(SerialCommStr);
	    
	    if ((NecleoComStatus == 0) || (strcmp(SerialCommStr, "") == 0)) {
		    printf("Error Nucleo Board not Detected!\n");
		    return(1);
	    }
	    
	    printf("Nucleo Board detected on %s\n\n", SerialCommStr);
    }
    
    // Initialize Comms
    pMyDevice->I2cDevAddr      = 0x52;
    pMyDevice->comms_type      =  1;
    pMyDevice->comms_speed_khz =  400;
    
    //Just inserted this for us.
    void init_i2c1();


   Status = VL53L0X_i2c_init(SerialCommStr, 460800);
    if (Status != VL53L0X_ERROR_NONE) {
        Status = VL53L0X_ERROR_CONTROL_INTERFACE;
        init_done = 1;
    } else
        printf ("Init Comms\n");

    //
     / Disable VL53L0X API logging if you want to run at full speed
     //
#ifdef VL53L0X_LOG_ENABLE
    VL53L0X_trace_config("test.log", TRACE_MODULE_ALL, TRACE_LEVEL_ALL, TRACE_FUNCTION_ALL);
#endif


    //
     /  Get the version of the VL53L0X API running in the firmware
     //

    if(Status == VL53L0X_ERROR_NONE)
    {
        status_int = VL53L0X_GetVersion(pVersion);
        if (status_int != 0)
            Status = VL53L0X_ERROR_CONTROL_INTERFACE;
    }

    //
     /  Verify the version of the VL53L0X API running in the firmware
     //

    if(Status == VL53L0X_ERROR_NONE)
    {
        if( pVersion->major != VERSION_REQUIRED_MAJOR ||
            pVersion->minor != VERSION_REQUIRED_MINOR ||
            pVersion->build != VERSION_REQUIRED_BUILD )
        {
            printf("VL53L0X API Version Error: Your firmware has %d.%d.%d (revision %d). This example requires %d.%d.%d.\n",
                pVersion->major, pVersion->minor, pVersion->build, pVersion->revision,
                VERSION_REQUIRED_MAJOR, VERSION_REQUIRED_MINOR, VERSION_REQUIRED_BUILD);
        }
    }


    if(Status == VL53L0X_ERROR_NONE)
    {
        printf ("Call of VL53L0X_DataInit\n");
        Status = VL53L0X_DataInit(&MyDevice); // Data initialization
        print_pal_error(Status);
    }

    if(Status == VL53L0X_ERROR_NONE)
    {
        Status = VL53L0X_GetDeviceInfo(&MyDevice, &DeviceInfo);
        if(Status == VL53L0X_ERROR_NONE)
        {
            printf("VL53L0X_GetDeviceInfo:\n");
            printf("Device Name : %s\n", DeviceInfo.Name);
            printf("Device Type : %s\n", DeviceInfo.Type);
            printf("Device ID : %s\n", DeviceInfo.ProductId);
            printf("ProductRevisionMajor : %d\n", DeviceInfo.ProductRevisionMajor);
        printf("ProductRevisionMinor : %d\n", DeviceInfo.ProductRevisionMinor);

        if ((DeviceInfo.ProductRevisionMinor != 1) && (DeviceInfo.ProductRevisionMinor != 1)) {
        	printf("Error expected cut 1.1 but found cut %d.%d\n",
                       DeviceInfo.ProductRevisionMajor, DeviceInfo.ProductRevisionMinor);
                Status = VL53L0X_ERROR_NOT_SUPPORTED;
            }
        }
        print_pal_error(Status);
    }

    if(Status == VL53L0X_ERROR_NONE)
    {
        Status = rangingTest(pMyDevice);
    }

    print_pal_error(Status);
    
    // Implementation specific

    //
     /  Disconnect comms - part of VL53L0X_platform.c
     //

    if(init_done == 0)
    {
        printf ("Close Comms\n");
        status_int = VL53L0X_comms_close();
        if (status_int != 0)
            Status = VL53L0X_ERROR_CONTROL_INTERFACE;
    }

    print_pal_error(Status);
    return (0);
}

*/

// Wava Chan + Bella Hottentrot
// Nov. 2025
// main.c function for reading measurements from VL53L0X sensor 

#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "VL53L0X.h"

#define Lidar1 PA11
#define Lidar2 PA12
#define Lidar3 PA3
#define Lidar4 PA2
#define Lidar5 PA1

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


    pinMode(Lidar1, GPIO_OUTPUT);
    pinMode(Lidar2, GPIO_OUTPUT);
    pinMode(Lidar3, GPIO_OUTPUT);
    pinMode(Lidar4, GPIO_OUTPUT);
    pinMode(Lidar5, GPIO_OUTPUT);

    digitalWrite(Lidar1, PIO_LOW);
    digitalWrite(Lidar2, PIO_LOW);
    digitalWrite(Lidar3, PIO_LOW);
    digitalWrite(Lidar4, PIO_LOW);
    digitalWrite(Lidar5, PIO_LOW);

 
    

    
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
    


    float dist1 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor1);
    float dist2 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor2);
    float dist3 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor3);
    float dist4 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor4);
    float dist5 = VL53L0X_readRangeSingleMillimeters(&myTOFsensor5);

 
    printf("dist1 = %f \n", dist1);
    printf("dist2 = %f \n", dist2);
    printf("dist3 = %f \n", dist3);
    printf("dist4 = %f \n", dist4);
    printf("dist5 = %f \n", dist5);
    printf("done!");

      while (1) {
      float dist2cont = VL53L0X_readRangeSingleMillimeters(&myTOFsensor2);
      printf("dist 2 cont = %f\n", dist2cont);
      float dist3cont = VL53L0X_readRangeSingleMillimeters(&myTOFsensor3);
      printf("dist 3 cont = %f\n", dist3cont);


    }

}