`include "testbench_base.sv"


class matmul_tester extends barvinn_testbench_base;

    function new(Logger logger, virtual pito_interface pito_inf, virtual mvu_interface mvu_inf);
        super.new(logger, pito_inf, mvu_inf);
    endfunction

    task tb_setup();
        super.tb_setup();
    endtask

    // Given an input weight file in transposed format, this function
    // read the file and writes it into MVU weight memory
    task write_weight_data(input string weight_file, input int mvu, input logic [BWBANKA-1 : 0] base_addr, output w_data_q_t data_q);
        int fd = $fopen (weight_file, "r"), line_cnt;
        w_data_t temp_dat;
        string temp, line;
        int word_cnt = 0;
        line_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", weight_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", weight_file, fd)); $finish(); end
        while (!$feof(fd)) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                if ($sscanf(line, "%b", temp_dat)) begin
                    data_q.push_back(temp_dat);
                    write_mvu_weights(mvu, temp_dat, base_addr);
                    base_addr += 1;
                end else begin
                    logger.print($sformatf("Error convering line %0d of %s", line_cnt, weight_file));
                end
                word_cnt += 1;
            end
            line_cnt += 1;
        end
    endtask

    // Given an input weight file in transposed format, this function
    // read the file and writes it into MVU weight memory
    task write_input_data(input string input_file, input int mvu, input logic [BDBANKA-1 : 0] base_addr, output a_data_t data_q);
        int fd = $fopen (input_file, "r"), line_cnt;
        a_data_t temp_dat;
        string temp, line;
        int word_cnt = 0;
        line_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", input_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", input_file, fd)); $finish(); end
        while (!$feof(fd)) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                if ($sscanf(line, "%b", temp_dat)) begin
                    data_q.push_back(temp_dat);
                    write_mvu_data(mvu, temp_dat, base_addr);
                    base_addr += 1;
                end else begin
                    logger.print($sformatf("Error convering line %0d of %s", line_cnt, input_file));
                end
                word_cnt += 1;
            end
            line_cnt += 1;
        end
    endtask



    task run();
        // Weight tensor that was written into MVU rams
        w_data_q_t w_data;

        logger.print_banner("Testbench Run phase");
        write_weight_data("/users/hemmat/MyRepos/BARVINN/weight.txt", 0, 0, w_data);
        // // read back data that was written into the rams
        // for (int i=0; i<w_data.size(); i++) begin

        // end

        fork
            this.monitor.run();
            // monitor_regs();
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass

