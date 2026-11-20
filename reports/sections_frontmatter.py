# -*- coding: utf-8 -*-
"""
sections_frontmatter.py
Generates the front matter flowables:
1. Title Cover Page
2. Certificate
3. Declaration
4. Acknowledgements
5. Abstract
6. Table of Contents
7. List of Figures
8. List of Tables
"""

import os
from reportlab.platypus import Paragraph, Spacer, Table, TableStyle, PageBreak, Image, HRFlowable, KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT

def get_frontmatter_flowables(styles):
    story = []

    # -------------------------------------------------------------
    # 1. Title Cover Page
    # -------------------------------------------------------------
    story.append(Spacer(1, 20))
    story.append(Paragraph("<b>HONOURS COURSE BASED PROJECT</b>", styles['CoverHeader']))
    story.append(Spacer(1, 10))
    story.append(Paragraph("TECHNICAL REPORT ON", styles['CoverSubHeader']))
    story.append(Spacer(1, 25))
    
    story.append(Paragraph("<b>RISC-V VeeR EL2 BASED SENSOR MONITORING AND SIGNAL PROCESSING SoC</b>", styles['CoverTitle']))
    story.append(Spacer(1, 25))
    
    story.append(Paragraph("<i>A Course Based Project Report Submitted in Partial Fulfillment of the Requirements for the Award of the Honours Degree in</i>", styles['CoverNormalItalic']))
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>SYSTEM ON CHIP DESIGN</b>", styles['CoverDegree']))
    story.append(Spacer(1, 6))
    story.append(Paragraph("<b>BACHELOR OF ENGINEERING IN ELECTRONICS AND COMMUNICATION ENGINEERING</b>", styles['CoverSubDegree']))
    story.append(Spacer(1, 30))
    
    story.append(Paragraph("Submitted by:", styles['CoverNormal']))
    story.append(Spacer(1, 6))
    story.append(Paragraph("<b>Veeramalla Akshay</b>", styles['CoverAuthor']))
    story.append(Paragraph("<b>Roll No: 1602-23-735-130</b>", styles['CoverRollNo']))
    story.append(Spacer(1, 35))
    
    # College Emblem
    logo_path = os.path.join("reports", "figures", "vce_logo.png")
    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=1.3*72, height=1.3*72))
    else:
        story.append(Spacer(1, 1.3*72))
    story.append(Spacer(1, 25))
    
    story.append(Paragraph("<b>DEPARTMENT OF ELECTRONICS AND COMMUNICATION ENGINEERING</b>", styles['CoverDept']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>VASAVI COLLEGE OF ENGINEERING (AUTONOMOUS)</b>", styles['CoverCollege']))
    story.append(Spacer(1, 4))
    story.append(Paragraph("Ibrahimbagh, Hyderabad – 500031, Telangana, India", styles['CoverAddress']))
    story.append(Spacer(1, 6))
    story.append(Paragraph("<b>ACADEMIC YEAR 2026 – 2027</b>", styles['CoverYear']))
    
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 2. Certificate Page (Page ii)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>CERTIFICATE</b>", styles['CertTitle']))
    story.append(Spacer(1, 15))
    
    story.append(Paragraph("<b>VASAVI COLLEGE OF ENGINEERING (AUTONOMOUS)</b>", styles['CertCollege']))
    story.append(Paragraph("<b>DEPARTMENT OF ELECTRONICS AND COMMUNICATION ENGINEERING</b>", styles['CertDept']))
    story.append(Paragraph("(Accredited by NAAC with ‘A++’ Grade, Affiliated to Osmania University)", styles['CertAccred']))
    story.append(Paragraph("Ibrahimbagh, Hyderabad – 500031", styles['CertAddress']))
    story.append(Spacer(1, 15))
    
    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=1.1*72, height=1.1*72))
    story.append(Spacer(1, 25))
    
    cert_text = (
        "This is to certify that the project report entitled <b>“RISC-V VeeR EL2 BASED SENSOR "
        "MONITORING AND SIGNAL PROCESSING SoC”</b>, submitted by <b>Veeramalla Akshay "
        "(Roll No: 1602-23-735-130)</b>, a student of the Department of Electronics and Communication "
        "Engineering, Vasavi College of Engineering (Autonomous), in partial fulfillment of the requirements "
        "for the award of the Honours Degree in <b>System on Chip Design</b> in Electronics and "
        "Communication Engineering, is a record of the bonafide work carried out by him during the academic "
        "year 2026–2027 under the supervision of <b>Dr. M. Praveen Kumar</b>.<br/><br/>"
        "The results embodied in this project report have not been submitted to any other University or "
        "Institute for the award of any degree."
    )
    story.append(Paragraph(cert_text, styles['BodyJustify']))
    story.append(Spacer(1, 60))
    
    sig_data = [
        [
            Paragraph("<b>Supervisor</b><br/><b>Dr. M. Praveen Kumar</b><br/>Assistant Professor<br/>Department of ECE<br/>Vasavi College of Engineering", styles['SigLeft']),
            Paragraph("<b>Head of the Department</b><br/><b>Dr. E. Sreenivasa Rao</b><br/>Professor and Head<br/>Department of ECE<br/>Vasavi College of Engineering", styles['SigRight'])
        ],
        [
            Spacer(1, 40),
            Spacer(1, 40)
        ],
        [
            Paragraph("<b>Signature of the External Examiner</b>", styles['SigLeft']),
            Paragraph("<b>Date: 21st November, 2026</b>", styles['SigRight'])
        ]
    ]
    sig_table = Table(sig_data, colWidths=[240, 240])
    sig_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(sig_table)
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 3. Declaration Page (Page iii)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>DECLARATION</b>", styles['CertTitle']))
    story.append(Spacer(1, 25))
    
    decl_text1 = (
        "I, the undersigned, hereby declare that the project report titled <b>“RISC-V VeeR EL2 Based "
        "Sensor Monitoring and Signal Processing SoC”</b>, submitted in partial fulfillment of the "
        "requirements for the award of the Honours Degree in System on Chip Design at Vasavi College of "
        "Engineering (Autonomous), Ibrahimbagh, Hyderabad, is a bonafide work carried out by me under the "
        "supervision of <b>Dr. M. Praveen Kumar</b>."
    )
    decl_text2 = (
        "I declare that this submission represents my own ideas and work, and wherever the ideas or words "
        "of others have been included, I have adequately and accurately cited and referenced the sources. "
        "I further declare that I have adhered to the principles of academic honesty and integrity and have "
        "not misrepresented or fabricated any data, ideas, facts, or sources in this submission."
    )
    decl_text3 = (
        "I understand that any violation of the above declaration may result in disciplinary action by the "
        "institute and/or the University and may also invite penal action from the sources whose work has not "
        "been properly cited or for which permission has not been obtained."
    )
    decl_text4 = (
        "I also declare that this report has not previously formed the basis for the award of any degree, "
        "diploma, or similar title from any other University or institution."
    )
    
    story.append(Paragraph(decl_text1, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(decl_text2, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(decl_text3, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(decl_text4, styles['BodyJustify']))
    story.append(Spacer(1, 60))
    
    decl_sig_data = [
        [
            Paragraph("<b>Place:</b> Hyderabad, Telangana<br/><br/><b>Date:</b> 21st November, 2026", styles['SigLeft']),
            Paragraph("<b>Signature of Student:</b><br/><br/><b>Veeramalla Akshay</b><br/>Roll No: 1602-23-735-130<br/>Department of ECE, VCE", styles['SigRight'])
        ]
    ]
    decl_sig_table = Table(decl_sig_data, colWidths=[240, 240])
    decl_sig_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(decl_sig_table)
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 4. Acknowledgements Page (Page iv)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>ACKNOWLEDGEMENTS</b>", styles['CertTitle']))
    story.append(Spacer(1, 20))
    
    ack_text1 = (
        "The satisfaction and academic fulfillment that accompany the successful completion of any "
        "engineering project would be incomplete without expressing sincere gratitude to the individuals "
        "whose guidance, mentorship, and infrastructure support made this work possible."
    )
    ack_text2 = (
        "I express my profound gratitude to my project supervisor, <b>Dr. M. Praveen Kumar</b>, Assistant "
        "Professor, Department of Electronics and Communication Engineering, Vasavi College of Engineering "
        "(Autonomous), for his continuous technical direction, architectural reviews, and mentorship "
        "throughout the RTL integration, bare-metal firmware bring-up, and UVM verification phases of this "
        "System-on-Chip project."
    )
    ack_text3 = (
        "I extend my sincere thanks to <b>Dr. E. Sreenivasa Rao</b>, Professor and Head of the Department "
        "of Electronics and Communication Engineering, for providing access to industry-standard Synopsys "
        "VCS and Verdi EDA computing facilities and fostering a strong research environment in VLSI and SoC design."
    )
    ack_text4 = (
        "Finally, I thank the Principal and management of Vasavi College of Engineering, my peers in the ECE "
        "department, and my family for their constant encouragement and moral support."
    )
    
    story.append(Paragraph(ack_text1, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(ack_text2, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(ack_text3, styles['BodyJustify']))
    story.append(Spacer(1, 14))
    story.append(Paragraph(ack_text4, styles['BodyJustify']))
    story.append(Spacer(1, 60))
    
    ack_sig_data = [
        [
            Paragraph("", styles['SigLeft']),
            Paragraph("<b>Veeramalla Akshay</b><br/>Roll No: 1602-23-735-130<br/>Department of ECE, Vasavi College of Engineering", styles['SigRight'])
        ]
    ]
    ack_sig_table = Table(ack_sig_data, colWidths=[240, 240])
    ack_sig_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(ack_sig_table)
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 5. Abstract Page (Page v)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>ABSTRACT</b>", styles['CertTitle']))
    story.append(Spacer(1, 20))
    
    from report_sections import ABSTRACT_TEXT
    for para in ABSTRACT_TEXT.split("\n\n"):
        story.append(Paragraph(para, styles['BodyJustify']))
        story.append(Spacer(1, 12))
        
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 6. Contents (Pages vi, vii, viii)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>Contents</b>", styles['TocMainTitle']))
    story.append(Spacer(1, 15))
    
    toc_data_p1 = [
        [Paragraph("<b>Certificate</b>", styles['TocEntryBold']), Paragraph("<b>ii</b>", styles['TocPage'])],
        [Paragraph("<b>Declaration</b>", styles['TocEntryBold']), Paragraph("<b>iii</b>", styles['TocPage'])],
        [Paragraph("<b>Acknowledgements</b>", styles['TocEntryBold']), Paragraph("<b>iv</b>", styles['TocPage'])],
        [Paragraph("<b>Abstract</b>", styles['TocEntryBold']), Paragraph("<b>v</b>", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>1  Project Proposal</b>", styles['TocEntryBold']), Paragraph("<b>1</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.1  Project Title and Classification", styles['TocEntry']), Paragraph("1", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.2  Industrial Context & Background: Cyber-Physical Systems", styles['TocEntry']), Paragraph("1", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.3  Problem Statement", styles['TocEntry']), Paragraph("1", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.4  Proposed Solution & Architectural Innovation", styles['TocEntry']), Paragraph("2", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.5  Project Objectives & Deliverables", styles['TocEntry']), Paragraph("2", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.6  Project Milestones & Work Breakdown", styles['TocEntry']), Paragraph("2", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>2  Architecture Specification</b>", styles['TocEntryBold']), Paragraph("<b>4</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.1  System Architecture Overview", styles['TocEntry']), Paragraph("4", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.2  Top-Level SoC Block Diagram & Bus Topology", styles['TocEntry']), Paragraph("4", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.3  Complete IP Inventory & Detailed Block Specifications", styles['TocEntry']), Paragraph("4", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.3.1  RISC-V Processor Core — VeeR EL2", styles['TocEntry']), Paragraph("5", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.3.2  64-to-32 Bit AXI4-to-AXI4-Lite LSU Bridge (axi4_to_axi4lite)", styles['TocEntry']), Paragraph("5", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.3.3  Hardware 16-Tap FIR Filter Accelerator (fir_filter.sv)", styles['TocEntry']), Paragraph("5", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.4  Interfacing Signals & Pinout Specification", styles['TocEntry']), Paragraph("5", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.5  Control Path Specification", styles['TocEntry']), Paragraph("6", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.6  Data Path Specification: The Closed-Loop Pipeline", styles['TocEntry']), Paragraph("6", styles['TocPage'])],
    ]
    t_toc1 = Table(toc_data_p1, colWidths=[430, 50])
    t_toc1.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
    ]))
    story.append(t_toc1)
    story.append(PageBreak())

    # TOC Page 2 (Page vii)
    toc_data_p2 = [
        [Paragraph("<b>3  GitHub Account Steps</b>", styles['TocEntryBold']), Paragraph("<b>8</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;3.1  Version Control in Safety-Critical EDA Projects", styles['TocEntry']), Paragraph("8", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;3.2  GitHub Account Creation & Secure Authentication Setup", styles['TocEntry']), Paragraph("8", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;3.3  Repository Initialization and Remote Configuration", styles['TocEntry']), Paragraph("8", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;3.4  EDA-Specific .gitignore Configuration", styles['TocEntry']), Paragraph("8", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;3.5  Day-to-Day Development & Collaboration Workflow", styles['TocEntry']), Paragraph("9", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>4  RISC-V Toolchain Setup Steps</b>", styles['TocEntryBold']), Paragraph("<b>10</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.1  Overview of the RISC-V GNU Compiler Toolchain", styles['TocEntry']), Paragraph("10", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.2  Host System Prerequisites & Dependency Installation", styles['TocEntry']), Paragraph("10", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.3  Sourcing & Cloning the Toolchain Repository", styles['TocEntry']), Paragraph("10", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.4  Toolchain Configuration for VeeR EL2 (RV32IMC / ILP32)", styles['TocEntry']), Paragraph("10", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.5  Compilation, Installation & Environment Configuration", styles['TocEntry']), Paragraph("10", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;4.6  Bare-Metal Firmware Build Flow & Toolchain Flags", styles['TocEntry']), Paragraph("11", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>5  Address Map</b>", styles['TocEntryBold']), Paragraph("<b>12</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;5.1  System-Wide Memory Map Overview", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;5.2  Master Memory Aperture Summary Table", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;5.3  Detailed Peripheral Register Maps", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.1  UART Register Map (Base: 0x8000_0000)", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.2  RISC-V Machine Timer Register Map (Base: 0x8000_1000)", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.3  GPIO Subsystem Register Map (Base: 0x8000_2000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.4  I2C Controller Register Map (Base: 0x8000_3000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.5  FIR Filter Accelerator Register Map (Base: 0x8000_4000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3.6  PWM Generator Register Map (Base: 0x8000_5000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>6  Testplan with External / Internal Test Column</b>", styles['TocEntryBold']), Paragraph("<b>14</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;6.1  Verification Methodology & Testplan Architecture", styles['TocEntry']), Paragraph("14", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;6.2  Complete SoC Verification Matrix (24 Test Cases)", styles['TocEntry']), Paragraph("14", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>7  All VIPs CSV Files and Interface Files</b>", styles['TocEntryBold']), Paragraph("<b>16</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.1  UVM Verification IP (VIP) Signal Boundary Architecture", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.2  VIP Automated Generation Tool (uvm_full_tb_generator.py)", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.3  FIR Filter VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.4  GPIO VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.5  I2C VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.6  PWM VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.7  System Timer VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
    ]
    t_toc2 = Table(toc_data_p2, colWidths=[430, 50])
    t_toc2.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
    ]))
    story.append(t_toc2)
    story.append(PageBreak())

    # TOC Page 3 (Page viii)
    toc_data_p3 = [
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.8  UART VIP — CSV Definition & Interface File", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;7.9  VIP Compilation Filelist (filelist.f / soc_vip_interfaces.sv)", styles['TocEntry']), Paragraph("18", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>8  UVM Testbench Block Diagram along with All UVM VIPs</b>", styles['TocEntryBold']), Paragraph("<b>19</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;8.1  UVM 1.2 Verification Architecture Overview", styles['TocEntry']), Paragraph("19", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;8.2  Detailed Breakdown of UVM Components", styles['TocEntry']), Paragraph("19", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;8.3  Virtual Sequences & Multi-Agent Coordination (soc_virtual_sequence)", styles['TocEntry']), Paragraph("20", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;8.4  Multi-VIP Simulation Execution (Makefile.vcs / run_vcs.sh)", styles['TocEntry']), Paragraph("20", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>9  C Test Case, UVM Test Case with Wave Snippet</b>", styles['TocEntryBold']), Paragraph("<b>21</b>", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;9.1  Bare-Metal C Verification Test Cases (Internal Core Tests)", styles['TocEntry']), Paragraph("21", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.1.1  Full Closed-Loop Application Firmware (main.c)", styles['TocEntry']), Paragraph("21", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.1.2  Hardware FIR Driver & Coeff Initialization (fir.c)", styles['TocEntry']), Paragraph("21", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;9.2  UVM Test Cases (External Testbench Verification)", styles['TocEntry']), Paragraph("21", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;9.3  Waveform Snippets & Cycle-by-Cycle Analysis", styles['TocEntry']), Paragraph("21", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.3.1  Wave Snippet 1: UART AXI-Lite Access & Serial Loopback", styles['TocEntry']), Paragraph("22", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.3.2  Wave Snippet 2: 64-to-32 Bit LSU AXI Bridge & Interconnect", styles['TocEntry']), Paragraph("22", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.3.3  Wave Snippet 3: Closed-Loop Sensor Telemetry Pipeline", styles['TocEntry']), Paragraph("23", styles['TocPage'])],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;9.4  Verification Debugging Log & Root Cause Analysis", styles['TocEntry']), Paragraph("23", styles['TocPage'])],
        [Spacer(1, 8), Spacer(1, 8)],
        [Paragraph("<b>References & Technical Standards</b>", styles['TocEntryBold']), Paragraph("<b>25</b>", styles['TocPage'])],
    ]
    t_toc3 = Table(toc_data_p3, colWidths=[430, 50])
    t_toc3.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
    ]))
    story.append(t_toc3)
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 7. List of Figures (Page ix)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>List of Figures</b>", styles['TocMainTitle']))
    story.append(Spacer(1, 20))
    
    lof_data = [
        [Paragraph("2.1  Top-Level SoC Block Diagram & Bus Topology Architecture", styles['TocEntry']), Paragraph("4", styles['TocPage'])],
        [Paragraph("8.1  Top-Level UVM 1.2 Verification Environment with Six Custom Verification IPs", styles['TocEntry']), Paragraph("19", styles['TocPage'])],
        [Paragraph("9.1  Verdi Waveform: AXI-Lite Write/Read Transactions, Serial TX/RX Framing, and Interrupt Assertion", styles['TocEntry']), Paragraph("22", styles['TocPage'])],
        [Paragraph("9.2  Verdi Waveform: 64-to-32 Bit Width Conversion, AXI Crossbar Handshaking, and Firmware Execution", styles['TocEntry']), Paragraph("22", styles['TocPage'])],
        [Paragraph("9.3  Verdi Waveform: Closed-Loop Telemetry Pipeline (I2C Ingest → FIR Filter → PWM Actuation)", styles['TocEntry']), Paragraph("23", styles['TocPage'])],
    ]
    t_lof = Table(lof_data, colWidths=[430, 50])
    t_lof.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('TOPPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_lof)
    story.append(PageBreak())

    # -------------------------------------------------------------
    # 8. List of Tables (Page x)
    # -------------------------------------------------------------
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>List of Tables</b>", styles['TocMainTitle']))
    story.append(Spacer(1, 20))
    
    lot_data = [
        [Paragraph("1.1  Project Milestones and Work Breakdown Schedule", styles['TocEntry']), Paragraph("2", styles['TocPage'])],
        [Paragraph("2.1  Complete IP Inventory and Functional Specifications", styles['TocEntry']), Paragraph("4", styles['TocPage'])],
        [Paragraph("2.2  AMBA AXI4-Lite Bus Interface Signal Definitions", styles['TocEntry']), Paragraph("5", styles['TocPage'])],
        [Paragraph("2.3  Top-Level SoC Physical Pinout and External Interrupt Signals", styles['TocEntry']), Paragraph("6", styles['TocPage'])],
        [Paragraph("5.1  Master System Memory Map and Peripheral Address Apertures", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("5.2  UART Controller Register Map (Base Address 0x8000_0000)", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("5.3  RISC-V Machine Timer Register Map (Base Address 0x8000_1000)", styles['TocEntry']), Paragraph("12", styles['TocPage'])],
        [Paragraph("5.4  GPIO Subsystem Register Map (Base Address 0x8000_2000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("5.5  I2C Controller Register Map (Base Address 0x8000_3000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("5.6  FIR Filter Accelerator Register Map (Base Address 0x8000_4000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("5.7  PWM Generator Register Map (Base Address 0x8000_5000)", styles['TocEntry']), Paragraph("13", styles['TocPage'])],
        [Paragraph("6.1  Comprehensive 24-Test SoC Verification Matrix (Internal C vs. External SV/UVM)", styles['TocEntry']), Paragraph("14", styles['TocPage'])],
        [Paragraph("7.1  FIR Filter VIP Signal Definitions (fir_signals.csv)", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("7.2  GPIO VIP Signal Definitions (gpio_signals.csv)", styles['TocEntry']), Paragraph("16", styles['TocPage'])],
        [Paragraph("7.3  I2C VIP Signal Definitions (i2c_signals.csv)", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("7.4  PWM VIP Signal Definitions (pwm_signals.csv)", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("7.5  System Timer VIP Signal Definitions (timer_signals.csv)", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("7.6  UART VIP Signal Definitions (uart_signals.csv)", styles['TocEntry']), Paragraph("17", styles['TocPage'])],
        [Paragraph("9.1  Verification Debugging Log and Root Cause Resolutions", styles['TocEntry']), Paragraph("23", styles['TocPage'])],
    ]
    t_lot = Table(lot_data, colWidths=[430, 50])
    t_lot.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('TOPPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_lot)
    story.append(PageBreak())

    return story
