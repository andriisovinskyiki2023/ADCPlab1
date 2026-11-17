// UART приймач, формат 8N1
module uart_rx #(
    parameter CLKS_PER_BIT = 434
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,             // вхідна лінія UART
    output reg  [7:0] data_out,       // прийнятий байт
    output reg        data_valid      // 1 такт, коли байт готовий
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  shift;

    // Двоступенева синхронізація асинхронного входу (захист від метастабільності)
    reg rx_s1, rx_s2;
    always @(posedge clk) begin
        rx_s1 <= rx;
        rx_s2 <= rx_s1;
    end

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            data_valid <= 1'b0;
            data_out   <= 8'd0;
            clk_cnt    <= 0;
            bit_idx    <= 0;
        end else begin
            data_valid <= 1'b0;       // за замовчуванням

            case (state)

                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_s2 == 1'b0)           // зафіксовано початок старт-біта
                        state <= START;
                end

                START: begin
                    // чекаємо середину стартового біта
                    if (clk_cnt == (CLKS_PER_BIT/2) - 1) begin
                        clk_cnt <= 0;
                        if (rx_s2 == 1'b0)
                            state <= DATA;       // старт підтверджено
                        else
                            state <= IDLE;       // хибне спрацювання
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

                DATA: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        shift[bit_idx] <= rx_s2; // записуємо біт у середині інтервалу
                        if (bit_idx == 7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else
                            bit_idx <= bit_idx + 1;
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

                STOP: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (rx_s2 == 1'b1) begin // коректний стоп-біт
                            data_out   <= shift;
                            data_valid <= 1'b1;
                        end
                        state <= IDLE;
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

            endcase
        end
    end
endmodule