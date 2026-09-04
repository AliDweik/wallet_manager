
import 'dart:convert';
import 'dart:io';

import 'package:wallet_manager/models/app_data.dart';
import 'package:wallet_manager/utlils/constants.dart';
import 'package:wallet_manager/utlils/formatters.dart';
import 'package:path_provider/path_provider.dart';



class StorageService {
  // Get documents directory path
  Future<Directory> _getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get active data file path
  Future<File> _getActiveDataFile() async {
    final dir = await _getDocumentsDirectory();
    return File('${dir.path}/${AppConstants.activeDataFile}');
  }

  // Load active data
  Future<AppData?> loadActiveData() async {
    try {
      final file = await _getActiveDataFile();

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return AppData.fromJson(jsonData);
    } catch (e) {
      print('Error loading active data: $e');
      return null;
    }
  }

  // Save active data
  Future<void> saveActiveData(AppData data) async {
    try {
      final file = await _getActiveDataFile();
      final jsonString = json.encode(data.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving active data: $e');
      throw Exception('Failed to save data');
    }
  }

  // Archive current month data
  Future<void> archiveCurrentMonth(AppData data) async {
    try {
      final dir = await _getDocumentsDirectory();
      final archiveFile = File(
          '${dir.path}/${AppConstants.getArchiveFileName(DateTime.now())}'
      );

      final jsonString = json.encode(data.toJson());
      await archiveFile.writeAsString(jsonString);
    } catch (e) {
      print('Error archiving data: $e');
      throw Exception('Failed to archive data');
    }
  }

  // Load archive data for a specific month
  Future<AppData?> loadArchiveData(String yearMonth) async {
    try {
      final dir = await _getDocumentsDirectory();
      final archiveFile = File(
          '${dir.path}/${AppConstants.archivePrefix}${yearMonth}.json'
      );

      if (!await archiveFile.exists()) {
        return null;
      }

      final jsonString = await archiveFile.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return AppData.fromJson(jsonData);
    } catch (e) {
      print('Error loading archive data: $e');
      return null;
    }
  }

  // List all archive files
  Future<List<String>> getAllArchiveFiles() async {
    try {
      final dir = await _getDocumentsDirectory();
      final files = dir.listSync()
          .where((f) => f is File &&
          f.path.contains(AppConstants.archivePrefix))
          .map((f) => f.path.split('/').last)
          .toList();

      return files;
    } catch (e) {
      print('Error listing archives: $e');
      return [];
    }
  }

  // Delete archive file
  Future<void> deleteArchiveFile(String fileName) async {
    try {
      final dir = await _getDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting archive: $e');
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
      currentMonth: Formatters.getCurrentMonthString(),
    );

    await saveActiveData(defaultData);
    return defaultData;
  }
}