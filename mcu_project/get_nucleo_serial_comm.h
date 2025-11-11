
#ifndef _GET_NUCLEO_SERIAL_COMM_H_
#define _GET_NUCLEO_SERIAL_COMM_H_

#ifdef _MSC_VER
#   ifdef VL53L1_API_EXPORTS
#       define VL53L1_API  __declspec(dllexport)
#   else
#       define VL53L1_API
#   endif
#else
#   define VL53L1_API
#endif

//#include <windows.h> //TODO: pretty sure we don't need this
#include <stdio.h>
//#include <tchar.h>
#include "SERIAL_COMMS.h"

#ifdef __cplusplus
extern "C"
{
#endif

#define MAX_KEY_LENGTH 255
#define MAX_VALUE_NAME 16383

DWORD GetNucleoSerialComm(TCHAR *pSerialCommStr); //TODO: replaced TCHAR w/ PCHAR. is this correct?

#ifdef __cplusplus
}
#endif

#endif
