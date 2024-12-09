#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xbram.h"
#include "xparameters.h"
#include "sleep.h"

XBram Bram;
#define NUMBER_OF_WORKERS 4
#define FRACTIONAL_BITS 22
#define WORKER_IDLE_STATE 0
#define WORKER_FINISHED_STATE 3
#define WORKER_ERROR_STATE 2

void dump_bram(XBram *Bram) {
    printf("BRAM Dump\n\r");
    for (int i = 0; i < 22; i++) {
        int32_t data = XBram_ReadReg(XPAR_BRAM_0_BASEADDR, i * 4);
        printf("BRAM[%d]: %X\n\r", i*4, data);
    }
}

int reset_worker(volatile uint32_t *workerReg, int worker_num) {
    printf("Resetting Worker %d\n\r", worker_num);
    // workerReg[0] = slv_reg0
    // slv_reg0(0) = reset
    // slv_reg0(1) = continue
    workerReg[0] = 0x1; // Assert Reset
    workerReg[0] = 0x0; // Deassert Reset
    int count = 0;
    int mask = workerReg[0] & 0x1100;
    while (mask != WORKER_IDLE_STATE) {
        printf("Waiting for Worker %d to Reset\n\r", worker_num);
        printf("Worker %d State: %X\n\r", worker_num, (unsigned char)workerReg[3]);
        sleep(0.1);
        count++;
        if (count > 10) {
            printf("Worker %d Failed to Reset\n\r", worker_num);
            dump_bram(&Bram);
            return 1;
        }
    }
    printf("Worker %d Reset\n\r", worker_num);
    return 0;
}

int worker_busy(int currentState) {
    if (currentState == WORKER_IDLE_STATE || currentState == WORKER_FINISHED_STATE) {
        return 0;
    }
    return 1;
}

int worker_done(int currentState) {
    if (currentState == WORKER_FINISHED_STATE) {
        return 0;
    }
    return 1;
}

int8_t get_worker_states() {
    volatile uint32_t *genWorker1Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_0_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker2Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_1_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker3Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_2_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker4Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_3_S00_AXI_BASEADDR;
    int8_t workerStates[4] = {genWorker1Reg[0], genWorker2Reg[0], genWorker3Reg[0], genWorker4Reg[0]};
    int8_t maxValue = 0;
    for (int i = 0; i < 4; i++) {
        int32_t masked = workerStates[i] & 1100;
        if (masked > maxValue) {
            maxValue = worker_busy(masked);
        }
        // if (workerStates[i] > maxValue) {
        //     maxValue = worker_busy(workerStates[i]);
        // }
    }
    xil_printf("Worker State: %d\n\r", maxValue);
    return maxValue;
}

int8_t are_workers_done() {
    volatile uint32_t *genWorker1Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_0_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker2Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_1_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker3Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_2_S00_AXI_BASEADDR;
    volatile uint32_t *genWorker4Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_3_S00_AXI_BASEADDR;
    int8_t workerStates[4] = {genWorker1Reg[0], genWorker2Reg[0], genWorker3Reg[0], genWorker4Reg[0]};
    int8_t maxValue = 0;
    for (int i = 0; i < 4; i++) {
        int32_t masked = workerStates[i] & 1100;
        if (masked > maxValue) {
            maxValue = worker_done(masked);
        }
        // if (workerStates[i] > maxValue) {
        //     maxValue = worker_busy(workerStates[i]);
        // }
    }
    xil_printf("Worker State: %d\n\r", maxValue);
    return maxValue;
}

int write_bram_data(int32_t baseAddress, int32_t data) {
    XBram_WriteReg(baseAddress, 0, data);
    int32_t readData = XBram_ReadReg(baseAddress, 0);
    if (readData != data) {
        printf("Failed to Write Data, Expected: %X, Got: %X\n\r", data, readData);
        return 1;
    }
    return 0;
}

// Fixed-point conversion math
int32_t double_to_fixed(double value) {
    int32_t result = (int32_t)(value * (1 << FRACTIONAL_BITS));
    printf("Double: %f, Fixed: %X\n\r", value, result);
    return result;
}

float fixed_to_float(int32_t value) {
    float result = (float)value / (1 << FRACTIONAL_BITS);
    printf("Fixed: %X, Float: %f\n\r", value, result);
    return result;
}

double fixed_to_double(int32_t value) {
    double result = (double)value / (1 << FRACTIONAL_BITS);
    printf("Fixed: %X, Double: %f\n\r", value, result);
    return result;
}

int init_bram() {
    printf("Initializing BRAM\n\r");
	XBram_Config *BRAMConfigPtr;
    BRAMConfigPtr = XBram_LookupConfig(XPAR_BRAM_0_DEVICE_ID);
    int Status = XBram_CfgInitialize(&Bram, BRAMConfigPtr, BRAMConfigPtr->CtrlBaseAddress);
    if (Status != XST_SUCCESS) {
        printf("BRAM Initialization Failed: %d\n", Status);
    	return XST_FAILURE;
    }
    printf("BRAM Initialized\n\r");
    return 0;
}

int32_t init_workers() {
    // Setup Hardware (arbiter, workers, etc)
    printf("Initializing Hardware\n\r");
    // Init Generation Workers
    volatile uint32_t *genWorker1Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_0_S00_AXI_BASEADDR;
    // int32_t genWorker1BaseAddress = (int32_t)XPAR_BRAM_0_BASEADDR + WORKER_BRAM_ADDRESS_OFFSET;
    volatile uint32_t *genWorker2Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_1_S00_AXI_BASEADDR;
    // int32_t genWorker2BaseAddress = (int32_t)genWorker1BaseAddress + WORKER_BRAM_SIZE;
    volatile uint32_t *genWorker3Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_2_S00_AXI_BASEADDR;
    // int32_t genWorker3BaseAddress = (int32_t)genWorker2BaseAddress + WORKER_BRAM_SIZE;
    volatile uint32_t *genWorker4Reg = (volatile uint32_t *) XPAR_GENERATION_WORKER_3_S00_AXI_BASEADDR;
    // int32_t genWorker4BaseAddress = (int32_t)genWorker3BaseAddress + WORKER_BRAM_SIZE;
    // printf("Worker 1 Base Address: %X\n\r", genWorker1BaseAddress);
    // printf("Worker 2 Base Address: %X\n\r", genWorker2BaseAddress);
    // printf("Worker 3 Base Address: %X\n\r", genWorker3BaseAddress);
    // printf("Worker 4 Base Address: %X\n\r", genWorker4BaseAddress);
    // Set the addresses of the workers
    // int32_t workerAddresses[3] = {genWorker1BaseAddress, genWorker2BaseAddress, genWorker3BaseAddress, genWorker4BaseAddress};
    // genWorker1Reg[1] = genWorker1BaseAddress;
    // genWorker2Reg[1] = genWorker2BaseAddress;
    // genWorker3Reg[1] = genWorker3BaseAddress;
    // genWorker4Reg[1] = genWorker4BaseAddress;
    // Reset Workers (IDLE State)

    int reset_result1 = reset_worker(genWorker1Reg, 1);
    int reset_result2 = reset_worker(genWorker2Reg, 2);
    int reset_result3 = reset_worker(genWorker3Reg, 3);
    int reset_result4 = reset_worker(genWorker4Reg, 4);
    if (reset_result1 != 0 || reset_result2 != 0 || reset_result3 != 0 || reset_result4 != 0) {
        printf("Failed to Reset Workers\n\r");
        return 1;
    }
    printf("Hardware Initialized\n\r");
    return 0;
}

// int write_seed(int64_t worldSeed) {
//     printf("Received World Seed: %lld from Host\n\r", worldSeed);
//     int32_t worldSeedLow = (uint32_t)(worldSeed & 0xFFFFFFFF);
//     int32_t worldSeedHigh = (uint32_t)((worldSeed >> 32) & 0xFFFFFFFF);
//     if (write_bram_data(XPAR_BRAM_0_BASEADDR, worldSeedLow) != 0) {
//         printf("Failed to Write World Seed Low\n\r");
//         return 1;
//     }
//     printf("World Seed Low Written: %X\n\r", worldSeedLow);
//     if (write_bram_data(XPAR_BRAM_0_BASEADDR+4, worldSeedHigh) != 0) {
//         printf("Failed to Write World Seed High\n\r");
//         return 1;
//     }
//     printf("World Seed High Written: %X\n\r", worldSeedHigh);
//     return 0;
// }

int write_coordinates(int32_t workerAddress, int32_t x, int32_t y, int32_t z, int32_t opcode) {
    // Write to all workers
    int32_t coordinates = ((x & 0xFF) << 24) | ((y & 0xFF) << 16) | ((z & 0xFF) << 8) | (opcode & 0xFF);
    printf("Coordinates: %d %d %d %d\n\r", x, y, z, opcode);
    if (write_bram_data(workerAddress, coordinates) != 0) {
        printf("Failed to Write Coordinates\n\r");
        return 1;
    }
    printf("Coordinates Written\n\r");
    return 0;
}

// int write_instruction(Instruction *instr) {
//     printf("Received Instruction: %d\n\r", instr->instruction_type);
//     int8_t opcode = instr->instruction_type;
    //
    // Ready to receive and process instructions
    // This is the part that loops as we send/receive instructions
    // for (int j = 0; j < 1; j++) {
    //     for (int i = 0; i < NUMBER_OF_WORKERS; i++) {
    //         // Receive these from the host
    //         int8_t x = 3;
    //         int8_t y = 4;
    //         int8_t z = 5;
    //         int8_t opcode = 13+i;
    //         int32_t coordinates = ((x & 0xFF) << 24) | ((y & 0xFF) << 16) | ((z & 0xFF) << 8) | (opcode & 0xFF);
    //         printf("Coordinates %d: %d %d %d %d\n\r", i+1, x, y, z, opcode);
    //         // Instruction Data (high and low)
    //         int32_t instructions_low = double_to_fixed(-0.1);
    //         int32_t instructions_high = double_to_fixed(0.5);
    //         printf("Instructions X: %X\n\r", instructions_low);
    //         printf("Instructions Y: %X\n\r", instructions_high);
    //         // Ready to Start so Write Instructions
    //         int write_result = write_bram_data(workerAddresses[i], coordinates);
    //         if (write_result != 0) {
    //             printf("Failed to Write Coordinates %d\n\r", i+1);
    //             return 1;
    //         }
    //         printf("Coordinates Written\n\r");
    //         write_result = write_bram_data(workerAddresses[i]+4, instructions_low);
    //         if (write_result != 0) {
    //             printf("Failed to Write Instructions Low %d\n\r", i+1);
    //             return 1;
    //         }
    //         write_result = write_bram_data(workerAddresses[i]+8, instructions_high);
    //         if (write_result != 0) {
    //             printf("Failed to Write Instructions High %d\n\r", i+1);
    //             return 1;
    //         }
    //     }
    //     printf("Instructions Written to Workers\n\r");

    //     // Start Workers
    //     printf("Starting Workers\n\r");
    //     genWorker1Reg[0] = 0x0; // Assert Continue
    //     genWorker2Reg[0] = 0x0; // Assert Continue
    //     genWorker3Reg[0] = 0x0; // Assert Continue
    //     int worker1Done, worker2Done, worker3Done;
    //     int count = 0;
    //     while (count < 10) {
    //         worker1Done = genWorker1Reg[3] == WORKER_FINISHED_STATE || genWorker1Reg[3] == WORKER_ERROR_STATE;
    //         worker2Done = genWorker2Reg[3] == WORKER_FINISHED_STATE || genWorker2Reg[3] == WORKER_ERROR_STATE;
    //         worker3Done = genWorker3Reg[3] == WORKER_FINISHED_STATE || genWorker3Reg[3] == WORKER_ERROR_STATE;
    //         if (worker1Done && worker2Done && worker3Done) {
    //             if (genWorker1Reg[3] == WORKER_ERROR_STATE) {
    //                 printf("Worker 1 Error\n\r");
    //                 printf("Worker 1 Data: %X\n\r", genWorker1Reg[2]);
    //             }
    //             if (genWorker2Reg[3] == WORKER_ERROR_STATE) {
    //                 printf("Worker 2 Error\n\r");
    //                 printf("Worker 2 Data: %X\n\r", genWorker2Reg[2]);
    //             }
    //             if (genWorker3Reg[3] == WORKER_ERROR_STATE) {
    //                 printf("Worker 3 Error\n\r");
    //                 printf("Worker 3 Data: %X\n\r", genWorker3Reg[2]);
    //             }
    //             break;
    //         }
    //         sleep(0.1);
    //         count++;
    //     }
    //     printf("Workers Finished!\n\r");
    //     int32_t resultData1 = XBram_ReadReg(genWorker1BaseAddress, WORKER_BRAM_SIZE-4);
    //     int32_t resultData2 = XBram_ReadReg(genWorker2BaseAddress, WORKER_BRAM_SIZE-4);
    //     int32_t resultData3 = XBram_ReadReg(genWorker3BaseAddress, WORKER_BRAM_SIZE-4);
    //     int32_t allResults[3] = {resultData1, resultData2, resultData3};
    //     for (int i = 0; i < NUMBER_OF_WORKERS; i++) {
    //         printf("Raw Result %d: %X\n\r", i+1, allResults[i]);
    //         printf("Clean Result %d: %f\n\r", i+1, fixed_to_double(allResults[i]));
        // }
        // Reset Workers
        // int reset_result1 = reset_worker(genWorker1Reg, genWorker1BaseAddress, 1);
        // int reset_result2 = reset_worker(genWorker2Reg, genWorker2BaseAddress, 2);
        // int reset_result3 = reset_worker(genWorker3Reg, genWorker3BaseAddress, 3);
        // if (reset_result1 != 0 || reset_result2 != 0 || reset_result3 != 0) {
        //     printf("Failed to Reset Workers\n\r");
        //     return 1;
        // }
    // }
    // dump_bram(&Bram);
    // printf("All Instructions Processed\n\r");

    // Cleanup
//     cleanup_platform();
//     return 0;
// }
