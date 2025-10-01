#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "sleep.h"

#define GPIO0_CHANNEL1 0x1
#define GPIO0_CHANNEL2 0x2
#define GPIO1_CHANNEL1 0x1
#define GPIO1_CHANNEL2 0x2

int main()
{
    init_platform();
    print("Hello World\n\r");
    XGpio first, second;

    XGpio_Initialize(&first, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&second, XPAR_AXI_GPIO_1_DEVICE_ID);

    XGpio_SetDataDirection(&second,GPIO1_CHANNEL1,0);
    XGpio_SetDataDirection(&second,GPIO1_CHANNEL2,0);
    XGpio_SetDataDirection(&first,GPIO0_CHANNEL1,0);
    XGpio_SetDataDirection(&first,GPIO0_CHANNEL2,1);


    int errors = 0;

        for(int i = 0; i < 100; i = i + 1)
        {
            int a, b, op, result_ps;
            int result_pl;

            a = rand() & 0xffffffff;

            printf("%d\n",a);
            b = rand() & 0xffffffff;

            printf("%d\n",b);

        	op = rand() & 0x03;

            printf("%d\n",op);

        	XGpio_DiscreteWrite(&second, GPIO1_CHANNEL1, a);
        	XGpio_DiscreteWrite(&second, GPIO1_CHANNEL2, b);
        	XGpio_DiscreteWrite(&first, GPIO0_CHANNEL1, op);

        	printf("This is just before reading the result...\n");

        	result_pl = XGpio_DiscreteRead(&first, GPIO0_CHANNEL2);

            printf("%d\n",result_pl);

        	if (op == 0)
        		result_ps = a + b;
        	else if(op == 1)
        		result_ps = a - (~ b);
        	else if(op == 2)
        		result_ps = ~(a & b);
        	else
        		result_ps = ~(a | b);

        	if (result_ps != result_pl)
        	{
        		if (op == 0)
        			printf("Test number %d: %d + %d = %d(but pl calculate it %d)\n",i,a,b,result_ps,result_pl);
        		else if(op == 1)
        			printf("Test number %d: %d - %d = %d(but pl calculate it %d)\n",i,a,b,result_ps,result_pl);
        		else if(op == 2)
        			printf("Test number %d: %d NAND %d = %d(but pl calculate it %d)\n",i,a,b,result_ps,result_pl);
        		else
        			printf("Test number %d: %d NOR %d = %d(but pl calculate it %d)\n",i,a,b,result_ps,result_pl);

        		errors++;
        		usleep(2000000);
        	}
        }

        printf("among 5000000 tests, there have been %d errors.\n",errors);
        if (errors == 0)
        	printf("good job!");




    cleanup_platform();
    return 0;
}
