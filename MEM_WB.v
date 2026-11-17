`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 21:09:46
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(clk,reset,LMD_in,ALUout_in,IR_in,LMD_out,ALUout_out,IR_out,
        reg_write_in,reg_write_out,mem_to_reg_in,mem_to_reg_out,
        instr_type_in,instr_type_out);
        
    input clk,reset;
    input [15:0] LMD_in,ALUout_in,IR_in;
    input reg_write_in,mem_to_reg_in;
    input [1:0] instr_type_in;
    
    output reg reg_write_out,mem_to_reg_out;
    output reg [1:0] instr_type_out;
    output reg [15:0] LMD_out,ALUout_out,IR_out;
    
    always@(posedge clk) begin
        if(reset) begin
            LMD_out <= 0;
            IR_out <= 0;
            ALUout_out <= 0; 
            reg_write_out <= 0;
            mem_to_reg_out <= 0;
            instr_type_out <= 0;
            end
        else begin
            LMD_out <= LMD_in;
            IR_out <= IR_in;
            ALUout_out <= ALUout_in; 
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            instr_type_out <= instr_type_in;
            end
    end
    
endmodule
