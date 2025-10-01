#include <stdio.h>
#include <stdint.h>
#include "pl_ps_bram_interconnect.h"
#include "xbram.h"
#include "xscugic.h"
#include "xparameters.h"
#include <math.h>
#include "sleep.h"
#include "xgpio.h"
#include "xil_exception.h"


#define PI 3.14159265


// Base address for BRAM controller
#define BRAM_CTRL_BASE      XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
// High address for BRAM controller
#define BRAM_CTRL_HIGH      XPAR_AXI_BRAM_CTRL_0_S_AXI_HIGHADDR
// Base address for PL-PS BRAM interconnect
#define PL_RAM_BASE         XPAR_PL_PS_BRAM_INTERCONN_0_S00_AXI_BASEADDR

// Register offsets for PL-PS BRAM interconnect
#define PL_RAM_REG0      PL_PS_BRAM_INTERCONNECT_S00_AXI_SLV_REG0_OFFSET
#define PL_RAM_REG1      PL_PS_BRAM_INTERCONNECT_S00_AXI_SLV_REG1_OFFSET
#define PL_RAM_REG2      PL_PS_BRAM_INTERCONNECT_S00_AXI_SLV_REG2_OFFSET
#define PL_RAM_REG3      PL_PS_BRAM_INTERCONNECT_S00_AXI_SLV_REG3_OFFSET
#define PL_RAM_REG4      PL_PS_BRAM_INTERCONNECT_S00_AXI_SLV_REG4_OFFSET

// Number of bytes per BRAM word (4 bytes = 32 bits)
#define BRAM_BYTENUM        4

/**
 * @brief Performs BRAM read/write operations with signal processing
 *
 * This function generates a sine wave, converts it to fixed-point format,
 * writes it to BRAM, and configures the PL-PS interconnect for processing.
 *
 * @return int XST_SUCCESS if successful, XST_FAILURE otherwise
 */

// Device ID Definitions
#define GPIO_DEVICE_ID      XPAR_GPIO_0_DEVICE_ID
#define GPIO_CHANNEL1       1
#define GPIO_CHANNEL2       2
#define INTC_GPIO_INTERRUPT_ID XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR
#define INTC_DEVICE_ID      XPAR_SCUGIC_SINGLE_DEVICE_ID

// Interrupt Controller Typedefs
#define INTC               XScuGic
#define INTC_HANDLER       XScuGic_InterruptHandler

// Global Variables
static volatile int Gpio1_flag = 0;  // Flag for GPIO Channel 1 interrupt
static volatile int Gpio2_flag = 0;  // Flag for GPIO Channel 2 interrupt
static u16 GlobalIntrMask1;          // Interrupt mask for GPIO Channel 1
static u16 GlobalIntrMask2;          // Interrupt mask for GPIO Channel 2

/******************************************************************************
* Function: GpioSetupIntrSystem
*
* Description: Configures the GPIO interrupt system including:
*              - Initializing the interrupt controller
*              - Setting up interrupt priorities and trigger types
*              - Connecting the interrupt handler
*              - Enabling interrupts
*
* Parameters:
*   IntcInstancePtr - Pointer to interrupt controller instance
*   InstancePtr     - Pointer to GPIO instance
*   DeviceId        - GPIO device ID
*   IntrId          - Interrupt ID
*   IntrMask1       - Interrupt mask for Channel 1
*   IntrMask2       - Interrupt mask for Channel 2
*
* Return: XST_SUCCESS if successful, XST_FAILURE otherwise
******************************************************************************/
XGpio PLGpio  ;
XScuGic INTCInst;

#define GPIO_INTR_ID   XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR

void GpioHandler(void *CallbackRef);

int status;
u32 Start_Addr , Dest_Addr , Len ,freq_mult ;

int GpioSetupIntrSystem(INTC *IntcInstancePtr, XGpio *InstancePtr,
                       u16 DeviceId, u16 IntrId, u16 IntrMask1, u16 IntrMask2)
{


    int Result;
    XScuGic_Config *IntcConfig;

    // Store the interrupt masks globally for use in the handler
    GlobalIntrMask1 = IntrMask1;
    GlobalIntrMask2 = IntrMask2;

    // Initialize the interrupt controller
    IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
    if (NULL == IntcConfig) {

        return XST_FAILURE;
    }

    Result = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
                                  IntcConfig->CpuBaseAddress);

    if (Result != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Configure interrupt priority and trigger type (rising edge)
    XScuGic_SetPriorityTriggerType(IntcInstancePtr, IntrId, 0xA0, 0x1);
    /* Trigger type options:
     * 0x1 : Rising Edge Interrupt
     * 0x2 : Falling Edge Interrupt
     * 0x3 : High Level Interrupt
     * 0x4 : Low Level Interrupt
     */

    // Connect the interrupt handler
    Result = XScuGic_Connect(IntcInstancePtr, IntrId,
                            (Xil_ExceptionHandler)GpioHandler, InstancePtr);

    if (Result != XST_SUCCESS) {
        return Result;
    }


    // Enable the interrupt
    XScuGic_Enable(IntcInstancePtr, IntrId);

    // Enable GPIO channel interrupts
    XGpio_InterruptEnable(InstancePtr, IntrMask1);
    XGpio_InterruptEnable(InstancePtr, IntrMask2);
    XGpio_InterruptGlobalEnable(InstancePtr);

    // Initialize exception handling
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)INTC_HANDLER,
                               IntcInstancePtr);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

/******************************************************************************
* Function: GpioHandler
*
* Description: Handles GPIO interrupts by:
*              - Reading the interrupt status
*              - Determining which channel triggered the interrupt
*              - Setting the appropriate flag
*              - Clearing the interrupt
*
* Parameters:
*   CallbackRef - Pointer to the GPIO instance that triggered the interrupt
*
* Return: None
******************************************************************************/
int flag = 0;
void GpioHandler(void *CallbackRef)
{


    XGpio *GpioPtr = (XGpio *)CallbackRef;
    u32 IntrStatus;

    // Read the interrupt status register
    IntrStatus = XGpio_InterruptGetStatus(GpioPtr);

    // Check and handle Channel 1 interrupt
    if (IntrStatus & GlobalIntrMask1) {
        Gpio1_flag = 1;  // Set flag for Channel 1
        XGpio_InterruptClear(GpioPtr, GlobalIntrMask1);  // Clear interrupt
    }

    // Check and handle Channel 2 interrupt
    if (IntrStatus & GlobalIntrMask2) {
        Gpio2_flag = 1;  // Set flag for Channel 2
        XGpio_InterruptClear(GpioPtr, GlobalIntrMask2);  // Clear interrupt
    }

    if(flag == 1){

    for (int i = 0; i < (512 ) ; i++)
   {
    //printf("hi_narges!\n\r");
    int16_t val = (int16_t)((XBram_ReadReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Dest_Addr + i))) & 0x0000FFFF);
    float real_val = ((float)val / (16384.0));
    printf("%f\n\r", real_val);
    //usleep(10000);    //?
   }
    }

}



int generate_and_process_wave(u32 Start_Addr, u32 Dest_Addr, u32 Len, u32 freq_mult, float amplitude, int frac_bits)
{

    // Check if addresses exceed BRAM capacity
    if (((Start_Addr + Len) > (BRAM_CTRL_HIGH - BRAM_CTRL_BASE + 1)/4) ||
        ((Dest_Addr + Len) > (BRAM_CTRL_HIGH - BRAM_CTRL_BASE + 1)/4))
    {
        xil_printf("******************************************\n\r");
        xil_printf("Error! Exceed Bram Control Address Range!\n\r");
        return XST_FAILURE;
    }

    // generate and write sin value
     for (int i = 0; i < Len; i++)
    {
        float angle = (2 * PI) * ((float)i / (float)Len);
        float sine_val = sin(angle);
        uint16_t fixed_val = (uint16_t)((int16_t)(sine_val * 16384));  //16 bit unsigned

        u32 u_32fixed_val = fixed_val;
        XBram_WriteReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Start_Addr + i), u_32fixed_val);

    }

    // Configure PL-PS BRAM interconnect registers
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG1, freq_mult);  // Slave Register 4 = Freq Mult
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG2, Len);              // Data length (Slave Register 3)
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG3, BRAM_BYTENUM*Start_Addr);  // Source address (Slave Register 2)
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG4, BRAM_BYTENUM*Dest_Addr);   // Destination address (Slave Register 1)

    // Trigger processing
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG0, 1);  // Start signal (Slave Register 0)
    asm("nop");  // Small delay
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG0, 0);  // Clear start signal (Slave Register 0)

    return XST_SUCCESS;
}

int main()
   {
  init_platform();

  //printf("hi!\n\r");
  //xil_printf("wait...");



  int status;
  u32 Start_Addr , Dest_Addr , Len , freq_mult;

  Gpio1_flag = 1;

  status = XGpio_Initialize(&PLGpio , GPIO_DEVICE_ID);
  if (status != XST_SUCCESS)
       return XST_FAILURE;

  status = GpioSetupIntrSystem(&INTCInst , &PLGpio , GPIO_DEVICE_ID , GPIO_INTR_ID , 1 , 1 );   // (INTC *IntcInstancePtr, XGpio *InstancePtr, u16 DeviceId, u16 IntrId, u16 IntrMask1, u16 IntrMask2)
  if (status != XST_SUCCESS)
       return XST_FAILURE;

  Start_Addr = 0;
  Dest_Addr = 1024;
  Len = 512;
  freq_mult = 2;



  //for (volatile int d = 0; d < 1000000; d++)
     //  asm("nop");

  while (1) {
  flag = 1;
  if(Gpio1_flag){
        Gpio1_flag = 0;
        status = generate_and_process_wave(Start_Addr,Dest_Addr,Len,freq_mult,1.0,14);
        if(status != XST_SUCCESS)
          {
            xil_printf("failed!\n\r");
             Gpio1_flag = 1;
         }

  }
  }


  cleanup_platform();
  return 0;
   }
