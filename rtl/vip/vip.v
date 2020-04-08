// Descriptions:    数字图像处理模块封装层
//****************************************************************************************//

module	vip(
    input				clk				,	// 时钟信号
    input				rst_n			,	// 复位信号，低电平有效
	
	//图像处理前的数据接口
	input				pre_frame_vsync	,
	input				pre_frame_hsync	,
	input				pre_frame_de	,
	input		[15:0]	pre_rgb			,
	input		[10:0]	xpos			,
	input		[10:0]	ypos			,
	
	//图像处理后的数据接口
	output				post_frame_vsync,
	output				post_frame_hsync,
	output				post_frame_de   ,
	output		[15:0]	post_rgb		,
	
	//user interface
	//因为有6个数码管，每个数码管都是4位的8421BCD编码，所以就是24位
	output		[23:0]	digit
);

//parameter define
parameter NUM_ROW = 1  ;               // 需识别的图像的行数
parameter NUM_COL = 4  ;               // 需识别的图像的列数
parameter H_PIXEL = 480;               // 图像的水平像素
parameter V_PIXEL = 272;               // 图像的垂直像素
parameter DEPBIT  = 10 ;               // 数据位宽

//wire define
wire  [ 7:0]		img_y	 		;
wire				monoc	  		;
wire				monoc_fall		;
wire           	 	hs_t0			;
wire           		vs_t0			;
wire            	de_t0			;
wire  [DEPBIT-1:0]	row_border_addr	;
wire  [DEPBIT-1:0]	row_border_data	;
wire  [DEPBIT-1:0]	col_border_addr	;
wire  [DEPBIT-1:0]	col_border_data	;
wire  [3:0]			num_col			;
wire  [3:0]			num_row			;
wire  [1:0]			frame_cnt		;
wire				project_done_flag;


//*****************************************************
//**                    main code
//*****************************************************

//RGB转YCbCr模块
rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (clk    ),            // 时钟信号
    .rst_n           (rst_n  ),            // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync (pre_frame_vsync),    // vsync信号
    .pre_frame_hsync (pre_frame_hsync),    // href信号
    .pre_frame_de    (pre_frame_de   ),    // data enable信号
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
    .img_blue        (pre_rgb[ 4:0 ] ),
    //图像处理后的数据接口
    .post_frame_vsync(vs_t0),               // vsync信号
    .post_frame_hsync(hs_t0),               // href信号
    .post_frame_de   (de_t0),               // data enable信号
    .img_y           (img_y),
    .img_cb          (),
    .img_cr          ()
);

//二值化模块
binarization u_binarization(
    //module clock
    .clk                (clk    ),          // 时钟信号
    .rst_n              (rst_n  ),          // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync    (vs_t0),            // vsync信号
    .pre_frame_hsync    (hs_t0),            // href信号
    .pre_frame_de       (de_t0),            // data enable信号
    .color              (img_y),
    //图像处理后的数据接口
    .post_frame_vsync   (post_frame_vsync), // vsync信号
    .post_frame_hsync   (post_frame_hsync), // href信号
    .post_frame_de      (post_frame_de   ), // data enable信号
    .monoc              (monoc           ), // 单色图像像素数据
    .monoc_fall         (monoc_fall      )
    //user interface
);

//投影模块
projection #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .H_PIXEL(H_PIXEL),
    .V_PIXEL(V_PIXEL),
    .DEPBIT (DEPBIT)
) u_projection(
    //module clock
    .clk                (clk    ),          // 时钟信号
    .rst_n              (rst_n  ),          // 复位信号（低有效）
    //Image data interface
    .frame_vsync        (post_frame_vsync), // vsync信号
    .frame_hsync        (post_frame_hsync), // href信号
    .frame_de           (post_frame_de   ), // data enable信号
    .monoc              (monoc           ), // 单色图像像素数据
    .ypos               (ypos),
    .xpos               (xpos),
    //project border ram interface
    .row_border_addr_rd (row_border_addr),
    .row_border_data_rd (row_border_data),
    .col_border_addr_rd (col_border_addr),
    .col_border_data_rd (col_border_data),
    //user interface
    .num_col            (num_col),
    .num_row            (num_row),
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag)
);

//数字特征识别模块
digital_recognition #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .H_PIXEL(H_PIXEL),
    .V_PIXEL(V_PIXEL),
    .NUM_WIDTH((NUM_ROW*NUM_COL<<2)-1)
)u_digital_recognition(
    //module clock
    .clk                (clk       ),        // 时钟信号
    .rst_n              (rst_n     ),        // 复位信号（低有效）
    //image data interface
    .monoc              (monoc     ),
    .monoc_fall         (monoc_fall),
    .color_rgb          (post_rgb  ),
    .xpos               (xpos      ),
    .ypos               (ypos      ),
    //project border ram interface
    .row_border_addr    (row_border_addr),
    .row_border_data    (row_border_data),
    .col_border_addr    (col_border_addr),
    .col_border_data    (col_border_data),
    .num_col            (num_col),
    .num_row            (num_row),
    //user interface
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag),
    .digit              (digit)
);


endmodule
