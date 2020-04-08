// Descriptions:    CMOS摄像头数据采集模块
//****************************************************************************************//

module	cmos_capture_data(
    input               rst_n			,	// 复位信号，低电平有效
	//摄像头接口
	input				cam_pclk		,	//cmos 数据像素时钟
	input				cam_vsync		,   //cmos 场同步信号
	input				cam_href		,   //cmos 行同步信号
	input		[ 7:0]	cam_data		,   //cmos 数据
	//用户接口                              
	output				cmos_frame_vsync,   //帧有效信号
	output				cmos_frame_href	,   //行有效信号
	output				cmos_frame_valid,   //数据有效使能信号
	output		[15:0]	cmos_frame_data     //有效数据
);

//寄存器全部配置完成后，先等待10帧数据
//待寄存器配置生效后再开始采集图像
parameter	WAIT_FRAME = 4'd10;				//寄存器数据稳定等待的帧个数

//reg define
reg				cam_vsync_d0	;
reg				cam_vsync_d1	;
reg				cam_href_d0		;
reg				cam_href_d1		;
reg		[ 3:0]	cmos_fps_cnt	;			 //等待帧数稳定计数器
reg             frame_val_flag 	;            //帧有效的标志

reg		[ 7:0]	cam_data_d0		;
reg		[15:0]	cmos_data_t		;			 //用于8位转16位的临时寄存器
reg				byte_flag		;
reg				byte_flag_d0	;

//wire define
wire			pos_vsync		;

//*****************************************************
//**                    main code
//*****************************************************

//采集输入场同步信号的上升沿
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;

//输出帧有效信号
assign cmos_frame_vsync = frame_val_flag ? cam_vsync_d1 : 1'b0;
//输出行有效信号
assign cmos_frame_href	= frame_val_flag ? cam_href_d1  : 1'b0;
//输出数据使能有效信号
assign cmos_frame_valid	= frame_val_flag ? byte_flag_d0 : 1'b0;
//输出数据
assign cmos_frame_data  = frame_val_flag ? cmos_data_t  : 1'b0;

//检测场同步信号的上升沿
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
		cam_vsync_d1 <= 1'b0;
		cam_href_d0  <= 1'b0;
		cam_href_d1  <= 1'b0;
    end
	else begin
		cam_vsync_d0 <= cam_vsync;
		cam_vsync_d1 <= cam_vsync_d0;
		cam_href_d0  <= cam_href;
		cam_href_d1  <= cam_href_d0;
	end	
end

//对帧数进行计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_fps_cnt <= 4'd0;
	else if (pos_vsync && (cmos_fps_cnt < WAIT_FRAME))
		cmos_fps_cnt <= cmos_fps_cnt + 4'd1;
end

//帧有效标志
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'd0;
	else if ((cmos_fps_cnt == WAIT_FRAME-1) && pos_vsync)
		frame_val_flag <= 1'd1;
	else;
end

//8位摄像头输出的数据转16位RGB565数据
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
		cmos_data_t <= 16'd0;
        cam_data_d0 <= 8'd0;
		byte_flag	<= 1'b0;
    end
	else if (cam_href) begin
		byte_flag   <= ~byte_flag;
		cam_data_d0 <= cam_data;
		if (byte_flag)
			cmos_data_t <= {cam_data_d0, cam_data};
		else;
	end	
	else begin
		cam_data_d0 <= 8'd0;
		byte_flag	<= 1'b0;
	end
end

//产生输出数据有效信号(cmos_frame_valid)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
	else
		byte_flag_d0 <= byte_flag;
end

endmodule
