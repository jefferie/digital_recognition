// Descriptions:  时钟分频模块  
//****************************************************************************************//

module	clk_div(
    input				clk			,		// 100M时钟信号
    input				rst_n		,		// 复位信号，低电平有效
	input		[15:0]	ID_lcd		,		//LCD的ID
	output	reg			clk_lcd		        //驱动LCD的时钟
);

//parameter define
parameter	ID_4342 = 0;
parameter	ID_7084 = 1;
parameter	ID_7016 = 2;
parameter	ID_1018 = 5;

//wire define
wire	clk_33m;			//输出的33.3m时钟

//reg define
reg			clk_33m_0;
reg			clk_33m_1;
reg	[1:0]	cnt_33m;		//33.3m计数器
reg	[2:0]	cnt_10m;		//10m计数器
reg			clk_50m;		//输出的50m时钟
reg			clk_10m;		//输出的10m时钟

//*****************************************************
//**                    main code
//*****************************************************

//50m hz时钟分频
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        clk_50m <= 1'd0;
	else
		clk_50m <= ~clk_50m;
end

//33.3m hz时钟分频计数器（3分频电路）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
		cnt_33m <= 2'b0;
	else if (cnt_33m == 2'd2)
		cnt_33m <= 2'b0;
	else
		cnt_33m <= cnt_33m + 1'b1;
end

//33.3m hz时钟分频（3分频电路）
always @(posedge clk) begin
    if(!rst_n)
        clk_33m_0 <= 1'b1;
	else if ((cnt_33m == 2'd1) || (cnt_33m == 2'd2))
		clk_33m_0 <= ~clk_33m_0;
	else
		clk_33m_0 <= clk_33m_0;
end

always @(negedge clk) begin
    if(!rst_n)
        clk_33m_1 <= 1'b1;
	else if ((cnt_33m == 2'd1) || (cnt_33m == 2'd2))
		clk_33m_1 <= ~clk_33m_1;
	else
		clk_33m_1 <= clk_33m_1;
end

assign	clk_33m = clk_33m_0 & clk_33m_1;

//10m hz时钟分频计数器（10分频电路）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
		cnt_10m <= 3'b0;
	else if (cnt_10m == 3'd4)
		cnt_10m <= 3'b0;
	else
		cnt_10m <= cnt_10m + 1'b1;
end

//10m hz时钟分频（10分频电路）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_10m <= 1'd0;
    end
	else if (cnt_10m == 3'd4)
		clk_10m <= ~clk_10m;
	else
		clk_10m <= clk_10m;
end

//选择输出的时钟
always @(*) begin
    case(ID_lcd)
		ID_4342: clk_lcd <= clk_10m;
		ID_7084: clk_lcd <= clk_33m;
		ID_7016: clk_lcd <= clk_50m;
		ID_1018: clk_lcd <= clk_50m;
	default: clk_lcd <= clk_10m;
	endcase
end

endmodule
