`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:11:47 08/02/2018
// Design Name:   top_module
// Module Name:   D:/work/segmentation/clastering/top_module_tb.v
// Project Name:  clastering
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_module
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_module_tb;

	// Inputs
	reg          rst;
	reg          clk;
	reg  [7 : 0] point_x;
	reg  [7 : 0] point_y;
	reg          valid_p;
	reg          sop_p;
	reg          eop_p;
	
	wire [7 : 0] point_indx;    // index of point
	wire         point_indx_vld;// index of point valid
	wire [7 : 0] n_cluster;     // number of cluster
	
	wire         ready_nd;
	wire [7 : 0] N_p;

	// Instantiate the Unit Under Test (UUT)
	top_module uut (
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
	
	localparam N = 21;
	integer    fidR, fidC;
		
	reg  [7 : 0] address;
	reg  rst_m;

	reg  [7 : 0] x_point_mem [0 : N - 1];
	initial $readmemh("hdl_files/x_point.txt", x_point_mem, 0, N - 1);
	reg  [7 : 0] y_point_mem [0 : N - 1];
	initial $readmemh("hdl_files/y_point.txt", y_point_mem, 0, N - 1);
	
	
	`define PERIOD 5      // 100 MHz clock 
	
	initial begin
     clk       <= 0;                              
     forever #(`PERIOD)  clk =  ! clk; 
    end
	
	 
	event reset_trigger;
    event reset_done_trigger;
	
	initial begin 
         rst    <= 1;
         @ (reset_trigger); 
         @ (posedge clk) rst <= 1;             
         repeat (20) begin
         @ (posedge clk); 
         end 
         rst = 0;
          -> reset_done_trigger;
    end 
	
	always @(posedge clk) if(rst_m) address <= 0; else if(address == N) address <= N; else address <= address + 1;
	
	always @(*)if(rst_m) point_x = 0; else point_x = x_point_mem[address];
	always @(*)if(rst_m) point_y = 0; else point_y = y_point_mem[address];
	
	always @(*)if(rst_m) valid_p = 0; else valid_p = (address < N)   ? 1'b1 : 1'b0;
	always @(*)if(rst_m) sop_p   = 0; else if (address == 0)  sop_p = 1'b1; else sop_p = 1'b0;
	always @(*)if(rst_m) eop_p   = 0; else if (address == N-1)eop_p = 1'b1; else eop_p = 1'b0;
	
	
	
	reg [7 : 0] p_cnt;
	always @(posedge clk) if(ready_nd)p_cnt <= 8'd0; else if (point_indx_vld)p_cnt <= p_cnt + 1;
		
	

	initial begin
		// Initialize Inputs
	fidR = $fopen("hdl_files/index_point.txt","w");
	fidC = $fopen("hdl_files/index_cluster.txt","w");

		  rst_m = 1'b1;
		->reset_trigger;
		@(reset_done_trigger);
		repeat (20) begin
        @ (posedge clk); 
        end 
		 rst_m = 1'b0;
		repeat (N+1) begin
        @ (posedge clk); 
        end 
		rst_m = 1'b1;
		repeat (10) @ (posedge clk); 
		
		while (p_cnt <= N - 1)begin
			
			if(point_indx_vld)begin
			$fwrite(fidR, "%d \n", point_indx);
			$fwrite(fidC, "%d \n", n_cluster);
			end 
			@(posedge clk);	
			
		end
		
		@ (ready_nd); 
		
		repeat (100) @ (posedge clk);
		 rst_m = 1'b0;
		repeat (N+1) begin
        @ (posedge clk); 
        end 
		rst_m = 1'b1;
		// Wait 100 ns for global reset to finish
		#20000;
						$fclose(fidR);
							$fclose(fidC);

		$stop;
        
		// Add stimulus here

	end
      
endmodule

