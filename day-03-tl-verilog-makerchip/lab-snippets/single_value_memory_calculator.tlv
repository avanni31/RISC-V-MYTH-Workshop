\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |calc
      @0
         $sum[31:0] = $val1 + $val2;
      @1
         $mem_value[31:0] = $reset ? 32'b0 : >>1$sum;
      @2
         $out[31:0] = $mem_value;
\SV
endmodule
