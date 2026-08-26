\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |mux
      @0
         $out[7:0] = $sel ? $in1[7:0] : $in2[7:0];
\SV
endmodule
