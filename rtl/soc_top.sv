// SPDX-License-Identifier: Apache-2.0
// Top-Level SoC Integration (soc_top)
// VeeR EL2 RISC-V SoC with AXI4-Lite Interconnect and Sensor Processing IPs
// Compliant with Sections 3, 7, 8, 9, 10 of VeeR EL2 SoC Specification v2.0

`timescale 1ns/1ps

`include "common_defines.vh"
`include "el2_pdef.vh"

module soc_top
import el2_pkg::*;
#(
`include "el2_param.vh",
    parameter int NUM_CH = 1,
    parameter int NGPIO  = 16,
    parameter int IMEM_DEPTH = 8192, // 32 KB
    parameter int DMEM_DEPTH = 8192  // 32 KB
)(
    input  logic              clk,
    input  logic              rst_n,

    // UART
    output logic              uart_tx,
    input  logic              uart_rx,

    // I2C (Open-drain)
    inout  wire               i2c_scl,
    inout  wire               i2c_sda,

    // PWM
    output logic [NUM_CH-1:0] pwm_out,

    // GPIO
    inout  wire  [NGPIO-1:0]  gpio
);

    // =========================================================================
    // Reset Synchronizer (CP-10)
    // 2-FF synchronizer: asynchronous assert, synchronous deassert
    // =========================================================================
    logic rst_sync1, rst_sync2;
    wire  aresetn = rst_sync2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= 1'b0;
        end else begin
            rst_sync1 <= 1'b1;
            rst_sync2 <= rst_sync1;
        end
    end

    // =========================================================================
    // Core Signals
    // =========================================================================
    // IFU AXI4 Read Channel
    logic [pt.IFU_BUS_TAG-1:0] ifu_axi_arid;
    logic [31:0]               ifu_axi_araddr;
    logic [7:0]                ifu_axi_arlen;
    logic [2:0]                ifu_axi_arsize;
    logic [1:0]                ifu_axi_arburst;
    logic [2:0]                ifu_axi_arprot;
    logic                      ifu_axi_arvalid;
    logic                      ifu_axi_arready;
    logic [pt.IFU_BUS_TAG-1:0] ifu_axi_rid;
    logic [63:0]               ifu_axi_rdata;
    logic [1:0]                ifu_axi_rresp;
    logic                      ifu_axi_rlast;
    logic                      ifu_axi_rvalid;
    logic                      ifu_axi_rready;

    // LSU AXI4 Full Channel
    logic [pt.LSU_BUS_TAG-1:0] lsu_axi_awid;
    logic [31:0]               lsu_axi_awaddr;
    logic [7:0]                lsu_axi_awlen;
    logic [2:0]                lsu_axi_awsize;
    logic [1:0]                lsu_axi_awburst;
    logic [2:0]                lsu_axi_awprot;
    logic                      lsu_axi_awvalid;
    logic                      lsu_axi_awready;
    logic [63:0]               lsu_axi_wdata;
    logic [7:0]                lsu_axi_wstrb;
    logic                      lsu_axi_wlast;
    logic                      lsu_axi_wvalid;
    logic                      lsu_axi_wready;
    logic [pt.LSU_BUS_TAG-1:0] lsu_axi_bid;
    logic [1:0]                lsu_axi_bresp;
    logic                      lsu_axi_bvalid;
    logic                      lsu_axi_bready;
    logic [pt.LSU_BUS_TAG-1:0] lsu_axi_arid;
    logic [31:0]               lsu_axi_araddr;
    logic [7:0]                lsu_axi_arlen;
    logic [2:0]                lsu_axi_arsize;
    logic [1:0]                lsu_axi_arburst;
    logic [2:0]                lsu_axi_arprot;
    logic                      lsu_axi_arvalid;
    logic                      lsu_axi_arready;
    logic [pt.LSU_BUS_TAG-1:0] lsu_axi_rid;
    logic [63:0]               lsu_axi_rdata;
    logic [1:0]                lsu_axi_rresp;
    logic                      lsu_axi_rlast;
    logic                      lsu_axi_rvalid;
    logic                      lsu_axi_rready;

    // Interrupt lines
    logic                      timer_int;
    logic [pt.PIC_TOTAL_INT:1] extintsrc_req;
    logic                      irq_uart, irq_timer, irq_i2c, irq_fir, irq_pwm, irq_gpio;

    assign extintsrc_req[1] = irq_uart;
    assign extintsrc_req[2] = irq_timer;
    assign extintsrc_req[3] = irq_i2c;
    assign extintsrc_req[4] = irq_fir;
    assign extintsrc_req[5] = irq_pwm;
    assign extintsrc_req[6] = irq_gpio;
    assign extintsrc_req[7] = 1'b0;
    assign extintsrc_req[8] = 1'b0;

    // Memory and Cache dummy interfaces for core
    el2_mem_if el2_mem_export ();
    el2_mem_if el2_icache_export ();

    // =========================================================================
    // VeeR EL2 Core Instantiation
    // =========================================================================
    el2_veer_wrapper u_core (
        .clk             (clk),
        .rst_l           (aresetn),
        .dbg_rst_l       (aresetn),
        .rst_vec         (31'h0000_0000), // Reset vector: 0x0000_0000 (IMEM base)
        .nmi_int         (1'b0),
        .nmi_vec         (31'h1111_0000),
        .jtag_id         (31'h0),
        .core_id         (28'h0),

        // Trace ports
        .trace_rv_i_insn_ip     (),
        .trace_rv_i_address_ip  (),
        .trace_rv_i_valid_ip    (),
        .trace_rv_i_exception_ip(),
        .trace_rv_i_ecause_ip   (),
        .trace_rv_i_interrupt_ip(),
        .trace_rv_i_tval_ip     (),

        // IFU AXI4 Read Channel
        .ifu_axi_arvalid (ifu_axi_arvalid),
        .ifu_axi_arready (ifu_axi_arready),
        .ifu_axi_arid    (ifu_axi_arid),
        .ifu_axi_araddr  (ifu_axi_araddr),
        .ifu_axi_arlen   (ifu_axi_arlen),
        .ifu_axi_arsize  (ifu_axi_arsize),
        .ifu_axi_arburst (ifu_axi_arburst),
        .ifu_axi_arcache (),
        .ifu_axi_arprot  (ifu_axi_arprot),
        .ifu_axi_arqos   (),
        .ifu_axi_arregion(),
        .ifu_axi_arlock  (),
        .ifu_axi_rvalid  (ifu_axi_rvalid),
        .ifu_axi_rready  (ifu_axi_rready),
        .ifu_axi_rid     (ifu_axi_rid),
        .ifu_axi_rdata   (ifu_axi_rdata),
        .ifu_axi_rresp   (ifu_axi_rresp),
        .ifu_axi_rlast   (ifu_axi_rlast),

        // Unused IFU Write Channel tied off per Section 7.2
        .ifu_axi_awvalid (),
        .ifu_axi_awready (1'b0),
        .ifu_axi_awid    (),
        .ifu_axi_awaddr  (),
        .ifu_axi_awregion(),
        .ifu_axi_awlen   (),
        .ifu_axi_awsize  (),
        .ifu_axi_awburst (),
        .ifu_axi_awlock  (),
        .ifu_axi_awcache (),
        .ifu_axi_awprot  (),
        .ifu_axi_awqos   (),
        .ifu_axi_wvalid  (),
        .ifu_axi_wready  (1'b0),
        .ifu_axi_wdata   (),
        .ifu_axi_wstrb   (),
        .ifu_axi_wlast   (),
        .ifu_axi_bvalid  (1'b0),
        .ifu_axi_bready  (),
        .ifu_axi_bresp   (2'b00),
        .ifu_axi_bid     ({pt.IFU_BUS_TAG{1'b0}}),

        // LSU AXI4 Full Channel
        .lsu_axi_awvalid (lsu_axi_awvalid),
        .lsu_axi_awready (lsu_axi_awready),
        .lsu_axi_awid    (lsu_axi_awid),
        .lsu_axi_awaddr  (lsu_axi_awaddr),
        .lsu_axi_awregion(),
        .lsu_axi_awlen   (lsu_axi_awlen),
        .lsu_axi_awsize  (lsu_axi_awsize),
        .lsu_axi_awburst (lsu_axi_awburst),
        .lsu_axi_awlock  (),
        .lsu_axi_awcache (),
        .lsu_axi_awprot  (lsu_axi_awprot),
        .lsu_axi_awqos   (),
        .lsu_axi_wvalid  (lsu_axi_wvalid),
        .lsu_axi_wready  (lsu_axi_wready),
        .lsu_axi_wdata   (lsu_axi_wdata),
        .lsu_axi_wstrb   (lsu_axi_wstrb),
        .lsu_axi_wlast   (lsu_axi_wlast),
        .lsu_axi_bvalid  (lsu_axi_bvalid),
        .lsu_axi_bready  (lsu_axi_bready),
        .lsu_axi_bresp   (lsu_axi_bresp),
        .lsu_axi_bid     (lsu_axi_bid),
        .lsu_axi_arvalid (lsu_axi_arvalid),
        .lsu_axi_arready (lsu_axi_arready),
        .lsu_axi_arid    (lsu_axi_arid),
        .lsu_axi_araddr  (lsu_axi_araddr),
        .lsu_axi_arregion(),
        .lsu_axi_arlen   (lsu_axi_arlen),
        .lsu_axi_arsize  (lsu_axi_arsize),
        .lsu_axi_arburst (lsu_axi_arburst),
        .lsu_axi_arlock  (),
        .lsu_axi_arcache (),
        .lsu_axi_arprot  (lsu_axi_arprot),
        .lsu_axi_arqos   (),
        .lsu_axi_rvalid  (lsu_axi_rvalid),
        .lsu_axi_rready  (lsu_axi_rready),
        .lsu_axi_rid     (lsu_axi_rid),
        .lsu_axi_rdata   (lsu_axi_rdata),
        .lsu_axi_rresp   (lsu_axi_rresp),
        .lsu_axi_rlast   (lsu_axi_rlast),

        // System Bus (Debug) tied off as idle slave per Section 7.2
        .sb_axi_awvalid  (),
        .sb_axi_awready  (1'b0),
        .sb_axi_awid     (),
        .sb_axi_awaddr   (),
        .sb_axi_awregion (),
        .sb_axi_awlen    (),
        .sb_axi_awsize   (),
        .sb_axi_awburst  (),
        .sb_axi_awlock   (),
        .sb_axi_awcache  (),
        .sb_axi_awprot   (),
        .sb_axi_awqos    (),
        .sb_axi_wvalid   (),
        .sb_axi_wready   (1'b0),
        .sb_axi_wdata    (),
        .sb_axi_wstrb    (),
        .sb_axi_wlast    (),
        .sb_axi_bvalid   (1'b0),
        .sb_axi_bready   (),
        .sb_axi_bresp    (2'b00),
        .sb_axi_bid      ({pt.SB_BUS_TAG{1'b0}}),
        .sb_axi_arvalid  (),
        .sb_axi_arready  (1'b0),
        .sb_axi_arid     (),
        .sb_axi_araddr   (),
        .sb_axi_arregion (),
        .sb_axi_arlen    (),
        .sb_axi_arsize   (),
        .sb_axi_arburst  (),
        .sb_axi_arlock   (),
        .sb_axi_arcache  (),
        .sb_axi_arprot   (),
        .sb_axi_arqos    (),
        .sb_axi_rvalid   (1'b0),
        .sb_axi_rready   (),
        .sb_axi_rid      ({pt.SB_BUS_TAG{1'b0}}),
        .sb_axi_rdata    (64'h0),
        .sb_axi_rresp    (2'b00),
        .sb_axi_rlast    (1'b0),

        // DMA Slave Port tied off as idle master per Section 7.2
        .dma_axi_awvalid (1'b0),
        .dma_axi_awready (),
        .dma_axi_awid    ({pt.DMA_BUS_TAG{1'b0}}),
        .dma_axi_awaddr  (32'h0),
        .dma_axi_awsize  (3'b0),
        .dma_axi_awprot  (3'b0),
        .dma_axi_awlen   (8'h0),
        .dma_axi_awburst (2'b0),
        .dma_axi_wvalid  (1'b0),
        .dma_axi_wready  (),
        .dma_axi_wdata   (64'h0),
        .dma_axi_wstrb   (8'h0),
        .dma_axi_wlast   (1'b0),
        .dma_axi_bvalid  (),
        .dma_axi_bready  (1'b1),
        .dma_axi_bresp   (),
        .dma_axi_bid     (),
        .dma_axi_arvalid (1'b0),
        .dma_axi_arready (),
        .dma_axi_arid    ({pt.DMA_BUS_TAG{1'b0}}),
        .dma_axi_araddr  (32'h0),
        .dma_axi_arsize  (3'b0),
        .dma_axi_arprot  (3'b0),
        .dma_axi_arlen   (8'h0),
        .dma_axi_arburst (2'b0),
        .dma_axi_rvalid  (),
        .dma_axi_rready  (1'b1),
        .dma_axi_rid     (),
        .dma_axi_rdata   (),
        .dma_axi_rresp   (),
        .dma_axi_rlast   (),

        // Clock enables
        .lsu_bus_clk_en  (1'b1),
        .ifu_bus_clk_en  (1'b1),
        .dbg_bus_clk_en  (1'b1),
        .dma_bus_clk_en  (1'b1),

        // ECC errors
        .iccm_ecc_single_error(),
        .iccm_ecc_double_error(),
        .dccm_ecc_single_error(),
        .dccm_ecc_double_error(),
        .dccm_write_readback_error(),

        // Interrupts
        .timer_int       (timer_int),
        .soft_int        (1'b0),
        .extintsrc_req   (extintsrc_req),

        // Perf counters
        .dec_tlu_perfcnt0(),
        .dec_tlu_perfcnt1(),
        .dec_tlu_perfcnt2(),
        .dec_tlu_perfcnt3(),

        // JTAG tied inactive
        .jtag_tck        (1'b0),
        .jtag_tms        (1'b1),
        .jtag_tdi        (1'b0),
        .jtag_trst_n     (1'b0),
        .jtag_tdo        (),
        .jtag_tdoEn      (),

        // MPC debug
        .mpc_debug_halt_req(1'b0),
        .mpc_debug_run_req (1'b0),
        .mpc_reset_run_req (1'b1),
        .mpc_debug_halt_ack(),
        .mpc_debug_run_ack (),
        .debug_brkpt_status(),
        .i_cpu_halt_req    (1'b0),
        .o_cpu_halt_ack    (),
        .o_cpu_halt_status (),
        .o_debug_mode_status(),
        .i_cpu_run_req     (1'b0),
        .o_cpu_run_ack     (),

        // Test mode
        .scan_mode       (1'b0),
        .mbist_mode      (1'b0),

        // DMI
        .dmi_core_enable (1'b1),
        .dmi_uncore_enable(1'b0),
        .dmi_uncore_en   (),
        .dmi_uncore_wr_en(),
        .dmi_uncore_addr (),
        .dmi_uncore_wdata(),
        .dmi_uncore_rdata(32'h0),
        .dmi_active      (),

        // Memory & Cache export interfaces
        .el2_icache_export(el2_icache_export),
        .el2_mem_export   (el2_mem_export)
    );

    // =========================================================================
    // IFU Read-Only Bridge -> IMEM Port A
    // =========================================================================
    logic [31:0] ifu_axil_araddr;
    logic [2:0]  ifu_axil_arprot;
    logic        ifu_axil_arvalid;
    logic        ifu_axil_arready;
    logic [31:0] ifu_axil_rdata;
    logic [1:0]  ifu_axil_rresp;
    logic        ifu_axil_rvalid;
    logic        ifu_axil_rready;

    axi4_to_axi4lite_ro #(.ID_WIDTH(pt.IFU_BUS_TAG)) u_ifu_bridge (
        .aclk          (clk),
        .aresetn       (aresetn),
        .s_axi_arid    (ifu_axi_arid),
        .s_axi_araddr  (ifu_axi_araddr),
        .s_axi_arlen   (ifu_axi_arlen),
        .s_axi_arsize  (ifu_axi_arsize),
        .s_axi_arburst (ifu_axi_arburst),
        .s_axi_arprot  (ifu_axi_arprot),
        .s_axi_arvalid (ifu_axi_arvalid),
        .s_axi_arready (ifu_axi_arready),
        .s_axi_rid     (ifu_axi_rid),
        .s_axi_rdata   (ifu_axi_rdata),
        .s_axi_rresp   (ifu_axi_rresp),
        .s_axi_rlast   (ifu_axi_rlast),
        .s_axi_rvalid  (ifu_axi_rvalid),
        .s_axi_rready  (ifu_axi_rready),
        .m_axil_araddr (ifu_axil_araddr),
        .m_axil_arprot (ifu_axil_arprot),
        .m_axil_arvalid(ifu_axil_arvalid),
        .m_axil_arready(ifu_axil_arready),
        .m_axil_rdata  (ifu_axil_rdata),
        .m_axil_rresp  (ifu_axil_rresp),
        .m_axil_rvalid (ifu_axil_rvalid),
        .m_axil_rready (ifu_axil_rready)
    );

    // =========================================================================
    // LSU Full Bridge -> AXI4-Lite Interconnect
    // =========================================================================
    logic [31:0] lsu_axil_awaddr;
    logic [2:0]  lsu_axil_awprot;
    logic        lsu_axil_awvalid;
    logic        lsu_axil_awready;
    logic [31:0] lsu_axil_wdata;
    logic [3:0]  lsu_axil_wstrb;
    logic        lsu_axil_wvalid;
    logic        lsu_axil_wready;
    logic [1:0]  lsu_axil_bresp;
    logic        lsu_axil_bvalid;
    logic        lsu_axil_bready;
    logic [31:0] lsu_axil_araddr;
    logic [2:0]  lsu_axil_arprot;
    logic        lsu_axil_arvalid;
    logic        lsu_axil_arready;
    logic [31:0] lsu_axil_rdata;
    logic [1:0]  lsu_axil_rresp;
    logic        lsu_axil_rvalid;
    logic        lsu_axil_rready;

    axi4_to_axi4lite #(.ID_WIDTH(pt.LSU_BUS_TAG)) u_lsu_bridge (
        .aclk          (clk),
        .aresetn       (aresetn),
        .s_axi_awid    (lsu_axi_awid),
        .s_axi_awaddr  (lsu_axi_awaddr),
        .s_axi_awlen   (lsu_axi_awlen),
        .s_axi_awsize  (lsu_axi_awsize),
        .s_axi_awburst (lsu_axi_awburst),
        .s_axi_awprot  (lsu_axi_awprot),
        .s_axi_awvalid (lsu_axi_awvalid),
        .s_axi_awready (lsu_axi_awready),
        .s_axi_wdata   (lsu_axi_wdata),
        .s_axi_wstrb   (lsu_axi_wstrb),
        .s_axi_wlast   (lsu_axi_wlast),
        .s_axi_wvalid  (lsu_axi_wvalid),
        .s_axi_wready  (lsu_axi_wready),
        .s_axi_bid     (lsu_axi_bid),
        .s_axi_bresp   (lsu_axi_bresp),
        .s_axi_bvalid  (lsu_axi_bvalid),
        .s_axi_bready  (lsu_axi_bready),
        .s_axi_arid    (lsu_axi_arid),
        .s_axi_araddr  (lsu_axi_araddr),
        .s_axi_arlen   (lsu_axi_arlen),
        .s_axi_arsize  (lsu_axi_arsize),
        .s_axi_arburst (lsu_axi_arburst),
        .s_axi_arprot  (lsu_axi_arprot),
        .s_axi_arvalid (lsu_axi_arvalid),
        .s_axi_arready (lsu_axi_arready),
        .s_axi_rid     (lsu_axi_rid),
        .s_axi_rdata   (lsu_axi_rdata),
        .s_axi_rresp   (lsu_axi_rresp),
        .s_axi_rlast   (lsu_axi_rlast),
        .s_axi_rvalid  (lsu_axi_rvalid),
        .s_axi_rready  (lsu_axi_rready),
        .m_axil_awaddr (lsu_axil_awaddr),
        .m_axil_awprot (lsu_axil_awprot),
        .m_axil_awvalid(lsu_axil_awvalid),
        .m_axil_awready(lsu_axil_awready),
        .m_axil_wdata  (lsu_axil_wdata),
        .m_axil_wstrb  (lsu_axil_wstrb),
        .m_axil_wvalid (lsu_axil_wvalid),
        .m_axil_wready (lsu_axil_wready),
        .m_axil_bresp  (lsu_axil_bresp),
        .m_axil_bvalid (lsu_axil_bvalid),
        .m_axil_bready (lsu_axil_bready),
        .m_axil_araddr (lsu_axil_araddr),
        .m_axil_arprot (lsu_axil_arprot),
        .m_axil_arvalid(lsu_axil_arvalid),
        .m_axil_arready(lsu_axil_arready),
        .m_axil_rdata  (lsu_axil_rdata),
        .m_axil_rresp  (lsu_axil_rresp),
        .m_axil_rvalid (lsu_axil_rvalid),
        .m_axil_rready (lsu_axil_rready)
    );

    // =========================================================================
    // AXI4-Lite Interconnect (1 Master to 9 Slaves)
    // =========================================================================
    localparam int NSLV = 9;

    logic [NSLV-1:0][31:0] s_awaddr, s_araddr, s_wdata, s_rdata;
    logic [NSLV-1:0][2:0]  s_awprot, s_arprot;
    logic [NSLV-1:0][3:0]  s_wstrb;
    logic [NSLV-1:0][1:0]  s_bresp, s_rresp;
    logic [NSLV-1:0]       s_awvalid, s_awready, s_wvalid, s_wready;
    logic [NSLV-1:0]       s_bvalid, s_bready, s_arvalid, s_arready;
    logic [NSLV-1:0]       s_rvalid, s_rready;

    axi4lite_interconnect #(.NSLV(NSLV)) u_interconnect (
        .aclk       (clk),
        .aresetn    (aresetn),
        .m_awaddr   (lsu_axil_awaddr),
        .m_awprot   (lsu_axil_awprot),
        .m_awvalid  (lsu_axil_awvalid),
        .m_awready  (lsu_axil_awready),
        .m_wdata    (lsu_axil_wdata),
        .m_wstrb    (lsu_axil_wstrb),
        .m_wvalid   (lsu_axil_wvalid),
        .m_wready   (lsu_axil_wready),
        .m_bresp    (lsu_axil_bresp),
        .m_bvalid   (lsu_axil_bvalid),
        .m_bready   (lsu_axil_bready),
        .m_araddr   (lsu_axil_araddr),
        .m_arprot   (lsu_axil_arprot),
        .m_arvalid  (lsu_axil_arvalid),
        .m_arready  (lsu_axil_arready),
        .m_rdata    (lsu_axil_rdata),
        .m_rresp    (lsu_axil_rresp),
        .m_rvalid   (lsu_axil_rvalid),
        .m_rready   (lsu_axil_rready),
        .s_awaddr   (s_awaddr),
        .s_awprot   (s_awprot),
        .s_awvalid  (s_awvalid),
        .s_awready  (s_awready),
        .s_wdata    (s_wdata),
        .s_wstrb    (s_wstrb),
        .s_wvalid   (s_wvalid),
        .s_wready   (s_wready),
        .s_bresp    (s_bresp),
        .s_bvalid   (s_bvalid),
        .s_bready   (s_bready),
        .s_araddr   (s_araddr),
        .s_arprot   (s_arprot),
        .s_arvalid  (s_arvalid),
        .s_arready  (s_arready),
        .s_rdata    (s_rdata),
        .s_rresp    (s_rresp),
        .s_rvalid   (s_rvalid),
        .s_rready   (s_rready)
    );

    // =========================================================================
    // Slave 0: IMEM (Dual-Port SRAM, 32 KB at 0x0000_0000)
    // =========================================================================
    axi4lite_sram_dp #(.DEPTH_WORDS(IMEM_DEPTH)) u_imem (
        .aclk       (clk),
        .aresetn    (aresetn),
        // Port A (from IFU bridge)
        .s_a_araddr (ifu_axil_araddr),
        .s_a_arprot (ifu_axil_arprot),
        .s_a_arvalid(ifu_axil_arvalid),
        .s_a_arready(ifu_axil_arready),
        .s_a_rdata  (ifu_axil_rdata),
        .s_a_rresp  (ifu_axil_rresp),
        .s_a_rvalid (ifu_axil_rvalid),
        .s_a_rready (ifu_axil_rready),
        // Port B (from LSU interconnect)
        .s_b_awaddr (s_awaddr[0]),
        .s_b_awprot (s_awprot[0]),
        .s_b_awvalid(s_awvalid[0]),
        .s_b_awready(s_awready[0]),
        .s_b_wdata  (s_wdata[0]),
        .s_b_wstrb  (s_wstrb[0]),
        .s_b_wvalid (s_wvalid[0]),
        .s_b_wready (s_wready[0]),
        .s_b_bresp  (s_bresp[0]),
        .s_b_bvalid (s_bvalid[0]),
        .s_b_bready (s_bready[0]),
        .s_b_araddr (s_araddr[0]),
        .s_b_arprot (s_arprot[0]),
        .s_b_arvalid(s_arvalid[0]),
        .s_b_arready(s_arready[0]),
        .s_b_rdata  (s_rdata[0]),
        .s_b_rresp  (s_rresp[0]),
        .s_b_rvalid (s_rvalid[0]),
        .s_b_rready (s_rready[0])
    );

    // =========================================================================
    // Slave 1: DMEM (Single-Port SRAM, 32 KB at 0x1000_0000)
    // =========================================================================
    axi4lite_sram #(.DEPTH_WORDS(DMEM_DEPTH)) u_dmem (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[1]),
        .s_awprot (s_awprot[1]),
        .s_awvalid(s_awvalid[1]),
        .s_awready(s_awready[1]),
        .s_wdata  (s_wdata[1]),
        .s_wstrb  (s_wstrb[1]),
        .s_wvalid (s_wvalid[1]),
        .s_wready (s_wready[1]),
        .s_bresp  (s_bresp[1]),
        .s_bvalid (s_bvalid[1]),
        .s_bready (s_bready[1]),
        .s_araddr (s_araddr[1]),
        .s_arprot (s_arprot[1]),
        .s_arvalid(s_arvalid[1]),
        .s_arready(s_arready[1]),
        .s_rdata  (s_rdata[1]),
        .s_rresp  (s_rresp[1]),
        .s_rvalid (s_rvalid[1]),
        .s_rready (s_rready[1])
    );

    // =========================================================================
    // Slave 2: UART (Base 0x8000_0000)
    // =========================================================================
    uart #(.FIFO_DEPTH(16)) u_uart (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[2]),
        .s_awprot (s_awprot[2]),
        .s_awvalid(s_awvalid[2]),
        .s_awready(s_awready[2]),
        .s_wdata  (s_wdata[2]),
        .s_wstrb  (s_wstrb[2]),
        .s_wvalid (s_wvalid[2]),
        .s_wready (s_wready[2]),
        .s_bresp  (s_bresp[2]),
        .s_bvalid (s_bvalid[2]),
        .s_bready (s_bready[2]),
        .s_araddr (s_araddr[2]),
        .s_arprot (s_arprot[2]),
        .s_arvalid(s_arvalid[2]),
        .s_arready(s_arready[2]),
        .s_rdata  (s_rdata[2]),
        .s_rresp  (s_rresp[2]),
        .s_rvalid (s_rvalid[2]),
        .s_rready (s_rready[2]),
        .uart_tx  (uart_tx),
        .uart_rx  (uart_rx),
        .irq      (irq_uart)
    );

    // =========================================================================
    // Slave 3: Timer (Base 0x8000_1000)
    // =========================================================================
    timer u_timer (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[3]),
        .s_awprot (s_awprot[3]),
        .s_awvalid(s_awvalid[3]),
        .s_awready(s_awready[3]),
        .s_wdata  (s_wdata[3]),
        .s_wstrb  (s_wstrb[3]),
        .s_wvalid (s_wvalid[3]),
        .s_wready (s_wready[3]),
        .s_bresp  (s_bresp[3]),
        .s_bvalid (s_bvalid[3]),
        .s_bready (s_bready[3]),
        .s_araddr (s_araddr[3]),
        .s_arprot (s_arprot[3]),
        .s_arvalid(s_arvalid[3]),
        .s_arready(s_arready[3]),
        .s_rdata  (s_rdata[3]),
        .s_rresp  (s_rresp[3]),
        .s_rvalid (s_rvalid[3]),
        .s_rready (s_rready[3]),
        .timer_int(timer_int),
        .irq      (irq_timer)
    );

    // =========================================================================
    // Slave 4: GPIO (Base 0x8000_2000)
    // =========================================================================
    logic [NGPIO-1:0] gpio_in;
    logic [NGPIO-1:0] gpio_out;
    logic [NGPIO-1:0] gpio_oe;

    gpio #(.NGPIO(NGPIO)) u_gpio (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[4]),
        .s_awprot (s_awprot[4]),
        .s_awvalid(s_awvalid[4]),
        .s_awready(s_awready[4]),
        .s_wdata  (s_wdata[4]),
        .s_wstrb  (s_wstrb[4]),
        .s_wvalid (s_wvalid[4]),
        .s_wready (s_wready[4]),
        .s_bresp  (s_bresp[4]),
        .s_bvalid (s_bvalid[4]),
        .s_bready (s_bready[4]),
        .s_araddr (s_araddr[4]),
        .s_arprot (s_arprot[4]),
        .s_arvalid(s_arvalid[4]),
        .s_arready(s_arready[4]),
        .s_rdata  (s_rdata[4]),
        .s_rresp  (s_rresp[4]),
        .s_rvalid (s_rvalid[4]),
        .s_rready (s_rready[4]),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out),
        .gpio_oe  (gpio_oe),
        .irq      (irq_gpio)
    );

    // Tri-state GPIO modeling
    genvar gi;
    generate
        for (gi = 0; gi < NGPIO; gi++) begin : gen_gpio_tri
            assign gpio[gi]    = gpio_oe[gi] ? gpio_out[gi] : 1'bz;
            assign gpio_in[gi] = gpio[gi];
        end
    endgenerate

    // =========================================================================
    // Slave 5: I2C Controller (Base 0x8000_3000)
    // =========================================================================
    logic scl_o, scl_oe, sda_o, sda_oe;

    i2c_ctrl u_i2c (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[5]),
        .s_awprot (s_awprot[5]),
        .s_awvalid(s_awvalid[5]),
        .s_awready(s_awready[5]),
        .s_wdata  (s_wdata[5]),
        .s_wstrb  (s_wstrb[5]),
        .s_wvalid (s_wvalid[5]),
        .s_wready (s_wready[5]),
        .s_bresp  (s_bresp[5]),
        .s_bvalid (s_bvalid[5]),
        .s_bready (s_bready[5]),
        .s_araddr (s_araddr[5]),
        .s_arprot (s_arprot[5]),
        .s_arvalid(s_arvalid[5]),
        .s_arready(s_arready[5]),
        .s_rdata  (s_rdata[5]),
        .s_rresp  (s_rresp[5]),
        .s_rvalid (s_rvalid[5]),
        .s_rready (s_rready[5]),
        .scl_i    (i2c_scl),
        .scl_o    (scl_o),
        .scl_oe   (scl_oe),
        .sda_i    (i2c_sda),
        .sda_o    (sda_o),
        .sda_oe   (sda_oe),
        .irq      (irq_i2c)
    );

    // Open-drain I2C modeling
    assign i2c_scl = scl_oe ? 1'b0 : 1'bz;
    assign i2c_sda = sda_oe ? 1'b0 : 1'bz;

    // =========================================================================
    // Slave 6: FIR Filter (Base 0x8000_4000)
    // =========================================================================
    fir_filter #(
        .NTAPS (16),
        .DWIDTH(16),
        .CWIDTH(16),
        .AWIDTH(40)
    ) u_fir (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[6]),
        .s_awprot (s_awprot[6]),
        .s_awvalid(s_awvalid[6]),
        .s_awready(s_awready[6]),
        .s_wdata  (s_wdata[6]),
        .s_wstrb  (s_wstrb[6]),
        .s_wvalid (s_wvalid[6]),
        .s_wready (s_wready[6]),
        .s_bresp  (s_bresp[6]),
        .s_bvalid (s_bvalid[6]),
        .s_bready (s_bready[6]),
        .s_araddr (s_araddr[6]),
        .s_arprot (s_arprot[6]),
        .s_arvalid(s_arvalid[6]),
        .s_arready(s_arready[6]),
        .s_rdata  (s_rdata[6]),
        .s_rresp  (s_rresp[6]),
        .s_rvalid (s_rvalid[6]),
        .s_rready (s_rready[6]),
        .irq      (irq_fir)
    );

    // =========================================================================
    // Slave 7: PWM Generator (Base 0x8000_5000)
    // =========================================================================
    pwm_gen #(
        .NUM_CH(NUM_CH),
        .CWIDTH(16)
    ) u_pwm (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[7]),
        .s_awprot (s_awprot[7]),
        .s_awvalid(s_awvalid[7]),
        .s_awready(s_awready[7]),
        .s_wdata  (s_wdata[7]),
        .s_wstrb  (s_wstrb[7]),
        .s_wvalid (s_wvalid[7]),
        .s_wready (s_wready[7]),
        .s_bresp  (s_bresp[7]),
        .s_bvalid (s_bvalid[7]),
        .s_bready (s_bready[7]),
        .s_araddr (s_araddr[7]),
        .s_arprot (s_arprot[7]),
        .s_arvalid(s_arvalid[7]),
        .s_arready(s_arready[7]),
        .s_rdata  (s_rdata[7]),
        .s_rresp  (s_rresp[7]),
        .s_rvalid (s_rvalid[7]),
        .s_rready (s_rready[7]),
        .pwm_out  (pwm_out),
        .irq      (irq_pwm)
    );

    // =========================================================================
    // Slave 8: Decode Error Slave (Default DECERR)
    // =========================================================================
    axi4lite_err_slave u_err_slave (
        .aclk     (clk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr[8]),
        .s_awprot (s_awprot[8]),
        .s_awvalid(s_awvalid[8]),
        .s_awready(s_awready[8]),
        .s_wdata  (s_wdata[8]),
        .s_wstrb  (s_wstrb[8]),
        .s_wvalid (s_wvalid[8]),
        .s_wready (s_wready[8]),
        .s_bresp  (s_bresp[8]),
        .s_bvalid (s_bvalid[8]),
        .s_bready (s_bready[8]),
        .s_araddr (s_araddr[8]),
        .s_arprot (s_arprot[8]),
        .s_arvalid(s_arvalid[8]),
        .s_arready(s_arready[8]),
        .s_rdata  (s_rdata[8]),
        .s_rresp  (s_rresp[8]),
        .s_rvalid (s_rvalid[8]),
        .s_rready (s_rready[8])
    );

endmodule

