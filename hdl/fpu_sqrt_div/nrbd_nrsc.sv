////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lei Li                  //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 // 
// Design Name:    div_sqrt                                                        // 
// Module Name:    nrbd.sv                                                   //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:   non restroring binary  divisior/ square root                                       //
//                                                   t                        //
//                                                                            //
// Revision:       19/01/2017                                                           //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_div_sqrt::*;

module nrbd_nrsc
  (//Input
   input logic                                 Clk_CI,
   input logic                                 Rst_RBI,
   input logic                                 Div_start_SI , 
   input logic                                 Sqrt_start_SI,
   input logic                                 Start_SI,
 
   input logic [C_MANT:0]                      Mant_a_DI,
   input logic [C_MANT:0]                      Mant_b_DI,

   input logic [C_EXP:0]                       Exp_a_DI,
   input logic [C_EXP:0]                       Exp_b_DI,
   
  //output
   output logic                                Div_enable_SO,
   output logic                                Ready_SO,
   output logic                                Done_SO,
   output logic  [C_MANT:0]                    Mant_z_DO,
 //  output  logic sign_z,
   output logic [C_EXP+1:0]                    Exp_z_DO
    );
   



    logic [C_MANT+1:0]                        First_iteration_cell_sum_D, Sec_iteration_cell_sum_D,Thi_iteration_cell_sum_D,Fou_iteration_cell_sum_D;
    logic                                     First_iteration_cell_carry_D,Sec_iteration_cell_carry_D,Thi_iteration_cell_carry_D,Fou_iteration_cell_carry_D;
   
    logic [1:0]                               Sqrt_Da0,Sqrt_Da1,Sqrt_Da2,Sqrt_Da3;
    logic [1:0]                               Sqrt_D0,Sqrt_D1,Sqrt_D2,Sqrt_D3;

    logic [C_MANT+1:0]                        First_iteration_cell_a_D,First_iteration_cell_b_D;
    logic [C_MANT+1:0]                        Sec_iteration_cell_a_D,Sec_iteration_cell_b_D;
    logic [C_MANT+1:0]                        Thi_iteration_cell_a_D,Thi_iteration_cell_b_D;
    logic [C_MANT+1:0]                        Fou_iteration_cell_a_D,Fou_iteration_cell_b_D;
    logic                                     Div_start_dly_S,Sqrt_start_dly_S,Sqrt_enable_S;

control  control_U0
(  .Clk_CI                                   (Clk_CI                          ),
   .Rst_RBI                                  (Rst_RBI                         ),
   .Div_start_SI                             (Div_start_SI                    ),
   .Sqrt_start_SI                            (Sqrt_start_SI                   ),
   .Start_SI                                 (Start_SI                        ),
   .Numerator_DI                             (Mant_a_DI                       ),
   .Exp_num_DI                               (Exp_a_DI                        ),

   .Denominator_DI                           (Mant_b_DI                       ),
   .Exp_den_DI                               (Exp_b_DI                        ),

   .First_iteration_cell_sum_DI              (First_iteration_cell_sum_D      ),
   .First_iteration_cell_carry_DI            (First_iteration_cell_carry_D    ),
   .Sqrt_Da0                                 (Sqrt_Da0                        ),
   .Sec_iteration_cell_sum_DI                (Sec_iteration_cell_sum_D        ),
   .Sec_iteration_cell_carry_DI              (Sec_iteration_cell_carry_D      ),
   .Sqrt_Da1                                 (Sqrt_Da1                        ),
   .Thi_iteration_cell_sum_DI                (Thi_iteration_cell_sum_D        ),
   .Thi_iteration_cell_carry_DI              (Thi_iteration_cell_carry_D      ),
   .Sqrt_Da2                                 (Sqrt_Da2                        ),
   .Fou_iteration_cell_sum_DI                (Fou_iteration_cell_sum_D        ),
   .Fou_iteration_cell_carry_DI              (Fou_iteration_cell_carry_D      ),
   .Sqrt_Da3                                 (Sqrt_Da3                        ),


   .Div_start_dly_SO                         (Div_start_dly_S                 ),
   .Sqrt_start_dly_SO                        (Sqrt_start_dly_S                ),
   .Div_enable_SO                            (Div_enable_SO                    ),
   .Sqrt_enable_SO                           (Sqrt_enable_S                   ),
   .Sqrt_D0                                  (Sqrt_D0                         ),
   .Sqrt_D1                                  (Sqrt_D1                         ),
   .Sqrt_D2                                  (Sqrt_D2                         ),
   .Sqrt_D3                                  (Sqrt_D3                         ),

   .First_iteration_cell_a_DO                (First_iteration_cell_a_D        ),
   .First_iteration_cell_b_DO                (First_iteration_cell_b_D        ),
   .Sec_iteration_cell_a_DO                  (Sec_iteration_cell_a_D          ),
   .Sec_iteration_cell_b_DO                  (Sec_iteration_cell_b_D          ),
   .Thi_iteration_cell_a_DO                  (Thi_iteration_cell_a_D          ),
   .Thi_iteration_cell_b_DO                  (Thi_iteration_cell_b_D          ),
   .Fou_iteration_cell_a_DO                  (Fou_iteration_cell_a_D          ),
   .Fou_iteration_cell_b_DO                  (Fou_iteration_cell_b_D          ),

   .Ready_SO                                 (Ready_SO                        ),
   .Done_SO                                  (Done_SO                         ),
   .Mant_result_prenorm_DO                   (Mant_z_DO                       ),
   .Exp_result_prenorm_DO                    (Exp_z_DO                        )

);  



iteration_div_sqrt_first  iteration_unit_U0    
(
   .A_DI                                    (First_iteration_cell_a_D        ),
   .B_DI                                    (First_iteration_cell_b_D        ),
   .Div_enable_SI                           (Div_enable_SO                    ),
   .Div_start_dly_SI                        (Div_start_dly_S                 ),
   .Sqrt_enable_SI                          (Sqrt_enable_S                   ),
   .D_DI                                    (Sqrt_D0                         ),
   .D_DO                                    (Sqrt_Da0                        ), 
   .Sum_DO                                  (First_iteration_cell_sum_D      ),
   .Carry_out_DO                            (First_iteration_cell_carry_D    )
);


iteration_div_sqrt  iteration_unit_U1    
(
   .A_DI                                    (Sec_iteration_cell_a_D          ),
   .B_DI                                    (Sec_iteration_cell_b_D          ),
   .Div_enable_SI                           (Div_enable_SO                    ),
   .Sqrt_enable_SI                          (Sqrt_enable_S                   ),
   .D_DI                                    (Sqrt_D1                         ),
   .D_DO                                    (Sqrt_Da1                        ), 
   .Sum_DO                                  (Sec_iteration_cell_sum_D        ),
   .Carry_out_DO                            (Sec_iteration_cell_carry_D      )
);


iteration_div_sqrt  iteration_unit_U2    
(
   .A_DI                                    (Thi_iteration_cell_a_D         ),
   .B_DI                                    (Thi_iteration_cell_b_D         ),
   .Div_enable_SI                           (Div_enable_SO                   ),
   .Sqrt_enable_SI                          (Sqrt_enable_S                  ),
   .D_DI                                    (Sqrt_D2                        ),
   .D_DO                                    (Sqrt_Da2                       ), 
   .Sum_DO                                  (Thi_iteration_cell_sum_D       ),
   .Carry_out_DO                            (Thi_iteration_cell_carry_D     )
);


iteration_div_sqrt  iteration_unit_U3    
(
   .A_DI                                    (Fou_iteration_cell_a_D        ),
   .B_DI                                    (Fou_iteration_cell_b_D        ),
   .Div_enable_SI                           (Div_enable_SO                  ),
   .Sqrt_enable_SI                          (Sqrt_enable_S                 ),
   .D_DI                                    (Sqrt_D3                       ),
   .D_DO                                    (Sqrt_Da3                      ), 
   .Sum_DO                                  (Fou_iteration_cell_sum_D      ),
   .Carry_out_DO                            (Fou_iteration_cell_carry_D    )
);   




endmodule // 