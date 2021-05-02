\m4_TLV_version 1d: tl-x.org
\SV
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/c1719d5b338896577b79ee76c2f443ca2a76e14f/tlv_lib/risc-v_shell_lib.tlv'])
	m4_makerchip_module   // (Expanded in Nav-TLV pane.)

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
\TLV imem(@_stage)
   @_stage
      \SV_plus
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
      /M4_IMEM_HIER
         $instr[31:0] = *instrs\[#imem\];
      ?$imem_rd_en
         $imem_rd_data[31:0] = /imem[$imem_rd_addr]$instr;

// Register File Implementation
\TLV rf(@_rd, @_wr)
   // Reg File
   @_wr
      /xreg[63:0]
         $wr = |cpu$rf_wr_en && (|cpu$rf_wr_index != 5'b0) && (|cpu$rf_wr_index == #xreg);
         $value[63:0] = |cpu$reset ?   20 : // change 20 to the number whose multiples are needed
                        $wr        ?   |cpu$rf_wr_data :
                                       $RETAIN;
   @_rd
      ?$rf_rd_en1
         $rf_rd_data1[63:0] = /xreg[$rf_rd_index1]>>m4_stage_eval(@_wr - @_rd + 1)$value;
      ?$rf_rd_en2
         $rf_rd_data2[63:0] = /xreg[$rf_rd_index2]>>m4_stage_eval(@_wr - @_rd + 1)$value;
      `BOGUS_USE($rf_rd_data1 $rf_rd_data2)

// ------------------ LIBRARY CODE ENDS HERE ------------------ //
// DRIVER CODE
\TLV
   m4_asm()
   m4_define_hier(['M4_IMEM'], 8)
   |cpu
      @0 // PC IMPLEMENTATION
         $reset = *reset;
         $start = >>1$reset && !$reset;
         
         $pc[31:0] = >>1$reset ? 32'b0 :
                     >>3$valid_taken_br ? >>3$br_tgt_pc :
                     >>1$inc_pc;
      
      @1 // INSTRUCTION FETCH and PC INCREMENT
         
         // Default PC Increment
         $inc_pc[31:0] = $pc + 32'd4;
         
         // Fetch the Instruction from Instruction Memory
         $imem_rd_en = !$reset;
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
         $instr[31:0] = $imem_rd_data[31:0];
         
         // Extract the PO, XO, REGISTER INDICES and IMMEDIATE FIELDS from Instuction
         $po_bits[5:0] = {$instr[31:26]};
         $xo_bits[9:0] = $instr[9:1];
         $imm[63:0] = ($po_bits ==? 6'd14) ? {{48{$instr[15]}}, $instr[15:0]} :
                      ($po_bits ==? 6'd28) ? {{48{$instr[15]}}, $instr[15:0]} :
                      ($po_bits ==? 6'd24) ? {{48{$instr[15]}}, $instr[15:0]} :
                      ($po_bits ==? 6'd58) ? {{50{$instr[15]}}, $instr[15:2]} :
                      ($po_bits ==? 6'd62) ? {{50{$instr[15]}}, $instr[15:2]} :
                      ($po_bits ==? 6'd19) ? {{50{$instr[15]}}, $instr[15:2]} : 64'd0;
         $rd_valid = ($po_bits ==? 6'd31) ? 1 : 0;
         $rs2[4:0] = $instr[25:21];
         $rs1[4:0] = $instr[20:16];
         ?$rd_valid
            $rd[4:0] = $instr[15:11];
      
      @2 // INSTRUCTION DECODE and REGISTER FILE DATA ACCESS
         
         // Determine the exact type of instruction
         $is_sub  = ($po_bits == 31) && ($xo_bits == 40);
         $is_and  = ($po_bits == 31) && ($xo_bits == 28);
         $is_add  = ($po_bits == 31) && ($xo_bits == 266);
         $is_nand = ($po_bits == 31) && ($xo_bits == 476);
         $is_or   = ($po_bits == 31) && ($xo_bits == 444);
         $is_addi = ($po_bits == 14);
         $is_andi = ($po_bits == 28);
         $is_ori  = ($po_bits == 24);
         $is_ld   = ($po_bits == 58);
         $is_std  = ($po_bits == 62);
         $is_b    = ($po_bits == 19);
         
         // Read Data from Register File
         $rf_rd_en1 = 1;
         $rf_rd_index1[4:0] = $rs1;
         $rf_rd_en2 = 1;
         $rf_rd_index2[4:0] = $rs2;
         
         // Set correct source values for the ALU operation
         // Since there is a pipeline in effect, we check for hazards
         $temp = $rf_rd_index2 << 2;
         $src1_value[63:0] = (>>1$rf_wr_index == $rf_rd_index1) && >>1$rf_wr_en ? >>1$result : $rf_rd_data1;
         $src3_value[63:0] = (>>1$rf_wr_index == $temp) && >>1$rf_wr_en ? >>1$result : $rf_rd_data2;
         $src2_value[63:0] = (>>1$rf_wr_index == $rf_rd_index2) && >>1$rf_wr_en ? >>1$result : $rf_rd_data2;
         
         // Branch Target PC for Branch Type Instruction
         $br_tgt_pc[31:0] = $pc + $imm;
      
      @3
         // Set Vaid bit to indicate a successful branch
         $taken_br = $is_b ? ($src1_value == $src3_value) : 0;
         
         // Branching leads to immediate stall 
         // In the case of read after write with a branch condition in next cycle
         // The valid bit will help increment the PC every cycle instead of every 3 cycles.
         $valid = !(>>1$valid_taken_br || >>2$valid_taken_br || >>1$valid_load || >>2$valid_load);
         
         // Valid Signal for branching which feeds into PC so that during pipeline,
         // unnecesarily, PC doesn't increment for INVALID CYCLES. 
         $valid_taken_br = $valid && $taken_br;
         
         // ALU Implmentation based on type of Instruction
         $result[63:0] = $is_sub  ? $src1_value - $src2_value :
                         $is_and  ? $src1_value & $src2_value :
                         $is_add  ? $src1_value + $src2_value :
                         $is_nand ? ~($src1_value & $src2_value) :
                         $is_or   ? $src1_value | $src2_value :
                         $is_addi ? $src1_value + $imm :
                         $is_andi ? $src1_value & $imm :
                         $is_ori  ? $src1_value | $imm :
                         $is_ld   ? $src1_value + $imm :
                         $is_std  ? $src1_value + $imm :
                         $is_b    ? $src1_value + $imm : 0;
         
         // Set a valid bit to indicate a valid load instruction
         $valid_load = $valid && $is_ld;
         
         // Register File Write - Considering three cases
         //    o Will be enabled only when Valid Bit is high
         //    o Along with that destination register needs to be valid
         //    o Destination register cannot be zero as it will be treated as R0 by nPOWER ISA standards. 
         $rf_wr_en = ($valid && $rd_valid) || >>2$valid_load;
         $rf_wr_index[4:0] = >>2$valid_load ? >>2$rd : $rd;
         $rf_wr_data[63:0] = >>2$valid_load ? >>2$ld_data : $result;
      
      @4 // DATA MEMORY WRITES and READS
         $dmem_wr_en = $is_std && $valid; // store
         $dmem_rd_en = $is_ld;            // load
         $dmem_addr  = $result[5:2];
         $dmem_wr_data[63:0] = $src2_value;
      
      @5 // MAKE DMEM AVAILABLE FOR NEXT CYCLES, SET PASS AND FAIL CONDITIONS FOR THE SIMULATION
         $ld_data[63:0] = $dmem_rd_data;
         
         *passed = |cpu/xreg[14]$value == 100;
         // change 100 to the number you want to check
         // in the multiplication tables of the number on line 66
         *failed = 1'b0;
         
         // Clearing Data Usage Warnings
         `BOGUS_USE($imm $imem_rd_en $imem_rd_addr $rd $rs1 $rs2 $start $start $is_ld $is_std $is_b $dmem_rd_en $dmem_rd_data $dmem_addr $dmem_wr_data $dmem_wr_en $src3_value $rf_rd_index2)
   
   // Macro instantiations for:
   //    o instruction memory
   //    o register file
   //    o data memory
   |cpu
      m4+imem(@1)    // Args: (read stage)
      m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
      m4+dmem(@4)    // Args: (read/write stage)

\SV
   endmodule