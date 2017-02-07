/* There are multiple ways of transfering data from one domain to another.
* 1. use a graycoding technique and a 2 flop synchronizer for monotonically
* increasing by fixed value counters.
* 2. use an async FIFO for data which is comming at rate and needs to be
* maintained at rate.
* 3. synchronize the enable bit and encode understanding of clock domain
* relationship in the wait cycle until source data is changed.
* 4. Use full handshake between source and destination domain. This has the
* interface of the async FIFO based implementation but does not waste gates in
* FIFO logic under the assumption that a hit in data rate is acceptable.
*/
module wordSync (
	input wire sclk,
	input wire srst_n,
	input wire dclk,
	input wire drst_n,
	input wire [DWIDTH -1:0] din,
	input wire din_en,
	output wire srdy,

	output wire dout_rdy,
	output wire dout_ack,
	output reg [DWIDTH -1:0] dout,

	);
	always @(posedge sclk or negedge srst_n)
	begin
		if (!srst_n)begin
			srdy<=1'b0;
			inrst<=1'b1;
			data<=1'b0;
			
		end else begin
			if(inrst) srdy<=1'b1;
			inrst<=1'b0;
		if(sen)begin
			data<=~data;
			srdy<=1'b0;
			d<=din;
		end
		if(dack_sync)begin
			data<=1'b0;
			srdy<=1'b1;

		end
	end
	bitsync src2dest(
		.din(data),
		.clk(dclk),
		.rst_n(drst_n),
		.dout(data_out));
	always @(posedge dclk or negedge drst_n)
	begin
		if(!drst_n)begin
			drdy<=1'b0;
			ddata<=1'b0;
			data_out1<=1'b0;
		end
		else if(dack)begin
			ddata<=data_out;
			drdy<=0;
		end
		if(data_out ^ data_out1) drdy<=1'b1;
		data_out1<=data_out;

	end
	bitsync dest2src (
		.din(data_out1),
		.clk(sclk),
		.rst_n(srst_n),
		.dout(dack_sync)
	);
endmodule
