`timescale 1ns / 1ps

module rec #(parameter WIDTH = 8)(input wire sys_clk,input wire sys_rst_l,input wire uart_REC_dataH,input wire rdy_clr,
    input wire rx_en,output reg rec_readyH,output reg [WIDTH-1:0] rec_dataH,output wire rec_busy);

    // State parameters
    parameter ST_IDLE = 2'b00;
    parameter ST_START = 2'b01;
    parameter ST_DATA = 2'b10;
    parameter ST_STOP = 2'b11;

    reg [1:0] c_st, n_st;
    reg [3:0] sample;
    reg [31:0] bit_count; 
    reg [WIDTH-1:0] data_store; 
    
    /*wire rx_en,tx_en;
    
     baud_clk u_baud_clk (
        .sys_clk (sys_clk),
        .sys_rst_l(sys_rst_l),
        .rx_en (rx_en),
        .tx_en(tx_en)
    );*/

    
    reg rx_ff1, rx_ff2;
    always @(posedge sys_clk or negedge sys_rst_l) begin
        if (!sys_rst_l) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
        end else begin
            rx_ff1 <= uart_REC_dataH;
            rx_ff2 <= rx_ff1;
        end
    end

always @(posedge sys_clk or negedge sys_rst_l) begin
  if (!sys_rst_l)
     c_st <= ST_IDLE;
        else
    c_st <= n_st;
    end


 always @(*) begin
   if (!sys_rst_l) begin
      n_st = ST_IDLE;
      sample = 4'd0;
      bit_count = 32'd0;
      data_store = {WIDTH{1'b0}};
      rec_readyH = 1'b0;
      rec_dataH = {WIDTH{1'b0}};
        end 
        else 
  begin

            
if (rdy_clr)
   rec_readyH = 1'b0;
                
if (rx_en)
        begin
  case (c_st)
                    
ST_IDLE: begin
        sample = 4'd0;
        bit_count = 32'd0;
        if (rx_ff2 == 1'b0) 
        n_st = ST_START;
        else
        n_st = ST_IDLE;
       end
ST_START: begin
    if (sample == 4'd7) begin
      if (rx_ff2 == 1'b0) begin 
        sample = 4'd0;
        data_store = {WIDTH{1'b0}};
        n_st = ST_DATA;
        end 
        else 
        begin 
        n_st = ST_IDLE;
        end
        end 
        else begin
        sample = sample + 1'b1;
        n_st = ST_START;
      end
     end

                    
ST_DATA: begin
   if (sample == 4'd7) begin
     data_store[bit_count] = rx_ff2; 
     sample = sample + 1'b1;
     n_st = ST_DATA;
   end 
   else if (sample == 4'd15) begin
     sample = 4'd0; 
     if (bit_count == (WIDTH - 1)) begin
       bit_count = 32'd0;
       n_st = ST_STOP; 
      end 
      else begin
     bit_count = bit_count + 1'b1;
     n_st = ST_DATA;
     end
     end 
     else begin
    sample = sample + 1'b1;
    n_st = ST_DATA;
  end
 end
ST_STOP: begin
 if (sample == 4'd8) begin
   if (rx_ff2 == 1'b1) begin 
    rec_dataH = data_store;
    rec_readyH = 1'b1;
  end
sample = sample + 1'b1;
n_st = ST_STOP;
end 
else if (sample == 4'd15) begin
sample = 4'd0;
n_st = ST_IDLE;
end else 
begin
sample = sample + 1'b1;
n_st = ST_STOP;
  end
  end

default: n_st = ST_IDLE;

endcase
end else begin
n_st = c_st;
 end
 end
 end

    
assign rec_busy = (c_st != ST_IDLE);

endmodule
