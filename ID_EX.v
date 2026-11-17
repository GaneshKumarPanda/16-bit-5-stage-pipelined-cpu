`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 19:43:07
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(clk,reset,PC_in,A_in,B_in,IR_in,immediate_in,
                        PC_out,A_out,B_out,IR_out,immediate_out,
                        mem_read_in,mem_read_out,reg_write_in,reg_write_out,
                        mem_write_in,mem_write_out,mem_to_reg_in,mem_to_reg_out,
                        branch_in,branch_out,ALUcontrol_in,ALUcontrol_out,
                        ALUsrc1_in,ALUsrc2_in,instr_type_in,ALUsrc1_out,
                        ALUsrc2_out,instr_type_out,flush);
    input clk,reset,flush;
    input [7:0] PC_in;
    input [15:0] A_in,B_in,immediate_in,IR_in;
    
    output reg [15:0] A_out,B_out,immediate_out,IR_out;
    output reg [7:0] PC_out;
    
    input mem_read_in,reg_write_in,mem_write_in,branch_in,mem_to_reg_in,ALUsrc1_in;
    input [2:0] ALUcontrol_in;
    input [1:0] ALUsrc2_in,instr_type_in;
    
    output reg mem_read_out,reg_write_out,mem_write_out,branch_out,mem_to_reg_out,ALUsrc1_out;
    output reg [2:0] ALUcontrol_out;
    output reg [1:0] ALUsrc2_out,instr_type_out;
    
    always@(posedge clk) begin
        if(reset || flush) begin
            A_out <= 0;
            B_out <= 0;
            PC_out <= 0;
            immediate_out <= 0; 
            IR_out <= 0; 
            mem_read_out <= 0;
            reg_write_out <= 0;
            mem_write_out <= 0;
            branch_out <= 0;
            mem_to_reg_out <= 0;
            ALUcontrol_out <= 0;
            ALUsrc1_out <= 0;
            ALUsrc2_out <= 0;
            instr_type_out <= 0;
            end
        else begin
            A_out <= A_in;
            B_out <= B_in;
            PC_out <= PC_in;
            immediate_out <= immediate_in; 
            IR_out <= IR_in; 
            mem_read_out <= mem_read_in;
            reg_write_out <= reg_write_in;
            mem_write_out <= mem_write_in;
            branch_out <= branch_in;
            mem_to_reg_out <= mem_to_reg_in;
            ALUcontrol_out <= ALUcontrol_in;
            ALUsrc1_out <= ALUsrc1_in;
            ALUsrc2_out <= ALUsrc2_in;
            instr_type_out <= instr_type_in;
            end
    end
     
endmodule
