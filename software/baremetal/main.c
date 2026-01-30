#include <stdio.h>
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_cache.h"      // Required for Xil_DCacheDisable()
#include "midside_core.h"   // Mid-Side AXI-Lite driver

// ===========================================================
// BASE ADDRESS CONFIGURATION
// ===========================================================
// Resolve base address from xparameters.h
#if defined(XPAR_MIDSIDE_AXIS_WRAPPER_0_BASEADDR)
    #define MIDSIDE_BASE_ADDR XPAR_MIDSIDE_AXIS_WRAPPER_0_BASEADDR
#elif defined(XPAR_MIDSIDE_AXIS_WRAPPER_0_S_AXI_BASEADDR)
    #define MIDSIDE_BASE_ADDR XPAR_MIDSIDE_AXIS_WRAPPER_0_S_AXI_BASEADDR
#else
    #warning "MIDSIDE base address not found, using manual fallback"
    #define MIDSIDE_BASE_ADDR 0xA0010000
#endif

// ===========================================================
// GLOBAL DRIVER INSTANCE
// ===========================================================
static MidsideConfig Midside;

// ===========================================================
// SIMPLE BUSY DELAY (hot-swap style)
// ===========================================================
static void delay_cycles(volatile int cycles)
{
    while (cycles--) {
        __asm__("nop");
    }
}

// ===========================================================
// MAIN
// ===========================================================
int main(void)
{
    int Status;
    u32 ModeReadback;

    // -------------------------------------------------------
    // 1. SYSTEM PREP
    // -------------------------------------------------------
    // AXI-Lite register access MUST run with cache disabled
    Xil_DCacheDisable();

    xil_printf("\033[2J\033[H"); // Clear terminal
    xil_printf("=== Mid-Side AXI Core Bare-Metal Test ===\n\r");
    xil_printf("D-Cache disabled for AXI-Lite safety.\n\r\n\r");

    // -------------------------------------------------------
    // 2. DRIVER INITIALIZATION
    // -------------------------------------------------------
    Status = Midside_Init(&Midside, MIDSIDE_BASE_ADDR);
    if (Status != XST_SUCCESS) {
        xil_printf("ERROR: Midside_Init failed!\n\r");
        return -1;
    }

    xil_printf("Core initialized at base address: 0x%08X\n\r\n\r",
               Midside.BaseAddress);

    // -------------------------------------------------------
    // TEST 1: ENCODER MODE
    // -------------------------------------------------------
    xil_printf("[TEST 1] Set ENCODER mode... ");
    Midside_SetMode(&Midside, MIDSIDE_MODE_ENCODER);

    ModeReadback = Midside_GetMode(&Midside);
    if (ModeReadback == MIDSIDE_MODE_ENCODER) {
        xil_printf("OK (mode=%d)\n\r", ModeReadback);
    } else {
        xil_printf("FAIL (read=%d, expected=%d)\n\r",
                   ModeReadback, MIDSIDE_MODE_ENCODER);
    }

    delay_cycles(5000000);

    // -------------------------------------------------------
    // TEST 2: DECODER MODE
    // -------------------------------------------------------
    xil_printf("[TEST 2] Set DECODER mode... ");
    Midside_SetMode(&Midside, MIDSIDE_MODE_DECODER);

    ModeReadback = Midside_GetMode(&Midside);
    if (ModeReadback == MIDSIDE_MODE_DECODER) {
        xil_printf("OK (mode=%d)\n\r", ModeReadback);
    } else {
        xil_printf("FAIL (read=%d, expected=%d)\n\r",
                   ModeReadback, MIDSIDE_MODE_DECODER);
    }

    delay_cycles(5000000);

    // -------------------------------------------------------
    // TEST 3: BYPASS / RESET
    // -------------------------------------------------------
    xil_printf("[TEST 3] Reset to BYPASS... ");
    Midside_Reset(&Midside);

    ModeReadback = Midside_GetMode(&Midside);
    if (ModeReadback == MIDSIDE_MODE_BYPASS) {
        xil_printf("OK (mode=%d)\n\r", ModeReadback);
    } else {
        xil_printf("FAIL (read=%d, expected=%d)\n\r",
                   ModeReadback, MIDSIDE_MODE_BYPASS);
    }

    // -------------------------------------------------------
    // DONE
    // -------------------------------------------------------
    xil_printf("\nBare-metal register test completed successfully.\n\r");
    xil_printf("No streaming test performed in this application.\n\r");

    return 0;
}
