#include <stdio.h>
#include <stdint.h>
#include "pl_ps_bram_interconnect.h"
#include "xbram.h"
#include "xscugic.h"
#include "xparameters.h"


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
int bram_read_write(u32 Start_Addr, u32 Dest_Addr, u32 Len, u32 SlaveRegister4)
{

    const char *input_str = "ILOVEZYNQ";
int str_len = strlen(input_str);      // length
  //  u32 Write_Data;                 // Some 32-bit data to write
    int i;                          // Loop counter

    // Check if addresses exceed BRAM capacity
    if (((Start_Addr + Len) > (BRAM_CTRL_HIGH - BRAM_CTRL_BASE + 1)/4) ||
        ((Dest_Addr + Len) > (BRAM_CTRL_HIGH - BRAM_CTRL_BASE + 1)/4))
    {
        xil_printf("******************************************\n\r");
        xil_printf("Error! Exceed Bram Control Address Range!\n\r");
        return XST_FAILURE;
    }

    // Write random data to BRAM

    for(i = 0; i < str_len; i++)
        {
       u32 word;
       word =  input_str[i] + 3;
            XBram_WriteReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Start_Addr + i),word);
        }




    // Configure PL-PS BRAM interconnect registers
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG1, SlaveRegister4);  // Slave Register 4
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG2, Len);              // Data length (Slave Register 3)
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG3, BRAM_BYTENUM*Start_Addr);  // Source address (Slave Register 2)
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG4, BRAM_BYTENUM*Dest_Addr);   // Destination address (Slave Register 1)

    // Trigger processing
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG0, 1);  // Start signal (Slave Register 0)
    asm("nop");  // Small delay
    PL_PS_BRAM_INTERCONNECT_mWriteReg(PL_RAM_BASE, PL_RAM_REG0, 0);  // Clear start signal (Slave Register 0)

  

    printf("Original string written by PS: ");
    for(i = 0; i < str_len; i++)
    {
        printf("%c", input_str[i]);
    }
    printf("\n");

    // Print what PL wrote back
    printf("Decrypted string read from BRAM by PL: ");
    for(i = 0; i < str_len; i++)
    {
        char c = XBram_ReadReg(XPAR_BRAM_0_BASEADDR, BRAM_BYTENUM * (Dest_Addr + i));
        printf("%c", c);
    }
    printf("\n");


    return XST_SUCCESS;
}


   int main()
   {
  init_platform();

  int status;
  int Start_Addr , Dest_Addr , Len ;


  status = bram_read_write(0,64,9,1);
  if(status != XST_SUCCESS)
  {
  xil_printf("failed!\n\r");
  }


  cleanup_platform();
  return 0;
   }
