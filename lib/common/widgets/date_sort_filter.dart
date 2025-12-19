import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';

enum DateSortOption {
  newest('Newest First'),
  oldest('Oldest First'),
  relevance('Most Relevant');

  const DateSortOption(this.label);
  final String label;
}

class DateSortFilter extends StatelessWidget {
  final DateSortOption selectedOption;
  final Function(DateSortOption) onOptionChanged;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? selectedColor;
  final double? fontSize;

  const DateSortFilter({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
    this.backgroundColor,
    this.textColor,
    this.selectedColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            color: textColor ?? Colors.black,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Sort by:',
            style: TextStyle(
              color: textColor ?? Colors.black,
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DateSortOption.values.map((option) {
                  final isSelected = option == selectedOption;
                  return GestureDetector(
                    onTap: () => onOptionChanged(option),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (selectedColor ?? ColorRes.brightYellow)
                            : (backgroundColor ?? Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (selectedColor ?? ColorRes.brightYellow)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : (textColor ?? Colors.black54),
                          fontSize: (fontSize ?? 14) - 1,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactDateSortFilter extends StatelessWidget {
  final DateSortOption selectedOption;
  final Function(DateSortOption) onOptionChanged;
  final Color? backgroundColor;
  final Color? iconColor;

  const CompactDateSortFilter({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateSortOption>(
      onSelected: onOptionChanged,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorRes.brightYellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              color: iconColor ?? Colors.black,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              selectedOption.label.split(' ').first, // Show only first word
              style: TextStyle(
                color: iconColor ?? Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => DateSortOption.values.map((option) {
        return PopupMenuItem<DateSortOption>(
          value: option,
          child: Row(
            children: [
              Icon(
                _getIconForOption(option),
                size: 18,
                color: option == selectedOption
                    ? ColorRes.brightYellow
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                option.label,
                style: TextStyle(
                  fontWeight: option == selectedOption
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color:
                      option == selectedOption ? Colors.black : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForOption(DateSortOption option) {
    switch (option) {
      case DateSortOption.newest:
        return Icons.arrow_downward;
      case DateSortOption.oldest:
        return Icons.arrow_upward;
      case DateSortOption.relevance:
        return Icons.star;
    }
  }
}

// Helper class for sorting job listings by date
class DateSortHelper {
  // Sort a list of Firestore documents by date
  static List<T> sortDocuments<T>(
    List<T> documents,
    DateSortOption sortOption,
    String dateField, {
    Function(T)? getTimestamp,
  }) {
    final List<T> sortedList = List.from(documents);

    switch (sortOption) {
      case DateSortOption.newest:
        sortedList.sort((a, b) {
          final timestampA =
              getTimestamp?.call(a) ?? _getTimestampFromDoc(a, dateField);
          final timestampB =
              getTimestamp?.call(b) ?? _getTimestampFromDoc(b, dateField);
          return _compareTimestamps(
              timestampB, timestampA); // Newest first (descending)
        });
        break;

      case DateSortOption.oldest:
        sortedList.sort((a, b) {
          final timestampA =
              getTimestamp?.call(a) ?? _getTimestampFromDoc(a, dateField);
          final timestampB =
              getTimestamp?.call(b) ?? _getTimestampFromDoc(b, dateField);
          return _compareTimestamps(
              timestampA, timestampB); // Oldest first (ascending)
        });
        break;

      case DateSortOption.relevance:
        // For relevance, we could implement a more complex scoring algorithm
        // For now, we'll sort by newest as a fallback
        sortedList.sort((a, b) {
          final timestampA =
              getTimestamp?.call(a) ?? _getTimestampFromDoc(a, dateField);
          final timestampB =
              getTimestamp?.call(b) ?? _getTimestampFromDoc(b, dateField);
          return _compareTimestamps(timestampB, timestampA);
        });
        break;
    }

    return sortedList;
  }

  static dynamic _getTimestampFromDoc(dynamic doc, String dateField) {
    if (doc is Map<String, dynamic>) {
      return doc[dateField];
    }
    // Assume it's a QueryDocumentSnapshot
    try {
      final data = (doc as dynamic).data();
      if (data is Map<String, dynamic>) {
        return data[dateField];
      }
    } catch (e) {
      // Handle error gracefully
    }
    return null;
  }

  static int _compareTimestamps(dynamic a, dynamic b) {
    // Handle null values
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    // Convert to DateTime if necessary
    DateTime? dateA = _convertToDateTime(a);
    DateTime? dateB = _convertToDateTime(b);

    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;

    return dateA.compareTo(dateB);
  }

  static DateTime? _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is DateTime) {
      return timestamp;
    }

    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }

    // Handle Firestore Timestamp
    try {
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        return (timestamp as dynamic).toDate() as DateTime;
      }
    } catch (e) {
      // Handle conversion error
    }

    return null;
  }

  // Show a snackbar with sorting feedback
  static void showSortingFeedback(DateSortOption option) {
    String message;
    switch (option) {
      case DateSortOption.newest:
        message = 'Sorted by newest jobs first';
        break;
      case DateSortOption.oldest:
        message = 'Sorted by oldest jobs first';
        break;
      case DateSortOption.relevance:
        message = 'Sorted by relevance';
        break;
    }

    Get.snackbar(
      '📅 Sorting Applied',
      message,
      backgroundColor: ColorRes.brightYellow,
      colorText: Colors.black,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.sort, color: Colors.black),
    );
  }
}
