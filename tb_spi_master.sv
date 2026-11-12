
`timescale 1ns/1ps

module tb_spi_master;
    localparam int DATA_WIDTH = 8;
    localparam int CLK_DIV = 4;
    localparam logic [7:0] MASTER_DATA = 8'hA5;
    localparam logic [7:0] SLAVE_RESPONSE = 8'h3C;
    logic clk, rst, start;
    logic [7:0] tx_data, rx_data;
    logic busy, done, sclk, mosi, miso, cs_n;
    logic [7:0] captured_tx;
    integer tx_bit_count, rx_bit_index;
    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_DIV(CLK_DIV)
    ) dut (.*);
    always #5 clk = ~clk;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_spi_master);
    end

    // SPI slave: supply first MISO bit
    always @(negedge cs_n) begin
        rx_bit_index = 0;
        miso = SLAVE_RESPONSE[DATA_WIDTH-1];
    end

    // Update MISO on falling SCLK edges
    always @(negedge sclk) begin
        if (!cs_n && rx_bit_index < DATA_WIDTH-1) begin
            rx_bit_index = rx_bit_index + 1;
            miso = SLAVE_RESPONSE[DATA_WIDTH-1-rx_bit_index];
        end
    end

    // Capture MOSI on rising SCLK edges
    always @(posedge sclk) begin
        if (!cs_n) begin
            captured_tx = {captured_tx[DATA_WIDTH-2:0], mosi};
            tx_bit_count = tx_bit_count + 1;
        end
    end

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        miso = 0;
        tx_data = MASTER_DATA;
        captured_tx = 0;
        tx_bit_count = 0;
        rx_bit_index = 0;

        repeat (3) @(negedge clk);
        rst = 0;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        $display("--------------------------------");
        $display("SPI MASTER TEST STARTED");
        $display("Master TX: %h", MASTER_DATA);
        $display("Slave TX : %h", SLAVE_RESPONSE);
        $display("--------------------------------");

        // Wait for completion or timeout
        fork
            begin
                wait(done === 1'b1);
            end
            begin
                repeat (200) @(posedge clk);
                $fatal(1, "ERROR: SPI TIMEOUT");
            end
        join_any
        disable fork;

        // Allow done to clear
        @(posedge clk);
        #1;

        if (captured_tx !== MASTER_DATA)
            $fatal(1, "TX FAILED: Expected %h, Got %h",
                   MASTER_DATA, captured_tx);
        else
            $display("TX PASS: %h", captured_tx);

        if (rx_data !== SLAVE_RESPONSE)
            $fatal(1, "RX FAILED: Expected %h, Got %h",
                   SLAVE_RESPONSE, rx_data);
        else
            $display("RX PASS: %h", rx_data);

        if (tx_bit_count != DATA_WIDTH)
            $fatal(1, "BIT COUNT FAILED: %0d", tx_bit_count);
        else
            $display("BIT COUNT PASS: %0d", tx_bit_count);

        if (busy !== 0 || cs_n !== 1 || sclk !== 0)
            $fatal(1, "CONTROL SIGNAL CHECK FAILED");
        else
            $display("CONTROL SIGNAL PASS");

        if (done !== 0)
            $fatal(1, "DONE PULSE DID NOT CLEAR");

        $display("--------------------------------");
        $display("ALL SPI MASTER TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

endmodule
