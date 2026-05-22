`timescale 1ns / 1ps

module baud_clk #(parameter SYS_CLK_FREQ = 100000000, parameter BAUD_RATE = 9600)(input wire sys_clk,input wire sys_rst_l,output reg rx_en,tx_en );

localparam RX_MAX = (SYS_CLK_FREQ / (BAUD_RATE * 16)) - 1;

reg [13:0] tx_count;
reg [31:0] rx_count;

//always @(posedge sys_clk or negedge sys_rst_l) begin
//    if (!sys_rst_l) begin
//        tx_count <= 14'd0;
//        tx_en <= 1'b0;
//    end else begin
//        if (tx_count == 14'd10415) begin
//            tx_count <= 14'd0;
//            tx_en <= 1'b1; 
//        end else begin
//            tx_count <= tx_count + 1'b1;
//            tx_en <= 1'b0;
//        end
//    end
//end


always @(posedge sys_clk or negedge sys_rst_l) begin
    if (!sys_rst_l) begin
        rx_count <= 32'd0;
        rx_en <= 1'b0;
    end else begin
        if (rx_count==RX_MAX) begin
            rx_count <=32'd0;
            rx_en <=1'b1; 
        end else begin
            rx_count <= rx_count + 1'b1;
            rx_en <= 1'b0;
        end
    end
end
 
endmodule
