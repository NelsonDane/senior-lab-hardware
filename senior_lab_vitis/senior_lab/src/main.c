// Ethernet
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "lwip/tcp.h"
#include "xil_cache.h"
#include "lwip/dhcp.h"
#include "echo.h"

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
static struct netif server_netif;
struct netif *echo_netif;
struct pbuf *p;
extern volatile int dhcp_timoutcntr;

void print_ip(char *msg, ip_addr_t *ip) {
	print(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip),
			ip4_addr3(ip), ip4_addr4(ip));
}

void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw) {

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}

int main() {
    init_platform();
    printf("\n\r\n\r");
    printf("========================================\n\r");
    printf("Senior Lab Minecraft Gen Starting\n\r");
    printf("========================================\n\r");
    // Initialize Ethernet
    printf("Initializing Ethernet\n\r");
    ip_addr_t ipaddr, netmask, gw;
    unsigned char mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };
    echo_netif = &server_netif;
    // DHCP
    ipaddr.addr = 0;
    gw.addr = 0;
    netmask.addr = 0;
    printf("Initializing lwIP\n\r");
	lwip_init();
    printf("Adding Network Interface\n\r");
    if (!xemac_add(echo_netif, &ipaddr, &netmask,
					&gw, mac_ethernet_address,
					PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n\r");
		return -1;
	}
    printf("Setting Default Network Interface\n\r");
    netif_set_default(echo_netif);
    printf("Enabling Interrupts\n\r");
    platform_enable_interrupts();
    printf("Starting Network Interface\n\r");
    netif_set_up(echo_netif);
    printf("Starting DHCP\n\r");
    dhcp_start(echo_netif);
    dhcp_timoutcntr = 24;
	while(((echo_netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0))
    xemacif_input(echo_netif);
    if (dhcp_timoutcntr <= 0) {
        if ((echo_netif->ip_addr.addr) == 0) {
            xil_printf("DHCP Timeout\r\n");
            return -1;
        }
	}
	ipaddr.addr = echo_netif->ip_addr.addr;
	gw.addr = echo_netif->gw.addr;
	netmask.addr = echo_netif->netmask.addr;
    print_ip_settings(&ipaddr, &netmask, &gw);
    start_application();
    printf("Ethernet Initialized\n\r");
    // int32_t x, y, z;
    while (1) {
		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
		xemacif_input(echo_netif);
		// transfer_data();

        // Get worker states
        // uint8_t workerStates[NUMBER_OF_WORKERS];
        // get_worker_states(workerStates);
        // for (int i = 0; i < NUMBER_OF_WORKERS; i++) {
        //     int workerState = workerStates[i];
        //     switch(workerState) {
        //         case WORKER_IDLE_STATE:
        //             // Worker is idle
        //             break;
        //         case WORKER_FINISHED_STATE:

        //     }
        // }
        
        


    }
    cleanup_platform();
    return 0;
}