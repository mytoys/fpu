/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */
////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
//                 Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    26/10/2014                                                 //
// Design Name:    FPU                                                        //
// Module Name:    riscv_fpu.sv                                               //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point unit with input and ouput registers         //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs::*;

module riscv_fpu
  (
   //Clock and reset
   input logic             clk,
   input logic             rst_n,

   //Input Operands
   input logic [C_OP-1:0]  operand_a_i,
   input logic [C_OP-1:0]  operand_b_i,
   input logic [C_RM-1:0]  rounding_mode_i,    //Rounding Mode
   input logic [C_CMD-1:0] operator_i,
   input logic             enable_i,

   input logic             stall_i,

   output logic [C_OP-1:0] result_o,
   //Output-Flags
   output logic            fpu_ready_o,   // high if fpu is ready
   output logic            result_valid_o // result is valid
   );


   // Number of cycles the fpu needs, after two cycles the output is valid
   localparam CYCLES = 2;

   //Internal Operands
   logic [C_OP-1:0]             operand_a_q;
   logic [C_OP-1:0]             operand_b_q;

   logic [C_RM-1:0]             rounding_mode_q;
   logic [C_CMD-1:0]            operator_q;

   logic [$clog2(CYCLES):0]     valid_count_q, valid_count_n;

   // result is valid if we waited 2 cycles
   assign result_valid_o = (valid_count_q == CYCLES - 1) ? 1'b1 : 1'b0;

   // combinatorial update logic - set output bit accordingly
   always_comb
   begin
      valid_count_n = valid_count_q;
      fpu_ready_o = 1'b1;

      if (enable_i)
      begin
          valid_count_n = valid_count_q + 1;
          fpu_ready_o = 1'b0;
          // if we already waited 2 cycles set the output to valid, fpu is ready
          if (valid_count_q == CYCLES - 1)
          begin
            fpu_ready_o = 1'b1;
            valid_count_n = 2'd0;
          end
      end
   end

   always_ff @(posedge clk, negedge rst_n)
    begin
      if (~rst_n)
      begin
        valid_count_q <= 1'b0;
      end
      else
      begin
        if (enable_i && ~stall_i)
        begin
          valid_count_q <= valid_count_n;
        end
      end
    end

   /////////////////////////////////////////////////////////////////////////////
   // FPU_core                                                                //
   /////////////////////////////////////////////////////////////////////////////

  fpu_core fpcore
     (
      .Clk_CI        ( clk              ),
      .Rst_RBI       ( rst_n            ),
      .Enable_SI     ( enable_i         ),

      .Operand_a_DI  ( operand_a_i      ),
      .Operand_b_DI  ( operand_b_i      ),
      .RM_SI         ( rounding_mode_i  ),
      .OP_SI         ( operator_i       ),
      .Stall_SI      ( stall_i          ),

      .Result_DO     ( result_o         ),

      .OF_SO         (                  ),
      .UF_SO         (                  ),
      .Zero_SO       (                  ),
      .IX_SO         (                  ),
      .IV_SO         (                  ),
      .Inf_SO        (                  )
      );

endmodule // fpu
