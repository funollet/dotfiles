#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
calculatePast - Timewarrior historical report remaining work hours per week and month, to work with main remaining extension
Author: Miguel Crespo and Lucia Moya-Sans
Usage:
timew calculatePast
"""

import json
import sys
import os

import calendar
import datetime

from collections import defaultdict
from datetime import datetime
from itertools import chain
from typing import DefaultDict, Iterable, TextIO, Tuple

ParsedData = DefaultDict[str, int]
Row = Tuple[str, ...]
Lengths = Tuple[int, ...]

def error_and_exit(error: str) -> None:
    print(error)
    sys.exit(1)

def parse(input_stream: TextIO) -> ParsedData:
    DATEFORMAT = "%Y%m%dT%H%M%SZ"
    header = True
    config = {}
    body = ""
    for line in input_stream:
        if header:
            if line == "\n":
                header = False
                continue
            try:
                key, value = line.strip().split(": ", 1)
                config[key] = value
            except ValueError:
                continue
        else:
            body += line
    if "temp.report.tags" in config:
        error_and_exit("This report only works without tags.")
    
    if not "remaining.hours_per_day" in config:
        error_and_exit(f'Please use "timew config remaining.hours_per_day HOURS" to add to the configuration file the desired quantity')
    HOURS_PER_DAY = config['remaining.hours_per_day']

    if not "remaining.start_date" in config:
        error_and_exit(f'Please use "timew config remaining.start_date YYYY-MM-DD" to add the contract start date to the configuration file')
    START_DATE = config['remaining.start_date']
    START_DATE = datetime.strptime(START_DATE, '%Y-%m-%d')


    totals: ParsedData = defaultdict(lambda: 0)
    tags: ParsedData = defaultdict(lambda: 0)
    tracked = json.loads(body)
    #print(tracked)
    sum_total = 0
    now = datetime.now()

    for session in tracked: #fallo al coger los datos
        start = datetime.strptime(session["start"], DATEFORMAT)
        if "end" in session:
            end = datetime.strptime(session["end"], DATEFORMAT)
        else:
            end = datetime.utcnow()
        
        if not (now.year == start.year and now.month == start.month):
            #2nd if is failing
            if (START_DATE.year==start.year and START_DATE.month<=start.month) or START_DATE.year<=start.year:
                duration = int((end - start).total_seconds()) / 3600 # Translate to hours
                day = start.day
                key = (str(start.year) + "-" +str(start.month) + "-" + str(day))
                totals[key] += duration
                sum_total += duration
                tag_name = session['tags'][0]
                tags[tag_name] += duration
    return totals, tags, sum_total, float(HOURS_PER_DAY),START_DATE, config

def print_data(data, sum_total, HOURS_PER_DAY, START_DATE, config, offset=10):
    if "remaining.verbose" in config:
        if config["remaining.verbose"]=="yes":
            pr = True
        else:
            pr=False
    else:
        pr=False
    DAYS_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    remainingPast = 0
    now = datetime.now()
    if not(now.year == START_DATE.year and now.month == START_DATE.month):
        calendarm = []
        for years in range(START_DATE.year, now.year+1):
            START = 1
            END = 12+1
            if (START_DATE.year == years):
                START = START_DATE.month
            if (now.year == years):
                END = now.month
            
            for months in range(START, END):
                calendarm.append([years,months])

        for cm in range(len(calendarm)):
            days_month = calendar.monthcalendar(calendarm[cm][0], calendarm[cm][1])
            if pr:
                for day in DAYS_WEEK:
                    print(day.center(offset), end='')
                print(f'')
                print('-'*71)
            sum_month = 0
            work_days = 0
            for week in days_month:
                sum_week = 0
                for day in week:
                    if pr:
                        d = '-'
                    if day != 0:
                        key = str(calendarm[cm][0]) + "-" + str(calendarm[cm][1]) + "-" + str(day)
                        if key in data:
                            if pr:
                                d = "{0:.3f}".format(data[key])
                            sum_week += data[key]
                        elif pr:
                            d='0'
                    if pr:
                        print(d.center(offset), end='')
                work_week = sum([1 for i in week[:-2] if i != 0 and not 'exclusions.days.' + str(calendarm[cm][0]) + '_' + "{0:0=2d}".format(calendarm[cm][1]) + '_' + "{0:0=2d}".format(i) in config.keys()])
                total_week = sum_week - HOURS_PER_DAY * work_week
                if pr:
                    print('| {0:0.3f}'.format(total_week))
                sum_month += sum_week
                work_days += work_week
            remaining_month = sum_month - work_days * HOURS_PER_DAY
            if pr:
                print(f'Total {sum_month:0.3f} Remaining {remaining_month:0.3f}')
            remainingPast = remainingPast + remaining_month
    bashCommand = "timew config remaining.past_hours " + str(remainingPast) + " :yes" 
    os.system(bashCommand)
        


if __name__ == "__main__":
    data, tags, sum_total, HOURS_PER_DAY, START_DATE, config = parse(sys.stdin)
    calendar.setfirstweekday(calendar.MONDAY)
    print_data(data, sum_total, HOURS_PER_DAY, START_DATE, config)
