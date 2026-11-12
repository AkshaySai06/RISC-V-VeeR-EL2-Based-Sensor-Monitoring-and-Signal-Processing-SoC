#!/usr/bin/env python3
"""
Generate CSV files for external interfaces (UART, FIR, GPIO, Timer, I2C, PWM)
and export test plan CSVs according to docs/Updated_Test_Plan.xlsx.
"""

import os
import csv
import re
import zipfile
import xml.etree.ElementTree as ET

# 1. Read Test Plan from XLSX
def parse_test_plan(xlsx_path):
    with zipfile.ZipFile(xlsx_path, 'r') as z:
        ss_xml = z.read('xl/sharedStrings.xml')
        ss_root = ET.fromstring(ss_xml)
        shared_strings = []
        ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
        for si in ss_root.findall('ns:si', ns):
            text = ''.join([t.text for t in si.findall('.//ns:t', ns) if t.text])
            shared_strings.append(text)

        sheet_xml = z.read('xl/worksheets/sheet1.xml')
        sheet_root = ET.fromstring(sheet_xml)
        rows = []
        for row in sheet_root.findall('.//ns:row', ns):
            r_num = int(row.attrib.get('r'))
            if r_num < 2:
                continue
            cells = {}
            for c in row.findall('ns:c', ns):
                coord = c.attrib.get('r')
                col = ''.join([ch for ch in coord if ch.isalpha()])
                t = c.attrib.get('t')
                v = c.find('ns:v', ns)
                val = v.text if v is not None else ''
                if t == 's' and val != '':
                    val = shared_strings[int(val)]
                cells[col] = val
            if cells.get('A') or cells.get('B'):
                rows.append(cells)

    cols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']
    header = [rows[0].get(c, '').strip() for c in cols]
    
    test_cases = []
    for r in rows[1:]:
        sno = r.get('A', '').strip()
        if not sno.startswith('TC-'):
            continue
        tc = {
            'SNo.': sno,
            'Test Name': r.get('B', '').strip(),
            'Description': r.get('C', '').strip(),
            'Checkpoints': r.get('D', '').strip(),
            'C Test Output': r.get('E', '').strip(),
            'C Test Expected Output': r.get('F', '').strip(),
            'SV Test Output': r.get('G', '').strip(),
            'SV Test Expected Output': r.get('H', '').strip(),
            'Internal': r.get('I', '').strip(),
            'External': r.get('J', '').strip(),
            'Interfaces Required': r.get('K', '').strip()
        }
        test_cases.append(tc)
    return header, test_cases

def write_test_plan_csvs(header, test_cases):
    os.makedirs('docs/test_plans', exist_ok=True)
    
    # Full Test Plan
    with open('docs/test_plans/Updated_Test_Plan.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=header)
        writer.writeheader()
        writer.writerows(test_cases)
        
    # All External Interfaces Test Plan (TCs marked External = Yes or having external pins)
    ext_tcs = [tc for tc in test_cases if tc['External'].lower() == 'yes' or 'n/a' not in tc['Interfaces Required'].lower()]
    with open('docs/test_plans/testplan_external_interfaces.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=header)
        writer.writeheader()
        writer.writerows(ext_tcs)

    # Per-interface test plans
    ips = {
        'uart': r'\buart\b',
        'fir': r'\bfir\b',
        'gpio': r'\bgpio\b',
        'timer': r'\btimer\b',
        'i2c': r'\bi2c\b',
        'pwm': r'\bpwm\b'
    }

    for ip, pattern in ips.items():
        matching = []
        for tc in test_cases:
            combined = f"{tc['SNo.']} {tc['Test Name']} {tc['Description']} {tc['Checkpoints']} {tc['Interfaces Required']}"
            if re.search(pattern, combined, re.IGNORECASE):
                matching.append(tc)
        
        filepath = f'docs/test_plans/testplan_{ip}.csv'
        with open(filepath, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=header)
            writer.writeheader()
            writer.writerows(matching)
        print(f"Generated test plan CSV: {filepath} ({len(matching)} test cases)")

# 2. Generate Interface Signals CSVs (compatible with uvm_full_tb_generator.py)
SIGNAL_DEFINITIONS = {
    'uart': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('uart_rx', 'input', 1),
            ('uart_tx', 'output', 1),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('uart_tx', 'output', 1),
            ('uart_rx', 'input', 1),
            ('irq', 'output', 1)
        ]
    },
    'fir': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('sample_in', 'input', 16),
            ('sample_valid', 'input', 1),
            ('sample_ready', 'output', 1),
            ('filtered_out', 'output', 16),
            ('filtered_valid', 'output', 1),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('irq', 'output', 1)
        ]
    },
    'gpio': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('gpio_in', 'input', 16),
            ('gpio_out', 'output', 16),
            ('gpio_oe', 'output', 16),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('gpio_in', 'input', 16),
            ('gpio_out', 'output', 16),
            ('gpio_oe', 'output', 16),
            ('irq', 'output', 1)
        ]
    },
    'timer': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('timer_int', 'output', 1),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('timer_int', 'output', 1),
            ('irq', 'output', 1)
        ]
    },
    'i2c': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('scl_i', 'input', 1),
            ('scl_o', 'output', 1),
            ('scl_oe', 'output', 1),
            ('sda_i', 'input', 1),
            ('sda_o', 'output', 1),
            ('sda_oe', 'output', 1),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('scl_i', 'input', 1),
            ('scl_o', 'output', 1),
            ('scl_oe', 'output', 1),
            ('sda_i', 'input', 1),
            ('sda_o', 'output', 1),
            ('sda_oe', 'output', 1),
            ('irq', 'output', 1)
        ]
    },
    'pwm': {
        'external': [
            ('clk', 'input', 1),
            ('rst_n', 'input', 1),
            ('pwm_out', 'output', 1),
            ('irq', 'output', 1)
        ],
        'axi': [
            ('aclk', 'input', 1),
            ('aresetn', 'input', 1),
            ('s_awaddr', 'input', 32),
            ('s_awprot', 'input', 3),
            ('s_awvalid', 'input', 1),
            ('s_awready', 'output', 1),
            ('s_wdata', 'input', 32),
            ('s_wstrb', 'input', 4),
            ('s_wvalid', 'input', 1),
            ('s_wready', 'output', 1),
            ('s_bresp', 'output', 2),
            ('s_bvalid', 'output', 1),
            ('s_bready', 'input', 1),
            ('s_araddr', 'input', 32),
            ('s_arprot', 'input', 3),
            ('s_arvalid', 'input', 1),
            ('s_arready', 'output', 1),
            ('s_rdata', 'output', 32),
            ('s_rresp', 'output', 2),
            ('s_rvalid', 'output', 1),
            ('s_rready', 'input', 1),
            ('pwm_out', 'output', 1),
            ('irq', 'output', 1)
        ]
    }
}

def write_signal_csvs():
    os.makedirs('docs/interfaces', exist_ok=True)
    os.makedirs('interfaces', exist_ok=True)

    header = ['signal_name', 'direction', 'width']
    for ip, sig_dict in SIGNAL_DEFINITIONS.items():
        # External signals CSV (primary interface)
        ext_sigs = sig_dict['external']
        for target_dir in ['interfaces', 'docs/interfaces']:
            path = f"{target_dir}/{ip}.csv"
            with open(path, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(header)
                writer.writerows(ext_sigs)
            print(f"Generated signals CSV: {path}")

        # Explicit named external signals
        path_ext = f"docs/interfaces/{ip}_external.csv"
        with open(path_ext, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(header)
            writer.writerows(ext_sigs)

        # Full AXI IP signals
        axi_sigs = sig_dict['axi']
        path_axi = f"docs/interfaces/{ip}_axi.csv"
        with open(path_axi, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(header)
            writer.writerows(axi_sigs)
        print(f"Generated AXI IP signals CSV: {path_axi}")

if __name__ == '__main__':
    xlsx_path = 'docs/Updated_Test_Plan.xlsx'
    header, test_cases = parse_test_plan(xlsx_path)
    write_test_plan_csvs(header, test_cases)
    write_signal_csvs()
    print("All CSV files successfully generated!")
