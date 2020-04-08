// Descriptions:    myram
//****************************************************************************************//

module	myram #(
	parameter WIDTH = 1,				// 数据的位宽（位数）
	parameter DEPTH = 800,				// 数据的深度（个数）
	parameter DEPBIT = 10				// 地址的位宽
	
)(
    input					clk		,	// 时钟信号
    
	//ram interface
	input					we		,
	input	[DEPBIT-1'b1:0]	waddr	,
	input	[DEPBIT-1'b1:0]	raddr	,
	input	[WIDTH -1'b1:0]	dq_i	,
	output	[WIDTH -1'b1:0]	dq_o	
);

//wire define


//reg define
reg [WIDTH - 1'b1:0] mem [DEPTH - 1'b1:0];

//parameter define


//*****************************************************
//**                    main code
//*****************************************************

assign dq_o = mem[raddr];

always @(posedge clk) begin
    if(we) 
        mem[waddr-1] <= dq_i;
end

endmodule
