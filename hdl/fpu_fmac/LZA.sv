////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:                Lei Li  //lile@iis.ee.ethz.ch
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:      01/12/2016                                            // 
// Design Name:    fmac                                                        // 
// Module Name:    adders.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:          // decomposition and operand detection
//                                                                            //
//          FMAC=a*b+c                                                               //
//                                                                            //
// Revision:        26/06/2017                                                          //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module LZA
#( parameter  C_WIDTH=74)
  (

   input  logic [C_WIDTH-1:0]        A_DI,  
   input  logic [C_WIDTH-1:0]        B_DI,  

   output logic [C_LEADONE_WIDTH-1:0]        Leading_one_DO         

   );
  
   logic [C_WIDTH-1:0]               T_D;
   logic [C_WIDTH-1:0]               G_D;
   logic [C_WIDTH-1:0]               Z_D;
   logic [C_WIDTH-1:0]               F_S;

      generate
        genvar i;
            for (i=0;i<=C_WIDTH-1;i++)
              begin
                always@(*)
                  begin
                    T_D[i]=A_DI[i] ^ B_DI[i];
                    G_D[i]=A_DI[i] && B_DI[i];  
                    Z_D[i]=~(A_DI[i] | B_DI[i]); 
                 end 
              end 
      endgenerate;   


  assign F_S[C_WIDTH-1]=(~T_D[C_WIDTH-1])&T_D[C_WIDTH-2];

      generate
        genvar j;
            for (j=1;j<C_WIDTH-1;j++)
              begin
                always@(*)
                  begin
                    F_S[j]=  (T_D[j+1]& ((G_D[j]&(~Z_D[j-1])) | (Z_D[j]&(~G_D[j-1])) ) ) | ( (~T_D[j+1])&((Z_D[j]&&(~Z_D[j-1])) | ( G_D[j]&(~G_D[j-1]))) ) ; 
                  end
              end 
      endgenerate;   
   
  assign F_S[0]= T_D[1]&Z_D[0] | (~T_D[1])&(T_D[0] | G_D[0]); 
     
 logic [C_LEADONE_WIDTH-1:0]        Leading_one_D;
   //Detect leading one  
/*   firstone 
     #(.G_VECTORLEN(C_WIDTH),
       .G_FLIPVECTOR(1))
   LOD_Ua
     (
      .Vector_DI(F_S),
      .FirstOneIdx_DO(Leading_one_D)

      );
*/
   fpu_ff
   #(
     .LEN(C_WIDTH))
   LOD_Ub
   (
     .in_i        ( F_S         ),
     .first_one_o ( Leading_one_D )
   ); 

   
 assign Leading_one_DO=Leading_one_D;
endmodule // 