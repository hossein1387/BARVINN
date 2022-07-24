`include "testbench_base.sv"
`include "testbench_macros.svh"

class conv_tester extends barvinn_testbench_base;

    function new(Logger logger, virtual MVU_EXT_INTERFACE mvu_ext_intf, virtual pito_soc_ext_interface pito_intf);
        super.new(logger, mvu_ext_intf, pito_intf);
    endfunction

    task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Weight tensor that was written into MVU rams
        // w_data_q_t w_data;
        // write_weight_data("/users/hemmat/MyRepos/BARVINN/weight.txt", 0, 0, w_data);
        write_weight_data("/users/hemmat/MyRepos/BARVINN/verification/tests/conv/weight.hex", 0, 0);
        write_input_data("/users/hemmat/MyRepos/BARVINN/verification/tests/conv/input.hex", 0, 0);
        // Put DUT to reset and relax memory interface
        logger.print("Initializing MVUs...");
        super.mvu_init();
        logger.print("Initializing RISC-V cores ...");
        super.pito_init();
        logger.print("Setup Phase Done ...");
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

    function int get_mvu_bank_val (mvu, bank_num, addr);
        int val = 0;
        case (bank_num)
            0 : begin val = `hdl_path_mvu0_mem_0[addr]; end
            1 : begin val = `hdl_path_mvu0_mem_1[addr]; end
            2 : begin val = `hdl_path_mvu0_mem_2[addr]; end
            3 : begin val = `hdl_path_mvu0_mem_3[addr]; end
            4 : begin val = `hdl_path_mvu0_mem_4[addr]; end
            5 : begin val = `hdl_path_mvu0_mem_5[addr]; end
            6 : begin val = `hdl_path_mvu0_mem_6[addr]; end
            7 : begin val = `hdl_path_mvu0_mem_7[addr]; end
            8 : begin val = `hdl_path_mvu0_mem_8[addr]; end
            9 : begin val = `hdl_path_mvu0_mem_9[addr]; end
            10: begin val = `hdl_path_mvu0_mem_10[addr]; end
            11: begin val = `hdl_path_mvu0_mem_11[addr]; end
            12: begin val = `hdl_path_mvu0_mem_12[addr]; end
            13: begin val = `hdl_path_mvu0_mem_13[addr]; end
            14: begin val = `hdl_path_mvu0_mem_14[addr]; end
            15: begin val = `hdl_path_mvu0_mem_15[addr]; end
            16: begin val = `hdl_path_mvu0_mem_16[addr]; end
            17: begin val = `hdl_path_mvu0_mem_17[addr]; end
            18: begin val = `hdl_path_mvu0_mem_18[addr]; end
            19: begin val = `hdl_path_mvu0_mem_19[addr]; end
            20: begin val = `hdl_path_mvu0_mem_20[addr]; end
            21: begin val = `hdl_path_mvu0_mem_21[addr]; end
            22: begin val = `hdl_path_mvu0_mem_22[addr]; end
            23: begin val = `hdl_path_mvu0_mem_23[addr]; end
            24: begin val = `hdl_path_mvu0_mem_24[addr]; end
            25: begin val = `hdl_path_mvu0_mem_25[addr]; end
            26: begin val = `hdl_path_mvu0_mem_26[addr]; end
            27: begin val = `hdl_path_mvu0_mem_27[addr]; end
            28: begin val = `hdl_path_mvu0_mem_28[addr]; end
            29: begin val = `hdl_path_mvu0_mem_29[addr]; end
            30: begin val = `hdl_path_mvu0_mem_30[addr]; end
            31: begin val = `hdl_path_mvu0_mem_31[addr]; end
        endcase
        return val;
    endfunction

    task dump_output_data(input string output_file, input int mvu_num, input logic [BDBANKA-1 : 0] base_addr, input int words_to_read);
        logic grnt;
        int fd = $fopen (output_file, "w");
        a_data_t temp_dat;
        logic [BDBANKA-1 : 0] addr = base_addr;
        int word_cnt = 0;
        int bank_num = 0;
        int mem_val;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", output_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", output_file, fd)); $finish(); end
        logger.print($sformatf("=> Reading output ram ..."));
        while (word_cnt<words_to_read) begin
            // data_q.push_back(temp_dat);
            // readData(int mvu, logic unsigned [BDBANKA-1 : 0] addr, ref logic unsigned [BDBANKW-1 : 0] word, ref logic unsigned [NMVU-1 : 0] grnt);
            // readData(mvu, addr, temp_dat, grnt);
            if (addr>1023) begin
                bank_num = 0;
            end else begin
                bank_num = addr%1024;
            end
            mem_val = get_mvu_bank_val(mvu_num, bank_num, addr);
            logger.print($sformatf("[%4h]: 0x%16h", addr, mem_val));
            $fwrite(fd,"%16h\n", mem_val);
            addr += 1;
            word_cnt += 1;
        end
    endtask

    task run();
        // Kick start the MVU and pito
        // super.run();
        fork
            this.monitor.run();
            // monitor_regs();
        join_any
    endtask

    task report();
        string output_file = "result.hex";
        super.report();
        logger.print($sformatf("dumping results into %s ...", output_file));
        dump_output_data(output_file, 0, 0, 4096);
    endtask

endclass

