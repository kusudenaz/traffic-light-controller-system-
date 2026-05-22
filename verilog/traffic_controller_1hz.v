`timescale 1ns/1ps

module traffic_controller_1hz #(
    parameter integer T_YEL    = 2,
    parameter integer T_MAIN_G = 20,
    parameter integer T_SIDE_G = 15
)(
    input  wire clk_1hz,
    input  wire reset,

    input  wire night_mode,     // 0: normal, 1: night

    // Ana ışıklar
    output reg  e_r, output reg e_y, output reg e_g,
    output reg  w_r, output reg w_y, output reg w_g,
    output reg  n_r, output reg n_y, output reg n_g,
    output reg  s_r, output reg s_y, output reg s_g,

    // Sağa dönüş: her zaman yanıp sönen kırmızı (ayrı çıkış)
    output reg  e_rt,
    output reg  w_rt,
    output reg  n_rt,
    output reg  s_rt,

    // Debug
    output reg [1:0] dir_state,
    output reg [1:0] phase_state,
    output reg [7:0] sec_in_phase
);

    // Yönler
    localparam [1:0] DIR_E = 2'd0,
                     DIR_W = 2'd1,
                     DIR_N = 2'd2,
                     DIR_S = 2'd3;

    // Fazlar: PRE (sarı), G (yeşil), POST (sarı)
    localparam [1:0] PH_PRE  = 2'd0,
                     PH_G    = 2'd1,
                     PH_POST = 2'd2;

    reg boot;
    reg blink_1s;   // 1 saniyede bir toggle => blink

    function [7:0] green_dur;
        input [1:0] d;
        begin
            if (d == DIR_E || d == DIR_W) green_dur = T_MAIN_G[7:0];
            else                          green_dur = T_SIDE_G[7:0];
        end
    endfunction

    function [7:0] phase_dur;
        input [1:0] d;
        input [1:0] ph;
        begin
            if (ph == PH_G) phase_dur = green_dur(d);
            else            phase_dur = T_YEL[7:0];
        end
    endfunction

    function [1:0] next_dir;
        input [1:0] d;
        begin
            case (d)
                DIR_E:   next_dir = DIR_W;
                DIR_W:   next_dir = DIR_N;
                DIR_N:   next_dir = DIR_S;
                default: next_dir = DIR_E;
            endcase
        end
    endfunction

    // FSM + blink
    always @(posedge clk_1hz or posedge reset) begin
        if (reset) begin
            dir_state    <= DIR_E;
            phase_state  <= PH_PRE;
            sec_in_phase <= 8'd0;
            boot         <= 1'b1;
            blink_1s     <= 1'b0;
        end else begin
            // blink her saniye toggle
            blink_1s <= ~blink_1s;

            // night_mode açıkken FSM'i dondur (blink çalışmaya devam eder)
            if (night_mode) begin
                boot         <= 1'b0;
                sec_in_phase <= 8'd0;
            end else begin
                if (boot) begin
                    boot         <= 1'b0;
                    sec_in_phase <= 8'd0;
                end else begin
                    if (sec_in_phase == (phase_dur(dir_state, phase_state) - 1)) begin
                        sec_in_phase <= 8'd0;

                        if (phase_state == PH_PRE) begin
                            phase_state <= PH_G;
                        end else if (phase_state == PH_G) begin
                            phase_state <= PH_POST;
                        end else begin
                            phase_state <= PH_PRE;
                            dir_state   <= next_dir(dir_state);
                        end
                    end else begin
                        sec_in_phase <= sec_in_phase + 1;
                    end
                end
            end
        end
    end

    // Output decode
    always @(*) begin
        // default: herkes kırmızı
        e_r=1; e_y=0; e_g=0;
        w_r=1; w_y=0; w_g=0;
        n_r=1; n_y=0; n_g=0;
        s_r=1; s_y=0; s_g=0;

        // sağ dönüş: her zaman yanıp sönen kırmızı
        e_rt = blink_1s;
        w_rt = blink_1s;
        n_rt = blink_1s;
        s_rt = blink_1s;

        // NIGHT MODE:
        // - E/W kırmızı BLINK
        // - N/S sarı BLINK
        if (night_mode) begin
            // Ana yollar: kırmızı blink
            e_r = blink_1s; e_y = 0;       e_g = 0;
            w_r = blink_1s; w_y = 0;       w_g = 0;

            // Tali yollar: sarı blink
            n_r = 0;       n_y = blink_1s; n_g = 0;
            s_r = 0;       s_y = blink_1s; s_g = 0;
        end
        else if (boot) begin
            // boot: hepsi kırmızı (default zaten)
        end
        else begin
            // NORMAL MODE: aktif yön yeşil/sarı, diğerleri kırmızı
            case (dir_state)
                DIR_E: begin
                    if (phase_state == PH_G) begin
                        e_r=0; e_g=1;
                    end else begin
                        e_r=0; e_y=1;
                    end
                end

                DIR_W: begin
                    if (phase_state == PH_G) begin
                        w_r=0; w_g=1;
                    end else begin
                        w_r=0; w_y=1;
                    end
                end

                DIR_N: begin
                    if (phase_state == PH_G) begin
                        n_r=0; n_g=1;
                    end else begin
                        n_r=0; n_y=1;
                    end
                end

                default: begin // DIR_S
                    if (phase_state == PH_G) begin
                        s_r=0; s_g=1;
                    end else begin
                        s_r=0; s_y=1;
                    end
                end
            endcase
        end
    end

endmodule
