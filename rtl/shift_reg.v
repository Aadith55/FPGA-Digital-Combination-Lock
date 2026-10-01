module shift_reg (
    input wire        clk,
    input wire        rst,
    input wire        clear,
    input wire [3:0]  new_digit,
    input wire        new_digit_valid,
    output reg [15:0] code_out,
    output reg [2:0]  digit_count
);

    always @(posedge clk) begin
        if (rst || clear) begin
            code_out    <= 16'b0;
            digit_count <= 3'd0;
        end else if (new_digit_valid) begin
            if ((new_digit < 4'd10) && (digit_count < 3'd4)) begin
                code_out    <= {code_out[11:0], new_digit};
                digit_count <= digit_count + 1'b1;
            end
        end
    end

endmodule
