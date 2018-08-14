`timescale 1ns / 1ps


////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek LLC
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 02/08/18
// Design Name: point_bram
////////////////////////////////////////////////////////////////////////////////


module point_bram(
    input 			 rst,			// reset
    input 			 clk,			// clk
    input   [7 : 0]  point_x,		// x coordinate wire
    input   [7 : 0]  point_y,		// y coordinate wire
    input 			 valid_p,		// valid point
    input 			 sop_p,		    // start of point packet
    input 			 eop_p,		    // end of point packet
	output           ready_nd,      // ready for a new data
		
	output  [7 : 0]  point_indx,    // index of point
	output           point_indx_vld,// index of point valid
	output  [7 : 0]  n_cluster,     // number of cluster
	
	output  [7 : 0]  N_p			// amount of points
    );
	 
	 reg 	[7 : 0]  current_ptr;    // bram write/read address
	 reg    [7 : 0]  next_ptr;
	 reg    [7 : 0]  next_ptr_r;     // delayed next ptr
	 wire   [7 : 0]  crnt_ptr_wr;
	 
	 wire   [15: 0]  sq_distance;
	 
	 localparam      Dmin = 16'd100; // min distance for points	 
	 
	 reg    [15: 0]  Ndist;
	 
	 // test 	 
	 wire	[15: 0]  xy_point_1a;	 // point out from 1st bram
	 wire	[15: 0]  xy_point_1b;	 // point out from 2nd bram

	 reg 	[7 : 0]  counter_p;		 // point counter
	 reg    [7 : 0]  N_p_reg;	 	 
	 
	 assign          N_p = N_p_reg;
	 
	 /******************************************/
	 // registers for cluster computing fsm
	 reg 	[15 : 0] 	mDist_reg;
	 reg 	[15 : 0] 	c_word;
	 reg 	[15 : 0] 	dist_ptr;
	 reg    [7  : 0]    cluster_num;
	 reg    [7  : 0]	cluster_size;
	 reg    [7  : 0]    c_ptr, n_ptr;           // current and next pointer for reading distances
	 reg    [7  : 0]    points_used;            // register for counting of used points
	 reg    [31 : 0]    points_marking;         // bit-oriented list of points
	 
	 
	reg		[15 : 0] 	min_point_dist;
	reg     [07 : 0]    point_dist;
	wire                point_rd_vld;
	wire    [07 : 0]    point_rd_indx;
	

	 
	 parameter     idle_c  = 3'b001;	// store dist and look for d_min
     parameter  cluster_c  = 3'b010;	// assign number for current cluster
	 parameter    up_addr  = 3'b011;   // start list distances for pointers with min distance
	 parameter    dn_addr  = 3'b100;   // start list distances for pointers with min distance
	 parameter  dist_sort  = 3'b101;   // look for next min distance 
	 parameter      pause  = 3'b110;   // pause for reading
	 
	
	 (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [2:0] state_c =idle_c;
	 
	 /*****************************************/
	 
	 wire   [7 : 0]  a_addr_1i2i = (valid_p) ? counter_p : next_ptr_r-1;  /////////////!!!!!!!!!!!!!
	 wire   [7 : 0]  b_addr_1i2i = (!point_rd_vld) ? current_ptr : point_rd_indx;                        

	 
	 BRAM_Memory #(8) BRAM_Memory_1i (.a_clk(clk), .a_wr(valid_p), .a_addr(a_addr_1i2i), .a_data_in({point_x, point_y}), .a_data_out(xy_point_1a), 
     .b_clk(clk), .b_wr(1'b0), .b_addr(b_addr_1i2i), .b_data_in(16'd0), .b_data_out(xy_point_1b), .b_data_en(1'b1));
	
	
	always @(posedge clk)if(rst|eop_p)counter_p <= 0; else if (valid_p)counter_p <= counter_p + 1;	
	always @(posedge clk)if(rst)        N_p_reg <= 0; else if (eop_p)    N_p_reg <= counter_p;
	always @(posedge clk)if(rst)     next_ptr_r <= 0; else            next_ptr_r <= next_ptr;
	always @(posedge clk)if(rst)     Ndist      <= 0; else if (eop_p)      Ndist <= counter_p * (counter_p + 1)/2;
	
	
	/**********************************************************/
	/*************** fsm for calculation distances ************/
	// eop_p - signal to start calculation distances
	// next_ptr, next_ptr_r(delayed) - first point 
	// current_ptr                   - list of points
	// fsm description: - wait for eop_p signal
	//                  - read one point (next_ptr) and one by one , second point(current_ptr)
	//                  - stop and switch input bram, when next_ptr is reached N_p_reg (amount of point pairs)
	
   parameter idle   = 3'b001;
   parameter read   = 3'b010;
   parameter switch = 3'b100;
   
   reg sq_dst_vld ;


   
   (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [2:0] state =idle;

   always@(posedge clk)
      if (rst) begin
          state 	<= 	idle;
	   current_ptr 	<= 	8'd0;
	   next_ptr	    <= 	8'd1;
		sq_dst_vld  <= 0;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *)case (state)
            idle : begin
               if (eop_p) begin
			   state <= read;
		 current_ptr <= next_ptr;
		  sq_dst_vld <= 1'b1;
		 
			   end	else begin
			   state <= idle;
		  sq_dst_vld <= 1'b0;
		       end
			   
            end
			
            read : begin
               if (current_ptr == N_p_reg - 1)begin
                  state <= switch;
			   next_ptr <= next_ptr + 1;
               end else               
				  state <= read;				  
				current_ptr <= current_ptr + 1;
            end
			
            switch : begin		
               if (next_ptr == N_p_reg)begin
                  state <= idle;  
               next_ptr	<= 8'd1;			   
               end else begin
                  state <= read;
			   end				  
		   current_ptr  <= next_ptr;
            end           
         endcase
		 
    /**********************************************************/
	/**********************************************************/	 
	
	
	// distance for storing
	
	reg 	[5 : 0] 	 sh_valid_p;	
	wire                 vld_shifted = sh_valid_p[3];
	always @(posedge clk) if(rst) sh_valid_p <= 0; else sh_valid_p <= {sh_valid_p[4:0], sq_dst_vld};
	
	reg 	[31 : 0] 	 shift_point1st;	
	wire    [7  : 0]     point1st_shifted = shift_point1st[31 : 24];
	always @(posedge clk) if(rst) shift_point1st <= 0; else shift_point1st <= {shift_point1st[23:0], a_addr_1i2i};
	
	reg 	[31 : 0] 	 shift_point2nd;	
	wire    [7  : 0]     point2nd_shifted = shift_point2nd[31 : 24];
	always @(posedge clk) if(rst) shift_point2nd <= 0; else shift_point2nd <= {shift_point2nd[23:0], current_ptr};
	
	distance distance_i(.rst(rst),.clk(clk),.x_0(xy_point_1a[15:8]),.x_1(xy_point_1b[15:8]),.y_0(xy_point_1a[7:0]),.y_1(xy_point_1b[7:0]),.sq_distance(sq_distance));
	
    reg                  flag_intrpt_up_reg;  // flag interrupt 
	reg                  flag_intrpt_dn_reg;  // flag interrupt 
	reg     [15: 0]      points_xy;	          // coordinates of two points with min distance
	
	wire                 wr_ones;
	reg                  wr_ones_r;
	
	reg                  wr_ones_reg;
	reg                  wr_ones_reg_reg;

	reg     [15 : 0]     dist_bram_b_addr_reg;
	wire    [15 : 0]     dist_bram_b_addr      = (wr_ones) ? dist_bram_b_addr : {n_ptr, c_ptr};
	wire    [15 : 0]     dist_bram_b_data_out;
	
		
	wire 	[15 : 0]     dist_bram_a_addr      = (vld_shifted) ? {point1st_shifted, point2nd_shifted} : (wr_ones_reg) ? points_xy : {n_ptr, c_ptr};
	wire    [15 : 0]     dist_bram_a_data_in   = (vld_shifted) ?  sq_distance                         : 16'hFFFF;
	
	wire                 dist_bram_a_wr        = ((state_c == up_addr || state_c == dn_addr || state_c == pause) && !wr_ones) ? 1'b1 : vld_shifted;
	


	BRAM_Memory #(16) BRAM_Memory_dist (.a_clk(clk), .a_wr(dist_bram_a_wr), .a_addr(dist_bram_a_addr), .a_data_in(dist_bram_a_data_in), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(dist_bram_b_addr), .b_data_in(16'd0), .b_data_out(dist_bram_b_data_out), .b_data_en(1'b1));
   
    /**********************************************************/
	/********************* fsm clustering *********************/
	//
	//
	// fsm description: - wait for eop_p signal to start;
	//					- look for min distance and check whether one is less then Dmin;
	//                  - read all distances again for finding ;
	
	reg 	[15: 0]		x_sum, reg_x_sum;
	reg		[15: 0]		y_sum, reg_y_sum;
	reg 				pipline_sum;
	reg                 dist_bram_b_rd;
	reg                 bram_b_rd_reg;
	reg                 flag_point;      // 1-st or 2-nd point is processed
	reg                 flag_intrpt_up;  // flag interrupt 
	reg                 flag_intrpt_dn;  // flag interrupt 

	reg     [7 : 0]     interrupt_ptr; 
	reg     [7 : 0]     store_c_ptr; 
	reg     [7 : 0]     store_n_ptr;
	reg     [7 : 0]     point_num;       // number of point to add 
	reg                 point_add_flag;  // adding point into cluster
	reg                 ready;
	reg                 cl_end;          // finish clustering
	
	wire                flag_intrpt = flag_intrpt_up_reg || flag_intrpt_dn_reg || flag_intrpt_dn || flag_intrpt_up;
	
	assign              wr_ones = (!flag_intrpt && state_c != dist_sort  && bram_b_rd_reg && dist_bram_b_data_out < (Dmin*Dmin)/2) ? 1'b1 : 1'b0;
	assign              ready_nd = ready;
	


	always@(posedge clk) if (rst)flag_intrpt_up_reg       <= 1'd0; else flag_intrpt_up_reg <= flag_intrpt_up;
	always@(posedge clk) if (rst)flag_intrpt_dn_reg       <= 1'd0; else flag_intrpt_dn_reg <= flag_intrpt_dn;
	
	always@(posedge clk) if (rst)bram_b_rd_reg            <= 1'd0; else if (state_c == up_addr || state_c == dn_addr || state_c == pause && !wr_ones_reg) bram_b_rd_reg <= 1'b1;else bram_b_rd_reg <= 1'd0;
	always@(posedge clk) if (rst)dist_bram_b_rd           <= 1'd0; else           dist_bram_b_rd <= bram_b_rd_reg;
	always@(posedge clk) if (rst)dist_bram_b_addr_reg     <= 1'd0; else     dist_bram_b_addr_reg <= {n_ptr, c_ptr};


      always@(posedge clk)
      if (rst) begin
	  
            state_c 	<= 	idle_c;
		     c_word     <= 16'd0;
		cluster_num     <=  8'h00;
	   cluster_size     <=  8'h00;
	      point_num     <=  8'd0;
	   
			  x_sum     <= 16'd0;
			  y_sum     <= 16'd0;
		  reg_x_sum     <= 16'd0;
		  reg_y_sum     <= 16'd0;
		pipline_sum     <=  1'b0;
		
          points_xy     <= 16'd0;
		wr_ones_reg     <=  1'b0;
		      ready     <=  1'b1;
		
		      c_ptr     <=  8'd0;
			  n_ptr     <=  8'd0;
		store_c_ptr     <=  8'd0;
		store_n_ptr     <=  8'd0;
			  
		 flag_point     <=  1'b0;
	 flag_intrpt_up     <=  1'b0;
	 flag_intrpt_dn		<=  1'b0;
	  interrupt_ptr     <=  8'd0;
	 point_add_flag     <=  1'b0;
	 
	        cl_end      <= 1'b0;
	   
      end
      else
         (* FULL_CASE, PARALLEL_CASE *)case (state_c)
		 
            idle_c : begin
                if(vld_shifted)begin					
					c_word <= c_word + 1;
					 ready <= 1'b0;
				end
				
				if(c_word == Ndist - 1) state_c <= cluster_c;
				else                    state_c <= idle_c;
				
				cluster_num     <=  8'h00;
				     cl_end     <= 1'b0;
				
			   
            end
			
					
			cluster_c : begin	
			
			
				 flag_point <= 1'b0;
				  points_xy <= dist_ptr;
				      n_ptr <= dist_ptr[15:8];
				     c_word <= 16'd0;
				
				if (mDist_reg ==  16'hFFFF || mDist_reg > (Dmin*Dmin)/2) begin
					if(point_num != N_p_reg)begin
			    state_c <=  pause;
			wr_ones_reg <=  1'b0;
		 point_add_flag <=  1'b1;	
			cluster_num <=  cluster_num + 8'h01;
		 
					end else begin
				state_c <=  idle_c;
			wr_ones_reg <=  1'b0;
		 point_add_flag <=  1'b0;
		          ready <=  1'b1;
			     cl_end <=  1'b1;
		            end 
				end else begin					    
				state_c <=  pause;
			wr_ones_reg <=  1'b1;
		 point_add_flag <=  1'b0;
		 	cluster_num <=  cluster_num + 8'h01;

				end


				  
				
				if(dist_ptr[15:8] < N_p_reg)begin
				  c_ptr 	<= 	dist_ptr[15:8] + 1;
				end else begin
				  c_ptr 	<= 	dist_ptr[15:8] - 1;
				end
			
			  
            end  
			
			up_addr   : begin
			
							if(c_ptr == N_p_reg && !wr_ones)begin
																  
									if(points_xy[15:8] == 8'd0) begin
										
										if(flag_point)begin
													  state_c <=  pause;
													    c_ptr <=  8'd1;
				                                        n_ptr <=  8'd0;
									    end
										else  begin
										              state_c <=  up_addr;
												   flag_point <=  1'b1;
												        c_ptr <=  points_xy[7:0] + 1;
				                                        n_ptr <=  points_xy[7:0];
									                points_xy <= {points_xy[7:0], 8'h00};
										end
										
									end 
									else 	begin
										state_c <= dn_addr;	
										if(flag_intrpt_up)begin
										  c_ptr <= 	interrupt_ptr;
				                          n_ptr <= 	interrupt_ptr - 1;
										end else if (flag_intrpt_dn) begin
								 flag_intrpt_dn <= 1'b0;
									      c_ptr <= 	store_c_ptr;
				                          n_ptr <= 	store_n_ptr;	
										
										end else begin
										  c_ptr <= 	points_xy[15:8];
				                          n_ptr <= 	points_xy[15:8] - 1;
										end
									end
							 														
							end else if(wr_ones)begin
							
							       flag_intrpt_up <= 1'b1;
									  store_c_ptr <= c_ptr;
									  store_n_ptr <= n_ptr;
											if(dist_bram_b_addr_reg[7:0] == min_point_dist[15:8])begin
										interrupt_ptr <= dist_bram_b_addr_reg[15:8];
												c_ptr <= dist_bram_b_addr_reg[15:8] + 1;
												n_ptr <= dist_bram_b_addr_reg[15:8];	
											end else begin
										interrupt_ptr <= dist_bram_b_addr_reg[7:0];
												c_ptr <= dist_bram_b_addr_reg[7:0] + 1;
												n_ptr <= dist_bram_b_addr_reg[7:0];	
											end 
										
							end else  c_ptr <= c_ptr + 1;
							
				
				        end
				
			dn_addr   : begin
			
				if(n_ptr == 8'd0 && !wr_ones)begin
				
					if(flag_intrpt_up)begin
					                  state_c <=  up_addr;
										c_ptr <=  store_c_ptr;
										n_ptr <=  store_n_ptr;
					           flag_intrpt_up <= 1'b0;
					end else if (flag_intrpt_dn) begin
					                  state_c <=  up_addr;
										c_ptr <=  interrupt_ptr + 1;
										n_ptr <=  interrupt_ptr;
					            					
					end else begin
					    if(flag_point)begin
									  state_c <=  pause;
										c_ptr <=  8'd1;
										n_ptr <=  8'd0;
						end
						else  begin
						
								if(points_xy[7:0] == N_p_reg)begin
								      state_c <=  dn_addr;
										c_ptr <=  points_xy[7:0];
										n_ptr <=  points_xy[7:0] - 1;
								end else begin 
									  state_c <=  up_addr;
										c_ptr <=  points_xy[7:0] + 1;
										n_ptr <=  points_xy[7:0];
								end
									points_xy <= {points_xy[7:0], 8'h00};
								   flag_point <=  1'b1;
						end	
					end // flag_intrpt
									
				end else if (wr_ones) begin //
				
							   flag_intrpt_dn <= 1'b1;
								  store_c_ptr <= c_ptr;
								  store_n_ptr <= n_ptr;
								    if(dist_bram_b_addr_reg[15:8] == min_point_dist[7:0])begin
								interrupt_ptr <= dist_bram_b_addr_reg[7:0];
										c_ptr <= dist_bram_b_addr_reg[7:0];
										n_ptr <= dist_bram_b_addr_reg[7:0] - 1;
									end else if(dist_bram_b_addr_reg[15:8] == min_point_dist[15:8])begin
								interrupt_ptr <= dist_bram_b_addr_reg[7:0];
										c_ptr <= dist_bram_b_addr_reg[7:0];
										n_ptr <= dist_bram_b_addr_reg[7:0] - 1;
								    end else begin
								interrupt_ptr <= dist_bram_b_addr_reg[15:8];
										c_ptr <= dist_bram_b_addr_reg[15:8];
										n_ptr <= dist_bram_b_addr_reg[15:8] - 1;
									end
				
				
				end else  n_ptr <= n_ptr - 1;
		
			end
			
			pause     : begin
			

			if(wr_ones_reg)begin
			
				if(points_xy[15:8] < N_p_reg)begin
				      state_c <=  up_addr;
				end else begin
				      state_c <=  dn_addr;
				end
			      wr_ones_reg <= 1'b0;
				  
			end 
			
			else if(wr_ones)begin
			
			   flag_intrpt_up <= 1'b1;
			          state_c <=  up_addr;
				  store_c_ptr <= c_ptr;
				  store_n_ptr <= n_ptr;
						if(dist_bram_b_addr_reg[7:0] == min_point_dist[7:0])begin
					interrupt_ptr <= dist_bram_b_addr_reg[15:8];
							c_ptr <= dist_bram_b_addr_reg[15:8] + 1;
							n_ptr <= dist_bram_b_addr_reg[15:8];	
						end else begin
					interrupt_ptr <= dist_bram_b_addr_reg[7:0];
							c_ptr <= dist_bram_b_addr_reg[7:0] + 1;
							n_ptr <= dist_bram_b_addr_reg[7:0];	
						end 
			
			
			
			end
			else      state_c <=  dist_sort;
			
			    point_num     <=  8'd0;
			   point_add_flag <=  1'b0;					


				
			end
			
						
            dist_sort : begin
			
				if(c_ptr == N_p_reg)begin
					if(n_ptr == N_p_reg - 1)begin
						  n_ptr <= N_p_reg - 1;
						  c_ptr <= N_p_reg;
						state_c <= cluster_c;
						  
					end else  begin
						  c_ptr <= n_ptr + 2;
						  n_ptr <= n_ptr + 1;
					end							 
			
				end else  c_ptr <= c_ptr + 1;
				
				if (point_num == 8'hFF)                   point_num <= 8'hFF;
				else if(points_marking[point_num] == 1'b0)point_num <= point_num;
				else if(point_num == N_p_reg)             point_num <= N_p_reg;
				else                                      point_num <= point_num + 8'd1;

		   					   
            end			
			
         endcase


/***************************************************************/
/***************   counting of used points *********************/		

 
	always@(posedge clk)
		if(rst || eop_p)      points_used <= 0;
		else if (wr_ones_reg) points_used <= points_used + 8'd2; 
		else if (wr_ones)     points_used <= points_used + 8'd1;
	
	always@(posedge clk)
		if(rst || eop_p) 	  points_marking                             <= 32'd0;
		else if (wr_ones_reg) begin 
							  points_marking[points_xy[15:8]]            <= 1'b1;
							  points_marking[points_xy[07:0]]            <= 1'b1;
		end
		else if (wr_ones)     begin
							  points_marking[dist_bram_b_addr_reg[15:8]] <= 1'b1;
							  points_marking[dist_bram_b_addr_reg[07:0]] <= 1'b1;
		end
		else if (point_add_flag)begin
		                      points_marking[point_num] <= 1'b1;
		end 
		
		
		
/****************************************************************/
/****************************************************************/	
/****************************************************************/	
	

	always@(posedge clk)
		if(rst) begin
						    mDist_reg <=  16'hFFFF;
						     dist_ptr <=  16'd0;
		end else if (vld_shifted) begin
		            if(mDist_reg > sq_distance) begin
							mDist_reg <= sq_distance;              // find min distance				
                             dist_ptr <= dist_bram_a_addr;         // find 1st pair of points with min distance							
					end
		end else if (state_c == dist_sort || state_c == cluster_c) begin
		            if(mDist_reg > dist_bram_b_data_out) begin
							mDist_reg <= dist_bram_b_data_out;     // find min distance				
                             dist_ptr <= dist_bram_b_addr_reg;     // find 1st pair of points with min distance							
					end		
		end else begin
		        mDist_reg     <=  16'hFFFF;
		end
	
	
	always@(posedge clk)if(rst) wr_ones_reg_reg <= 1'b0; else wr_ones_reg_reg <= wr_ones_reg;
	always@(posedge clk)if(rst)       wr_ones_r <= 1'b0; else       wr_ones_r <= wr_ones;
	always@(posedge clk)if(rst)  min_point_dist <= 16'd0; else if (wr_ones_reg) min_point_dist <= points_xy;

	always@(posedge clk)
	if(rst)                                                    point_dist <= 8'd0; 
	else if(dist_bram_b_addr_reg[15:8] == min_point_dist[15:8])point_dist <= dist_bram_b_addr_reg[7 :0];
	else if(dist_bram_b_addr_reg[7 :0] == min_point_dist[7 :0])point_dist <= dist_bram_b_addr_reg[15:8];
	else if(dist_bram_b_addr_reg[15:8] == min_point_dist[7 :0])point_dist <= dist_bram_b_addr_reg[7 :0];
	else if(dist_bram_b_addr_reg[7 :0] == min_point_dist[15:8])point_dist <= dist_bram_b_addr_reg[15:8];

	
	assign  point_indx     = (wr_ones_reg) ?  points_xy[15:8] : (wr_ones_reg_reg) ? points_xy[7:0] : (wr_ones_r) ? point_dist : (point_add_flag) ? point_num : 8'd0;
	assign  point_indx_vld = wr_ones_reg_reg || wr_ones_r || wr_ones_reg || point_add_flag;
	assign  n_cluster      = cluster_num;
	assign  point_rd_vld   = wr_ones_reg_reg || wr_ones_r || wr_ones_reg || point_add_flag;
	assign  point_rd_indx  = (wr_ones_reg) ?  points_xy[15:8] : (wr_ones_reg_reg) ? points_xy[7:0] : (wr_ones_r) ? point_dist : (point_add_flag) ? point_num : 8'd0;
   
	
/**********************************************************/
/************** computing center of cluster ***************/

	reg  [15 : 0]  sum_x;
	reg  [15 : 0]  sum_y;
	reg            point_rd_vld_reg;
	reg  [7  : 0]  cl_length;
	wire           cl_cnt   = (state_c == cluster_c) ?  1'b1 : 1'b0;     // finish computing current cluster
	wire [15 : 0]  center_x = (state_c == pause)     ? sum_x : center_x;
	wire [15 : 0]  center_y = (state_c == pause)     ? sum_y : center_y;
	
	wire [7  : 0]  cent_x, cent_y;
	always@ (posedge clk) if(rst)    point_rd_vld_reg <= 1'b0; else point_rd_vld_reg <= point_rd_vld;

	

	always@ (posedge clk) if(rst || cl_cnt) sum_x     <= 16'h0000; else if (point_rd_vld_reg) sum_x     <= sum_x     +  {8'h00, xy_point_1b[15 :8]};
	always@ (posedge clk) if(rst || cl_cnt) sum_y     <= 16'h0000; else if (point_rd_vld_reg) sum_y     <= sum_y     +  {8'h00, xy_point_1b[07 :0]};
	always@ (posedge clk) if(rst || cl_cnt) cl_length <= 07'h00;   else if (point_rd_vld_reg) cl_length <= cl_length +   8'h01;
	
	div_uu	#(16) div_uu_x   (.clk(clk), .ena(1'b1), .z(sum_x), .d(cl_length), .q(cent_x),   .s(), .div0(), .ovf());
	div_uu	#(16) div_uu_y   (.clk(clk), .ena(1'b1), .z(sum_y), .d(cl_length), .q(cent_y),   .s(), .div0(), .ovf());	
	
	
	/**************************************************/
	/****** look for the best cluster *****************/
	// cl_end 	- 	clustering is over!!!
	
	reg 	[7 : 0] 	max_size;		// size   of the best cluster
	reg 	[7 : 0] 	max_cl;			// number of the best cluster
	reg 	[7 : 0] 	max_cent_x;		// center of the best cluster (x coordinate)
	reg 	[7 : 0] 	max_cent_y;     // center of the best cluster (y coordinate)
	
	always@ (posedge clk)
		if(rst || cl_end) begin
						max_size <= 8'h00;
						  max_cl <= 8'h00;
					  max_cent_x <= 8'h00;
					  max_cent_y <= 8'h00;
		end else if(cl_cnt) begin
				if(max_size < cl_length) begin
						max_size <= cl_length;
						  max_cl <= cluster_num;
					  max_cent_x <= cent_x;
					  max_cent_y <= cent_y;					
				end		
		end




/**********************************************************/
	
	


endmodule
