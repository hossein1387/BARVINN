`include "testbench_base.sv"

class matmul_tester extends barvinn_testbench_base;

    function new(Logger logger, virtual barvinn_interface barvinn_intf, virtual pito_interface pito_intf);
        super.new(logger, barvinn_intf, pito_intf);
    endfunction

    task tb_setup();
        // Weight tensor that was written into MVU rams
        // w_data_q_t w_data;
        // write_weight_data("/users/hemmat/MyRepos/BARVINN/weight.txt", 0, 0, w_data);
        super.tb_setup();
        write_weight_data("/users/hemmat/MyRepos/BARVINN/verification/tests/matmul/weight.hex", 0, 0);
        write_input_data("/users/hemmat/MyRepos/BARVINN/verification/tests/matmul/input.hex", 0, 0);
    endtask

    // Given an input weight file in transposed format, this function
    // read the file and writes it into MVU weight memory
    task write_weight_data(input string weight_file, input int mvu, input logic [BWBANKA-1 : 0] base_addr);
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
                    // data_q.push_back(temp_dat);
                    write_mvu_weights(mvu, temp_dat, base_addr);
                    base_addr += 1;
                end else begin
                    logger.print($sformatf("Error reading line %0d of %s", line_cnt, weight_file));
                end
                word_cnt += 1;
            end
            line_cnt += 1;
        end
    endtask

    // Given an input weight file in transposed format, this function
    // read the file and writes it into MVU weight memory
    task write_input_data(input string input_file, input int mvu, input logic [BDBANKA-1 : 0] base_addr);
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
                    // data_q.push_back(temp_dat);
                    // logger.print($sformatf("write_input_data: writing %16h at %12h", temp_dat, base_addr));
                    write_mvu_data(mvu, temp_dat, base_addr);
                    base_addr += 1;
                end else begin
                    logger.print($sformatf("Error reading line %0d of %s", line_cnt, input_file));
                end
                word_cnt += 1;
            end
            line_cnt += 1;
        end
    endtask


    task dump_output_data(input string output_file, input int mvu, input logic [BDBANKA-1 : 0] base_addr, input int words_to_read);
        logic grnt;
        int fd = $fopen (output_file, "w");
        a_data_t temp_dat;
        logic [BDBANKA-1 : 0] addr = base_addr;
        int word_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", output_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", output_file, fd)); $finish(); end
        while (word_cnt<words_to_read) begin
            // data_q.push_back(temp_dat);
            // readData(int mvu, logic unsigned [BDBANKA-1 : 0] addr, ref logic unsigned [BDBANKW-1 : 0] word, ref logic unsigned [NMVU-1 : 0] grnt);
            // readData(mvu, addr, temp_dat, grnt);
            addr += 1;
            word_cnt += 1;
        end
    endtask

    task run();
        // Kick start the MVU and pito
        super.run();
        fork
            this.monitor.run();
            // monitor_regs();
        join_any
    endtask

    task report();
        string output_file = "result.hex";
        super.report();
        logger.print($sformatf("dumping results into %s ...", output_file));
        dump_output_data(output_file, 0, 0, 1600);
    endtask

endclass

