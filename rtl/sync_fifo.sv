
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 4
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] dout
);

    // Storage for DEPTH values, each DATA_WIDTH bits wide.
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointer width needed to address the storage positions.
    localparam int PTR_WIDTH = $clog2(DEPTH);

    // Pointer identifies the next storage position to write.
    logic [PTR_WIDTH-1:0] write_ptr;

    // Pointer identifies the next storage position to read.
    logic [PTR_WIDTH-1:0] read_ptr;

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

    // Reset the read pointer and output; otherwise read data.
    always_ff @(posedge clk) begin
        if (rst) begin
            read_ptr <= '0;
            dout     <= '0;
        end else if (rd_en) begin
            dout <= mem[read_ptr];

            // Wrap around at the final storage position.
            if (read_ptr == DEPTH - 1)
                read_ptr <= '0;
            else
                read_ptr <= read_ptr + 1'b1;
        end
    end

endmodule
