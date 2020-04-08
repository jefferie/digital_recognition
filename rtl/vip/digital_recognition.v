// Descriptions:    数字特征识别模块
//****************************************************************************************//

module	digital_recognition #(
	parameter	NUM_ROW =  1 ,
	parameter	NUM_COL =  4 ,
	parameter	H_PIXEL = 480,
	parameter	V_PIXEL = 272,
	parameter	NUM_WIDTH = (NUM_ROW*NUM_COL<<2)-1
)(
    input						clk				,		// 时钟信号
    input						rst_n			,		// 复位信号，低电平有效
	
	//image data interface
	input						monoc			,		// 单色图像像素数据
	input						monoc_fall		,       // 图像数据变化,1-->0，即
	input		[10:0]			xpos			,       
	input		[10:0]			ypos			,       
	output reg	[15:0]			color_rgb		,       
	                                                    
	//project border ram interface                      
	input		[10:0]			row_border_data	,       
	output reg	[10:0]			row_border_addr	,       
	input		[10:0]			col_border_data	,       
	output reg	[10:0]			col_border_addr	,       
	                                                    
	//user interface                                    
	input		[ 1:0]			frame_cnt		,       // 当前帧
	input						project_done_flag,      // 投影完成标志
	input		[ 3:0]			num_col			,       // 采集到的数字列数
	input		[ 3:0]			num_row			,       // 采集到的数字行数
	output reg	[NUM_WIDTH:0] 	digit                   // 识别到的数字
);

//wire define
wire				y_flag_fall						;
wire				col_chg							;
wire				row_chg							;
wire				feature_deal					;

//reg define
reg	[10:0]			col_border_l					;
reg	[10:0]			col_border_r					;
reg	[10:0]			row_border_hgh					;
reg	[10:0]			row_border_low					;
reg	[16:0]			row_border_hgh_t				;
reg	[16:0]			row_border_low_t				;
reg					x1_l	[NUM_TOTAL:0]			;
reg					x1_r	[NUM_TOTAL:0]			;
reg					x2_l	[NUM_TOTAL:0]			;
reg					x2_r	[NUM_TOTAL:0]			;
reg	[1:0]			y		[NUM_TOTAL:0]			;
reg	[1:0]			y_flag	[NUM_TOTAL:0]			;
reg					row_area[NUM_ROW - 1'b1:0]		;
reg					col_area[NUM_TOTAL	   :0]		;
reg	[3:0]			row_cnt,row_cnt_t				;
reg	[3:0]			col_cnt,col_cnt_t				;
reg	[10:0]			cent_y							;
reg	[11:0]			cent_y_t						;
reg	[10:0]			v25								;
reg	[10:0]			v23								;
reg	[22:0]			v25_t							;
reg	[22:0]			v23_t							;
reg	[5:0]			num_cnt							;
reg					row_d0,row_d1					;
reg					col_d0,col_d1					;
reg					row_chg_d0,row_chg_d1,row_chg_d2;
reg					row_chg_d3						;
reg					col_chg_d0,col_chg_d1,col_chg_d2;
reg	[7:0]			real_num_total					;
reg	[3:0]			digit_id						;
reg	[3:0]			digit_cnt						;
reg	[NUM_WIDTH:0]	digit_t							;

//localparam define
localparam FP_1_3 = 6'b010101;                   // 1/3 小数的定点化
localparam FP_2_3 = 6'b101011;                   // 2/3 
localparam FP_2_5 = 6'b011010;                   // 2/5 
localparam FP_3_5 = 6'b100110;                   // 3/5 
localparam NUM_TOTAL = NUM_ROW * NUM_COL - 1'b1; // 需识别的数字共个数，始于0

//*****************************************************
//**                    main code
//*****************************************************

assign row_chg = row_d0 ^ row_d1;
assign col_chg = col_d0 ^ col_d1;
assign y_flag_fall = ~y_flag[num_cnt][0] & y_flag[num_cnt][1];
assign feature_deal = project_done_flag && frame_cnt == 2'd2;	// 处理特征

//实际采集到的数字总数
always @(*) begin
    if(project_done_flag) 
		real_num_total = num_col * num_row;
end

//检测行变化
always @(posedge clk) begin
    if(project_done_flag) begin
		row_cnt_t <= row_cnt;
		row_d1    <= row_d0;
		if (row_cnt_t != row_cnt)
			row_d0 <= ~row_d0;
	end
	else begin
		row_d0 <= 1'b1;
		row_d1 <= 1'b1;
		row_cnt_t <= 4'hf;
	end
end

//获取数字的行边界
always @(posedge clk) begin
    if(row_chg)
		row_border_addr <= (row_cnt << 1'b1) + 1'b1;
	else 
		row_border_addr <= row_cnt << 1'b1;
end

always @(posedge clk) begin
    if(row_border_addr[0])
		row_border_hgh <= row_border_data;		//下边界
	else 
		row_border_low <= row_border_data;		//上边界
end

always @(posedge clk) begin
	row_chg_d0 <= row_chg;
	row_chg_d1 <= row_chg_d0;
	row_chg_d2 <= row_chg_d1;
	row_chg_d3 <= row_chg_d2;
end

//检测列变化
always @(posedge clk) begin
    if(project_done_flag) begin
		col_cnt_t <= col_cnt;
		col_d1    <= col_d0;
		if (col_cnt_t != col_cnt)
			col_d0 <= ~col_d0;
	end
	else begin
		col_d0 <= 1'b1;
		col_d1 <= 1'b1;
		col_cnt_t <= 4'hf;
	end
end

//获取单个数字的列边界
always @(posedge clk) begin
    if(col_chg) 
        col_border_addr <= (col_cnt << 1'b1) + 1'b1;
	else 
		col_border_addr <= col_cnt << 1'b1;
end

always @(posedge clk) begin
    if(col_border_addr[0]) 
        col_border_r <= col_border_data;
	else 
		col_border_l <= col_border_data;
end

always @(posedge clk) begin
	col_chg_d0 <= col_chg;
	col_chg_d1 <= col_chg_d0;
	col_chg_d2 <= col_chg_d1;
end

//数字中心y
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cent_y_t <= 12'd0;
	else if (project_done_flag) begin
		if (col_chg_d1)
			cent_y_t <= col_border_l + col_border_r;
		if (col_chg_d2)
			cent_y = cent_y_t[11:1];
	end
end

//x1、x2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  begin
        v25 <= 11'd0;
		v23 <= 11'd0;
		v25_t <= 23'd0;
		v23_t <= 23'd0;
		row_border_hgh_t <= 17'd0;
		row_border_low_t <= 17'd0;
	end
	else if (project_done_flag) begin
		if (row_chg_d1) begin
			row_border_hgh_t <= {row_border_hgh,6'b0};
			row_border_low_t <= {row_border_low,6'b0};
		end
		if (row_chg_d2) begin
			v25_t <= row_border_hgh_t * FP_2_5 + row_border_low_t * FP_3_5;	//x1
			v23_t <= row_border_hgh_t * FP_2_3 + row_border_low_t * FP_1_3;	//x2
		end
		if (row_chg_d3) begin
			v25 <= v25_t[22:12];
			v23 <= v23_t[22:12];
		end
	end		
end

//行区域
always @(*) begin
	row_area[row_cnt] = ypos >= row_border_low && ypos <= row_border_hgh;
end

//列区域
always @(*) begin
	col_area[col_cnt] = xpos >= col_border_l   && xpos <= col_border_r;
end

//确定col_cnt
always @(posedge clk) begin
    if(project_done_flag) begin
		if (row_area[row_cnt] && xpos == col_border_r)
			col_cnt <= col_cnt == num_col - 1'b1 ? 'd0 : col_cnt + 1'b1;
	end
	else 
		col_cnt <= 4'd0;
end

//确定row_cnt
always @(posedge clk) begin
    if(project_done_flag) begin
		if (ypos == row_border_hgh + 1'b1)
			row_cnt <= row_cnt == num_row - 1'b1 ? 'd0 : row_cnt + 1'b1;
	end
	else 
		row_cnt <= 12'd0;
end

//num_cnt用于清零特征点和计数特征点
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        num_cnt <= 'd0;
	else if (feature_deal)
		num_cnt <= row_cnt * num_col + col_cnt;
	else if (num_cnt <= NUM_TOTAL)					//NUM_TOTAL==3，一行四列
		num_cnt <= num_cnt + 1'b1;
	else
		num_cnt <= 'd0;
end

//x1与x2的特征数
always @(posedge clk) begin
    if(feature_deal) begin
		if (ypos == v25) begin
			if (xpos >= col_border_l && xpos <= cent_y && monoc_fall)
				x1_l[num_cnt] <= 1'b1;
			else if (xpos <= col_border_r && xpos >= cent_y && monoc_fall)
				x1_r[num_cnt] <= 1'b1;
		end
		else if (ypos == v23) begin
			if (xpos >= col_border_l && xpos <= cent_y && monoc_fall)
				x2_l[num_cnt] <= 1'b1;
			else if (xpos <= col_border_r && xpos >= cent_y && monoc_fall)
				x2_r[num_cnt] <= 1'b1;
		end
	end
	else begin
		x1_l[num_cnt] <= 1'b0;
		x1_r[num_cnt] <= 1'b0;
		x2_l[num_cnt] <= 1'b0;
		x2_r[num_cnt] <= 1'b0;
	end	
end

//寄存y_flag，找下降沿
always @(posedge clk) begin
    if(feature_deal) begin
		if (row_area[row_cnt] && xpos == cent_y)
			y_flag[num_cnt] <= {y_flag[num_cnt][0],monoc};	//移位寄存器，如果monoc由白变黑（1-->0），
	end														//将y_flag[num_cnt]两位相与，则y_flag_fall为高
	else 
		y_flag[num_cnt] <= 2'd3;
end

//Y方向的特征数
always @(posedge clk) begin
    if(feature_deal) begin
		if (xpos == cent_y + 1'b1 && y_flag_fall)
			y[num_cnt] <= y[num_cnt] + 1'b1;	
	end														
	else 
		y[num_cnt] <= 2'd0;
end

//特征匹配
always @(*) begin
	case({y[digit_cnt],x1_l[digit_cnt],x1_r[digit_cnt],x2_l[digit_cnt],x2_r[digit_cnt]})
		6'b10_1_1_1_1: digit_id = 4'h0; //0
        6'b01_1_0_1_0: digit_id = 4'h1; //1
        6'b11_0_1_1_0: digit_id = 4'h2; //2
        6'b11_0_1_0_1: digit_id = 4'h3; //3
        6'b10_1_1_1_0: digit_id = 4'h4; //4
        6'b11_1_0_0_1: digit_id = 4'h5; //5
        6'b11_1_0_1_1: digit_id = 4'h6; //6
        6'b10_0_1_1_0: digit_id = 4'h7; //7
        6'b11_1_1_1_1: digit_id = 4'h8; //8
        6'b11_1_1_0_1: digit_id = 4'h9; //9
        default: digit_id <= 4'h0;
	endcase
end

//识别数字
always @(posedge clk) begin
    if(feature_deal && ypos == row_border_hgh + 1'b1) begin
		if (real_num_total == 1'b1)							//一行一列的情况
			digit_t <= digit_id;
		else if (digit_cnt < real_num_total) begin			//real_num_total = num_col * num_row = 4 * 1
			digit_cnt <= digit_cnt + 1'b1;                  
			digit_t	  <= {digit_t[NUM_WIDTH-4:0],digit_id}; //NUM_WIDTH = (NUM_ROW*NUM_COL<<2)-1
		end
	end
	else begin
		digit_cnt <= 'd0;
		digit_t   <= 'd0;
	end
end

//输出识别到的数字
always @(posedge clk) begin
    if(feature_deal && digit_cnt == real_num_total) 
        digit <= digit_t;
end

//输出边界和图像
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        color_rgb <= 16'h0000;
	else if (row_area[row_cnt] && (xpos == col_border_l || xpos == col_border_r
			||xpos == (col_border_l - 1) || xpos == (col_border_r + 1)))
		color_rgb <= 16'hf800;	//左右竖直边界线
	else if (col_area[col_cnt] && (ypos == row_border_low || ypos == row_border_hgh
			||ypos == (row_border_low - 1) || ypos == (row_border_hgh + 1)))
		color_rgb <= 16'hf800;	//上下水平边界线
	else if (monoc)
		color_rgb <= 16'hffff;	//白色
	else
		color_rgb <= 16'h0000;	//黑色
end

endmodule
