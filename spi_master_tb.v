`timescale 1ns/1ps
module spi_master_tb;

//宣告Testbench內要接的訊號
reg clk;
reg rst_n;
reg start;
reg [7:0] data_in;
wire [7:0] data_out;
wire busy;
wire sclk;
wire mosi;
reg miso;
wire cs_n;

//例化(instantiate) 你的DUT (Design Under Test)
spi_master uut(
	.clk(clk),
	.rst_n(rst_n),
	.start(start),
	.data_in(data_in),
	.data_out(data_out),
	.busy(busy),
	.sclk(sclk),
	.mosi(mosi),
	.miso(miso),
	.cs_n(cs_n)
);

//產生系統時脈,假設時脈週期 20ns(50MHz)
initial begin
	clk = 0;
	forever #10 clk = ~clk;  //10ns高,10ns低
end

//主控流程
initial begin
	rst_n = 0;
	start = 0;
	data_in = 8'h00;
	miso = 0;
	
	// Reset一小段時間
	#50;
	rst_n = 1;
	
	//等一下進入傳輸
	#50;
	
	//設定要送的資料
	data_in = 8'b10101010;  //假設傳送0xAA
	start = 1;
	#20;
	start = 0;  // Start只需要一拍脈衝
	
	//模擬MISO輸出
	wait(cs_n == 0);  //等待CS_N拉低開始傳輸
	forever begin
		@(negedge sclk);  //在SCLK下降緣設定MISO資料
		miso = $randm % 2; //模擬從機隨機給資料
	end
end
endmodule
