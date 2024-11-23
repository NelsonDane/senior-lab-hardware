library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_arbiter_v1_0 is
	generic (
		-- Users to add parameters here
        BRAM_WIDTH : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		-- Worker 1 Signals
		worker1_request : in std_logic;
		worker1_rw : in std_logic;
		worker1_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker1_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker1_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker1_ack : out std_logic;
		-- Worker 2 Signals
		worker2_request : in std_logic;
		worker2_rw : in std_logic;
		worker2_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker2_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker2_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker2_ack : out std_logic;
		-- Worker 3 Signals
		worker3_request : in std_logic;
		worker3_rw : in std_logic;
		worker3_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker3_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker3_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
		worker3_ack : out std_logic;
		-- BRAM Interface
		addrb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
		clkb : out std_logic;
		dinb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
		doutb : in std_logic_vector(BRAM_WIDTH-1 downto 0);
		enb : out std_logic;
		rstb : out std_logic;
		web : out std_logic_vector(3 downto 0);
		rstb_busy : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end bram_arbiter_v1_0;

architecture arch_imp of bram_arbiter_v1_0 is

	-- BRAM Interface
	ATTRIBUTE X_INTERFACE_INFO : string;
	ATTRIBUTE X_INTERFACE_INFO OF addrb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR";
	ATTRIBUTE X_INTERFACE_INFO OF clkb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK";
	ATTRIBUTE X_INTERFACE_INFO OF dinb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN";
	ATTRIBUTE X_INTERFACE_INFO OF doutb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT";
	ATTRIBUTE X_INTERFACE_INFO OF enb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB EN";
	ATTRIBUTE X_INTERFACE_INFO OF rstb : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB RST";
	ATTRIBUTE X_INTERFACE_INFO OF web : SIGNAL IS "xilinx.com:interface:bram:1.0 BRAM_PORTB WE";

	-- component declaration
	component bram_arbiter_v1_0_S00_AXI is
		generic (
			C_S_AXI_DATA_WIDTH	: integer	:= 32;
			C_S_AXI_ADDR_WIDTH	: integer	:= 4;
			BRAM_WIDTH : integer := BRAM_WIDTH
		);
		port (
			-- User ports
			-- Worker 1 Signals
			worker1_request : in std_logic;
			worker1_rw : in std_logic;
			worker1_address : in std_logic_vector(31 downto 0);
			worker1_data_in : in std_logic_vector(31 downto 0);
			worker1_data_out : out std_logic_vector(31 downto 0);
			worker1_ack : out std_logic;
			-- Worker 2 Signals
			worker2_request : in std_logic;
			worker2_rw : in std_logic;
			worker2_address : in std_logic_vector(31 downto 0);
			worker2_data_in : in std_logic_vector(31 downto 0);
			worker2_data_out : out std_logic_vector(31 downto 0);
			worker2_ack : out std_logic;
			-- Worker 3 Signals
			worker3_request : in std_logic;
			worker3_rw : in std_logic;
			worker3_address : in std_logic_vector(31 downto 0);
			worker3_data_in : in std_logic_vector(31 downto 0);
			worker3_data_out : out std_logic_vector(31 downto 0);
			worker3_ack : out std_logic;
			-- BRAM Interface
			addrb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
			clkb : out std_logic;
			dinb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
			doutb : in std_logic_vector(BRAM_WIDTH-1 downto 0);
			enb : out std_logic;
			rstb : out std_logic;
			web : out std_logic_vector(3 downto 0);
			rstb_busy : in std_logic;
			-- User ports ends
			S_AXI_ACLK	: in std_logic;
			S_AXI_ARESETN	: in std_logic;
			S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
			S_AXI_AWVALID	: in std_logic;
			S_AXI_AWREADY	: out std_logic;
			S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID	: in std_logic;
			S_AXI_WREADY	: out std_logic;
			S_AXI_BRESP	: out std_logic_vector(1 downto 0);
			S_AXI_BVALID	: out std_logic;
			S_AXI_BREADY	: in std_logic;
			S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
			S_AXI_ARVALID	: in std_logic;
			S_AXI_ARREADY	: out std_logic;
			S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP	: out std_logic_vector(1 downto 0);
			S_AXI_RVALID	: out std_logic;
			S_AXI_RREADY	: in std_logic
		);
	end component bram_arbiter_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
bram_arbiter_v1_0_S00_AXI_inst : bram_arbiter_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		BRAM_WIDTH => BRAM_WIDTH
	)
	port map (
		-- User ports
		-- Worker 1 Signals
		worker1_request => worker1_request,
		worker1_rw => worker1_rw,
		worker1_address => worker1_address,
		worker1_data_in => worker1_data_in,
		worker1_data_out => worker1_data_out,
		worker1_ack => worker1_ack,
		-- Worker 2 Signals
		worker2_request => worker2_request,
		worker2_rw => worker2_rw,
		worker2_address => worker2_address,
		worker2_data_in => worker2_data_in,
		worker2_data_out => worker2_data_out,
		worker2_ack => worker2_ack,
		-- Worker 3 Signals
		worker3_request => worker3_request,
		worker3_rw => worker3_rw,
		worker3_address => worker3_address,
		worker3_data_in => worker3_data_in,
		worker3_data_out => worker3_data_out,
		worker3_ack => worker3_ack,
		-- BRAM Interface
		addrb => addrb,
		clkb => clkb,
		dinb => dinb,
		doutb => doutb,
		enb => enb,
		rstb => rstb,
		web => web,
		rstb_busy => rstb_busy,
		-- User ports ends
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
