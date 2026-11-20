#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_complete_pdf.py
Main driver script to assemble and compile:
'reports/Honours_Project_Report_Veeramalla_Akshay.pdf'
"""

import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT

# Add reports directory to sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from build_pdf import HonoursReportCanvas
from sections_frontmatter import get_frontmatter_flowables
from sections_ch1_to_ch3 import get_ch1_to_ch3_flowables
from sections_ch4_to_ch6 import get_ch4_to_ch6_flowables
from sections_ch7_to_ch9 import get_ch7_to_ch9_flowables

def setup_styles():
    styles = getSampleStyleSheet()

    # Cover Page Styles
    styles.add(ParagraphStyle('CoverHeader', parent=styles['Normal'], fontName='Times-Bold', fontSize=13, leading=16, alignment=TA_CENTER, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('CoverSubHeader', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=14, alignment=TA_CENTER, textColor=colors.HexColor("#333333")))
    styles.add(ParagraphStyle('CoverTitle', parent=styles['Normal'], fontName='Times-Bold', fontSize=16, leading=21, alignment=TA_CENTER, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('CoverNormalItalic', parent=styles['Normal'], fontName='Times-Italic', fontSize=9.5, leading=13, alignment=TA_CENTER, textColor=colors.HexColor("#444444")))
    styles.add(ParagraphStyle('CoverDegree', parent=styles['Normal'], fontName='Times-Bold', fontSize=12, leading=15, alignment=TA_CENTER, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('CoverSubDegree', parent=styles['Normal'], fontName='Times-Bold', fontSize=9.5, leading=13, alignment=TA_CENTER, textColor=colors.HexColor("#222222")))
    styles.add(ParagraphStyle('CoverNormal', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=14, alignment=TA_CENTER, textColor=colors.HexColor("#333333")))
    styles.add(ParagraphStyle('CoverAuthor', parent=styles['Normal'], fontName='Times-Bold', fontSize=13, leading=16, alignment=TA_CENTER, textColor=colors.HexColor("#000000")))
    styles.add(ParagraphStyle('CoverRollNo', parent=styles['Normal'], fontName='Times-Bold', fontSize=11, leading=14, alignment=TA_CENTER, textColor=colors.HexColor("#222222")))
    styles.add(ParagraphStyle('CoverDept', parent=styles['Normal'], fontName='Times-Bold', fontSize=10, leading=13, alignment=TA_CENTER, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('CoverCollege', parent=styles['Normal'], fontName='Times-Bold', fontSize=11.5, leading=15, alignment=TA_CENTER, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('CoverAddress', parent=styles['Normal'], fontName='Times-Roman', fontSize=9, leading=12, alignment=TA_CENTER, textColor=colors.HexColor("#444444")))
    styles.add(ParagraphStyle('CoverYear', parent=styles['Normal'], fontName='Times-Bold', fontSize=10.5, leading=14, alignment=TA_CENTER, textColor=colors.HexColor("#222222")))

    # Certificate Styles
    styles.add(ParagraphStyle('CertTitle', parent=styles['Normal'], fontName='Times-Bold', fontSize=17, leading=21, alignment=TA_CENTER, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('CertCollege', parent=styles['Normal'], fontName='Times-Bold', fontSize=12, leading=15, alignment=TA_CENTER, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('CertDept', parent=styles['Normal'], fontName='Times-Bold', fontSize=10.5, leading=13, alignment=TA_CENTER, textColor=colors.HexColor("#222222")))
    styles.add(ParagraphStyle('CertAccred', parent=styles['Normal'], fontName='Times-Italic', fontSize=9, leading=12, alignment=TA_CENTER, textColor=colors.HexColor("#555555")))
    styles.add(ParagraphStyle('CertAddress', parent=styles['Normal'], fontName='Times-Roman', fontSize=9, leading=12, alignment=TA_CENTER, textColor=colors.HexColor("#555555")))
    styles.add(ParagraphStyle('SigLeft', parent=styles['Normal'], fontName='Times-Roman', fontSize=9, leading=12, alignment=TA_LEFT, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('SigRight', parent=styles['Normal'], fontName='Times-Roman', fontSize=9, leading=12, alignment=TA_RIGHT, textColor=colors.HexColor("#111111")))

    # Headings
    styles.add(ParagraphStyle('ChapNumber', parent=styles['Normal'], fontName='Times-Bold', fontSize=13, leading=16, alignment=TA_LEFT, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('ChapTitle', parent=styles['Normal'], fontName='Times-Bold', fontSize=16, leading=20, alignment=TA_LEFT, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('SecHeading', parent=styles['Normal'], fontName='Times-Bold', fontSize=11.5, leading=15, alignment=TA_LEFT, textColor=colors.HexColor("#111111"), keepWithNext=True))
    styles.add(ParagraphStyle('SubSecHeading', parent=styles['Normal'], fontName='Times-Bold', fontSize=10, leading=13, alignment=TA_LEFT, textColor=colors.HexColor("#222222"), keepWithNext=True))
    styles.add(ParagraphStyle('TocMainTitle', parent=styles['Normal'], fontName='Times-Bold', fontSize=18, leading=22, alignment=TA_LEFT, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('TocEntryBold', parent=styles['Normal'], fontName='Times-Bold', fontSize=9.5, leading=13, alignment=TA_LEFT))
    styles.add(ParagraphStyle('TocEntry', parent=styles['Normal'], fontName='Times-Roman', fontSize=8.8, leading=12, alignment=TA_LEFT))
    styles.add(ParagraphStyle('TocPage', parent=styles['Normal'], fontName='Times-Roman', fontSize=8.8, leading=12, alignment=TA_RIGHT))

    # Body & Tables
    styles.add(ParagraphStyle('BodyJustify', parent=styles['Normal'], fontName='Times-Roman', fontSize=9.5, leading=13.5, alignment=TA_JUSTIFY, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('TableHdr', parent=styles['Normal'], fontName='Times-Bold', fontSize=7.5, leading=9.5, alignment=TA_CENTER, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('TableBody', parent=styles['Normal'], fontName='Times-Roman', fontSize=7.2, leading=9, alignment=TA_LEFT, textColor=colors.HexColor("#222222")))
    styles.add(ParagraphStyle('TableBodyBold', parent=styles['Normal'], fontName='Times-Bold', fontSize=7.2, leading=9, alignment=TA_LEFT, textColor=colors.HexColor("#111111")))
    styles.add(ParagraphStyle('TableBodyPass', parent=styles['Normal'], fontName='Times-Bold', fontSize=7.2, leading=9, alignment=TA_LEFT, textColor=colors.HexColor("#0d652d")))
    styles.add(ParagraphStyle('TableCaption', parent=styles['Normal'], fontName='Times-Roman', fontSize=8.5, leading=11, alignment=TA_LEFT, textColor=colors.HexColor("#222222"), keepWithNext=True))
    styles.add(ParagraphStyle('FigureCaption', parent=styles['Normal'], fontName='Times-Italic', fontSize=8.5, leading=11, alignment=TA_CENTER, textColor=colors.HexColor("#222222"), keepWithNext=True))

    # Callouts & Code
    styles.add(ParagraphStyle('CalloutTitle', parent=styles['Normal'], fontName='Times-Bold', fontSize=9.5, leading=12, alignment=TA_LEFT, textColor=colors.HexColor("#0d47a1")))
    styles.add(ParagraphStyle('CalloutBody', parent=styles['Normal'], fontName='Times-Roman', fontSize=8.5, leading=11.5, alignment=TA_JUSTIFY, textColor=colors.HexColor("#222222")))
    styles.add(ParagraphStyle('CodeTitle', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=8, leading=10, alignment=TA_LEFT, textColor=colors.HexColor("#333333")))
    styles.add(ParagraphStyle('CodeBody', parent=styles['Normal'], fontName='Courier', fontSize=6.8, leading=8.5, alignment=TA_LEFT, textColor=colors.HexColor("#111111")))

    return styles

def build_pdf():
    out_pdf_path = os.path.join("reports", "Honours_Project_Report_Veeramalla_Akshay.pdf")
    doc = SimpleDocTemplate(
        out_pdf_path,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = setup_styles()

    story = []
    print("Generating Front Matter...")
    story.extend(get_frontmatter_flowables(styles))

    print("Generating Chapters 1 to 3...")
    story.extend(get_ch1_to_ch3_flowables(styles))

    print("Generating Chapters 4 to 6...")
    story.extend(get_ch4_to_ch6_flowables(styles))

    print("Generating Chapters 7 to 9 & References...")
    story.extend(get_ch7_to_ch9_flowables(styles))

    print(f"Building PDF with {len(story)} flowable elements...")
    doc.build(story, canvasmaker=HonoursReportCanvas)
    print(f"SUCCESS: Generated {out_pdf_path}")
    print(f"File size: {os.path.getsize(out_pdf_path):,} bytes")

if __name__ == "__main__":
    build_pdf()
