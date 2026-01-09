#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Remaining - Timewarrior report remaining work hours per week and month
Author: Miguel Crespo and Lucia Moya-Sans
Usage:
timew remaining
"""

import json
import sys

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

    totals: ParsedData = defaultdict(lambda: 0)
    tags: ParsedData = defaultdict(lambda: 0)
    tracked = json.loads(body)
    sum_total = 0
    now = datetime.now()

    for session in tracked:
        start = datetime.strptime(session["start"], DATEFORMAT)
        if "end" in session:
            end = datetime.strptime(session["end"], DATEFORMAT)
        else:
            end = datetime.utcnow()
        
        if now.year == start.year and now.month == start.month:
            duration = int((end - start).total_seconds()) / 3600 # Translate to hours
            day = start.day
            totals[day] += duration
            sum_total += duration
            tag_name = session['tags'][0]
            tags[tag_name] += duration
    return totals, tags, sum_total, float(HOURS_PER_DAY), config

def print_data(data, sum_total, HOURS_PER_DAY, config, offset=10):
    DAYS_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    now = datetime.now()
    days_month = calendar.monthcalendar(now.year, now.month)

    # work_days = calendar.monthrange(now.year, now.month)[1]
    for day in DAYS_WEEK:
        print(day.center(offset), end='')
    print(f'')
    print('-'*71)

    sum_month = 0
    work_days = 0
    for week in days_month:
        sum_week = 0
        for day in week:
            d = '-'
            if day != 0:
                if day in data:
                    d = "{0:.3f}".format(data[day])
                    sum_week += data[day]
                else:
                    d = '0'
            print(d.center(offset), end='')
        work_week = sum([1 for i in week[:-2] if i != 0 and not 'exclusions.days.' + str(now.year) + '_' + "{0:0=2d}".format(now.month) + '_' + "{0:0=2d}".format(i) in config.keys()])
        total_week = sum_week - HOURS_PER_DAY * work_week
        print('| {0:0.3f}'.format(total_week))
        sum_month += sum_week
        work_days += work_week
    remaining_month = sum_month - work_days * HOURS_PER_DAY
    if not 'remaining.past_hours' in config:
        print(f'Total {sum_month:0.3f} Remaining {remaining_month:0.3f}')
    else: #Esta parte no está funcionando
        remaining_past = float(config['remaining.past_hours'])
        remaining = remaining_month + remaining_past
        if remaining!=remaining_month:
            print(f'Total {sum_month:0.3f} Remaining this month {remaining_month:0.3f} Remaining past months {remaining_past:0.3f} Total remaining {remaining:0.3f}')
        else:
            print(f'Total {sum_month:0.3f} Remaining {remaining_month:0.3f}')

if __name__ == "__main__":
    data, tags, sum_total, HOURS_PER_DAY, config = parse(sys.stdin)
    calendar.setfirstweekday(calendar.MONDAY)
    print_data(data, sum_total, HOURS_PER_DAY, config)
