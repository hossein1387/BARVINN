`include "testbench_base.sv"
`include "testbench_macros.svh"

import utils::*;

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


    // Back-door function to read MVU data memory
    function int peekData(int mvu, int bank, int addr);
        case (mvu)
            0 : begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(0, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(0, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(0, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(0, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(0, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(0, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(0, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(0, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(0, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(0, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(0, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(0, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(0, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(0, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(0, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(0, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(0, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(0, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(0, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(0, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(0, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(0, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(0, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(0, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(0, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(0, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(0, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(0, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(0, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(0, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(0, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(0, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            1: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(1, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(1, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(1, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(1, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(1, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(1, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(1, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(1, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(1, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(1, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(1, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(1, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(1, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(1, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(1, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(1, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(1, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(1, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(1, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(1, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(1, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(1, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(1, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(1, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(1, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(1, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(1, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(1, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(1, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(1, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(1, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(1, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            2: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(2, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(2, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(2, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(2, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(2, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(2, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(2, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(2, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(2, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(2, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(2, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(2, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(2, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(2, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(2, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(2, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(2, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(2, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(2, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(2, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(2, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(2, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(2, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(2, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(2, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(2, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(2, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(2, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(2, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(2, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(2, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(2, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            3: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(3, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(3, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(3, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(3, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(3, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(3, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(3, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(3, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(3, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(3, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(3, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(3, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(3, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(3, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(3, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(3, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(3, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(3, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(3, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(3, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(3, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(3, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(3, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(3, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(3, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(3, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(3, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(3, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(3, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(3, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(3, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(3, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            4: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(4, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(4, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(4, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(4, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(4, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(4, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(4, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(4, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(4, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(4, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(4, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(4, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(4, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(4, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(4, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(4, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(4, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(4, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(4, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(4, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(4, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(4, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(4, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(4, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(4, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(4, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(4, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(4, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(4, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(4, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(4, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(4, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            5: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(5, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(5, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(5, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(5, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(5, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(5, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(5, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(5, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(5, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(5, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(5, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(5, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(5, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(5, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(5, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(5, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(5, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(5, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(5, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(5, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(5, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(5, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(5, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(5, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(5, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(5, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(5, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(5, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(5, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(5, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(5, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(5, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            6: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(6, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(6, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(6, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(6, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(6, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(6, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(6, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(6, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(6, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(6, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(6, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(6, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(6, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(6, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(6, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(6, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(6, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(6, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(6, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(6, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(6, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(6, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(6, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(6, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(6, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(6, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(6, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(6, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(6, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(6, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(6, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(6, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            7: begin
                case (bank)
                    0:      return `hdl_path_mvu_data_mem_bank_ram(7, 0)[addr];
                    1:      return `hdl_path_mvu_data_mem_bank_ram(7, 1)[addr];
                    2:      return `hdl_path_mvu_data_mem_bank_ram(7, 2)[addr];
                    3:      return `hdl_path_mvu_data_mem_bank_ram(7, 3)[addr];
                    4:      return `hdl_path_mvu_data_mem_bank_ram(7, 4)[addr];
                    5:      return `hdl_path_mvu_data_mem_bank_ram(7, 5)[addr];
                    6:      return `hdl_path_mvu_data_mem_bank_ram(7, 6)[addr];
                    7:      return `hdl_path_mvu_data_mem_bank_ram(7, 7)[addr];
                    8:      return `hdl_path_mvu_data_mem_bank_ram(7, 8)[addr];
                    9:      return `hdl_path_mvu_data_mem_bank_ram(7, 9)[addr];
                    10:     return `hdl_path_mvu_data_mem_bank_ram(7, 10)[addr];
                    11:     return `hdl_path_mvu_data_mem_bank_ram(7, 11)[addr];
                    12:     return `hdl_path_mvu_data_mem_bank_ram(7, 12)[addr];
                    13:     return `hdl_path_mvu_data_mem_bank_ram(7, 13)[addr];
                    14:     return `hdl_path_mvu_data_mem_bank_ram(7, 14)[addr];
                    15:     return `hdl_path_mvu_data_mem_bank_ram(7, 15)[addr];
                    16:     return `hdl_path_mvu_data_mem_bank_ram(7, 16)[addr];
                    17:     return `hdl_path_mvu_data_mem_bank_ram(7, 17)[addr];
                    18:     return `hdl_path_mvu_data_mem_bank_ram(7, 18)[addr];
                    19:     return `hdl_path_mvu_data_mem_bank_ram(7, 19)[addr];
                    20:     return `hdl_path_mvu_data_mem_bank_ram(7, 20)[addr];
                    21:     return `hdl_path_mvu_data_mem_bank_ram(7, 21)[addr];
                    22:     return `hdl_path_mvu_data_mem_bank_ram(7, 22)[addr];
                    23:     return `hdl_path_mvu_data_mem_bank_ram(7, 23)[addr];
                    24:     return `hdl_path_mvu_data_mem_bank_ram(7, 24)[addr];
                    25:     return `hdl_path_mvu_data_mem_bank_ram(7, 25)[addr];
                    26:     return `hdl_path_mvu_data_mem_bank_ram(7, 26)[addr];
                    27:     return `hdl_path_mvu_data_mem_bank_ram(7, 27)[addr];
                    28:     return `hdl_path_mvu_data_mem_bank_ram(7, 28)[addr];
                    29:     return `hdl_path_mvu_data_mem_bank_ram(7, 29)[addr];
                    30:     return `hdl_path_mvu_data_mem_bank_ram(7, 30)[addr];
                    31:     return `hdl_path_mvu_data_mem_bank_ram(7, 31)[addr];
                    default:
                        $error("Invalid address");
                endcase
            end
            default:
                $error("Invalid MVU value.");
        endcase
    endfunction

    // function int get_mvu_bank_val (mvu, bank_num, addr);
    //     int val = 0;
    //     case (bank_num)
    //         0 : begin val = `hdl_path_mvu0_mem_0[addr]; end
    //         1 : begin val = `hdl_path_mvu0_mem_1[addr]; end
    //         2 : begin val = `hdl_path_mvu0_mem_2[addr]; end
    //         3 : begin val = `hdl_path_mvu0_mem_3[addr]; end
    //         4 : begin val = `hdl_path_mvu0_mem_4[addr]; end
    //         5 : begin val = `hdl_path_mvu0_mem_5[addr]; end
    //         6 : begin val = `hdl_path_mvu0_mem_6[addr]; end
    //         7 : begin val = `hdl_path_mvu0_mem_7[addr]; end
    //         8 : begin val = `hdl_path_mvu0_mem_8[addr]; end
    //         9 : begin val = `hdl_path_mvu0_mem_9[addr]; end
    //         10: begin val = `hdl_path_mvu0_mem_10[addr]; end
    //         11: begin val = `hdl_path_mvu0_mem_11[addr]; end
    //         12: begin val = `hdl_path_mvu0_mem_12[addr]; end
    //         13: begin val = `hdl_path_mvu0_mem_13[addr]; end
    //         14: begin val = `hdl_path_mvu0_mem_14[addr]; end
    //         15: begin val = `hdl_path_mvu0_mem_15[addr]; end
    //         16: begin val = `hdl_path_mvu0_mem_16[addr]; end
    //         17: begin val = `hdl_path_mvu0_mem_17[addr]; end
    //         18: begin val = `hdl_path_mvu0_mem_18[addr]; end
    //         19: begin val = `hdl_path_mvu0_mem_19[addr]; end
    //         20: begin val = `hdl_path_mvu0_mem_20[addr]; end
    //         21: begin val = `hdl_path_mvu0_mem_21[addr]; end
    //         22: begin val = `hdl_path_mvu0_mem_22[addr]; end
    //         23: begin val = `hdl_path_mvu0_mem_23[addr]; end
    //         24: begin val = `hdl_path_mvu0_mem_24[addr]; end
    //         25: begin val = `hdl_path_mvu0_mem_25[addr]; end
    //         26: begin val = `hdl_path_mvu0_mem_26[addr]; end
    //         27: begin val = `hdl_path_mvu0_mem_27[addr]; end
    //         28: begin val = `hdl_path_mvu0_mem_28[addr]; end
    //         29: begin val = `hdl_path_mvu0_mem_29[addr]; end
    //         30: begin val = `hdl_path_mvu0_mem_30[addr]; end
    //         31: begin val = `hdl_path_mvu0_mem_31[addr]; end
    //     endcase
    //     return val;
    // endfunction

    task dump_output_data(input string output_file, input int mvu_num, input logic [BDBANKA-1 : 0] base_addr, input int words_to_read, input print_verbosity_t verbosity);
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
            // mem_val = get_mvu_bank_val(mvu_num, bank_num, addr);
            mem_val = peekData(mvu_num, bank_num, addr);
            logger.print($sformatf("[%4h]: 0x%16h", addr, mem_val), "INFO", verbosity);
            $fwrite(fd,"%16h\n", mem_val);
            addr += 1;
            word_cnt += 1;
        end
    endtask

    task external_mem_model();
    endtask

    task run();
        // Kick start the MVU and pito
        // super.run();
        fork
            this.monitor.run();
            // monitor_regs();
            // external_mem_model();
        join_any
    endtask

    task report();
        string output_file = "result.hex";
        super.report();
        logger.print($sformatf("dumping results into %s ...", output_file));
        dump_output_data(output_file, 0, 0, 4096, utils::VERB_LOW);
    endtask

endclass

