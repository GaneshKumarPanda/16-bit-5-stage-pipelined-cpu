`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 16:34:36
// Design Name: 
// Module Name: alu
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


module alu(A,B,ALUcontrol,result,Z,N,C);
    input [15:0] A,B;
    input [2:0] ALUcontrol;
    output reg [15:0] result;
    output Z,N;
    output reg C;
    
    always@(*) begin
        C = 1'b0;
        case(ALUcontrol)
            3'd0: {C,result} = A + B;
            3'd1: result = A - B;
            3'd2: result = ~(A&B);
            3'd3: result = ~(A|B);
            3'd4: result = A << B;
            3'd5: result = A >> B;
            default: result = 0;
        endcase
    end

    assign Z = (result == 16'b0);
    assign N = result[15];
    
endmodule
