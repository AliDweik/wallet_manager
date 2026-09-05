
import 'dart:convert';
import 'dart:io';

import 'package:wallet_manager/models/app_data.dart';
import 'package:wallet_manager/models/archive_summary.dart';
import 'package:wallet_manager/utlils/constants.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Get documents directory path
  Future<Directory> _getDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    print('📁 Documents Directory: ${dir.path}');
    return dir;
  }

  // Get active data file path
  Future<File> _getActiveDataFile() async {
    final dir = await _getDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.activeDataFile}');
    print('📄 Active Data File: ${file.path}');
    return file;
  }

  // Load active data
  Future<AppData?> loadActiveData() async {
    try {
      final file = await _getActiveDataFile();

      if (!await file.exists()) {
        print('❌ Active data file does not exist');
        return null;
      }

      final jsonString = await file.readAsString();
      print('✅ Active data loaded: ${jsonString.length} characters');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return AppData.fromJson(jsonData);
    } catch (e) {
      print('❌ Error loading active data: $e');
      return null;
    }
  }

  // Save active data
  Future<void> saveActiveData(AppData data) async {
    try {
      final file = await _getActiveDataFile();
      final jsonString = json.encode(data.toJson());
      await file.writeAsString(jsonString);
      print('✅ Active data saved: ${jsonString.length} characters');
    } catch (e) {
      print('❌ Error saving active data: $e');
      throw Exception('Failed to save data');
    }
  }

  // Archive current month data
  Future<void> archiveCurrentMonth(AppData data) async {
    try {
      final dir = await _getDocumentsDirectory();
      final fileName = AppConstants.getArchiveFileName(DateTime.now());
      final archiveFile = File('${dir.path}/$fileName');

      print('📦 Archiving to: $fileName');

      // Add archive metadata
      final archiveData = data.toJson();
      archiveData['archivedAt'] = DateTime.now().toIso8601String();
      archiveData['isArchived'] = true;

      final jsonString = json.encode(archiveData);
      await archiveFile.writeAsString(jsonString);

      print('✅ Archive saved: ${jsonString.length} characters');

      // Verify file exists
      if (await archiveFile.exists()) {
        final fileSize = await archiveFile.length();
        print('✅ Archive file verified: $fileSize bytes');
      } else {
        print('❌ Archive file was not created!');
      }
    } catch (e) {
      print('❌ Error archiving data: $e');
      throw Exception('Failed to archive data');
    }
  }

  // Load archive data for a specific month
  Future<AppData?> loadArchiveData(String fileName) async {
    try {
      final dir = await _getDocumentsDirectory();
      final archiveFile = File('${dir.path}/$fileName');

      print('📂 Loading archive: $fileName');

      if (!await archiveFile.exists()) {
        print('❌ Archive file does not exist');
        return null;
      }

      final jsonString = await archiveFile.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return AppData.fromJson(jsonData);
    } catch (e) {
      print('❌ Error loading archive data: $e');
      return null;
    }
  }

  // List all archive files with summaries
  Future<List<ArchiveSummary>> getAllArchiveSummaries() async {
    try {
      final dir = await _getDocumentsDirectory();

      print('📂 Listing files in: ${dir.path}');

      // List all files in directory
      final allFiles = dir.listSync();
      print('📄 Total files in directory: ${allFiles.length}');

      for (final file in allFiles) {
        print('  - ${file.path}');
      }

      final archiveFiles = allFiles
          .where((f) => f is File &&
          f.path.contains(AppConstants.archivePrefix))
          .map((f) => f.path)
          .toList();

      print('📦 Archive files found: ${archiveFiles.length}');

      final summaries = <ArchiveSummary>[];

      for (final filePath in archiveFiles) {
        try {
          final file = File(filePath);
          final jsonString = await file.readAsString();
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final appData = AppData.fromJson(jsonData);

          final summary = ArchiveSummary(
            fileName: filePath.split('/').last,
            monthYear: appData.currentMonth ?? 'Unknown',
            totalBalance: appData.totalBalance,
            cashBalance: appData.cashBalance,
            visaBalance: appData.visaBalance,
            savings: appData.savings,
            transactionsCount: appData.transactions.length,
            archivedAt: jsonData['archivedAt'] != null
                ? DateTime.parse(jsonData['archivedAt'] as String)
                : null,
          );

          print('✅ Archive summary created: ${summary.monthYearDisplay}');
          summaries.add(summary);
        } catch (e) {
          print('❌ Error parsing archive file $filePath: $e');
        }
      }

      // Sort newest first
      summaries.sort((a, b) => b.fileName.compareTo(a.fileName));

      return summaries;
    } catch (e) {
      print('❌ Error listing archives: $e');
      return [];
    }
  }

  // Delete archive file
  Future<void> deleteArchiveFile(String fileName) async {
    try {
      final dir = await _getDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      print('🗑️ Deleting archive: $fileName');

      if (await file.exists()) {
        await file.delete();
        print('✅ Archive deleted');
      } else {
        print('❌ Archive file not found for deletion');
      }
    } catch (e) {
      print('❌ Error deleting archive: $e');
      throw Exception('Failed to delete archive');
    }
  }

  // Create default data if none exists
  Future<AppData> loadOrCreateData() async {
    final existingData = await loadActiveData();

    if (existingData != null) {
      return existingData;
    }

    final defaultData = AppData(
      currentMonth: _getCurrentMonthString(),
    );

    await saveActiveData(defaultData);
    return defaultData;
  }

  String _getCurrentMonthString() {
    final now = DateTime.now();
    final monthString = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    print('📅 Current month string: $monthString');
    return monthString;
  }
}