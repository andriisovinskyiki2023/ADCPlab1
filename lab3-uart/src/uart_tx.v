// UART передавач, формат 8N1
module uart_tx #(
    parameter CLKS_PER_BIT = 434      // тактів на один біт (50 МГц / 115200)
)(
    input  wire       clk,            // тактовий сигнал
    input  wire       rst,            // скидання (активний рівень 1)
    input  wire       start,          // імпульс початку передачі
    input  wire [7:0] data_in,        // байт для передачі
    output reg        tx,             // вихідна лінія UART
    output reg        busy            // 1, поки йде передача
);

    // Кодування станів
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_cnt;               // лічильник тактів у межах біта
    reg [2:0]  bit_idx;               // номер поточного біта даних (0..7)
    reg [7:0]  data_reg;              // збережений байт

    always @(posedge clk) begin
        if (rst) begin
            state   <= IDLE;
            tx      <= 1'b1;
            busy    <= 1'b0;
            clk_cnt <= 0;
            bit_idx <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx      <= 1'b1;
                    busy    <= 1'b0;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (start) begin
                        data_reg <= data_in;
                        busy     <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;                       // стартовий біт
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

                DATA: begin
                    tx <= data_reg[bit_idx];          // LSB першим
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else
                            bit_idx <= bit_idx + 1;
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

                STOP: begin
                    tx <= 1'b1;                       // стоп-біт
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= IDLE;
                    end else
                        clk_cnt <= clk_cnt + 1;
                end

            endcase
        end
    end
endmodule