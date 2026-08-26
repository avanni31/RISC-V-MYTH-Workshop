\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |logic
      @0
         $out = !$in1;
         $and_out = $in1 && $in2;
         $or_out  = $in1 || $in2;
         $xor_out = $in1 ^ $in2;
\SV
endmodule
