module hdmi_phy (
    input wire clk_serial,  // 126MHz (5x pixel clock)
    input wire clk_pixel,   // 25.2MHz (1x pixel clock)
    input wire [9:0] tmds_d0, input wire [9:0] tmds_d1, input wire [9:0] tmds_d2, input wire [9:0] tmds_clk,
    output wire tmds_clk_p, tmds_clk_n,
    output wire [2:0] tmds_d_p, output wire [2:0] tmds_d_n
);
    // 1. Clock Serializer (Puts the clock signal onto the wire)
    logic clk_serial_out;
    OSER10 #( .GSREN("false"), .LSREN("true") ) ser_c (
        .Q(clk_serial_out),
        .D0(tmds_clk[0]), .D1(tmds_clk[1]), .D2(tmds_clk[2]), .D3(tmds_clk[3]), .D4(tmds_clk[4]),
        .D5(tmds_clk[5]), .D6(tmds_clk[6]), .D7(tmds_clk[7]), .D8(tmds_clk[8]), .D9(tmds_clk[9]),
        .PCLK(clk_pixel), .FCLK(clk_serial), .RESET(1'b0)
    );

    // 2. Data Serializers (R, G, B)
    logic [2:0] data_serial_out;
    genvar i;
    generate
        for (i = 0; i < 3; i++) begin : data_ser
            wire [9:0] data_in = (i==0) ? tmds_d0 : (i==1) ? tmds_d1 : tmds_d2;
            OSER10 #( .GSREN("false"), .LSREN("true") ) ser_d (
                .Q(data_serial_out[i]),
                .D0(data_in[0]), .D1(data_in[1]), .D2(data_in[2]), .D3(data_in[3]), .D4(data_in[4]),
                .D5(data_in[5]), .D6(data_in[6]), .D7(data_in[7]), .D8(data_in[8]), .D9(data_in[9]),
                .PCLK(clk_pixel), .FCLK(clk_serial), .RESET(1'b0)
            );
        end
    endgenerate

    // 3. Output Buffers (TLVDS for Tang Nano 20K)
    // NOTE: This uses TLVDS_OBUF, which is specific to the Gowin Arora family (Nano 20K)
    TLVDS_OBUF tmds_buf_clk (.I(clk_serial_out), .O(tmds_clk_p), .OB(tmds_clk_n));
    TLVDS_OBUF tmds_buf_d0  (.I(data_serial_out[0]), .O(tmds_d_p[0]), .OB(tmds_d_n[0]));
    TLVDS_OBUF tmds_buf_d1  (.I(data_serial_out[1]), .O(tmds_d_p[1]), .OB(tmds_d_n[1]));
    TLVDS_OBUF tmds_buf_d2  (.I(data_serial_out[2]), .O(tmds_d_p[2]), .OB(tmds_d_n[2]));

endmodule