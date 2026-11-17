`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2026 09:53:55
// Design Name: 
// Module Name: control_unit
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


module control_unit(opcode,mem_read,mem_write,reg_write,ALUsrc1,ALUsrc2,ALUcontrol,
                    mem_to_reg,instr_type,branch,halt);
                    
    input [3:0] opcode;
    output reg mem_read,mem_write,reg_write,mem_to_reg,branch,halt;
    output reg [2:0] ALUcontrol;
    output reg ALUsrc1;
    output reg [1:0] ALUsrc2,instr_type;
    
    always@(*) begin
    //initializing all signals 
    mem_read = 0; mem_write = 0; reg_write = 0; mem_to_reg = 0; ALUsrc1 = 0;
    branch = 0; halt = 0;
    ALUcontrol = 3'd0;
    ALUsrc2 = 2'd0; instr_type = 2'd0;
    
    case(opcode)
        4'd0: begin //add
                ALUcontrol = 3'd0; 
                reg_write = 1;
                end
                
        4'd1: begin //add immediate
                ALUcontrol = 3'd0; 
                ALUsrc2 = 2'd1;
                reg_write = 1;
                instr_type = 2'd1;
                end
                
        4'd2: begin //sub
                ALUcontrol = 3'd1;
                reg_write = 1;
                end
                
        4'd4: begin //nand
                ALUcontrol = 3'd2; 
                reg_write = 1;
                end
                
        4'd5: begin //nor
                ALUcontrol = 3'd3; 
                reg_write = 1;
                end
                
        4'd6: begin //load
                ALUcontrol = 3'd0; 
                ALUsrc2 = 2'd1;
                mem_read = 1;
                reg_write = 1;
                instr_type = 2'd1;
                mem_to_reg = 1;
                end
                
        4'd7: begin //store
                ALUcontrol = 3'd0; 
                ALUsrc2 = 2'd1;
                mem_write = 1;
                instr_type = 2'd1;
                end
                
        4'd8: begin //branch
                ALUcontrol = 3'd0;
                ALUsrc2 = 2'd1; 
                branch = 1;
                instr_type = 2'd2;
                end
                
        4'd9: begin //jump
                ALUcontrol = 3'd0; 
                ALUsrc1 = 1;
                ALUsrc2 = 2'd3;
                branch = 1;
                end
                
        4'd10: begin //shift left
                ALUcontrol = 3'd4; 
                reg_write = 1;
                instr_type = 2'd1;
                end
                
        4'd11: begin //shift right
                ALUcontrol = 3'd5; 
                reg_write = 1;
                instr_type = 2'd1;
                end  
                
        4'd15: halt = 1; //halt 
                      
    endcase
    end
    
endmodule
