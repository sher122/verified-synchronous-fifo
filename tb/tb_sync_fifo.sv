
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

                // Test 3: reading an empty FIFO must be rejected.
        // The previous tests have consumed all stored values.
        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        // Remember the previous output value.
        @(negedge clk);
        rd_en = 1;

        @(posedge clk);
        #1;

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should remain empty");

        if (dout !== 8'd30)
            $fatal(1, "FAIL: output changed during empty read");

        $display("PASS: read request rejected when FIFO is empty");

        @(negedge clk);
        rd_en = 0;

                // Test 4: a write to a full FIFO must be rejected.
        // Reset to begin this test with an empty FIFO.
        @(negedge clk);
        rst   = 1;
        rd_en = 0;
        wr_en = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Fill all four FIFO slots.
        din = 8'd11;
        wr_en = 1;
        @(posedge clk);

        @(negedge clk);
        din = 8'd22;
        @(posedge clk);

        @(negedge clk);
        din = 8'd33;
        @(posedge clk);

        @(negedge clk);
        din = 8'd44;
        @(posedge clk);

        @(negedge clk);
        wr_en = 0;

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO should be full");

        // Attempt to write a fifth value.
        din   = 8'd55;
        wr_en = 1;
        @(posedge clk);
        @(negedge clk);
        wr_en = 0;

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO should remain full");

        // Read back the original four values.
        rd_en = 1;

        @(posedge clk);
        #1;
        if (dout !== 8'd11)
            $fatal(1, "FAIL: expected 11, got %0d", dout);

        @(negedge clk);
        @(posedge clk);
        #1;
        if (dout !== 8'd22)
            $fatal(1, "FAIL: expected 22, got %0d", dout);

        @(negedge clk);
        @(posedge clk);
        #1;
        if (dout !== 8'd33)
            $fatal(1, "FAIL: expected 33, got %0d", dout);

        @(negedge clk);
        @(posedge clk);
        #1;
        if (dout !== 8'd44)
            $fatal(1, "FAIL: expected 44, got %0d", dout);

        $display("PASS: full FIFO rejects an extra write");

        @(negedge clk);
        rd_en = 0;

                // Test 5: simultaneous read and write while partially filled.
        @(negedge clk);
        rst   = 1;
        wr_en = 0;
        rd_en = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Write two values into the FIFO.
        din   = 8'd61;
        wr_en = 1;
        @(posedge clk);

        @(negedge clk);
        din = 8'd62;
        @(posedge clk);

        // Request a read and a write on the same clock edge.
        @(negedge clk);
        din   = 8'd63;
        wr_en = 1;
        rd_en = 1;

        @(posedge clk);
        #1;

        if (dout !== 8'd61)
            $fatal(1, "FAIL: expected 61, got %0d", dout);

        if (full !== 1'b0 || empty !== 1'b0)
            $fatal(1, "FAIL: FIFO status incorrect after simultaneous operation");

        $display("PASS: simultaneous read/write while partially filled");

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        
        // Test 6: simultaneous read/write while FIFO is full.
        @(negedge clk);
        rst   = 1;
        wr_en = 0;
        rd_en = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Fill all four slots.
        din = 8'd71;
        wr_en = 1;
        @(posedge clk);

        @(negedge clk);
        din = 8'd72;
        @(posedge clk);

        @(negedge clk);
        din = 8'd73;
        @(posedge clk);

        @(negedge clk);
        din = 8'd74;
        @(posedge clk);

        @(negedge clk);

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO should be full before simultaneous operation");

        // Request both operations while full.
        din   = 8'd75;
        wr_en = 1;
        rd_en = 1;

        @(posedge clk);
        #1;

        if (dout !== 8'd71)
            $fatal(1, "FAIL: expected 71, got %0d", dout);

        if (full !== 1'b0 || empty !== 1'b0)
            $fatal(1, "FAIL: FIFO status incorrect after simultaneous operation");

        $display("PASS: full FIFO accepts read and rejects write");

        // Stop requests before finishing.
        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        $display("ALL TESTS PASSED");
        $finish;

    end

endmodule
