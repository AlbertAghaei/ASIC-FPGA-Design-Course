
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpiops.h"
#include "sleep.h"


#define LED_DELAY		1000000

volatile int Delay;
int user_input;

XGpioPs Gpio;	/* The driver instance for GPIO Device. */
XGpioPs_Config *ConfigPtr;


int main()
{
    init_platform();

    print("Hello World\n\r");

	ConfigPtr = XGpioPs_LookupConfig(0);
	XGpioPs_CfgInitialize(&Gpio, ConfigPtr,ConfigPtr->BaseAddr);


	XGpioPs_SetDirectionPin(&Gpio, 54, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, 54, 1);


	while(1)
	{

		XGpioPs_WritePin(&Gpio, 54, 0x1);
		usleep(500000);
		XGpioPs_WritePin(&Gpio, 54, 0x0);
		usleep(500000);
	}

    cleanup_platform();
    return 0;
}
