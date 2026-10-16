module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 4
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din
);

    // Storage for DEPTH values, each DATA_WIDTH bits wide.
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointer identifies the next storage position to write.
    localparam int PTR_WIDTH = $clog2(DEPTH);
    logic [PTR_WIDTH-1:0] write_ptr;

    // Reset the write pointer; otherwise store accepted writes.
    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= '0;
        end else if (wr_en) begin
            mem[write_ptr] <= din;

            // Wrap around at the final storage position.
            if (write_ptr == DEPTH - 1)
                write_ptr <= '0;
            else
                write_ptr <= write_ptr + 1'b1;
        end
    end

endmodule