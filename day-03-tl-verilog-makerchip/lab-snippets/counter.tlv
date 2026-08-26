\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   |counter
      @0
         $cnt[31:0] = $reset ? 32'd0 : >>1$cnt + 32'd1;
\SV
endmodule
