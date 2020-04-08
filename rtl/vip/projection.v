// Descriptions:    对图像进行水平垂直投影
//****************************************************************************************//

module	projection #(
	parameter NUM_ROW =  1 ,
	parameter NUM_COL =  4 ,
	parameter H_PIXEL = 480,
	parameter V_PIXEL = 272,
	parameter DEPBIT  = 10							//地址的位宽
)(
    input				clk					,		// 时钟信号
    input				rst_n				,		// 复位信号，低电平有效
	
	//Image data interface
	input				frame_vsync			,		// vsync信号
	input				frame_hsync			,       // hsync信号
	input				frame_de			,       // data enable信号
	input				monoc				,       // 单色图像像素数据
	input	[10:0]		xpos				,
	input	[10:0]		ypos				,
	
	//project border ram interface
	input	[DEPBIT-1:0]row_border_addr_rd	,
	output	[DEPBIT-1:0]row_border_data_rd	,
	input	[DEPBIT-1:0]col_border_addr_rd	,
	output	[DEPBIT-1:0]col_border_data_rd	,
	
	//user interface
	output	reg	[3:0]	num_col				,		// 采集到的数字列数
	output	reg	[3:0]	num_row				,       // 采集到的数字行数
	output	reg	[1:0]	frame_cnt			,       // 当前帧
	output	reg			project_done_flag	        // 投影完成标志
);

//wire define
wire			frame_vsync_fall	;
wire			h_d0				;
wire			v_d0				;
wire			h_rise				;
wire			h_fall				;
wire			v_rise				;
wire			v_fall				;

//reg define
reg [ 1:0]		cur_state			;
reg [ 1:0]		nxt_state			;
reg [10:0]		cnt					;
reg				h_we				;
reg	[10:0]		h_waddr				;
reg	[10:0]		h_raddr				;
reg				h_di				;
reg				h_do_d0				;
reg				v_we				;
reg	[10:0]		v_waddr				;
reg	[10:0]		v_raddr				;
reg				v_di				;
reg				v_do_d0				;
reg				frame_vsync_d0		;
reg	[DEPBIT-1:0]col_border_addr_wr	;
reg	[DEPBIT-1:0]col_border_data_wr	;
reg				col_border_ram_we	;
reg	[DEPBIT-1:0]row_border_addr_wr	;
reg	[DEPBIT-1:0]row_border_data_wr	;
reg				row_border_ram_we	;
reg	[ 3:0]		num_col_t			;
reg	[ 3:0]		num_row_t			;


//localparameter define
localparam st_init    = 2'b00;
localparam st_project = 2'b01;
localparam st_process = 2'b10;

//*****************************************************
//**                    main code
//*****************************************************

assign h_rise =  h_d0 & ~h_do_d0;
assign h_fall = ~h_d0 &  h_do_d0;
assign v_rise =  v_d0 & ~v_do_d0;
assign v_fall = ~v_d0 &  v_do_d0;
assign frame_vsync_fall = frame_vsync_d0 & ~frame_vsync;

//投影结束后输出采集到的行列数
always @(*) begin
    if(project_done_flag && cur_state == st_process) begin
		num_col = num_col_t;
		num_row = num_row_t;
	end
	else begin
		num_col = num_col;
		num_row = num_row;
	end
end

//打拍采沿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_do_d0 <= 1'b0;
		v_do_d0 <= 1'b0;
	end
	else begin
		h_do_d0 <= h_do;
		v_do_d0 <= v_do;
	end	
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        frame_vsync_d0 <= 1'b0;
	else 
		frame_vsync_d0 <= frame_vsync;
end

//帧计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        frame_cnt <= 2'b0;
	else if (frame_cnt == 2'd3)
		frame_cnt <= 2'b0;
	else if (frame_vsync_fall)
		frame_cnt <= frame_cnt + 1'b1;	
end

//(三段式状态机)状态转移
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cur_state <= st_init;
	else 
		cur_state <= nxt_state;
end

//状态转移条件
always @(*) begin
	case(cur_state)
		st_init: begin
			if (frame_cnt == 2'd1)			// initial myram
				nxt_state <= st_project;
			else
				nxt_state <= st_init;
		end
		st_project: begin
			if (frame_cnt == 2'd2)
				nxt_state <= st_process;
			else
				nxt_state <= st_project;
		end
		st_process: begin
			if (frame_cnt == 2'd0)
				nxt_state <= st_init;
			else
				nxt_state <= st_process;
		end
	endcase
end

//状态任务
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_we	<= 1'b0;
		h_waddr <= 11'b0;
		h_raddr	<= 11'b0;
		h_di	<= 1'b0;
		v_we	<= 1'b0;
		v_waddr <= 11'b0;
		v_raddr	<= 11'b0;
		v_di	<= 1'b0;
		cnt		<= 11'b0;
		num_col_t <= 4'b0;
		num_row_t <= 4'b0;
		col_border_ram_we <= 1'b0;
		row_border_ram_we <= 1'b0;
		project_done_flag <= 1'b0;
	end
	else case(nxt_state)
			st_init: begin
				if (cnt == H_PIXEL) begin
					cnt		<=  'b0;
					h_we	<= 1'b0;
					h_waddr <=  'd0;
					h_raddr <=  'd0;
					h_di	<= 1'd0;
					v_we	<= 1'b0;
					v_waddr <=  'd0;
					v_raddr <=  'd0;
					v_di	<= 1'd0;
					num_col_t <= 4'b0;
					num_row_t <= 4'b0;
					col_border_addr_wr <= 0;
					row_border_addr_wr <= 0;
				end
				else begin
					cnt  <= cnt + 1'b1;
					h_we <= 1'b1;
					h_waddr <= h_waddr + 1'b1;
					h_di <= 1'b0;
					v_we <= 1'b1;
					v_waddr <= h_waddr + 1'b1;
					v_di <= 1'b0;
				end
			end
			st_project: begin
				if (frame_de && (!monoc)) begin			//黑色的像素点
					h_we <= 1'b1;
					h_waddr <= xpos;
					h_di <= 1'b1;						//黑色-->1
					v_we <= 1'b1;
					v_waddr <= ypos;
					v_di <= 1'b1;
				end
				else begin
					h_we <= 1'b0;
					h_waddr <= 'd0;
					h_di <= 1'b0;						//白色-->0
					v_we <= 1'b0;
					v_waddr <= 'd0;
					v_di <= 1'b0;
				end
			end
			st_process: begin
				if (h_raddr == H_PIXEL)
					project_done_flag <= 1'b1;
				else begin
					cnt <= 'd0;
					h_raddr <= h_raddr + 1'b1;
					v_raddr <= (v_raddr == V_PIXEL) ? v_raddr : (v_raddr + 1'b1);
					project_done_flag <= 1'b0;
				end
				if (h_rise) begin						//白-->黑
					num_col_t <= num_col_t + 1'b1;
					col_border_addr_wr <= col_border_addr_wr + 1'b1;
					col_border_data_wr <= h_raddr - 2'd2;
					col_border_ram_we  <= 1'b1;
				end
				else if (h_fall) begin						//黑-->白
					col_border_addr_wr <= col_border_addr_wr + 1'b1;
					col_border_data_wr <= h_raddr + 2'd2;
					col_border_ram_we  <= 1'b1;
				end
				else
					col_border_ram_we <= 1'b0;
				if (v_rise) begin							//白-->黑
					num_row_t <= num_row_t + 1'b1;
					row_border_addr_wr <= row_border_addr_wr + 1'b1;
					row_border_data_wr <= v_raddr - 2'd2;
					row_border_ram_we  <= 1'b1;
				end
				else if (v_fall) begin						//黑-->白
					row_border_addr_wr <= row_border_addr_wr + 1'b1;
					row_border_data_wr <= v_raddr + 2'd2;
					row_border_ram_we  <= 1'b1;
				end
				else
					row_border_ram_we <= 1'b0;
			end
	endcase	
end

//垂直投影
myram  #(
	.WIDTH( 1 )	,
	.DEPTH(H_PIXEL),
	.DEPBIT(DEPBIT)
)u_h_myram(
	.clk(clk),
	.we(h_we),
	.waddr(h_waddr),
	.raddr(h_raddr),
	.dq_i(h_di),
	.dq_o(h_do)
);

//水平投影
myram  #(
	.WIDTH( 1 )	,
	.DEPTH(V_PIXEL),
	.DEPBIT(DEPBIT)
)u_v_myram(
	.clk(clk),
	.we(v_we),
	.waddr(v_waddr),
	.raddr(v_raddr),
	.dq_i(v_di),
	.dq_o(v_do)
);

//垂直投影边界
myram #(
    .WIDTH(11),
    .DEPTH(2 * NUM_COL),
    .DEPBIT(DEPBIT)
)u_col_border_myram(
    //module clock
    .clk    (clk),
    //ram interface
    .we     (col_border_ram_we ),
    .waddr  (col_border_addr_wr),
    .raddr  (col_border_addr_rd),
    .dq_i   (col_border_data_wr),
    .dq_o   (col_border_data_rd)
);

//水平投影边界
myram #(
    .WIDTH(11),
    .DEPTH(2 * NUM_ROW),
    .DEPBIT(DEPBIT)
)u_row_border_myram(
    //module clock
    .clk    (clk),
    //ram interface
    .we     (row_border_ram_we ),
    .waddr  (row_border_addr_wr),
    .raddr  (row_border_addr_rd),
    .dq_i   (row_border_data_wr),
    .dq_o   (row_border_data_rd)
);

endmodule
