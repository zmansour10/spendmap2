import '../repositories/expense_repository.dart';

/// Use case for exporting expenses in various formats
class ExportExpensesUseCase {
  final ExpenseRepository _repository;

  const ExportExpensesUseCase(this._repository);

  /// Execute the use case
  Future<ExportExpensesResult> execute(ExportExpensesParams params) async {
    try {
      // Get expenses to export
      final expensesJson = await _repository.exportExpensesToJson(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      if (expensesJson.isEmpty) {
        return ExportExpensesResult.failure('No expenses found for the specified period');
      }

      // Process based on format
      ExportedData exportedData;
      switch (params.format) {
        case ExportFormat.json:
          exportedData = _exportAsJson(expensesJson, params);
          break;
        case ExportFormat.csv:
          exportedData = _exportAsCsv(expensesJson, params);
          break;
        case ExportFormat.summary:
          exportedData = await _exportAsSummary(expensesJson, params);
          break;
      }

      // Generate metadata
      final metadata = ExportMetadata(
        exportDate: DateTime.now(),
        totalRecords: expensesJson.length,
        dateRange: params.startDate != null && params.endDate != null
            ? '${params.startDate!.toIso8601String().split('T')[0]} to ${params.endDate!.toIso8601String().split('T')[0]}'
            : 'All time',
        format: params.format,
      );

      return ExportExpensesResult.success(exportedData, metadata);
    } catch (e) {
      return ExportExpensesResult.failure('Failed to export expenses: $e');
    }
  }

  /// Export as JSON format
  ExportedData _exportAsJson(List<Map<String, dynamic>> expenses, ExportExpensesParams params) {
    final jsonData = {
      'export_info': {
        'generated_at': DateTime.now().toIso8601String(),
        'total_expenses': expenses.length,
        'date_range': {
          'start': params.startDate?.toIso8601String(),
          'end': params.endDate?.toIso8601String(),
        },
      },
      'expenses': expenses,
    };

    return ExportedData(
      data: jsonData,
      mimeType: 'application/json',
      filename: 'expenses_export_${DateTime.now().millisecondsSinceEpoch}.json',
    );
  }

  /// Export as CSV format
  ExportedData _exportAsCsv(List<Map<String, dynamic>> expenses, ExportExpensesParams params) {
    if (expenses.isEmpty) {
      return ExportedData(
        data: '',
        mimeType: 'text/csv',
        filename: 'expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
    }

    final headers = ['ID', 'Amount', 'Description', 'Category ID', 'Date', 'Created At', 'Updated At'];
    final csvRows = <String>[headers.join(',')];

    for (final expense in expenses) {
      final row = [
        expense['id']?.toString() ?? '',
        expense['amount']?.toString() ?? '0',
        '"${expense['description']?.toString().replaceAll('"', '""') ?? ''}"',
        expense['category_id']?.toString() ?? '',
        expense['date']?.toString() ?? '',
        expense['created_at']?.toString() ?? '',
        expense['updated_at']?.toString() ?? '',
      ];
      csvRows.add(row.join(','));
    }

    return ExportedData(
      data: csvRows.join('\n'),
      mimeType: 'text/csv',
      filename: 'expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
  }

  /// Export as summary format
  Future<ExportedData> _exportAsSummary(List<Map<String, dynamic>> expenses, ExportExpensesParams params) async {
    // Calculate summary statistics
    final totalAmount = expenses.fold(0.0, (sum, expense) => 
        sum + (expense['amount'] as num).toDouble());
    final averageAmount = expenses.isNotEmpty ? totalAmount / expenses.length : 0.0;
    
    // Group by category (would need category names for full summary)
    final categoryTotals = <int, double>{};
    for (final expense in expenses) {
      final categoryId = expense['category_id'] as int;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + 
          (expense['amount'] as num).toDouble();
    }

    final summary = {
      'summary': {
        'total_expenses': expenses.length,
        'total_amount': totalAmount,
        'average_amount': averageAmount,
        'date_range': {
          'start': params.startDate?.toIso8601String(),
          'end': params.endDate?.toIso8601String(),
        },
        'category_breakdown': categoryTotals,
        'generated_at': DateTime.now().toIso8601String(),
      },
      'detailed_expenses': params.includeDetailedData ? expenses : null,
    };

    return ExportedData(
      data: summary,
      mimeType: 'application/json',
      filename: 'expenses_summary_${DateTime.now().millisecondsSinceEpoch}.json',
    );
  }
}

/// Parameters for exporting expenses
class ExportExpensesParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final ExportFormat format;
  final bool includeDetailedData;

  const ExportExpensesParams({
    this.startDate,
    this.endDate,
    required this.format,
    this.includeDetailedData = true,
  });

  /// Helper constructors
  static ExportExpensesParams json({DateTime? startDate, DateTime? endDate}) => ExportExpensesParams(
    startDate: startDate,
    endDate: endDate,
    format: ExportFormat.json,
  );

  static ExportExpensesParams csv({DateTime? startDate, DateTime? endDate}) => ExportExpensesParams(
    startDate: startDate,
    endDate: endDate,
    format: ExportFormat.csv,
  );

  static ExportExpensesParams summary({DateTime? startDate, DateTime? endDate, bool includeDetails = false}) => ExportExpensesParams(
    startDate: startDate,
    endDate: endDate,
    format: ExportFormat.summary,
    includeDetailedData: includeDetails,
  );
}

/// Export formats
enum ExportFormat {
 json,
 csv,
 summary,
}

/// Extension for ExportFormat
extension ExportFormatExtension on ExportFormat {
 String get displayName {
   switch (this) {
     case ExportFormat.json:
       return 'JSON';
     case ExportFormat.csv:
       return 'CSV';
     case ExportFormat.summary:
       return 'Summary';
   }
 }

 String get description {
   switch (this) {
     case ExportFormat.json:
       return 'Complete data in JSON format';
     case ExportFormat.csv:
       return 'Spreadsheet-compatible CSV format';
     case ExportFormat.summary:
       return 'Summary with statistics';
   }
 }
}

/// Exported data container
class ExportedData {
 final dynamic data; // String for CSV, Map for JSON
 final String mimeType;
 final String filename;

 const ExportedData({
   required this.data,
   required this.mimeType,
   required this.filename,
 });

 /// Get file extension
 String get fileExtension {
   return filename.split('.').last;
 }

 /// Get data as string (for file writing)
 String get dataAsString {
   if (data is String) {
     return data;
   } else if (data is Map || data is List) {
     // Convert JSON to string (would use dart:convert in real app)
     return data.toString(); // Simplified for this example
   }
   return data.toString();
 }
}

/// Export metadata
class ExportMetadata {
 final DateTime exportDate;
 final int totalRecords;
 final String dateRange;
 final ExportFormat format;

 const ExportMetadata({
   required this.exportDate,
   required this.totalRecords,
   required this.dateRange,
   required this.format,
 });

 /// Get formatted export date
 String get formattedExportDate => exportDate.toIso8601String().split('T')[0];
}

/// Result of exporting expenses
class ExportExpensesResult {
 final ExportedData? data;
 final ExportMetadata? metadata;
 final String? error;
 final bool isSuccess;

 const ExportExpensesResult._({
   this.data,
   this.metadata,
   this.error,
   required this.isSuccess,
 });

 factory ExportExpensesResult.success(ExportedData data, ExportMetadata metadata) {
   return ExportExpensesResult._(
     data: data,
     metadata: metadata,
     isSuccess: true,
   );
 }

 factory ExportExpensesResult.failure(String error) {
   return ExportExpensesResult._(
     error: error,
     isSuccess: false,
   );
 }
}