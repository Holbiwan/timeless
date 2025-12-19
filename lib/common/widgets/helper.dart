import 'package:intl/intl.dart';

// Formatting a date based on its recency to the current date
String getFormattedTime(DateTime time, {DateFormat? format}) {
  if (isToday(time)) {
    // Today: show time
    if (format != null) {
      return format.format(time);
    } else {
      return DateFormat("h:mm a").format(time);
    }
  } else if (isYesterday(time)) {
    // Yesterday
    return "Yesterday";
  } else if (isInWeek(time)) {
    // Same week: show day name
    return DateFormat("EEEE").format(time);
  } else if (isInMonth(time)) {
    // Same month: show day/month
    return DateFormat("dd/MM").format(time);
  } else if (isInYear(time)) {
    // Same year: show month
    return DateFormat("MMMM").format(time);
  } else {
    // Older: show year
    return time.year.toString();
  }
}

// Check if date is today
bool isToday(DateTime time) {
  DateTime now = DateTime.now();
  return now.year == time.year &&
      now.month == time.month &&
      now.day == time.day;
}

// Check if date is yesterday
bool isYesterday(DateTime time) {
  DateTime now = DateTime.now();
  return now.year == time.year &&
      now.month == time.month &&
      (now.day - 1) == time.day;
}

// Check if date is within the last week
bool isInWeek(DateTime time) {
  DateTime now = DateTime.now();
  return now.year == time.year &&
      now.month == time.month &&
      (now.day - 6) <= time.day;
}

// Check if date is in the current month
bool isInMonth(DateTime time) {
  DateTime now = DateTime.now();
  return now.year == time.year && now.month == time.month;
}

// Check if date is in the current year
bool isInYear(DateTime time) {
  DateTime now = DateTime.now();
  return now.year == time.year;
}

// Format date for alerts
String getAlertString(DateTime time) {
  if (isToday(time)) {
    return "Today";
  } else if (isYesterday(time)) {
    return "Yesterday";
  }
  return DateFormat('dd MMMM yyyy').format(time);
}
