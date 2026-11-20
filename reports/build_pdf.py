#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_pdf.py
Compiles the comprehensive, publication-quality Honours Project Technical Report:
'RISC-V VeeR EL2 BASED SENSOR MONITORING AND SIGNAL PROCESSING SoC'
Submitted by: Veeramalla Akshay (Roll No: 1602-23-735-130)
Department of Electronics and Communication Engineering
Vasavi College of Engineering (Autonomous), Hyderabad
"""

import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, HRFlowable, KeepTogether
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.pdfgen import canvas

# ----------------------------------------------------------------------
# 1. Custom NumberedCanvas for Running Headers, Footers, and Roman/Arabic
# ----------------------------------------------------------------------
class HonoursReportCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def to_roman(self, n):
        val = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        syb = ["m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i"]
        roman_num = ""
        i = 0
        while n > 0:
            for _ in range(n // val[i]):
                roman_num += syb[i]
                n -= val[i]
            i += 1
        return roman_num

    def draw_page_decorations(self, total_pages):
        page_num = self._pageNumber

        # Page 1: Cover page -> no header, no footer
        if page_num == 1:
            return

        self.saveState()
        self.setFont("Times-Italic", 9)
        self.setFillColor(colors.HexColor("#222222"))

        # Front matter pages (Certificate to List of Tables): pages 2 to 10
        front_matter_limit = 10

        if page_num <= front_matter_limit:
            num_str = self.to_roman(page_num)
            self.drawCentredString(letter[0] / 2.0, 36, num_str)
        else:
            arabic_num = str(page_num - front_matter_limit)
            header_y = letter[1] - 42
            self.drawString(54, header_y, "RISC-V VeeR EL2 Based Sensor Monitoring and Signal Processing SoC")
            self.drawRightString(letter[0] - 54, header_y, "Honours CBP Report")
            
            self.setStrokeColor(colors.HexColor("#777777"))
            self.setLineWidth(0.6)
            self.line(54, header_y - 4, letter[0] - 54, header_y - 4)

            self.setFont("Times-Roman", 10)
            self.drawCentredString(letter[0] / 2.0, 36, arabic_num)

        self.restoreState()

print("Canvas class configured.")
