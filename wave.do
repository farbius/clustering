onerror {resume}
quietly virtual signal -install /top_module_tb/uut/point_bram_i { /top_module_tb/uut/point_bram_i/xy_point_1b[15:8]} sdds
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_module_tb/uut/point_bram_i/rst
add wave -noupdate /top_module_tb/uut/point_bram_i/clk
add wave -noupdate -radix unsigned /top_module_tb/uut/point_indx
add wave -noupdate -radix unsigned /top_module_tb/uut/point_indx_vld
add wave -noupdate -radix unsigned /top_module_tb/uut/n_cluster
add wave -noupdate -divider states
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/idle_c
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/cluster_c
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/up_addr
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/dn_addr
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/dist_sort
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/pause
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/state_c
add wave -noupdate -divider pointers
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/n_ptr
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/c_ptr
add wave -noupdate /top_module_tb/uut/ready_nd
add wave -noupdate /top_module_tb/uut/point_bram_i/vld_shifted
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/dist_bram_a_data_in
add wave -noupdate -radix hexadecimal /top_module_tb/uut/point_bram_i/dist_bram_a_addr
add wave -noupdate /top_module_tb/uut/point_bram_i/dist_bram_a_wr
add wave -noupdate -radix hexadecimal /top_module_tb/uut/point_bram_i/dist_ptr
add wave -noupdate -color Magenta -radix hexadecimal /top_module_tb/uut/point_bram_i/dist_bram_b_addr_reg
add wave -noupdate -color Magenta -radix hexadecimal /top_module_tb/uut/point_bram_i/dist_bram_b_addr
add wave -noupdate -color Magenta -radix unsigned /top_module_tb/uut/point_bram_i/dist_bram_b_data_out
add wave -noupdate -color Magenta /top_module_tb/uut/point_bram_i/wr_ones
add wave -noupdate -color Magenta /top_module_tb/uut/point_bram_i/wr_ones_reg
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/mDist_reg
add wave -noupdate -radix hexadecimal /top_module_tb/uut/point_bram_i/min_point_dist
add wave -noupdate -color Gold -radix unsigned /top_module_tb/uut/point_bram_i/points_used
add wave -noupdate /top_module_tb/uut/point_bram_i/flag_intrpt_up
add wave -noupdate /top_module_tb/uut/point_bram_i/flag_intrpt_dn
add wave -noupdate /top_module_tb/uut/point_bram_i/flag_point
add wave -noupdate -radix hexadecimal /top_module_tb/uut/point_bram_i/points_xy
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/store_c_ptr
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/store_n_ptr
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/cluster_num
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/point_num
add wave -noupdate -divider {center computing}
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/cl_length
add wave -noupdate /top_module_tb/uut/point_bram_i/point_indx_vld
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/point_rd_indx
add wave -noupdate -color Red /top_module_tb/uut/point_bram_i/point_rd_vld_reg
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/center_x
add wave -noupdate -color Red -label x_data -radix unsigned /top_module_tb/uut/point_bram_i/sdds
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/max_size
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/max_cl
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/max_cent_x
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/max_cent_y
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/max_size
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/cent_x
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/cent_y
add wave -noupdate -color Red -radix unsigned /top_module_tb/uut/point_bram_i/sum_x
add wave -noupdate -radix unsigned /top_module_tb/uut/point_bram_i/b_addr_1i2i
add wave -noupdate -radix hexadecimal /top_module_tb/uut/point_bram_i/xy_point_1b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {7643030 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 341
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {41364750 ps}
