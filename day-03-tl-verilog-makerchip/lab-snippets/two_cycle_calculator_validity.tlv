\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |calc
      @0
         $valid = $reset ? 1'b0 : 1'b1;
      @1
         $sum[31:0] = $val1 + $val2;
      @2
         ?$valid
            $out[31:0] = $sum;
\SV
endmodule
