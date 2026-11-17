`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 19:33:29
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(clk,reset,ALUout_in,IR_in,B_in,ALUout_out,IR_out,B_out,
                Z_in,C_in,N_in,Z_out,C_out,N_out,
                mem_read_in,mem_read_out,reg_write_in,reg_write_out,
                mem_write_in,mem_write_out,mem_to_reg_in,mem_to_reg_out,
                branch_in,branch_out,instr_type_in,instr_type_out);
                
    input clk,reset;
    input [15:0] ALUout_in,IR_in,B_in;
    input  Z_in,C_in,N_in;
    input mem_read_in,reg_write_in,mem_write_in,mem_to_reg_in,branch_in;
    input [1:0] instr_type_in;
    
    output reg mem_read_out,reg_write_out,mem_write_out,
                mem_to_reg_out,branch_out;
    output reg [1:0] instr_type_out;
    output reg Z_out,C_out,N_out;
    output reg [15:0] ALUout_out,IR_out,B_out;
    
    always@(posedge clk) begin
        if(reset) begin
            ALUout_out <= 0;
            IR_out <= 0;
            B_out <= 0; 
            Z_out <= 0;
            C_out <= 0;
            N_out <= 0;
            mem_read_out <= 0;
            reg_write_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            branch_out <= 0;
            instr_type_out <= 0;
            end
        else begin
            ALUout_out <= ALUout_in;
            IR_out <= IR_in;
            B_out <= B_in; 
            Z_out <= Z_in;
            C_out <= C_in;
            N_out <= N_in;
            mem_read_out <= mem_read_in;
            reg_write_out <= reg_write_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out <= branch_in;
            instr_type_out <= instr_type_in;
            end
    end
endmodule
