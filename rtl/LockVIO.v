module LockVIO (
    input wire        clk,
    output wire [15:0] vio_golden,
    output wire        vio_write
);

    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(vio_golden),
        .probe_out1(vio_write)
    );

endmodule
