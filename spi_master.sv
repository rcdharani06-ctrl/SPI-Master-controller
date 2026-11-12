module spi_master #(
    parameter int DATA_WIDTH = 8,
    parameter int CLK_DIV = 4
)(
    input  logic clk, rst, start,
    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic busy, done, sclk, mosi,
    input  logic miso,
    output logic cs_n
);

    localparam int CW = (CLK_DIV > 1) ? $clog2(CLK_DIV) : 1;
    localparam int BW = $clog2(DATA_WIDTH + 1);

    typedef enum logic [1:0] {IDLE, TRANSFER, FINISH} state_t;
    state_t state;

    logic [DATA_WIDTH-1:0] tx_shift, rx_shift;
    logic [CW-1:0] clk_count;
    logic [BW-1:0] bit_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_shift <= '0;
            rx_shift <= '0;
            rx_data <= '0;
            clk_count <= '0;
            bit_count <= '0;
            sclk <= 0;
            mosi <= 0;
            cs_n <= 1;
            busy <= 0;
            done <= 0;
        end
        else begin
            done <= 0;

            case (state)
                IDLE: begin
                    sclk <= 0;
                    cs_n <= 1;
                    busy <= 0;
                    clk_count <= 0;
                    bit_count <= 0;

                    if (start) begin
                        tx_shift <= tx_data;
                        rx_shift <= '0;
                        mosi <= tx_data[DATA_WIDTH-1];
                        cs_n <= 0;
                        busy <= 1;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (clk_count == CLK_DIV-1) begin
                        clk_count <= 0;

                        if (!sclk) begin
                            sclk <= 1;
                            rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
                            bit_count <= bit_count + 1'b1;

                            if (bit_count == DATA_WIDTH-1)
                                rx_data <= {rx_shift[DATA_WIDTH-2:0], miso};
                        end
                        else begin
                            sclk <= 0;

                            if (bit_count == DATA_WIDTH)
                                state <= FINISH;
                            else begin
                                tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
                                mosi <= tx_shift[DATA_WIDTH-2];
                            end
                        end
                    end
                    else
                        clk_count <= clk_count + 1'b1;
                end

                FINISH: begin
                    cs_n <= 1;
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
