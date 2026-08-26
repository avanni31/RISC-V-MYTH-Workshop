\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |calc
      @1
         $aa_sq[31:0] = $aa * $aa;
         $bb_sq[31:0] = $bb * $bb;
      @2
         $cc_sq[31:0] = $aa_sq + $bb_sq;
      @3
         $cc[31:0] = sqrt($cc_sq);
\SV
endmodule
