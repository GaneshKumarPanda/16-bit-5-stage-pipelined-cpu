`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 13:53:15
// Design Name: 
// Module Name: pc
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


module pc(clk,NPC,PC,reset,halt);
    input clk,halt,reset;
    input [7:0] NPC;
    output reg [7:0] PC;
    
    always @(posedge clk) begin
        if (reset)
            PC <= 8'd0;
        else if (halt)
            PC <= PC;
        else
            PC <= NPC;
    end

endmodule
