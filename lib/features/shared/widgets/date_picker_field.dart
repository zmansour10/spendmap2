import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hasError = false,
    this.errorText,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.helpText,
    this.labelText,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool hasError;
  final String? errorText;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? helpText;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? () => _selectDate(context) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError 
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: enabled 
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: hasError 
                      ? Colors.red.shade600
                      : enabled 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (labelText != null) ...[
                        Text(
                          labelText!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        _formatDate(value),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: hasError 
                              ? Colors.red.shade600
                              : enabled 
                                  ? null
                                  : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        _getRelativeDateText(value),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled 
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        
        if (hasError && errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ],
        
        if (helpText != null && !hasError) ...[
          const SizedBox(height: 6),
          Text(
            helpText!,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(now.year - 10),
      lastDate: lastDate ?? DateTime(now.year + 1),
      helpText: helpText ?? 'Select expense date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      // Preserve the time component from the original date
      final newDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        value.hour,
        value.minute,
        value.second,
      );
      onChanged(newDate);
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final difference = dateOnly.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}