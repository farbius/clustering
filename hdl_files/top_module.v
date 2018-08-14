`timescale 1ns / 1ps


////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek LLC
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 02/08/18
// Design Name: top_module
////////////////////////////////////////////////////////////////////////////////


module top_module(
    input        rst,
    input        clk,
    input [7:0]  point_x,
    input [7:0]  point_y,
    input        valid_p,
    input        sop_p,
    input        eop_p,
	
	output  [7 : 0]  point_indx,    // index of point
	output           point_indx_vld,// index of point valid
	output  [7 : 0]  n_cluster,     // number of cluster
	 
	output       ready_nd,
	output [7:0] N_p
    );
	 

	 point_bram point_bram_i(
    .rst(rst),
    .clk(clk),
    .point_x(point_x),
    .point_y(point_y),
    .valid_p(valid_p),
    .sop_p(sop_p),
    .eop_p(eop_p),
	.point_indx(point_indx),
	.point_indx_vld(point_indx_vld),
	.n_cluster(n_cluster),
	.ready_nd(ready_nd),
	.N_p(N_p)
	 );

endmodule
