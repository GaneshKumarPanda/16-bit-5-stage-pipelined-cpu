`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2026 16:27:00
// Design Name: 
// Module Name: main
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


module main(clk,reset);
    input clk,reset;
    
    //IF stage declarations
    wire [15:0] IF_IR;
    wire [15:0] IF_ID_IR;
    wire [7:0] IF_ID_PC;
    
    //ID stage declarations
    wire [15:0] ID_A,ID_B,ID_imm;
    wire [15:0] ID_EX_A,ID_EX_B,ID_EX_IR,ID_EX_imm;
    wire [7:0] ID_EX_PC;
    wire ID_EX_mem_to_reg,ID_EX_mem_read,ID_EX_mem_write,
        ID_EX_branch,ID_EX_ALUsrc1,ID_EX_reg_write;
    wire [1:0] ID_EX_instr_type,ID_EX_ALUsrc2;
    wire [2:0] ID_EX_ALUcontrol;
    
    //EX stage declarations
    wire [15:0] EX_MEM_ALUout,EX_MEM_IR,EX_MEM_B;
    wire [15:0] EX_A_inter,EX_B_inter;
    wire [15:0] EX_ALUout,EX_A,EX_B;
    wire [1:0] EX_MEM_instr_type;
    wire EX_Z,EX_C,EX_N;
    wire EX_MEM_Z, EX_MEM_C, EX_MEM_N;
    wire EX_MEM_mem_to_reg,EX_MEM_mem_read,EX_MEM_mem_write,EX_MEM_reg_write,EX_MEM_branch;
    
    //MEM stage declarations
    wire [15:0] MEM_LMD;
    wire [15:0] MEM_WB_LMD,MEM_WB_ALUout,MEM_WB_IR;
    wire [1:0] MEM_WB_instr_type;
    wire MEM_WB_mem_to_reg,MEM_WB_reg_write;
    
    //from pc.v
    wire [7:0] PC,NPC;
    
    //from control_unit.v
    wire mem_read,mem_write,reg_write,ALUsrc1,mem_to_reg,branch,halt;
    wire [2:0] ALUcontrol;
    wire [1:0] instr_type,ALUsrc2;
    
    //from register_file.v
    wire write_enable;
    wire [2:0] write_addr;
    wire [15:0] write_data;
    wire [2:0] rs,rd,rt;
                 
    
    //IF modules
    pc program_counter(.clk(clk),.NPC(NPC),.PC(PC),.reset(reset),.halt(halt));
    instruction_mem IM(.PC(PC),.IR(IF_IR));
    
    //IF_ID
    IF_ID s1(.clk(clk),.reset(reset),.IR_in(IF_IR),.IR_out(IF_ID_IR),
                .PC_in(PC),.PC_out(IF_ID_PC),.flush(branch_taken));
                
     //IF_ID assignments
    assign rs = IF_ID_IR[11:9];
    assign rt = IF_ID_IR[8:6];
    assign rd = IF_ID_IR[5:3];
    assign ID_imm = (instr_type == 2'd0) ? {{13{IF_ID_IR[2]}},IF_ID_IR[2:0]} :
                    (instr_type == 2'd1) ? {{10{IF_ID_IR[5]}},IF_ID_IR[5:0]} :
                    (instr_type == 2'd2) ? {{7{IF_ID_IR[8]}},IF_ID_IR[8:0]} : 16'd0;
    
                
    //ID modules
    register_file RF(.clk(clk),.write_enable(write_enable),.read_addr1(rs),
                        .read_addr2(rt),.read_data1(ID_A),
                        .read_data2(ID_B),.write_addr(write_addr),
                        .write_data(write_data));
    control_unit CU(.opcode(IF_ID_IR[15:12]),.mem_read(mem_read),.mem_write(mem_write),
                    .reg_write(reg_write),.ALUsrc1(ALUsrc1),.ALUsrc2(ALUsrc2),
                    .ALUcontrol(ALUcontrol),.mem_to_reg(mem_to_reg),.instr_type(instr_type),
                    .branch(branch),.halt(halt));

    //ID_EX
    ID_EX s2(.clk(clk),.reset(reset),.PC_in(IF_ID_PC),.A_in(ID_A),.B_in(ID_B),
                .IR_in(IF_ID_IR),.immediate_in(ID_imm),.PC_out(ID_EX_PC),
                .A_out(ID_EX_A),.B_out(ID_EX_B),.IR_out(ID_EX_IR),.immediate_out(ID_EX_imm),
                .mem_read_in(mem_read),.mem_read_out(ID_EX_mem_read),
                .reg_write_in(reg_write),.reg_write_out(ID_EX_reg_write),
                .mem_write_in(mem_write),.mem_write_out(ID_EX_mem_write),
                .mem_to_reg_in(mem_to_reg),.mem_to_reg_out(ID_EX_mem_to_reg),
                .branch_in(branch),.branch_out(ID_EX_branch),
                .ALUcontrol_in(ALUcontrol),.ALUcontrol_out(ID_EX_ALUcontrol),
                .ALUsrc1_in(ALUsrc1),.ALUsrc1_out(ID_EX_ALUsrc1),
                .instr_type_in(instr_type),.instr_type_out(ID_EX_instr_type),
                .ALUsrc2_in(ALUsrc2),.ALUsrc2_out(ID_EX_ALUsrc2),
                .flush(branch_taken));   
                 
    //ID_EX assignments
    assign EX_A_inter = (ID_EX_ALUsrc1)?ID_EX_PC:ID_EX_A;
    assign EX_B_inter = (ID_EX_ALUsrc2 == 2'd0) ? ID_EX_B :
                        (ID_EX_ALUsrc2 == 2'd1) ? ID_EX_imm :
                        (ID_EX_ALUsrc2 == 2'd2) ? 16'd1 : 16'd0; //target offset missing 
    
    //forwarding implementation
    wire [2:0] MEM_WB_IR_dest, EX_MEM_IR_dest;
    assign EX_MEM_IR_dest = (EX_MEM_instr_type == 2'd0) ? EX_MEM_IR[5:3] : EX_MEM_IR[8:6];
    assign MEM_WB_IR_dest = (MEM_WB_instr_type == 2'd0) ? MEM_WB_IR[5:3] : MEM_WB_IR[8:6];
    
    assign EX_A = (EX_MEM_reg_write && (ID_EX_IR[11:9] == EX_MEM_IR_dest)) ? EX_MEM_ALUout :
              (MEM_WB_reg_write && (ID_EX_IR[11:9] == MEM_WB_IR_dest)) ? write_data    :
                                                                         EX_A_inter;

    assign EX_B = (ID_EX_ALUsrc2 == 2'd0) ? //only when B is register, not immediate
                  ((EX_MEM_reg_write && (ID_EX_IR[8:6] == EX_MEM_IR_dest)) ? EX_MEM_ALUout :
                   (MEM_WB_reg_write && (ID_EX_IR[8:6] == MEM_WB_IR_dest)) ? write_data    :
                                                                              EX_B_inter)
                  : EX_B_inter;
    
    //branch instruction flushing implementation
    wire branch_taken;
    assign branch_taken = ID_EX_branch && (ID_EX_A == 16'b0);
    assign NPC = branch_taken ? (ID_EX_PC + ID_EX_imm[7:0]) : (PC + 8'd1);
    
    
    //EX modules
    alu AL(.A(EX_A),.B(EX_B),.ALUcontrol(ID_EX_ALUcontrol),
            .result(EX_ALUout),.Z(EX_Z),.N(EX_N),.C(EX_C));
            
    //EX_MEM stage
    EX_MEM s3(.clk(clk),.reset(reset),.ALUout_in(EX_ALUout),.IR_in(ID_EX_IR),.B_in(ID_EX_B),
            .ALUout_out(EX_MEM_ALUout),.IR_out(EX_MEM_IR),.B_out(EX_MEM_B),
            .Z_in(EX_Z),.C_in(EX_C),.N_in(EX_N),
            .Z_out(EX_MEM_Z),.C_out(EX_MEM_C),.N_out(EX_MEM_N),
            .mem_read_in(ID_EX_mem_read),.mem_read_out(EX_MEM_mem_read),
            .reg_write_in(ID_EX_reg_write),.reg_write_out(EX_MEM_reg_write),
            .mem_write_in(ID_EX_mem_write),.mem_write_out(EX_MEM_mem_write),
            .mem_to_reg_in(ID_EX_mem_to_reg),.mem_to_reg_out(EX_MEM_mem_to_reg),
            .branch_in(ID_EX_branch),.branch_out(EX_MEM_branch),
            .instr_type_in(ID_EX_instr_type),.instr_type_out(EX_MEM_instr_type));
            
            
    //MEM modules
    data_memory DM(.clk(clk),.data_addr(EX_MEM_ALUout[7:0]),
                .data_in(EX_MEM_B),.data_out(MEM_LMD),
                .mem_read(EX_MEM_mem_read),.mem_write(EX_MEM_mem_write));
                
    //MEM_WB stage
    MEM_WB s4(.clk(clk),.reset(reset),.LMD_in(MEM_LMD),.ALUout_in(EX_MEM_ALUout),
                .IR_in(EX_MEM_IR),.LMD_out(MEM_WB_LMD),.ALUout_out(MEM_WB_ALUout),
                .IR_out(MEM_WB_IR),
                .reg_write_in(EX_MEM_reg_write),.reg_write_out(MEM_WB_reg_write),
                .mem_to_reg_in(EX_MEM_mem_to_reg),.mem_to_reg_out(MEM_WB_mem_to_reg),
                .instr_type_in(EX_MEM_instr_type),.instr_type_out(MEM_WB_instr_type));   
                
    //MEM_WB assignments
    assign write_data = (MEM_WB_mem_to_reg)? MEM_WB_LMD : MEM_WB_ALUout;
    assign write_addr = (MEM_WB_instr_type == 2'd0) ? MEM_WB_IR[5:3] :
                        (MEM_WB_instr_type == 2'd1) ? MEM_WB_IR[8:6] : 3'd0;
    assign write_enable = MEM_WB_reg_write;
    
endmodule
