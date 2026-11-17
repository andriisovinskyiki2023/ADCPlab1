`timescale 1ns/1ps

module uart_tb;

    localparam CLKS_PER_BIT = 16;
    localparam CLK_PERIOD   = 20;     // 50 МГц

    reg        clk = 0;
    reg        rst = 1;
    reg        start = 0;
    reg  [7:0] tx_data = 0;
    wire       line;                  // лінія між Tx та Rx
    wire       busy;
    wire [7:0] rx_data;
    wire       rx_valid;

    // Окремий вхід для ручної перевірки Rx
    reg        manual_rx = 1;
    wire [7:0] manual_data;
    wire       manual_valid;

    // Тестований передавач
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut_tx (
        .clk(clk), .rst(rst), .start(start),
        .data_in(tx_data), .tx(line), .busy(busy)
    );

    // Приймач у loopback з передавачем
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut_rx (
        .clk(clk), .rst(rst), .rx(line),
        .data_out(rx_data), .data_valid(rx_valid)
    );

    // Приймач для ручної перевірки (імітує зовнішній пристрій)
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut_rx_manual (
        .clk(clk), .rst(rst), .rx(manual_rx),
        .data_out(manual_data), .data_valid(manual_valid)
    );

    // Генерація тактового сигналу
    always #(CLK_PERIOD/2) clk = ~clk;

    integer errors = 0;

    // Завдання: відправити байт через Tx і перевірити прийом
    task send_and_check(input [7:0] value);
        begin
            @(posedge clk);
            tx_data = value;
            start   = 1;
            @(posedge clk);
            start   = 0;
            wait (rx_valid);              // чекаємо готовність прийому
            @(posedge clk);
            if (rx_data === value)
                $display("PASS: sent %h, received %h", value, rx_data);
            else begin
                $display("FAIL: sent %h, received %h", value, rx_data);
                errors = errors + 1;
            end
            wait (!busy);
        end
    endtask

    // Завдання: подати кадр на manual_rx вручну (як зовнішній пристрій)
    task drive_frame(input [7:0] value);
        integer i;
        begin
            manual_rx = 0;                                  // старт
            repeat (CLKS_PER_BIT) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                manual_rx = value[i];                       // дані, LSB першим
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            manual_rx = 1;                                  // стоп
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_tb);

        // Скидання
        repeat (5) @(posedge clk);
        rst = 0;
        repeat (5) @(posedge clk);

        // Тест 1: Tx -> Rx (loopback)
        send_and_check(8'hA5);
        send_and_check(8'h3C);
        send_and_check(8'hFF);
        send_and_check(8'h00);

        // Тест 2: окремо перевіряємо 
        fork
            drive_frame(8'h5A);              // подаємо кадр на вхід Rx
            begin
                wait (manual_valid);         // паралельно чекаємо результат
                if (manual_data === 8'h5A)
                    $display("PASS: manual RX got %h", manual_data);
                else begin
                    $display("FAIL: manual RX got %h", manual_data);
                    errors = errors + 1;
                end
            end
        join

        repeat (50) @(posedge clk);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule