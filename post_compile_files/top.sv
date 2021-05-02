`line 2 "top.tlv" 0 //_\TLV_version 1d: tl-x.org, generated by SandPiper(TM) 1.11-2021/01/28-beta
`include "sp_default.vh" //_\SV
   // Included URL: "https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/c1719d5b338896577b79ee76c2f443ca2a76e14f/tlv_lib/risc-v_shell_lib.tlv"// Included URL: "https://raw.githubusercontent.com/stevehoover/warp-v_includes/2d6d36baa4d2bc62321f982f78c8fe1456641a43/risc-v_defs.tlv"
	module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, output wire passed, output wire failed);    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  /* verilator lint_restore */  /* verilator lint_off WIDTH */ /* verilator lint_off UNOPTFLAT */   // (Expanded in Nav-TLV pane.)

/*
     // ------------------------------------------------------------------------------------------------------ //
     //                                5 STAGE PIPELINED nPOWER CPU SIMULATION                                 //
     // ------------------------------------------------------------------------------------------------------ //
     //    Members Involved :                                                                                  //
     //       o 191CS102 : AAKARSHEE JAIN                                                                      //
     //       o 191CS123 : IKJOT SINGH DHODY                                                                   //
     //       o 191CS124 : ISHAAN SINGH                                                                        //
     //       o 191CS160 : SWAPNIL GUDURU                                                                      //
     // ------------------------------------------------------------------------------------------------------ //
     //    Program Simulated by Instruction Set :                                                              //
     //       Multiplication Tables of the number declared in \TLV rf() function - line 66.                    //
     // ------------------------------------------------------------------------------------------------------ //
     //    How to execute the program :                                                                        //
     //       o Change the number on line 66 to the number whose multiplicative tables are needed.             //
     //       o Our instruction set will use that number and perform multiplication using an addition loop.    //
     //       o The program terminates when the register holds the nth multiple of the number you input.       //
     //       o If the program and simulation was successful, the logs will report so, and viceversa.          //
     //       o Use the waveform to see how the CPU updates the register values for register \xreg[14].        //
     //       o You need to change the input on line 66 and enter expected termination multiple on line 192.   //
     // ------------------------------------------------------------------------------------------------------ //
*/

// ------------------ LIBRARY CODE STARTS HERE ------------------ //
/* 
   Instruction Memory Implementation
      o ADD  x14, x0,  x0    -   initialise x14 to 0
      o ADDI x12, x0,  10    -   initialise x12 to 10
      o ADD  x13, x0,  x0    -   initialise x13 to 0
      o ADD  x14, x15, x14   -   x14 = x14 + x15  //  x15 is the input provided
      o ADDI x13, x13, 1     -   x13 = x13 + 1
      o BLT  x13, x12, -8    -   loop id x13 < x12
      o SDW  x14, 1000       -   store double word
      o LDW  x14, 1000       -   load double word
*/
`line 76 "top.tlv" 1
// ------------------ LIBRARY CODE ENDS HERE ------------------ //
// DRIVER CODE
`include "top_gen.sv" //_\TLV
   // Inst #0: 
   
   //_|cpu
      //_@0 // PC IMPLEMENTATION
         assign CPU_reset_a0 = reset;
         assign CPU_start_a0 = CPU_reset_a1 && !CPU_reset_a0;
         
         assign CPU_pc_a0[31:0] = CPU_reset_a1 ? 32'b0 :
                     CPU_valid_taken_br_a3 ? CPU_br_tgt_pc_a3 :
                     CPU_inc_pc_a1;
      
      //_@1 // INSTRUCTION FETCH and PC INCREMENT
         
         // Default PC Increment
         assign CPU_inc_pc_a1[31:0] = CPU_pc_a1 + 32'd4;
         
         // Fetch the Instruction from Instruction Memory
         assign CPU_imem_rd_en_a1 = !CPU_reset_a1;
         assign CPU_imem_rd_addr_a1[3-1:0] = CPU_pc_a1[3+1:2];
         assign CPU_instr_a1[31:0] = CPU_imem_rd_data_a1[31:0];
         
         // Extract the PO, XO, REGISTER INDICES and IMMEDIATE FIELDS from Instuction
         assign CPU_po_bits_a1[5:0] = {CPU_instr_a1[31:26]};
         assign CPU_xo_bits_a1[9:0] = CPU_instr_a1[9:1];
         assign CPU_imm_a1[63:0] = (CPU_po_bits_a1 ==? 6'd14) ? {{48{CPU_instr_a1[15]}}, CPU_instr_a1[15:0]} :
                      (CPU_po_bits_a1 ==? 6'd28) ? {{48{CPU_instr_a1[15]}}, CPU_instr_a1[15:0]} :
                      (CPU_po_bits_a1 ==? 6'd24) ? {{48{CPU_instr_a1[15]}}, CPU_instr_a1[15:0]} :
                      (CPU_po_bits_a1 ==? 6'd58) ? {{50{CPU_instr_a1[15]}}, CPU_instr_a1[15:2]} :
                      (CPU_po_bits_a1 ==? 6'd62) ? {{50{CPU_instr_a1[15]}}, CPU_instr_a1[15:2]} :
                      (CPU_po_bits_a1 ==? 6'd19) ? {{50{CPU_instr_a1[15]}}, CPU_instr_a1[15:2]} : 64'd0;
         assign CPU_rd_valid_a1 = (CPU_po_bits_a1 ==? 6'd31) ? 1 : 0;
         assign CPU_rs2_a1[4:0] = CPU_instr_a1[25:21];
         assign CPU_rs1_a1[4:0] = CPU_instr_a1[20:16];
         //_?$rd_valid
            assign CPU_rd_a1[4:0] = CPU_instr_a1[15:11];
      
      //_@2 // INSTRUCTION DECODE and REGISTER FILE DATA ACCESS
         
         // Determine the exact type of instruction
         assign CPU_is_sub_a2  = (CPU_po_bits_a2 == 31) && (CPU_xo_bits_a2 == 40);
         assign CPU_is_and_a2  = (CPU_po_bits_a2 == 31) && (CPU_xo_bits_a2 == 28);
         assign CPU_is_add_a2  = (CPU_po_bits_a2 == 31) && (CPU_xo_bits_a2 == 266);
         assign CPU_is_nand_a2 = (CPU_po_bits_a2 == 31) && (CPU_xo_bits_a2 == 476);
         assign CPU_is_or_a2   = (CPU_po_bits_a2 == 31) && (CPU_xo_bits_a2 == 444);
         assign CPU_is_addi_a2 = (CPU_po_bits_a2 == 14);
         assign CPU_is_andi_a2 = (CPU_po_bits_a2 == 28);
         assign CPU_is_ori_a2  = (CPU_po_bits_a2 == 24);
         assign CPU_is_ld_a2   = (CPU_po_bits_a2 == 58);
         assign CPU_is_std_a2  = (CPU_po_bits_a2 == 62);
         assign CPU_is_b_a2    = (CPU_po_bits_a2 == 19);
         
         // Read Data from Register File
         assign CPU_rf_rd_en1_a2 = 1;
         assign CPU_rf_rd_index1_a2[4:0] = CPU_rs1_a2;
         assign CPU_rf_rd_en2_a2 = 1;
         assign CPU_rf_rd_index2_a2[4:0] = CPU_rs2_a2;
         
         // Set correct source values for the ALU operation
         // Since there is a pipeline in effect, we check for hazards
         assign CPU_temp_a2 = CPU_rf_rd_index2_a2 << 2;
         assign CPU_src1_value_a2[63:0] = (CPU_rf_wr_index_a3 == CPU_rf_rd_index1_a2) && CPU_rf_wr_en_a3 ? CPU_result_a3 : CPU_rf_rd_data1_a2;
         assign CPU_src3_value_a2[63:0] = (CPU_rf_wr_index_a3 == CPU_temp_a2) && CPU_rf_wr_en_a3 ? CPU_result_a3 : CPU_rf_rd_data2_a2;
         assign CPU_src2_value_a2[63:0] = (CPU_rf_wr_index_a3 == CPU_rf_rd_index2_a2) && CPU_rf_wr_en_a3 ? CPU_result_a3 : CPU_rf_rd_data2_a2;
         
         // Branch Target PC for Branch Type Instruction
         assign CPU_br_tgt_pc_a2[31:0] = CPU_pc_a2 + CPU_imm_a2;
      
      //_@3
         // Set Vaid bit to indicate a successful branch
         assign CPU_taken_br_a3 = CPU_is_b_a3 ? (CPU_src1_value_a3 == CPU_src3_value_a3) : 0;
         
         // Branching leads to immediate stall 
         // In the case of read after write with a branch condition in next cycle
         // The valid bit will help increment the PC every cycle instead of every 3 cycles.
         assign CPU_valid_a3 = !(CPU_valid_taken_br_a4 || CPU_valid_taken_br_a5 || CPU_valid_load_a4 || CPU_valid_load_a5);
         
         // Valid Signal for branching which feeds into PC so that during pipeline,
         // unnecesarily, PC doesn't increment for INVALID CYCLES. 
         assign CPU_valid_taken_br_a3 = CPU_valid_a3 && CPU_taken_br_a3;
         
         // ALU Implmentation based on type of Instruction
         assign CPU_result_a3[63:0] = CPU_is_sub_a3  ? CPU_src1_value_a3 - CPU_src2_value_a3 :
                         CPU_is_and_a3  ? CPU_src1_value_a3 & CPU_src2_value_a3 :
                         CPU_is_add_a3  ? CPU_src1_value_a3 + CPU_src2_value_a3 :
                         CPU_is_nand_a3 ? ~(CPU_src1_value_a3 & CPU_src2_value_a3) :
                         CPU_is_or_a3   ? CPU_src1_value_a3 | CPU_src2_value_a3 :
                         CPU_is_addi_a3 ? CPU_src1_value_a3 + CPU_imm_a3 :
                         CPU_is_andi_a3 ? CPU_src1_value_a3 & CPU_imm_a3 :
                         CPU_is_ori_a3  ? CPU_src1_value_a3 | CPU_imm_a3 :
                         CPU_is_ld_a3   ? CPU_src1_value_a3 + CPU_imm_a3 :
                         CPU_is_std_a3  ? CPU_src1_value_a3 + CPU_imm_a3 :
                         CPU_is_b_a3    ? CPU_src1_value_a3 + CPU_imm_a3 : 0;
         
         // Set a valid bit to indicate a valid load instruction
         assign CPU_valid_load_a3 = CPU_valid_a3 && CPU_is_ld_a3;
         
         // Register File Write - Considering three cases
         //    o Will be enabled only when Valid Bit is high
         //    o Along with that destination register needs to be valid
         //    o Destination register cannot be zero as it will be treated as R0 by nPOWER ISA standards. 
         assign CPU_rf_wr_en_a3 = (CPU_valid_a3 && CPU_rd_valid_a3) || CPU_valid_load_a5;
         assign CPU_rf_wr_index_a3[4:0] = CPU_valid_load_a5 ? CPU_rd_a5 : CPU_rd_a3;
         assign CPU_rf_wr_data_a3[63:0] = CPU_valid_load_a5 ? CPU_ld_data_a5 : CPU_result_a3;
      
      //_@4 // DATA MEMORY WRITES and READS
         assign CPU_dmem_wr_en_a4 = CPU_is_std_a4 && CPU_valid_a4; // store
         assign CPU_dmem_rd_en_a4 = CPU_is_ld_a4;            // load
         assign CPU_dmem_addr_a4  = CPU_result_a4[5:2];
         assign CPU_dmem_wr_data_a4[63:0] = CPU_src2_value_a4;
      
      //_@5 // MAKE DMEM AVAILABLE FOR NEXT CYCLES, SET PASS AND FAIL CONDITIONS FOR THE SIMULATION
         assign CPU_ld_data_a5[63:0] = CPU_dmem_rd_data_a5;
         
         assign passed = CPU_Xreg_value_a5[14] == 100;
         // change 100 to the number you want to check
         // in the multiplication tables of the number on line 20
         assign failed = 1'b0;
         
         // Clearing Data Usage Warnings
         `BOGUS_USE(CPU_imm_a5 CPU_imem_rd_en_a5 CPU_imem_rd_addr_a5 CPU_rd_a5 CPU_rs1_a5 CPU_rs2_a5 CPU_start_a5 CPU_start_a5 CPU_is_ld_a5 CPU_is_std_a5 CPU_is_b_a5 CPU_dmem_rd_en_a5 CPU_dmem_rd_data_a5 CPU_dmem_addr_a5 CPU_dmem_wr_data_a5 CPU_dmem_wr_en_a5 CPU_src3_value_a5 CPU_rf_rd_index2_a5)
   
   // Macro instantiations for:
   //    o instruction memory
   //    o register file
   //    o data memory
   //_|cpu
      `line 42 "top.tlv" 1   // Instantiated from top.tlv, 205 as: m4+imem(@1)    // Args: (read stage)
         //_@1
            /*SV_plus*/
               logic [31:0] instrs [0:8-1];
               assign instrs = '{
                  {6'd31, 5'd14, 5'd0, 5'd0, 1'd0, 9'd266, 1'd0},
                  {6'd14, 5'd12, 5'd0, 16'd10},
                  {6'd31, 5'd13, 5'd0, 5'd0, 1'd0, 9'd266, 1'd0},
                  {6'd31, 5'd14, 5'd15, 5'd14, 1'd0, 9'd266, 1'd0},
                  {6'd14, 5'd13, 5'd13, 16'd1},
                  {6'd19, 5'd0, 5'd29, 14'd16376, 1'd1, 1'd1},
                  {6'd62, 5'd14, 5'd0, 15'd10, 2'd1000},
                  {6'd58, 5'd14, 5'd0, 15'd10, 2'd1000}
               };
            for (imem = 0; imem <= 7; imem++) begin : L1_CPU_Imem //_/imem
               assign CPU_Imem_instr_a1[imem][31:0] = instrs[imem]; end
            //_?$imem_rd_en
               assign CPU_imem_rd_data_a1[31:0] = CPU_Imem_instr_a1[CPU_imem_rd_addr_a1];
      //_\end_source    // Args: (read stage)
      `line 206 "top.tlv" 2
      `line 62 "top.tlv" 1   // Instantiated from top.tlv, 206 as: m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
         // Reg File
         //_@3
            for (xreg = 0; xreg <= 63; xreg++) begin : L1_CPU_Xreg logic L1_wr_a3; //_/xreg
               assign L1_wr_a3 = CPU_rf_wr_en_a3 && (CPU_rf_wr_index_a3 != 5'b0) && (CPU_rf_wr_index_a3 == xreg);
               assign CPU_Xreg_value_a3[xreg][63:0] = CPU_reset_a3 ?   20 : // change 20 to the number whose multiples are needed
                              L1_wr_a3        ?   CPU_rf_wr_data_a3 :
                                             CPU_Xreg_value_a4[xreg][63:0]; end
         //_@2
            //_?$rf_rd_en1
               assign CPU_rf_rd_data1_a2[63:0] = CPU_Xreg_value_a4[CPU_rf_rd_index1_a2];
            //_?$rf_rd_en2
               assign CPU_rf_rd_data2_a2[63:0] = CPU_Xreg_value_a4[CPU_rf_rd_index2_a2];
            `BOGUS_USE(CPU_rf_rd_data1_a2 CPU_rf_rd_data2_a2)
      //_\end_source  // Args: (read stage, write stage) - if equal, no register bypass is required
      `line 207 "top.tlv" 2
      `line 51 "/raw.githubusercontent.com/stevehoover/RISCVMYTHWorkshop/c1719d5b338896577b79ee76c2f443ca2a76e14f/tlvlib/riscvshelllib.tlv" 1   // Instantiated from top.tlv, 207 as: m4+dmem(@4)    // Args: (read/write stage)
         // Data Memory
         //_@4
            for (dmem = 0; dmem <= 15; dmem++) begin : L1_CPU_Dmem logic L1_wr_a4; //_/dmem
               assign L1_wr_a4 = CPU_dmem_wr_en_a4 && (CPU_dmem_addr_a4 == dmem);
               assign CPU_Dmem_value_a4[dmem][31:0] = CPU_reset_a4 ?   dmem :
                              L1_wr_a4        ?   CPU_dmem_wr_data_a4 :
                                             CPU_Dmem_value_a5[dmem][31:0]; end
                                        
            //_?$dmem_rd_en
               assign CPU_dmem_rd_data_a4[31:0] = CPU_Dmem_value_a5[CPU_dmem_addr_a4];
            `BOGUS_USE(CPU_dmem_rd_data_a4)
      endgenerate //_\end_source    // Args: (read/write stage)
      `line 208 "top.tlv" 2

//_\SV
   endmodule