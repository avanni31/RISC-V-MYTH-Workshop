\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |calc
      @1
         $sum[31:0]  = $val1 + $val2;
         $diff[31:0] = $val1 - $val2;
         $prod[31:0] = $val1 * $val2;
         $quot[31:0] = $val1 / $val2;
      @2
         $out[31:0] = $op[1:0] == 2'd0 ? $sum :
                      $op[1:0] == 2'd1 ? $diff :
                      $op[1:0] == 2'd2 ? $prod :
                                         $quot;
\SV
endmodule
