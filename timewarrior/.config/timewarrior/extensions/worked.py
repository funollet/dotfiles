#!/usr/bin/env python3
# worked.py
#   timewarrior extension to track working schedule hours
#   https://gist.github.com/edubxb/d3e5a1ebeff8ecc128d5616f4f6de62b

import dataclasses
import datetime
import json
import sys

TZ_OFFSET = datetime.timedelta(hours=2)
INTERVAL_DATE_FORMAT = "%Y%m%dT%H%M%SZ"
EXCLUSION_DATE_FORMAT = "%Y_%m_%d"
FIRST_WEEK_DAY = 0  # Monday
WORKING_HOURS = [7.5, 7.5, 7.5, 7.5, 7.5, 0, 0]
ALT_WORKING_HOURS = [7.0, 7.0, 7.0, 7.0, 7.0, 0, 0]
ALT_WORKING_HOURS_DATES = (
    (
        datetime.datetime.strptime("2022-07-01", "%Y-%m-%d").date(),
        datetime.datetime.strptime("2022-08-30", "%Y-%m-%d").date(),
    ),
)
# ALT_WORKING_HOURS_DATES = (
#     (
#         datetime.datetime.strptime("2021-03-29", "%Y-%m-%d").date(),
#         datetime.datetime.strptime("2021-04-01", "%Y-%m-%d").date(),
#     ),
#     (
#         datetime.datetime.strptime("2021-07-01", "%Y-%m-%d").date(),
#         datetime.datetime.strptime("2021-08-19", "%Y-%m-%d").date(),
#     ),
# )


@dataclasses.dataclass
class TimeWarriorData:
    config: dict[str, str]
    holidays: list
    exclusions: list
    intervals: list[dict[str, datetime.datetime]]


def read_json():
    config: dict[str, str] = {}
    holidays: list = []
    exclusions: list = []
    intervals: list[tuple(datetime.datetime, datetime.datetime)] = []

    data = sys.stdin.read().splitlines()
    for line_number, line in enumerate(data):
        if line != "":
            if line.startswith("holidays."):
                holidays.append(
                    datetime.datetime.strptime(
                        line.split(".")[2].split(":")[0],
                        EXCLUSION_DATE_FORMAT
                    ).date()
                )
            elif line.startswith("exclusions.days."):
                exclusions.append(
                    datetime.datetime.strptime(
                        line.split(".")[2].split(":")[0],
                        EXCLUSION_DATE_FORMAT
                    ).date()
                )
            else:
                config_entry = line.split(":")
                config[config_entry[0]] = config_entry[1].strip(" ")
        else:
            break

    for interval in json.loads("".join(data[line_number:])):
        start = datetime.datetime.strptime(interval["start"], INTERVAL_DATE_FORMAT)
        if "end" in interval:
            end = datetime.datetime.strptime(interval["end"], INTERVAL_DATE_FORMAT)
        else:
            end = datetime.datetime.utcnow()

        intervals.append((start + TZ_OFFSET, end + TZ_OFFSET))

    return TimeWarriorData(config, holidays, exclusions, intervals)


def print_entry(week, week_worked, week_expected, alt_week, has_holidays):
    if round(week_worked) > week_expected:
        worked_str = f"\033[32m{week_worked:4.1f}\033[00m"
    elif round(week_worked) < week_expected:
        worked_str = f"\033[31m{week_worked:4.1f}\033[00m"
    else:
        worked_str = f"{week_worked:4.1f}"

    if has_holidays:
        expected_str = f"\033[36m{week_expected:4}\033[00m"
    else:
        expected_str = f"{week_expected:4}"

    if alt_week:
        expected_str = f"\033[1m{expected_str}\033[00m"

    print(f"Week {week:2} - {worked_str} of {expected_str}")


def main():
    timewarrior_data = read_json()
    exclusions = sorted(timewarrior_data.exclusions + timewarrior_data.holidays)

    total_expected = 0
    total_worked = 0
    week_worked = 0
    week_expected = 0
    previous_date = None
    previous_week = None
    alt_working_hours_week = False
    has_holidays = False

    for interval in timewarrior_data.intervals:
        date = interval[0].date()
        week = interval[0].isocalendar().week

        if date != previous_date:
            if previous_week != week and previous_week is not None:
                for exclusion in exclusions:
                    if exclusion.isocalendar().week == previous_week:
                        if exclusion.weekday() not in (5, 6):
                            has_holidays = True
                        exclusions.remove(exclusion)

                print_entry(
                    previous_week,
                    week_worked,
                    week_expected,
                    alt_working_hours_week,
                    has_holidays
                )

                total_expected += week_expected
                total_worked += week_worked

                alt_working_hours_week = False
                has_holidays = False

                week_expected = 0
                week_worked = 0

            for period_start, period_end in ALT_WORKING_HOURS_DATES:
                if period_start <= date <= period_end:
                    week_expected += ALT_WORKING_HOURS[interval[0].weekday()]
                    alt_working_hours_week = True
                    break
            else:
                if date not in exclusions:
                    week_expected += WORKING_HOURS[interval[0].weekday()]

        week_worked += (interval[1] - interval[0]).seconds / 60 / 60

        previous_week = week
        previous_date = date

    for exclusion in exclusions:
        if exclusion.isocalendar().week == week:
            if exclusion.weekday() not in (5, 6):
                has_holidays = True
            exclusions.remove(exclusion)

    print_entry(week, week_worked, week_expected, alt_working_hours_week, has_holidays)

    total_expected += week_expected
    total_worked += week_worked

    if round(total_worked) > total_expected:
        worked_str = f"\033[32m{total_worked:6.1f}\033[00m"
    elif round(total_worked) < total_expected:
        worked_str = f"\033[31m{total_worked:6.1f}\033[00m"
    else:
        worked_str = f"{total_worked:6.1f}"

    print("----------------------")
    print(f"Expected:       {total_expected:6.1f}")
    print(f"Worked:         {worked_str}", end="")


if __name__ == "__main__":
    main()
