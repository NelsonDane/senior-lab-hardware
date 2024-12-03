
#include "xil_printf.h"
#include "lwip/err.h"
#include "lwip/tcp.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include "workers.h"
#pragma pack(1)

int transfer_data() {
	return 0;
}

#define MAX_QUEUE_SIZE 10
#define PACKET_SIZE 513 // Example size (you can adjust this based on your needs)
#define MAX_INSTRUCTION_LENGTH 256
#define MAX_LOG_LENGTH 256

#define REQUEST_GET_SYSTEM_STATUS 1
#define REQUEST_INITIALIZE_HARDWARE 2
#define REQUEST_SEND_SEED 3
#define REQUEST_GENERATE_CHUNK 4
#define REQUEST_WRITE_LOG 5
#define REQUEST_ERROR 0

// const uint8_t REQUEST_GET_SYSTEM_STATUS = 0x01;
// const uint8_t REQUEST_INITIALIZE_HARDWARE = 0x02;
// const uint8_t REQUEST_SEND_SEED = 0x03;
// const uint8_t REQUEST_GENERATE_CHUNK = 0x04;
// const uint8_t REQUEST_WRITE_LOG = 0x05;
// const uint8_t REQUEST_ERROR = 0x00;
// Request types
// typedef uint8_t {
//     REQUEST_GET_SYSTEM_STATUS = 0x01,
//     REQUEST_INITIALIZE_HARDWARE = 0x02,
//     REQUEST_SEND_SEED = 0x03,
//     REQUEST_GENERATE_CHUNK = 0x04,
//     REQUEST_WRITE_LOG = 0x05,
//     REQUEST_ERROR = 0x00
// } RequestType;

// Get System Status (empty request)
typedef struct {
    uint8_t type;
    uint8_t Flags;
    int64_t CurrentSeed;
} GetSystemStatusResponse;

// Initialize Hardware Request
typedef struct {
    uint8_t SequenceNumber;
    uint8_t Instructions[MAX_INSTRUCTION_LENGTH];
} InitializeHardwareRequest;

// Initialize Hardware Response
typedef struct {
    uint8_t type;
    uint8_t SequenceNumber;
    uint8_t ReturnCode;  // 0 for success, non-zero for error
} InitializeHardwareResponse;

// Send Seed Request
typedef struct {
    int64_t Seed;
} SendSeedRequest;

// Send Seed Response
typedef struct {
    uint8_t type;
    uint8_t ReturnCode;  // 0 for success, non-zero for error
} SendSeedResponse;

// Generate Chunk Segment Request
typedef struct {
    uint8_t BaseX;
    uint8_t BaseY;
    uint8_t BaseZ;
} GenerateChunkRequest;

// Generate Chunk Segment Response
typedef struct {
    uint8_t type;
    uint8_t BaseX;
    uint8_t BaseY;
    uint8_t BaseZ;
    uint8_t Generated[64]; // Generated data chunk
} GenerateChunkResponse;

// Write Log Request
typedef struct {
    uint8_t type;
    uint8_t Length;
    char Message[MAX_LOG_LENGTH]; // Message content
} WriteLogRequest;

// Structure for the payload of the packet
struct NetworkPayload {
    uint8_t type;
    char payload[PACKET_SIZE];  // 513 bytes to hold the payload
};

// Structure for the outgoing packet queue
struct OutgoingQueue {
    uint8_t type;
    struct NetworkPayload queue[MAX_QUEUE_SIZE];
    int head;
    int tail;
};

// Define the Instruction structure
typedef struct {
    uint8_t instruction_type;
} Instruction;

// Initialize the queue
// struct OutgoingQueue outgoing_queue = { .head = 0, .tail = 0 };

// Enqueue function
// int enqueue_outgoing_packet(struct NetworkPayload *packet) {
//     int next_tail = (outgoing_queue.tail + 1) % MAX_QUEUE_SIZE;
//     if (next_tail == outgoing_queue.head) {
//         // Queue is full
//         return -1;
//     }
//     outgoing_queue.queue[outgoing_queue.tail] = *packet;
//     outgoing_queue.tail = next_tail;
//     return 0;
// }

// Dequeue function
// int dequeue_outgoing_packet(struct NetworkPayload *packet) {
//     if (outgoing_queue.head == outgoing_queue.tail) {
//         // Queue is empty
//         return -1;
//     }
//     *packet = outgoing_queue.queue[outgoing_queue.head];
//     outgoing_queue.head = (outgoing_queue.head + 1) % MAX_QUEUE_SIZE;
//     return 0;
// }

// Instruction queue setup
Instruction instruction_queue[MAX_QUEUE_SIZE];
int queue_head = 0;
int queue_tail = 0;

// Function to queue instructions
int queue_instruction(Instruction *instr) {
    if ((queue_tail + 1) % MAX_QUEUE_SIZE == queue_head) {
        xil_printf("Queue is full, dropping instruction\n\r");
        return -1;
    }
    instruction_queue[queue_tail] = *instr;
    queue_tail = (queue_tail + 1) % MAX_QUEUE_SIZE;
    return 0;
}

// Function to get the instruction queue
Instruction dequeue_instruction() {
    if (queue_head == queue_tail) {
        xil_printf("Queue is empty\n\r");
        Instruction instr;
        instr.instruction_type = 0;
        return instr;
    }
    Instruction instr = instruction_queue[queue_head];
    queue_head = (queue_head + 1) % MAX_QUEUE_SIZE;
    return instr;
}

err_t write_log_to_host(struct tcp_pcb *pcb, char Message[MAX_LOG_LENGTH]) {
    WriteLogRequest log_packet;
    log_packet.type = (uint8_t)REQUEST_WRITE_LOG;
    log_packet.Length = strlen(Message);
    sprintf(log_packet.Message, "%s", Message);
    xil_printf("LOGGED: %s\n\r", log_packet.Message);
    err_t write_success = tcp_write(pcb, &log_packet, sizeof(WriteLogRequest), 1);
    if (write_success != ERR_OK) {
        xil_printf("Error writing to client\n\r");
        return ERR_VAL;
    }
    err_t write_now = tcp_output(pcb);
    if (write_now != ERR_OK) {
        xil_printf("Error writing now to client\n\r");
        return ERR_VAL;
    }
    return ERR_OK;
}

// Function to queue a periodic debug packet
// void queue_debug_packet(char Message[MAX_LOG_LENGTH]) {
//     WriteLogRequest debug_packet;

//     // Fill the payload with some debug information (you can customize this)
//    snprintf(debug_packet.Message, sizeof(debug_packet.Message), "Debug message: %s", Message);

//     // queue the debug packet
//     if (enqueue_outgoing_packet(&debug_packet) != 0) {
//        printf("Failed to enqueue debug packet\n");
//    } else {
//        printf("Debug packet enqueued\n");
//    }
// }

// Function to periodic sending of debug info (called periodically)
// void send_periodic_debug_info() {
//     static time_t last_sent_time = 0;
//     time_t current_time = time(NULL);

//     if (current_time - last_sent_time >= 2) {  // Send every 2 seconds
//        queue_debug_packet();
//        last_sent_time = current_time;
//     }
// }

// TCP receive callback function to handle incoming packets
err_t recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err) {
    if (!p) {
        return ERR_OK;
    }
    // Indicate packet has been received
    tcp_recved(tpcb, p->len);
    uint8_t *payload = (uint8_t *)p->payload;
    uint8_t request_type = (uint8_t)payload[0];

    xil_printf("Received request type: %d\n\r", request_type);
    switch (request_type) {
        case REQUEST_GET_SYSTEM_STATUS: {
            GetSystemStatusResponse response;
            response.type = (uint8_t)REQUEST_GET_SYSTEM_STATUS;
            response.Flags = get_worker_states();
            response.CurrentSeed = get_current_seed();
            err_t write_err = tcp_write(tpcb, &response, sizeof(GetSystemStatusResponse), 1);
            if (write_err != ERR_OK) {
                xil_printf("Error writing System Status response to client\n\r");
            }
            break;
        }

        case REQUEST_INITIALIZE_HARDWARE: {
            int bramSuccess = init_bram();
            int hardwareSuccess = init_workers();
            int totalSuccess;
            if (bramSuccess == 0 && hardwareSuccess == 0) {
                totalSuccess = 0;
            } else {
                totalSuccess = 1;
            }
            InitializeHardwareRequest *request = (InitializeHardwareRequest *)payload;
            InitializeHardwareResponse response;
            response.type = (uint8_t)REQUEST_INITIALIZE_HARDWARE;
            response.SequenceNumber = request->SequenceNumber;
            response.ReturnCode = totalSuccess;

            // Add instructions to the queue
            for (int i = 0; i < MAX_INSTRUCTION_LENGTH && request->Instructions[i] != 0; i++) {
                Instruction instr;
                instr.instruction_type = request->Instructions[i];
                queue_instruction(&instr);
            }

            err_t write_err = tcp_write(tpcb, &response, sizeof(InitializeHardwareResponse), 1);
            if (write_err != ERR_OK) {
                xil_printf("Error writing Request Initialize Hardware response to client\n\r");
            }
            break;
        }

        case REQUEST_SEND_SEED: {
            SendSeedRequest *request = (SendSeedRequest *)payload;
            SendSeedResponse response;
            response.type = (uint8_t)REQUEST_SEND_SEED;
            response.ReturnCode = write_seed(request->Seed);
            err_t write_err = tcp_write(tpcb, &response, sizeof(SendSeedResponse), 1);
            if (write_err != ERR_OK) {
                xil_printf("Error writing Send Seed response to client\n\r");
            }
            break;
        }

        case REQUEST_GENERATE_CHUNK: {
            GenerateChunkRequest *request = (GenerateChunkRequest *)payload;
            GenerateChunkResponse response;
            response.type = (uint8_t)REQUEST_GENERATE_CHUNK;
            response.BaseX = request->BaseX;
            response.BaseY = request->BaseY;
            response.BaseZ = request->BaseZ;
            // Fill response.Generated with generated data
            err_t write_err = tcp_write(tpcb, &response, sizeof(GenerateChunkResponse), 1);
            if (write_err != ERR_OK) {
                xil_printf("Error writing Generate Chunk response to client\n\r");
            }
            break;
        }

        case REQUEST_WRITE_LOG: {
            WriteLogRequest *request = (WriteLogRequest *)payload;
            // Handle the log message
            break;
        }

        default:
            // Handle unknown request type
            xil_printf("Unknown request type: %d\n\r", request_type);
            write_log_to_host(tpcb, "Unknown request type");
            break;
    }
    
    pbuf_free(p);
    return ERR_OK;
}

err_t sent_callback(void *arg, struct tcp_pcb *tpcb, u16_t len) {
    xil_printf("Sent %d bytes\n\r", len);
    return ERR_OK;
}

// TCP accept callback function to handle incoming connections
err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err) {
    static int connection = 1;
    xil_printf("Incoming connection: %d.%d.%d.%d - port: %d \r\n",
        (u8)(newpcb->remote_ip.addr),
        (u8)(newpcb->remote_ip.addr >> 8),
        (u8)(newpcb->remote_ip.addr >> 16),
        (u8)(newpcb->remote_ip.addr >> 24),
        newpcb->remote_port
    );
    // Receive callback
    tcp_recv(newpcb, recv_callback);
    // Sent callback
    tcp_sent(newpcb, sent_callback);
    // Connection ID
    tcp_arg(newpcb, (void*)(UINTPTR)connection);
    // Increment connection
    connection++;
    WriteLogRequest request;
    write_log_to_host(newpcb, "Connection established");
    return ERR_OK;
}

int start_application() {
    struct tcp_pcb *pcb;
    err_t err;
    unsigned port = 9055;

    // Create new TCP PCB (protocol control block)
    pcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
    if (!pcb) {
        xil_printf("Error creating PCB. Out of Memory\n\r");
        return -1;
    }

    // Bind to specified port
    err = tcp_bind(pcb, IP_ANY_TYPE, port);
    if (err != ERR_OK) {
        xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
        return -2;
    }
    tcp_arg(pcb, NULL);

    // Listen for incoming connections
    pcb = tcp_listen(pcb);
    if (!pcb) {
        xil_printf("Out of memory while tcp_listen\n\r");
    }
    tcp_accept(pcb, accept_callback);
    xil_printf("TCP echo server started @ port %d\n\r", port);
    return 0;
}
