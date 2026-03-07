import math
from datetime import datetime, timedelta

import pytz
from django.utils import timezone
from django.utils.dateparse import parse_date
from django.conf import settings


def str_time(date) -> str:
    return timezone.localtime(date).strftime('%Y/%m/%d %H:%M:%S')


def to_text_hide(data: str) -> str:
    if not isinstance(data, str):
        return ''

    if len(data) < 4:
        return data

    if len(data) < 7:
        return data[:2] + '****' + data[-2:]

    if len(data) < 15:
        return data[:4] + '****' + data[-4:]

    return data[:6] + '****' + data[-7:]


def get_local_now(zone=settings.TIME_ZONE):
    timezone.deactivate()
    tz = pytz.timezone(zone) if zone else timezone.get_current_timezone()
    now = timezone.now()
    return tz.normalize(now.astimezone(tz))


def get_today_timezone(zone=settings.TIME_ZONE):
    timezone.deactivate()
    tz = pytz.timezone(zone) if zone else timezone.get_current_timezone()
    now = timezone.now()
    local_now = tz.normalize(now.astimezone(tz))
    start = local_now.replace(hour=0, minute=0, second=0, microsecond=0)
    end = local_now.replace(hour=23, minute=59, second=59, microsecond=0)
    return start, end


def get_yesterday_timezone(zone=settings.TIME_ZONE):
    timezone.deactivate()
    tz = pytz.timezone(zone) if zone else timezone.get_current_timezone()
    yesterday = timezone.now() - timedelta(hours=24)
    local_yesterday = tz.normalize(yesterday.astimezone(tz))
    start = local_yesterday.replace(hour=0, minute=0, second=0, microsecond=0)
    end = local_yesterday.replace(hour=23, minute=59, second=59, microsecond=0)
    return start, end


def get_time_range_timezone(start_date: str, end_date: str, zone=settings.TIME_ZONE):
    timezone.deactivate()
    tz = pytz.timezone(zone) if zone else timezone.get_current_timezone()
    start = tz.localize(datetime.combine(
        parse_date(start_date), datetime.min.time()))
    end = tz.localize(datetime.combine(
        parse_date(end_date), datetime.max.time()))
    return start, end


def daterange(start_date, end_date):
    for n in range(int((end_date - start_date).days + 1)):
        yield start_date + timedelta(n)


def paginate(data: list, page: int, limit: int) -> dict:
    total = len(data)
    total_pages = math.ceil(total / limit) if limit else 1
    start = (page - 1) * limit
    end = start + limit

    return {
        'data': data[start:end],
        'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': total_pages,
        }
    }


def paginate_queryset(qs, page: int, limit: int, serializer=None) -> dict:
    total = qs.count()
    total_pages = math.ceil(total / limit) if limit else 1
    start = (page - 1) * limit
    sliced = qs[start:start + limit]

    data = [serializer(obj) for obj in sliced] if serializer else list(sliced)

    return {
        'data': data,
        'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': total_pages,
        }
    }
