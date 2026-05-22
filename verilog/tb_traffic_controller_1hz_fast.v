`timescale 1ns/1ps

module tb_traffic_controller_1hz_fast;

  // Simde 1 saniye = 10ns
  localparam integer SIM_SEC_NS  = 10;
  localparam integer HALF_PER_NS = SIM_SEC_NS/2;

  reg clk_1hz;
  reg reset;
  reg night_mode;

  wire e_r,e_y,e_g, w_r,w_y,w_g, n_r,n_y,n_g, s_r,s_y,s_g;
  wire e_rt, w_rt, n_rt, s_rt;
  wire [1:0] dir_state, phase_state;
  wire [7:0] sec_in_phase;

  traffic_controller_1hz dut (
    .clk_1hz(clk_1hz),
    .reset(reset),
    .night_mode(night_mode),

    .e_r(e_r), .e_y(e_y), .e_g(e_g),
    .w_r(w_r), .w_y(w_y), .w_g(w_g),
    .n_r(n_r), .n_y(n_y), .n_g(n_g),
    .s_r(s_r), .s_y(s_y), .s_g(s_g),

    .e_rt(e_rt), .w_rt(w_rt), .n_rt(n_rt), .s_rt(s_rt),

    .dir_state(dir_state),
    .phase_state(phase_state),
    .sec_in_phase(sec_in_phase)
  );

  // Clock
  initial begin
    clk_1hz = 1'b0;
    forever #HALF_PER_NS clk_1hz = ~clk_1hz;
  end

  // Reset
  initial begin
    reset = 1'b1;
    night_mode = 1'b0;
    repeat (2) @(posedge clk_1hz);
    reset = 1'b0;
  end

  // Log (her saniye)
  always @(posedge clk_1hz) begin
    $display("t=%0t | night=%0d | dir=%0d phase=%0d sec=%0d | E=%0d%0d%0d W=%0d%0d%0d N=%0d%0d%0d S=%0d%0d%0d | RT(EWNS)=%0d%0d%0d%0d",
             $time, night_mode, dir_state, phase_state, sec_in_phase,
             e_r,e_y,e_g, w_r,w_y,w_g, n_r,n_y,n_g, s_r,s_y,s_g,
             e_rt,w_rt,n_rt,s_rt);
  end

  initial begin
    @(negedge reset);

    // --- 1) NORMAL MODE: 2 tam tur (4 fazın hepsi kesin görünür) ---
    // 1 tur ~ 86 sn => 2 tur ~ 172 sn
    $display("===== NORMAL MODE: 2 FULL CYCLES START (t=%0t) =====", $time);
    night_mode = 1'b1;
    repeat (180) @(posedge clk_1hz);

    // --- 2) NIGHT MODE: 20 sn açık kalsın ---
    $display("===== NIGHT MODE ON (t=%0t) =====", $time);
    night_mode = 1'b1;
    repeat (20) @(posedge clk_1hz);

    // --- 3) NORMAL MODE: tekrar 1 tur izleyelim ---
    $display("===== NIGHT MODE OFF (t=%0t) =====", $time);
    night_mode = 1'b0;
    repeat (100) @(posedge clk_1hz);

    $display("TB finished.");
    $finish;
  end

endmodule
