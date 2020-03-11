// Descriptions:    读RGB LCD显示屏 的ID
//****************************************************************************************//

module	rd_id(
    input				clk			,		// 时钟信号
    input				rst_n		,		// 复位信号，低电平有效
	
	input		[15:0]	lcd_rgb		,		//像素点数据
	output	reg	[15:0]	ID_lcd				//输出LCD的ID号
);	

//reg define
reg ID_rd_en;

//*****************************************************
//**                    main code
//*****************************************************

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ID_lcd   <= 16'd0;
		ID_rd_en <= 1'd0;
    end
	else if (!ID_rd_en) begin
		ID_lcd <= {13'b0,lcd_rgb[4],lcd_rgb[10],lcd_rgb[15]};
		ID_rd_en <= 1'd1;
	end
	else
		ID_lcd <= ID_lcd;
end

endmodule
