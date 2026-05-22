`timescale 1ns / 1ps
module uart_tx #(parameter WIDTH = 8)( 
    input wire sys_clk,input wire sys_rst_l,input wire xmitH,input wire rx_en,
    input wire [WIDTH-1:0] xmit_dataH,output reg uart_XMIT_dataH,output wire xmit_active, 
    output wire xmit_doneH);
  

    // State parameters
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;
//    parameter baud=9600;
//    parameter sys_clk=100000000;

    reg [1:0] c_st, n_st;
    reg [31:0] bit_count;
    reg [3:0] count; 
    reg [WIDTH-1:0] data_reg; 

 /*baud_clk u_baud_clk (
        .sys_clk (sys_clk),
        .sys_rst_l(sys_rst_l),
        .rx_en (rx_en),
        .tx_en(tx_en)
    );*/

    
   always @(posedge sys_clk or negedge sys_rst_l) begin
        if (!sys_rst_l)
            c_st <= IDLE;
        else
            c_st <= n_st;
    end

   always @(*) begin
    if (!sys_rst_l) begin
      n_st = IDLE;
      uart_XMIT_dataH = 1'b1; 
      bit_count = 32'd0;
      data_reg = {WIDTH{1'b0}};
     count=4'd0;
    end else  
    begin 
   case (c_st)

IDLE: begin
     uart_XMIT_dataH = 1'b1; 
     if (xmitH) 
     begin
        data_reg = xmit_dataH;
        bit_count = 32'd0;
        n_st = START;
        count=4'd0;
        end 
        else
        n_st = IDLE;
      end 

START: begin
         uart_XMIT_dataH = 1'b0;
         if(rx_en)
          begin
            count=count+1;
            if(count==4'd15)
            begin 
            n_st = DATA;
            count=4'd0;
            end
          end
        end

DATA: begin
      uart_XMIT_dataH = data_reg[bit_count]; 
       if(rx_en)
           begin
           count=count+1;
           if(count==4'd15)
           begin
           if(bit_count == (WIDTH - 1)) 
             begin
             bit_count = 32'd0;
             n_st = STOP;
             end else begin
             bit_count = bit_count + 1'b1;
             n_st = DATA;
             end
             count=4'd0;
            end
                    
          end
         end             

STOP: begin
           uart_XMIT_dataH = 1'b1;
        if(rx_en)
           begin
         count=count+1;
          if(count==4'd15)
             begin
                n_st = IDLE;
                count=4'd0;
                end
                    
                end
                end

default: begin
     uart_XMIT_dataH = 1'b1;
     n_st = IDLE;
                end

            endcase
        end
    end

assign xmit_active = (c_st != IDLE); 
assign xmit_doneH = (c_st == IDLE)||(c_st == STOP); 

endmodule
