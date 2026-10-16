
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 4
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                  full,
    output logic                  empty
);
         // Validate FIFO parameters at simulation time.
    initial begin
        if (DATA_WIDTH < 1)
            $fatal(1, "DATA_WIDTH must be at least 1");

        if (DEPTH < 1)
            $fatal(1, "DEPTH must be at least 1");
    end
    // Storage for DEPTH values, each DATA_WIDTH bits wide.
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointer and counter widths.
    localparam int PTR_WIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam int COUNT_WIDTH = $clog2(DEPTH + 1);

    // Next storage positions for writing and reading.
    logic [PTR_WIDTH-1:0] write_ptr;
    logic [PTR_WIDTH-1:0] read_ptr;

    // Number of valid items currently stored.
    logic [COUNT_WIDTH-1:0] occupancy;

    // Accepted operations.
    logic write_accept;
    logic read_accept;

    // FIFO status flags.
    assign empty = (occupancy == 0);
    assign full  = (occupancy == DEPTH);

    // Reject writes when full and reads when empty.
    assign write_accept = wr_en && !full;
    assign read_accept  = rd_en && !empty;

    // Write data into storage.
    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= '0;
        end else if (write_accept) begin
            mem[write_ptr] <= din;

            // Wrap around at the final storage position.
            if (write_ptr == DEPTH - 1)
                write_ptr <= '0;
            else
                write_ptr <= write_ptr + 1'b1;
        end
    end

    // Read data from storage.
    always_ff @(posedge clk) begin
        if (rst) begin
            read_ptr <= '0;
            dout     <= '0;
        end else if (read_accept) begin
            dout <= mem[read_ptr];

            // Wrap around at the final storage position.
            if (read_ptr == DEPTH - 1)
                read_ptr <= '0;
            else
                read_ptr <= read_ptr + 1'b1;
        end
    end

    // Update occupancy based on accepted operations.
    always_ff @(posedge clk) begin
        if (rst) begin
            occupancy <= '0;
        end else begin
            case ({write_accept, read_accept})
                2'b10: occupancy <= occupancy + 1'b1;
                2'b01: occupancy <= occupancy - 1'b1;
                default: occupancy <= occupancy;
            endcase
        end
    end

endmodule
