
`timescale 1ns/1ps

module tb_sync_fifo;

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] din;
    logic [7:0] dout;
    logic full;
    logic empty;

    // Device under test (DUT): the FIFO we are verifying.
    sync_fifo #(
        .DATA_WIDTH(8),
        .DEPTH(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Generate a clock with a 10 ns period.
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs.
        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // Hold reset for two rising clock edges.
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Write the value 42.
        din   = 8'd42;
        wr_en = 1;
        @(posedge clk);
        @(negedge clk);
        wr_en = 0;

        // Read the value back.
        rd_en = 1;
        @(posedge clk);
        #1;

        if (dout !== 8'd42)
            $fatal(1, "FAIL: expected 42, got %0d", dout);

        $display("PASS: read back the value 42");

        @(negedge clk);
        rd_en = 0;

        $finish;
    end

endmodule
