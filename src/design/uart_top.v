`timescale 1ns / 1ps

module top_tb;

reg sys_clk;
reg sys_rst_l;
reg xmitH;
reg [7:0] xmit_dataH;
reg rdy_clr;

wire uart_xmitout;
wire xmit_active;
wire xmit_doneH;
wire rec_readyH;
wire [7:0] rec_dataH;
wire rec_busy;

top uut (
.sys_clk(sys_clk),
.sys_rst_l(sys_rst_l),
.xmitH(xmitH),
.xmit_dataH(xmit_dataH),
.rdy_clr(rdy_clr),
.uart_xmitout(uart_xmitout),
.xmit_active(xmit_active),
.xmit_doneH(xmit_doneH),
.rec_readyH(rec_readyH),
.rec_dataH(rec_dataH),
.rec_busy(rec_busy)
);

always begin
#5 sys_clk = ~sys_clk;
end

initial begin
sys_clk = 0;
sys_rst_l = 0;
xmitH = 0;
xmit_dataH = 8'h00;
rdy_clr = 0;

#100;
sys_rst_l = 1;
#100;

run_loopback_test(8'hA5);
run_loopback_test(8'h5A);
run_loopback_test(8'hFF);
run_loopback_test(8'h00);
run_loopback_test(8'hF0);

#50000;
$finish;
end

task run_loopback_test(input [7:0] target_data);
begin
@(posedge sys_clk);
xmit_dataH = target_data;
xmitH = 1'b1;
#100;
xmitH = 1'b0;

// Wait a fixed amount of simulation time for the packet to send and receive
// 1 bit = 651 * 16 * 10ns = 104,160 ns. A whole frame takes ~1.2 ms.
#1200000;

@(posedge sys_clk);
rdy_clr = 1'b1;
#100;
rdy_clr = 1'b0;
#50000;
end
endtask

endmodule
