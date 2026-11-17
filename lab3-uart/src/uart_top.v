// Верхній модуль для синтезу: Tx та Rx з'єднані між собою (loopback)
module uart_top (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] data_in,
    output wire       busy,
    output wire [7:0] data_out,
    output wire       data_valid
);
    wire line;  // внутрішня лінія UART

    uart_tx #(.CLKS_PER_BIT(434)) u_tx (
        .clk(clk), .rst(rst), .start(start),
        .data_in(data_in), .tx(line), .busy(busy)
    );

    uart_rx #(.CLKS_PER_BIT(434)) u_rx (
        .clk(clk), .rst(rst), .rx(line),
        .data_out(data_out), .data_valid(data_valid)
    );
endmodule