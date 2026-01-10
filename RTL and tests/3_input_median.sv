// 3 input sorting //
// finding the meadian //
module sorting 
  (input logic[7:0] a,b,c,
   output logic [7:0] median);
  
  logic [7:0] small_1,large_1,small_2,large_2;
  
  //comparitor-1 a and b
  assign small_1 = (a < b) ? a:b;
  assign large_1 = (a < b) ? b:a;
  
  //comparitor-2 small_1 and c
  assign small_2 = (small_1 < c) ? small_1:c;
  assign large_2 = (small_1 < c) ? c:small_1;
  
  //comparitor3
 // assign low = small_2;
  assign median = (large_1 <large_2)?large_1:large_2;
 // assign high = (large_1<large_2)?large_2:large_1;
  
endmodule
