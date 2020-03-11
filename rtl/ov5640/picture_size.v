// Descriptions:    摄像头输出图像尺寸及帧率配置
//****************************************************************************************//

module	picture_size(
    input               rst_n      ,      // 复位信号，低电平有效
	
	input		[15:0]	ID_lcd		,
	
	output	reg	[12:0]	cmos_h_pixel,
	output	reg	[12:0]	cmos_v_pixel,
	output	reg	[12:0]	total_h_pixel,
	output	reg	[12:0]	total_v_pixel,
	output	reg	[23:0]	sdram_max_addr
);

//parameter define
parameter	ID_4342 = 0;			//4.3寸，480*272的分辨率
parameter	ID_7084 = 1;			//7寸，800*480的分辨率
parameter	ID_7016 = 2;			//7寸，1024*600的分辨率
parameter	ID_1018 = 5;			//10.1寸，1280*800的分辨率

//*****************************************************
//**                    main code                      
//*****************************************************

//配置摄像头输出图像的尺寸大小
always @(*) begin
    case(ID_lcd)
		ID_4342: begin
			cmos_h_pixel   = 13'd480;
			cmos_v_pixel   = 13'd272;
			sdram_max_addr = 24'd130560; 
		end
		ID_7084: begin
			cmos_h_pixel   = 13'd800;
			cmos_v_pixel   = 13'd480;
			sdram_max_addr = 24'd384000; 
		end
		ID_7016: begin
			cmos_h_pixel   = 13'd1024;
			cmos_v_pixel   = 13'd600;
			sdram_max_addr = 24'd614400; 
		end
		ID_1018: begin
			cmos_h_pixel   = 13'd1280;
			cmos_v_pixel   = 13'd800;
			sdram_max_addr = 24'd1024000; 
		end
		default: begin
			cmos_h_pixel   = 13'd480;
			cmos_v_pixel   = 13'd272;
			sdram_max_addr = 24'd130560; 
		end
	endcase	
end

//对HTS及VTS的配置会影响摄像头输出图像的帧率
always @(*) begin
    case(ID_lcd)
		ID_4342: begin
			total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000; 
		end
		ID_7084: begin
			total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
		end
		ID_7016: begin
			total_h_pixel =   13'd2200;
            total_v_pixel =   13'd1000;
		end
		ID_1018: begin
			total_h_pixel =   13'd2570;
            total_v_pixel =   13'd980;
		end
		default: begin
			total_h_pixel  = 13'd1800;
			total_v_pixel  = 13'd1000; 
		end
	endcase	
end


endmodule
