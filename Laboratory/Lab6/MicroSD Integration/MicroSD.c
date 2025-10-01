#include <stdio.h>
#include <stdint.h>
#include "pl_ps_bram_interconnect.h"
#include "xbram.h"
#include "xscugic.h"
#include "xparameters.h"
#include <math.h>
#include "sleep.h"


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
static FATFS fatfs;
static FIL fil;
/**
 * @brief Performs BRAM read/write operations with signal processing
 *
 * This function generates a sine wave, converts it to fixed-point format,
 * writes it to BRAM, and configures the PL-PS interconnect for processing.
 *
 * @return int XST_SUCCESS if successful, XST_FAILURE otherwise
 */
int generate_and_process_wave(u32 Start_Addr, u32 Dest_Addr, u32 Len, u32 freq_mult, float amplitude, int frac_bits)
{

    FRESULT Res;
    UINT BytesRead;
    char line[32];

    // Mount SD card
    Res = f_mount(&fatfs, "0:/", 0);
    if (Res != FR_OK) {
        xil_printf("Failed to mount SD card.\n\r");
        return XST_FAILURE;
    }

    // Open the sine data file
    Res = f_open(&fil, "sin_values_512", FA_READ);
    if (Res != FR_OK) {
        xil_printf("Failed to open file: %s\n\r", filename);
        return XST_FAILURE;
    }

    for (int i = 0; i < Len; i++) {
        if (!f_gets(line, sizeof(line), &fil)) {
            xil_printf("Unexpected end of file at line %d.\n\r", i);
            break;
        }

        float fval = atof(line);
        int16_t fixed_val = (int16_t)(fval * 16384.0f);  // Q1.14 format
        u32 u_32fixed_val = (u16)fixed_val;

        XBram_WriteReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Start_Addr + i), u_32fixed_val);
    }

    f_close(&fil);

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

  printf("%d",(1 << 14));
  int status;
  u32 Start_Addr , Dest_Addr , Len ;


  Len = 512;
  u32 freq_mult = 2;
  status = generate_and_process_wave(0,1024,Len,freq_mult,1.0,14);
  if(status != XST_SUCCESS)
  {
  xil_printf("failed!\n\r");
  }


  for (volatile int d = 0; d < 1000000; d++)
       asm("nop");

  //while (1) {
   // delay



   // Read back and print the processed data
   // xil_printf("Processed Samples:\n\r");
   for (int i = 0; i < (Len ) ; i++)
   {
    int16_t val = (int16_t)((XBram_ReadReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Dest_Addr + i))) & 0x0000FFFF);
       //printf("val: %x\n\r",val);
    float s_16_val = ((float)val / (16384.0));
//        float real_val = s_16_val;
    printf("%f\n\r", s_16_val);
    usleep(10000);
   }





  cleanup_platform();
  return 0;
   }
