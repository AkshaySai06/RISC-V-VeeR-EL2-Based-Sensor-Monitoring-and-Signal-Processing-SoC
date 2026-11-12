"""
VeeR EL2 Configuration Generator in Python
Replicates configs/veer.config for:
-target=default -set=build_axi4=1 -set=iccm_enable=0 -set=dccm_enable=0 -set=icache_enable=0 -set=reset_vec=0x00000000 -set=pic_total_int=8
"""
import os
import math

def log2(v):
    return int(math.ceil(math.log2(v)))

def main():
    out_dir = os.path.abspath("core_config")
    os.makedirs(out_dir, exist_ok=True)

    # Core configuration parameters
    pic_total_int = 8
    reset_vec = "0x00000000"
    nmi_vec = "0x11110000"
    
    # Generate pic_map_auto.svh
    pic_lines = [
        "// mask[3:0] = { 4'b1000 - 30b mask, 4'b0100 - 31b mask, 4'b0010 - 28b mask, 4'b0001 - 32b mask }",
        "always_comb begin",
        "  case (address[14:0])",
        "    15'b011000000000000 : mask[3:0] = 4'b0100;"
    ]
    for i in range(1, pic_total_int + 1):
        pic_lines.append(f"    15'b{bin(0x4000 + i*4)[2:].zfill(15)} : mask[3:0] = 4'b1000;")
    for i in range(1, pic_total_int + 1):
        pic_lines.append(f"    15'b{bin(0x2000 + i*4)[2:].zfill(15)} : mask[3:0] = 4'b0100;")
    for i in range(1, pic_total_int + 1):
        pic_lines.append(f"    15'b{bin(0x0000 + i*4)[2:].zfill(15)} : mask[3:0] = 4'b0010;")
    pic_lines.append("    default           : mask[3:0] = 4'b0001;")
    pic_lines.append("  endcase")
    pic_lines.append("end\n")

    with open(os.path.join(out_dir, "pic_map_auto.svh"), "w") as f:
        f.write("\n".join(pic_lines))

    # Parameter struct entries (verilog_parms)
    # Widths in bits for packed struct el2_param_t
    parms = {
        "bht_array_depth": (11, 512),
        "bht_ghr_hash_1": (1, 0),
        "bht_ghr_size": (4, 9),
        "bht_size": (12, 512),
        "bitmanip_zba": (1, 1),
        "bitmanip_zbb": (1, 1),
        "bitmanip_zbc": (1, 1),
        "bitmanip_zbe": (1, 0),
        "bitmanip_zbf": (1, 0),
        "bitmanip_zbp": (1, 0),
        "bitmanip_zbr": (1, 0),
        "bitmanip_zbs": (1, 1),
        "btb_array_depth": (9, 64),
        "btb_btag_fold": (1, 0),
        "btb_btag_size": (5, 5),
        "btb_enable": (1, 1),
        "btb_fold2_index_hash": (1, 0),
        "btb_fullya": (1, 0),
        "btb_index1_hi": (5, 7),
        "btb_index1_lo": (5, 2),
        "btb_index2_hi": (5, 13),
        "btb_index2_lo": (5, 8),
        "btb_index3_hi": (5, 19),
        "btb_index3_lo": (5, 14),
        "btb_size": (10, 64),
        "btb_toffset_size": (5, 12),
        "build_ahb_lite": (1, 0),
        "build_axi4": (1, 1),
        "build_axi_native": (1, 1),
        "bus_prty_default": (2, 3),
        "data_access_addr0": (32, 0),
        "data_access_addr1": (32, 0),
        "data_access_addr2": (32, 0),
        "data_access_addr3": (32, 0),
        "data_access_addr4": (32, 0),
        "data_access_addr5": (32, 0),
        "data_access_addr6": (32, 0),
        "data_access_addr7": (32, 0),
        "data_access_enable0": (1, 0),
        "data_access_enable1": (1, 0),
        "data_access_enable2": (1, 0),
        "data_access_enable3": (1, 0),
        "data_access_enable4": (1, 0),
        "data_access_enable5": (1, 0),
        "data_access_enable6": (1, 0),
        "data_access_enable7": (1, 0),
        "data_access_mask0": (32, 0xFFFFFFFF),
        "data_access_mask1": (32, 0xFFFFFFFF),
        "data_access_mask2": (32, 0xFFFFFFFF),
        "data_access_mask3": (32, 0xFFFFFFFF),
        "data_access_mask4": (32, 0xFFFFFFFF),
        "data_access_mask5": (32, 0xFFFFFFFF),
        "data_access_mask6": (32, 0xFFFFFFFF),
        "data_access_mask7": (32, 0xFFFFFFFF),
        "dccm_bank_bits": (3, 0),
        "dccm_bits": (5, 16),
        "dccm_byte_width": (3, 4),
        "dccm_data_width": (6, 32),
        "dccm_ecc_width": (3, 7),
        "dccm_enable": (1, 0),
        "dccm_fdata_width": (6, 39),
        "dccm_index_bits": (4, 12),
        "dccm_num_banks": (5, 4),
        "dccm_region": (4, 0xF),
        "dccm_sadr": (32, 0xF0040000),
        "dccm_size": (10, 64),
        "dccm_width_bits": (2, 2),
        "div_bit": (3, 2),
        "div_new": (1, 1),
        "dma_buf_depth": (3, 5),
        "dma_bus_id": (1, 1),
        "dma_bus_prty": (2, 2),
        "dma_bus_tag": (1, 1),
        "fast_interrupt_redirect": (1, 0),
        "icache_bank_bits": (3, 1),
        "icache_beat_addr_hi": (4, 5),
        "icache_beat_bits": (4, 3),
        "icache_bypass_enable": (1, 1),
        "icache_enable": (1, 0),
        "icache_ln_sz": (7, 64),
        "icache_num_beats": (4, 8),
        "icache_num_bypass": (4, 2),
        "icache_num_bypass_width": (4, 2),
        "icache_num_ways": (3, 2),
        "icache_scnd_last": (4, 6),
        "icache_size": (9, 16),
        "icache_status_bits": (3, 1),
        "icache_tag_bypass_enable": (1, 1),
        "icache_tag_num_bypass": (4, 2),
        "icache_tag_num_bypass_width": (4, 2),
        "icache_waypack": (1, 0),
        "iccm_bank_bits": (3, 2),
        "iccm_bank_hi": (5, 3),
        "iccm_bank_index_lo": (5, 4),
        "iccm_bits": (5, 16),
        "iccm_ecc_width": (3, 7),
        "iccm_enable": (1, 0),
        "iccm_index_bits": (4, 12),
        "iccm_num_banks": (5, 4),
        "iccm_region": (4, 0xE),
        "iccm_sadr": (32, 0xEE000000),
        "iccm_size": (10, 64),
        "iccm_icache": (1, 0),
        "iccm_only": (1, 0),
        "icache_only": (1, 0),
        "ifu_bus_id": (1, 1),
        "ifu_bus_prty": (2, 2),
        "ifu_bus_tag": (3, 3),
        "inst_access_addr0": (32, 0),
        "inst_access_addr1": (32, 0),
        "inst_access_addr2": (32, 0),
        "inst_access_addr3": (32, 0),
        "inst_access_addr4": (32, 0),
        "inst_access_addr5": (32, 0),
        "inst_access_addr6": (32, 0),
        "inst_access_addr7": (32, 0),
        "inst_access_enable0": (1, 0),
        "inst_access_enable1": (1, 0),
        "inst_access_enable2": (1, 0),
        "inst_access_enable3": (1, 0),
        "inst_access_enable4": (1, 0),
        "inst_access_enable5": (1, 0),
        "inst_access_enable6": (1, 0),
        "inst_access_enable7": (1, 0),
        "inst_access_mask0": (32, 0xFFFFFFFF),
        "inst_access_mask1": (32, 0xFFFFFFFF),
        "inst_access_mask2": (32, 0xFFFFFFFF),
        "inst_access_mask3": (32, 0xFFFFFFFF),
        "inst_access_mask4": (32, 0xFFFFFFFF),
        "inst_access_mask5": (32, 0xFFFFFFFF),
        "inst_access_mask6": (32, 0xFFFFFFFF),
        "inst_access_mask7": (32, 0xFFFFFFFF),
        "load_to_use_plus1": (1, 0),
        "lockstep_delay": (3, 0),
        "lockstep_enable": (1, 0),
        "lockstep_regfile_enable": (1, 0),
        "lsu2dma": (1, 0),
        "lsu_bus_id": (1, 1),
        "lsu_bus_prty": (2, 2),
        "lsu_bus_tag": (4, 4),
        "lsu_num_nbload": (5, 0),
        "lsu_num_nbload_width": (3, 2),
        "lsu_sb_bits": (5, 16),
        "lsu_stbuf_depth": (4, 4),
        "no_iccm_no_icache": (1, 1),
        "pic_2cycle": (1, 0),
        "pic_base_addr": (32, 0xF00C0000),
        "pic_offset": (10, 0xC0000),
        "pic_region": (4, 0xF),
        "pic_size": (10, 32),
        "pic_total_int": (8, 8),
        "pic_total_int_plus1": (9, 9),
        "pmp_entries": (7, 16),
        "ret_stack_size": (4, 8),
        "sb_bus_id": (1, 1),
        "sb_bus_prty": (2, 2),
        "sb_bus_tag": (1, 1),
        "smepmp": (1, 0),
        "timer_legal_en": (1, 1),
        "user_mode": (1, 1),
    }

    # Generate el2_pdef.vh
    pdef_lines = [
        "// Automatically generated parameter typedef struct",
        "`ifndef _EL2_PDEF_VH_",
        "`define _EL2_PDEF_VH_",
        "typedef struct packed {"
    ]
    for key in sorted(parms.keys()):
        width, _ = parms[key]
        upper = key.upper()
        if width == 1:
            pdef_lines.append(f"    logic            {upper};")
        else:
            pdef_lines.append(f"    logic [{width-1:2d}:0]     {upper};")
    pdef_lines.append("} el2_param_t;")
    pdef_lines.append("`endif\n")

    with open(os.path.join(out_dir, "el2_pdef.vh"), "w") as f:
        f.write("\n".join(pdef_lines))

    # Generate el2_param.vh
    param_lines = [
        "// Automatically generated parameter instantiation",
        "parameter el2_param_t pt = '{"
    ]
    items = []
    for key in sorted(parms.keys()):
        width, val = parms[key]
        upper = key.upper()
        items.append(f"    {upper}: {width}'d{val}")
    param_lines.append(",\n".join(items))
    param_lines.append("};\n")

    with open(os.path.join(out_dir, "el2_param.vh"), "w") as f:
        f.write("\n".join(param_lines))

    # Generate common_defines.vh
    common_lines = [
        "// Automatically generated common_defines.vh",
        "`ifndef _COMMON_DEFINES_VH_",
        "`define _COMMON_DEFINES_VH_",
        "",
        "`define RV_BUILD_AXI4 1",
        "`define RV_NO_ICCM_NO_ICACHE 1",
        "`define RV_USER_MODE 1",
        "`define RV_DIV_NEW 1",
        "`define RV_DIV_BIT 2",
        "`define RV_TIMER_LEGAL_EN 1",
        "`define RV_BITMANIP_ZBA 1",
        "`define RV_BITMANIP_ZBB 1",
        "`define RV_BITMANIP_ZBC 1",
        "`define RV_BITMANIP_ZBS 1",
        "`define RV_BTB_ENABLE 1",
        "`define RV_BTB_SIZE 64",
        "`define RV_BHT_SIZE 512",
        "`define RV_RET_STACK_SIZE 8",
        "`define RV_LSU_STBUF_DEPTH 4",
        "`define RV_DMA_BUF_DEPTH 5",
        "`define RV_PIC_TOTAL_INT 8",
        "`define RV_PIC_TOTAL_INT_PLUS1 9",
        "`define RV_PIC_REGION 4'hF",
        "`define RV_PIC_OFFSET 32'h000C0000",
        "`define RV_PIC_BASE_ADDR 32'hF00C0000",
        "`define RV_PIC_SIZE 32",
        "`define RV_RESET_VEC 32'h00000000",
        "`define RV_NMI_VEC 32'h11110000",
        "`define RV_XLEN 32",
        "`define RV_REGWIDTH 32",
        "`define RV_NUMIREGS 32",
        "`define RV_IFU_BUS_TAG 3",
        "`define RV_LSU_BUS_TAG 4",
        "`define RV_SB_BUS_TAG 1",
        "`define RV_DMA_BUS_TAG 1",
        "`define RV_LSU_BUS_ID 1",
        "`define RV_IFU_BUS_ID 1",
        "`define RV_SB_BUS_ID 1",
        "`define RV_DMA_BUS_ID 1",
        "`define RV_BUS_PRTY_DEFAULT 3",
        "`define RV_LSU_BUS_PRTY 2",
        "`define RV_IFU_BUS_PRTY 2",
        "`define RV_SB_BUS_PRTY 2",
        "`define RV_DMA_BUS_PRTY 2",
        "",
        "`endif\n"
    ]

    with open(os.path.join(out_dir, "common_defines.vh"), "w") as f:
        f.write("\n".join(common_lines))

    # Generate defines.h (assembly/C defines)
    defines_h = [
        "#ifndef _DEFINES_H_",
        "#define _DEFINES_H_",
        "",
        "#define RV_RESET_VEC 0x00000000",
        "#define RV_NMI_VEC 0x11110000",
        "#define RV_XLEN 32",
        "#define RV_PIC_TOTAL_INT 8",
        "#define RV_PIC_BASE_ADDR 0xF00C0000",
        "",
        "#endif\n"
    ]
    with open(os.path.join(out_dir, "defines.h"), "w") as f:
        f.write("\n".join(defines_h))

    print("Successfully generated all core_config files in", out_dir)

if __name__ == "__main__":
    main()

