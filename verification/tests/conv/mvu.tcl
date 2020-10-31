add_wave_group mvu
    add_wave -into mvu {{/conv_tester/accelerator/mvu/clk}}
    add_wave_group -into mvu mvu0
        add_wave_group -into mvu0 input_ram
            add_wave -into input_ram {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /\bankarray[0].db /b/inst/\native_mem_module.blk_mem_gen_v8_4_3_inst /memory}}
        add_wave_group -into mvu0 output_ram
            add_wave -into output_ram {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /\bankarray[1].db /b/inst/\native_mem_module.blk_mem_gen_v8_4_3_inst /memory}}
        add_wave_group -into mvu0 pipeline
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /core_data}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /core_weights}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /core_out}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /shacc_out}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /scaler_out}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /pool_out}}
            add_wave -into pipeline {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /quant_out}}
        add_wave_group -into mvu0 configs
            add_wave -into configs {{/conv_tester/accelerator/mvu/iprecision_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/iprecision_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/wprecision_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/oprecision_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/quant_msbidx_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/countdown_q}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /mul_mode}}
            add_wave -into configs {{/conv_tester/accelerator/mvu/\mvuarray[0].mvunit /scaler_b}}
set_property display_limit 40000000 [current_wave_config]