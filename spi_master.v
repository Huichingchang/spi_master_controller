module spi_master (
	input wire clk,  //系統時脈
	input wire rst_n,  //非同步Reset(低有效)
	input wire start,  //開始傳輸
	input wire [7:0] data_in,  //要傳送的資料
	output reg [7:0] data_out,  //接收到的資料
	output reg busy,  //傳輸進行中標誌
	output reg sclk,  //SPI時脈輸出
	output reg mosi,  //主送從收
	input wire miso,  //從送主收
	output reg cs_n   //從機選擇(低有效)
);

//狀態定義
localparam IDLE = 2'b00;
localparam LOAD = 2'b01;
localparam TRANS = 2'b10;
localparam DONE = 2'b11;

reg [1:0] state, next_state;
reg [7:0] tx_reg;
reg [7:0] rx_reg;
reg [2:0] bit_cnt;

// Clock Divider參數(假設除4倍慢下來)
parameter DIVIDER = 4;
reg [1:0] clk_div;
wire clk_en;

assign clk_en = (clk_div == 0);

// Clock Divider計數
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		clk_div <= 0;
	else if (busy)
		clk_div <= clk_div + 1;
	else
		clk_div <= 0;
end

//主狀態機
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		state <= IDLE;
	else 
		state <= next_state;
end

//下一個狀態邏輯
always @(*) begin
	case(state)
		IDLE: next_state = (start)? LOAD: IDLE;
		LOAD: next_state = TRANS;
		TRANS: next_state = (bit_cnt == 3'd7 && clk_en)? DONE: TRANS;
		DONE: next_state = IDLE;
		default: next_state = IDLE;
	endcase
end

//傳輸過程
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
			tx_reg <= 8'd0;
			rx_reg <= 8'd0;
			bit_cnt <= 3'd0;
			sclk <= 1'b0;
			cs_n <= 1'b1;
			mosi <= 1'b0;
			data_out <= 8'd0;
			busy <= 1'b0;
	end else begin
		case (state)
			IDLE: begin
				busy <= 1'b0;
				cs_n <= 1'b1;
				sclk <= 1'b0;
			end
			
			LOAD: begin
				busy <= 1'b1;
				cs_n <= 1'b0;  //啟動CS
				tx_reg <= data_in;
				bit_cnt <= 3'd0;
			end
			
			TRANS: begin
				if (clk_en) begin
					sclk <= ~sclk;
					if (!sclk) begin
						mosi <= tx_reg [7];  //傳送最高位元
						tx_reg <= {tx_reg[6:0], 1'b0};
					end else begin
						rx_reg <= {rx_reg[6:0], miso};  //接收資料
						bit_cnt <= bit_cnt + 1;
					end
				end
			end
			
			DONE: begin
				busy <= 1'b0;
				cs_n <= 1'b1;  //關閉CS,傳輸結束拉高
				data_out <= rx_reg;  //輸出接收的資料
				sclk <= 1'b0;
			end
		endcase
	end
end
endmodule
