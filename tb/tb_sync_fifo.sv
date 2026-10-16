
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
        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // Reset the FIFO.
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Test 1: write 42, then read it back.
        din   = 8'd42;
        wr_en = 1;
        @(posedge clk);
        @(negedge clk);
        wr_en = 0;

        rd_en = 1;
        @(posedge clk);
        #1;

        if (dout !== 8'd42)
            $fatal(1, "FAIL: expected 42, got %0d", dout);

        $display("PASS: single-value write/read");

        @(negedge clk);
        rd_en = 0;

        // Test 2: write three values in order.
        din   = 8'd10;
        wr_en = 1;
        @(posedge clk);

        @(negedge clk);
        din = 8'd20;
        @(posedge clk);

        @(negedge clk);
        din = 8'd30;
        @(posedge clk);

        @(negedge clk);
        wr_en = 0;

        // Read and check the values in FIFO order.
        rd_en = 1;

        @(posedge clk);
        #1;
        if (dout !== 8'd10)
            $fatal(1, "FAIL: expected 10, got %0d", dout);

        @(negedge clk);
        @(posedge clk);
        #1;
        if (dout !== 8'd20)
            $fatal(1, "FAIL: expected 20, got %0d", dout);

        @(negedge clk);
        @(posedge clk);
        #1;
        if (dout !== 8'd30)
            $fatal(1, "FAIL: expected 30, got %0d", dout);

        $display("PASS: FIFO ordering (10, 20, 30)");

        @(negedge clk);
        rd_en = 0;

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
