`timescale 1ns / 1ps


////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek LLC
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 02/08/18
// Design Name: point_bram
////////////////////////////////////////////////////////////////////////////////

module distance(
    input rst,
    input clk,
    input [7:0] x_0,
    input [7:0] x_1,
    input [7:0] y_0,
    input [7:0] y_1,
    output [15:0] sq_distance
    );
	 
	 reg signed [8 :0] reg_a, reg_c;
	 reg signed [16:0] reg_b, reg_d, reg_out;
	 assign sq_distance = (reg_out >> 1);
	 
	 always @(posedge clk)
		if(rst) begin
			reg_a <= 0;
			reg_b <= 0;
		end else begin
		   reg_a <= x_0 - x_1;
			reg_b <= reg_a * reg_a;		
		end
		
	 always @(posedge clk)
		if(rst) begin
			reg_c <= 0;
			reg_d <= 0;
		end else begin
		   reg_c <= y_0 - y_1;
			reg_d <= reg_c * reg_c;		
		end
		
	always @(posedge clk)if(rst) reg_out <= 0; else reg_out <= reg_d + reg_b;


endmodule
