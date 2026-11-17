`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 19:32:58
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF_ID(clk,reset,IR_in,IR_out,PC_in,PC_out,flush);
    input clk,reset,flush;
    input [15:0] IR_in;
    input [7:0] PC_in;
    
    output reg [15:0] IR_out;
    output reg [7:0] PC_out;
    
    always@(posedge clk) begin
        if(reset || flush) begin
            IR_out <= 0;
            PC_out <= 0; end
        else begin
            IR_out <= IR_in;
            PC_out <= PC_in; end
    end
endmodule
