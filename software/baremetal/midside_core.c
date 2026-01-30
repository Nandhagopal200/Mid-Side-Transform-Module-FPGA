#include "midside_core.h"

// ===========================================================
// DRIVER INITIALIZATION
// ===========================================================

/**
 * Initialize Mid-Side AXI-Lite driver instance
 *
 * @param InstancePtr  Pointer to driver instance
 * @param BaseAddress  AXI-Lite base address of the core
 *
 * @return XST_SUCCESS on success, XST_FAILURE otherwise
 */
int Midside_Init(MidsideConfig *InstancePtr, u32 BaseAddress)
{
    if (InstancePtr == NULL) {
        return XST_FAILURE;
    }

    InstancePtr->BaseAddress = BaseAddress;
    InstancePtr->IsReady     = XIL_COMPONENT_IS_READY;

    // Default to BYPASS mode reminding: safe power-up state
    Midside_SetMode(InstancePtr, MIDSIDE_MODE_BYPASS);

    return XST_SUCCESS;
}

// ===========================================================
// CONTROL REGISTER ACCESS
// ===========================================================

/**
 * Set Mid-Side operating mode
 *
 * Mode values:
 *  - MIDSIDE_MODE_BYPASS
 *  - MIDSIDE_MODE_ENCODER
 *  - MIDSIDE_MODE_DECODER
 */
void Midside_SetMode(MidsideConfig *InstancePtr, u32 Mode)
{
    if ((InstancePtr == NULL) ||
        (InstancePtr->IsReady != XIL_COMPONENT_IS_READY)) {
        return;
    }

    Xil_Out32(InstancePtr->BaseAddress + MIDSIDE_CTRL_REG_OFFSET, Mode);
}

/**
 * Get current Mid-Side operating mode
 *
 * @return Current mode register value
 */
u32 Midside_GetMode(MidsideConfig *InstancePtr)
{
    if ((InstancePtr == NULL) ||
        (InstancePtr->IsReady != XIL_COMPONENT_IS_READY)) {
        return 0;
    }

    return Xil_In32(InstancePtr->BaseAddress + MIDSIDE_CTRL_REG_OFFSET);
}

// ===========================================================
// RESET
// ===========================================================

/**
 * Reset Mid-Side core to BYPASS mode
 *
 * This is a logical reset only (control register),
 * not a hardware reset.
 */
void Midside_Reset(MidsideConfig *InstancePtr)
{
    Midside_SetMode(InstancePtr, MIDSIDE_MODE_BYPASS);
}
