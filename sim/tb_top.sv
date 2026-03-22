// Minimal Verilator testbench for CV32E40S
module tb_top (
  input logic clk,
  input logic rst_n
);
  import cv32e40s_pkg::*;

  // OBI instruction interface
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // OBI data interface
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic [31:0] data_addr;
  logic [3:0]  data_be;
  logic        data_we;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  // Fence.i
  logic fencei_flush_req;
  logic fencei_flush_ack;

  // ---------------------------------------------------------------
  // Unified memory: 256KB at 0x80000000
  // ---------------------------------------------------------------
  localparam MEM_SIZE  = 256 * 1024;  // bytes
  localparam MEM_WORDS = MEM_SIZE / 4;
  localparam MEM_BASE  = 32'h8000_0000;
  localparam MEM_MASK  = MEM_SIZE - 1;
  localparam TOHOST_ADDR = 32'h8000_1000;

  logic [31:0] mem [0:MEM_WORDS-1];
  integer cycle_count;
  logic [31:0] last_pc;
  logic done;

  initial begin
    $readmemh("firmware.hex", mem);
  end

  // ---------------------------------------------------------------
  // Instruction OBI responder (1-cycle grant, 1-cycle response)
  // ---------------------------------------------------------------
  assign instr_gnt = instr_req;  // always grant immediately

  logic        instr_rvalid_q;
  logic [31:0] instr_rdata_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      instr_rvalid_q <= 1'b0;
      instr_rdata_q  <= 32'h0;
    end else begin
      instr_rvalid_q <= instr_req & instr_gnt;
      if (instr_req & instr_gnt)
        instr_rdata_q <= mem[(instr_addr & MEM_MASK) >> 2];
      else
        instr_rdata_q <= 32'h0;
    end
  end

  assign instr_rvalid = instr_rvalid_q;
  assign instr_rdata  = instr_rdata_q;

  // Track a simple "PC" based on the last instruction fetch address.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cycle_count <= 0;
      last_pc <= MEM_BASE;
      done <= 1'b0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (instr_req & instr_gnt) begin
        last_pc <= instr_addr;
      end
    end
  end

  // ---------------------------------------------------------------
  // Data OBI responder (1-cycle grant, 1-cycle response)
  // ---------------------------------------------------------------
  assign data_gnt = data_req;  // always grant immediately

  logic        data_rvalid_q;
  logic [31:0] data_rdata_q;
  logic [31:0] data_addr_q;
  logic [3:0]  data_be_q;
  logic        data_we_q;
  logic [31:0] data_wdata_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_rvalid_q <= 1'b0;
      data_rdata_q  <= 32'h0;
      data_addr_q   <= 32'h0;
      data_be_q     <= 4'h0;
      data_we_q     <= 1'b0;
      data_wdata_q  <= 32'h0;
    end else begin
      data_rvalid_q <= data_req & data_gnt;
      data_addr_q   <= data_addr;
      data_be_q     <= data_be;
      data_we_q     <= data_we;
      data_wdata_q  <= data_wdata;
      if (data_req & data_gnt)
        data_rdata_q <= mem[(data_addr & MEM_MASK) >> 2];
      else
        data_rdata_q <= 32'h0;
    end
  end

  assign data_rvalid = data_rvalid_q;
  assign data_rdata  = data_rdata_q;

  // Byte-enable write on response phase
  wire [31:0] data_word_addr = (data_addr_q & MEM_MASK) >> 2;
  always_ff @(posedge clk) begin
    if (data_rvalid_q && data_we_q) begin
      if (data_be_q[0]) mem[data_word_addr][ 7: 0] <= data_wdata_q[ 7: 0];
      if (data_be_q[1]) mem[data_word_addr][15: 8] <= data_wdata_q[15: 8];
      if (data_be_q[2]) mem[data_word_addr][23:16] <= data_wdata_q[23:16];
      if (data_be_q[3]) mem[data_word_addr][31:24] <= data_wdata_q[31:24];

      if (!done && data_addr_q == TOHOST_ADDR) begin
        done <= 1'b1;
        $display("RESULT_SIM %0d", data_wdata_q);
        $display("PC_VALID 1");
        $display("PC_VALUE %032b", last_pc);
        $display("NUM_CYCLES %0d", cycle_count);
        $finish;
      end
    end
  end

  // ---------------------------------------------------------------
  // Fence.i flush handshake (ack 1 cycle after req)
  // ---------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      fencei_flush_ack <= 1'b0;
    else
      fencei_flush_ack <= fencei_flush_req;
  end

  // ---------------------------------------------------------------
  // Tohost detection (address 0x80001000)
  // ---------------------------------------------------------------
  localparam TOHOST_ADDR = 32'h8000_1000;
  localparam TOHOST_WORD = (TOHOST_ADDR & MEM_MASK) >> 2;

  always_ff @(posedge clk) begin
    if (data_rvalid_q && data_we_q && data_addr_q == TOHOST_ADDR) begin
      if (data_wdata_q == 32'h1) begin
        $display("*** PASS ***");
        $finish;
      end else begin
        $display("*** FAIL *** (tohost = 0x%08x)", data_wdata_q);
        $finish;
      end
    end
  end

  // ---------------------------------------------------------------
  // Core instantiation
  // ---------------------------------------------------------------
  cv32e40s_core #(
    .LIB              (0),
    .RV32             (RV32I),
    .B_EXT            (B_NONE),
    .M_EXT            (M),
    .DEBUG            (0),
    .CLIC             (0),
    .PMP_NUM_REGIONS  (0),
    .PMA_NUM_REGIONS  (0),
    .DBG_NUM_TRIGGERS (0),
    .LFSR0_CFG        ('{coeffs: 32'hB800_0001, default_seed: 32'h0000_0001}),
    .LFSR1_CFG        ('{coeffs: 32'hD000_0001, default_seed: 32'hA5A5_A5A5}),
    .LFSR2_CFG        ('{coeffs: 32'hF800_0001, default_seed: 32'h5A5A_5A5A})
  ) core_i (
    .clk_i              (clk),
    .rst_ni             (rst_n),
    .scan_cg_en_i       (1'b0),

    // Static config
    .boot_addr_i        (MEM_BASE),
    .dm_exception_addr_i(32'h0),
    .dm_halt_addr_i     (32'h0),
    .mhartid_i          (32'h0),
    .mimpid_patch_i     (4'h0),
    .mtvec_addr_i       (32'h0000_0001),

    // Instruction OBI
    .instr_req_o        (instr_req),
    .instr_gnt_i        (instr_gnt),
    .instr_rvalid_i     (instr_rvalid),
    .instr_addr_o       (instr_addr),
    .instr_memtype_o    (),
    .instr_prot_o       (),
    .instr_dbg_o        (),
    .instr_rdata_i      (instr_rdata),
    .instr_err_i        (1'b0),

    // Instruction OBI parity (inverted)
    .instr_reqpar_o     (),
    .instr_gntpar_i     (~instr_gnt),
    .instr_rvalidpar_i  (~instr_rvalid),
    .instr_achk_o       (),
    .instr_rchk_i       (5'h0),

    // Data OBI
    .data_req_o         (data_req),
    .data_gnt_i         (data_gnt),
    .data_rvalid_i      (data_rvalid),
    .data_addr_o        (data_addr),
    .data_be_o          (data_be),
    .data_we_o          (data_we),
    .data_wdata_o       (data_wdata),
    .data_memtype_o     (),
    .data_prot_o        (),
    .data_dbg_o         (),
    .data_rdata_i       (data_rdata),
    .data_err_i         (1'b0),

    // Data OBI parity (inverted)
    .data_reqpar_o      (),
    .data_gntpar_i      (~data_gnt),
    .data_rvalidpar_i   (~data_rvalid),
    .data_achk_o        (),
    .data_rchk_i        (5'h0),

    // Cycle count
    .mcycle_o           (),

    // Interrupts (all disabled)
    .irq_i              (32'h0),
    .wu_wfe_i           (1'b0),
    .clic_irq_i         (1'b0),
    .clic_irq_id_i      (5'h0),
    .clic_irq_level_i   (8'h0),
    .clic_irq_priv_i    (2'h0),
    .clic_irq_shv_i     (1'b0),

    // Fence.i
    .fencei_flush_req_o (fencei_flush_req),
    .fencei_flush_ack_i (fencei_flush_ack),

    // Security alerts (unused)
    .alert_minor_o      (),
    .alert_major_o      (),

    // Debug (disabled)
    .debug_req_i        (1'b0),
    .debug_havereset_o  (),
    .debug_running_o    (),
    .debug_halted_o     (),
    .debug_pc_valid_o   (),
    .debug_pc_o         (),

    // CPU control
    .fetch_enable_i     (1'b1),
    .core_sleep_o       ()
  );

endmodule
