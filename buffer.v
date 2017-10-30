//------------------------------------------------------------------------------
// Buffer for ouput of MISO
//------------------------------------------------------------------------------

module buffer
#(parameter width = 1)
(
input   [width-1:0] in,
input               en,
output  [width-1:0] out
    );

    // Assign out to input or high-z
    assign out = en ? in : {width{1'bz}};

endmodule
