
package utils;
//==================================================================================================
// Enum: print_verbosity_t
// Defines standard verbosity levels for reports.
//
//  VERB_NONE    Report is always printed. Verbosity level setting cannot disable it.
//  VERB_LOW     Report is issued if configured verbosity is set to VERB_LOW or above.
//  VERB_MEDIUM  Report is issued if configured verbosity is set to VERB_MEDIUM or above.
//  VERB_HIGH    Report is issued if configured verbosity is set to VERB_HIGH or above.
//  VERB_FULL    Report is issued if configured verbosity is set to VERB_FULL or above.
typedef enum {
    VERB_NONE   = 0,
    VERB_LOW    = 100,
    VERB_MEDIUM = 200,
    VERB_HIGH   = 300,
    VERB_FULL   = 400,
    VERB_DEBUG  = 500
} print_verbosity_t;


//==================================================================================================
// Logger class, logs test string to a file
class Logger;  /* base class*/;
    int fd;
    bit log_time;
    bit log_to_std_out;

    function new (string file_name, bit log_time=1, bit log_to_std_out=1);
          this.fd = $fopen(file_name,"w");
          this.log_time = log_time;
          this.log_to_std_out = log_to_std_out;
    endfunction

    function void print (string msg, string id="INFO", print_verbosity_t verbosity=VERB_LOW);
        string time_stamp = this.log_time ? $sformatf("%t",$time()) : "";
        string log = $sformatf("[%5s] %s %s ", id, time_stamp, msg);
        if (verbosity<VERB_MEDIUM) begin
            if (log_to_std_out == 1) begin
                $display("%s", log);
            end
        end
        $fwrite(this.fd, log);
    endfunction

    function void print_banner (string msg, string id="INFO", print_verbosity_t verbosity=VERB_LOW);
        string sep = "=======================================================================";
        string log = $sformatf("%s\n[%5s]  %s \n%s", sep, id, msg, sep);
        if (verbosity<VERB_MEDIUM) begin
            if (log_to_std_out == 1) begin
                $display("%s", log);
            end
        end
        $fwrite(this.fd, log);
    endfunction

endclass
//==================================================================================================
// Struct test_stats_t
// Defines a struct that holds test statistics 

typedef struct packed
{
    int unsigned pass_cnt;
    int unsigned fail_cnt;
} test_stats_t;

//==================================================================================================
// Test print macro
// Defines a macro to print 
`define test_print(ID,MSG,VERBOSITY) \
   begin \
            $display($sformatf("[%5s]  %s ", ID, MSG)); \
   end

//==================================================================================================
// Print Banner macro
// Defines a macro to print a banner that bolds the msg
`define print_banner(ID,MSG,VERBOSITY) \
   begin \
        `test_print(ID,"=======================================================================",VERBOSITY) \
        `test_print(ID,MSG,VERBOSITY) \
        `test_print(ID,"=======================================================================",VERBOSITY) \
   end

//==================================================================================================
// Macro to set bits of a vector t
`define set_bits(vector, number_of_bits, val)\
    begin \
        for (int i = 0; i < number_of_bits; i++) begin\
            vector[i] = val;\
        end\
    end

//==================================================================================================
// Macro to set bits of a vector t
`define set_bits_mat(mat, number_of_rows, number_of_cols, val)\
    begin \
        for (int j = 0; j < number_of_rows; j++) begin\
            for (int i = 0; i < number_of_cols; i++) begin\
                mat[j][i] = val;\
            end\
        end\
    end

//==================================================================================================
// A function to report results
function void print_result(test_stats_t test_stat, print_verbosity_t verbosity=VERB_LOW, Logger logger=null);
    if (logger == null) begin
        `print_banner("INFO", "Test results", verbosity)
        `test_print("INFO", $sformatf("Total Number of tests  = %0d\n", test_stat.pass_cnt+test_stat.fail_cnt), verbosity)
        `test_print("INFO", $sformatf("Number of passed tests = %0d", test_stat.pass_cnt), verbosity)
        `test_print("INFO", $sformatf("Number of failed tests = %0d\n", test_stat.fail_cnt), verbosity)
    end else begin
        logger.print_banner("Test results");
        logger.print($sformatf("Total Number of tests  = %0d", test_stat.pass_cnt+test_stat.fail_cnt));
        logger.print($sformatf("Number of passed tests = %0d", test_stat.pass_cnt));
        logger.print($sformatf("Number of failed tests = %0d", test_stat.fail_cnt));
    end
endfunction : print_result

//==================================================================================================
// Given the size of a matrix and an input array, this function prints array in matrix format 
function void print_matrix_from_array(inout integer array, integer row_len, integer col_len);
    static string array_shape_str = "";
    static int elcnt = 0;
    for (int rows=0; rows<row_len; rows++) begin
        for(int cols=0; cols<col_len; cols++) begin
            array_shape_str = {array_shape_str, $sformatf("%2h ",array[elcnt])};
            elcnt++;
        end
        `test_print("INFO", $sformatf("%s", array_shape_str), VERB_LOW)
        array_shape_str = "";
    end
endfunction : print_matrix_from_array

endpackage : utils