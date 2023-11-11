`timescale 1ns/100ps
`include "instr_set.v"

module cpu_id #(
    parameter WIDTH = 13,
    parameter IWIDTH = 5, //Instruction width. Widht of data part -> WIDTH-IWIDTH i.e 13 - 5 = 8 bit Data width
    parameter REG_F_SEL_SIZE = 4, //8 reg + PORT = 9 -> 4 bit
    parameter IN_B_SEL_SIZE = 2 // 00 - IMM, 01 - REG_F, 10 - DATA_MEM
)(
    IN,
    RST,
    PC_LD,
    ALU_OUT,
    IMM,
    IN_B_SEL,
    REG_F_SEL,
    EN_REG_F,
    D_MEM_ADDR,
    D_MEM_ADDR_MODE,  
    EN_D_MEM,
    EN_ACC,
    JMP_MODE,   
    BASE_REG_OFFSET,
    BASE_REG_LD,
    BASE_REG_DATA
);

input [WIDTH-1:0] IN;

output reg RST;
output reg PC_LD;
output reg [IWIDTH-2:0] ALU_OUT; //4 bit
output reg [(WIDTH-IWIDTH)-1:0] IMM;
output reg [IN_B_SEL_SIZE-1:0] IN_B_SEL;

//REG_F
output reg [REG_F_SEL_SIZE-1:0] REG_F_SEL;
output reg EN_REG_F;

//DATA_MEM
output reg [(WIDTH-IWIDTH)-1:0] D_MEM_ADDR;
output reg D_MEM_ADDR_MODE; //0 - ADDR from operand, 1 - ADDR form R0-R7
output reg EN_D_MEM;

output reg EN_ACC;
output reg JMP_MODE; // 0 - absolute, 1 - relative to base address register

//BASE ADDRESS REGISTER
output reg [(WIDTH-IWIDTH)-1:0] BASE_REG_OFFSET;
output reg BASE_REG_LD;
output reg [(WIDTH-IWIDTH)-1:0] BASE_REG_DATA;

//TO DO: STACK, MAIN REGISTER

always @(*) begin
    ALU_OUT = IN[WIDTH-2:(WIDTH-IWIDTH)];
    
    RST = 1'b0;
    PC_LD = 1'b0;
    EN_ACC = 1'b0;
    JMP_MODE = 1'b0;
    
    IN_B_SEL = 2'b10; //DATA_MEM
    IMM = {(WIDTH-IWIDTH){1'b0}};

    REG_F_SEL = {REG_F_SEL_SIZE{1'b0}}; // R0
    EN_REG_F = 1'b0;

    D_MEM_ADDR = {(WIDTH-IWIDTH){1'b0}};
    D_MEM_ADDR_MODE = 1'b0;
    EN_D_MEM = 1'b0;

    BASE_REG_OFFSET = {(WIDTH-IWIDTH){1'b0}};
    BASE_REG_LD = 1'b0;
    BASE_REG_DATA = {(WIDTH-IWIDTH){1'b0}};

    if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `RST) begin
        RST = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `LD) begin
        D_MEM_ADDR = IN[(WIDTH-IWIDTH)-1:0];
        IN_B_SEL = 2'b10; 
        EN_ACC = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `ST) begin
        D_MEM_ADDR = IN[(WIDTH-IWIDTH)-1:0];
        EN_D_MEM = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `LDR) begin
        REG_F_SEL = IN[REG_F_SEL_SIZE-1:0]; //LAST 4 bits of IN
        IN_B_SEL = 2'b01;
        EN_ACC = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `STR) begin
        REG_F_SEL = IN[REG_F_SEL_SIZE-1:0];
        EN_REG_F = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `BAR) begin
        BASE_REG_DATA = IN[(WIDTH-IWIDTH)-1:0];
        BASE_REG_LD = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `JMP) begin
        BASE_REG_OFFSET = IN[(WIDTH-IWIDTH)-1:0];
        JMP_MODE = 1'b0;
        PC_LD = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `JMPO) begin
        BASE_REG_OFFSET = IN[(WIDTH-IWIDTH)-1:0];
        JMP_MODE = 1'b1;
        PC_LD = 1'b1;
    end
    else if((IN[WIDTH-1:(WIDTH-IWIDTH)] == `XORR) ||
            (IN[WIDTH-1:(WIDTH-IWIDTH)] == `ORR)  ||
            (IN[WIDTH-1:(WIDTH-IWIDTH)] == `ANDR) ||
            (IN[WIDTH-1:(WIDTH-IWIDTH)] == `ADDR) ||
            (IN[WIDTH-1:(WIDTH-IWIDTH)] == `SUBR)
    ) begin
        REG_F_SEL = IN[REG_F_SEL_SIZE-1:0]; 
        IN_B_SEL = 2'b01;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `LDI) begin
        IMM = IN[(WIDTH-IWIDTH)-1:0];
        IN_B_SEL = 2'b00; 
        EN_ACC = 1'b1;
    end
    else if(IN[WIDTH-1:(WIDTH-IWIDTH)] == `LDAR) begin
        REG_F_SEL = IN[REG_F_SEL_SIZE-1:0];
        D_MEM_ADDR_MODE = 1'b1;
        IN_B_SEL = 2'b10; 
        EN_ACC = 1'b1;
    end
end

endmodule