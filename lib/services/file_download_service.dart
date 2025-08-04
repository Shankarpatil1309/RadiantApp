import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class FileDownloadService {

  /// Download a file from URL and save it to device storage
  /// Returns the path where the file was saved
  Future<String> downloadFile({
    required String url,
    required String fileName,
    String? customPath,
    Function(double)? onProgress,
  }) async {
    try {
      print('🔄 Starting download - URL: $url');
      print('🔄 File name: $fileName');
      
      // Validate inputs
      if (url.isEmpty) {
        throw FileDownloadException('Download URL is empty');
      }
      
      if (fileName.isEmpty) {
        throw FileDownloadException('File name is empty');
      }

      // Get the appropriate directory for file storage
      Directory appDir;
      if (customPath != null) {
        appDir = Directory(customPath);
        print('🔄 Using custom path: ${customPath}');
        if (!await appDir.exists()) {
          print('🔄 Creating custom directory: ${customPath}');
          await appDir.create(recursive: true);
        }
      } else {
        if (Platform.isAndroid) {
          // For Android, try multiple approaches for compatibility
          try {
            // First try external storage directory
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              appDir = Directory('${externalDir.path}/Download');
              print('🔄 Using Android external storage: ${appDir.path}');
              if (!await appDir.exists()) {
                await appDir.create(recursive: true);
              }
            } else {
              throw Exception('External storage not available');
            }
          } catch (e) {
            print('🔄 External storage failed, trying downloads directory');
            // Fallback to downloads directory
            final downloadsDir = await getDownloadsDirectory();
            if (downloadsDir != null) {
              appDir = downloadsDir;
              print('🔄 Using downloads directory: ${appDir.path}');
            } else {
              print('🔄 Downloads directory not available, using app documents');
              appDir = await getApplicationDocumentsDirectory();
            }
          }
        } else if (Platform.isIOS) {
          // For iOS, use documents directory
          appDir = await getApplicationDocumentsDirectory();
          print('🔄 Using iOS Documents directory: ${appDir.path}');
        } else {
          // For other platforms, use downloads directory
          appDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
          print('🔄 Using platform downloads directory: ${appDir.path}');
        }
      }

      print('🔄 Final directory: ${appDir.path}');
      print('🔄 Directory exists: ${await appDir.exists()}');

      // Create the full file path
      final filePath = path.join(appDir.path, fileName);
      print('🔄 Full file path: $filePath');

      // Check if file already exists and create a unique name if needed
      final uniqueFilePath = await _getUniqueFilePath(filePath);
      print('🔄 Unique file path: $uniqueFilePath');

      // Validate URL format
      Uri uri;
      try {
        uri = Uri.parse(url);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          throw FileDownloadException('Invalid URL format: $url');
        }
      } catch (e) {
        throw FileDownloadException('Invalid URL: $url - ${e.toString()}');
      }

      print('🔄 Starting HTTP download...');
      
      // Download the file using http
      final response = await http.get(uri);
      
      if (response.statusCode != 200) {
        throw FileDownloadException('HTTP error: ${response.statusCode}');
      }
      
      print('🔄 Download completed. Status code: ${response.statusCode}');
      print('🔄 Downloaded ${response.bodyBytes.length} bytes');
      
      // Get file extension for file_saver
      final extension = path.extension(fileName).isEmpty 
          ? '.bin' 
          : path.extension(fileName);
      
      final baseFileName = path.basenameWithoutExtension(fileName);
      
      // Save file using file_saver
      final savedFilePath = await FileSaver.instance.saveFile(
        name: baseFileName,
        bytes: response.bodyBytes,
        ext: extension.replaceFirst('.', ''), // Remove the dot
      );
      
      print('🔄 File saved using file_saver: $savedFilePath');
      
      // For consistency, return the expected path format
      final finalPath = savedFilePath;
      
      // Verify the download was successful
      if (response.bodyBytes.isEmpty) {
        throw FileDownloadException('Downloaded file is empty');
      }
      
      print('✅ File downloaded successfully! Size: ${response.bodyBytes.length} bytes');
      print('✅ File location: $finalPath');
      
      return finalPath;
    } catch (e) {
      print('❌ Download failed: ${e.toString()}');
      throw FileDownloadException('Failed to download file: ${e.toString()}');
    }
  }

  /// Download an assignment attachment
  Future<String> downloadAssignmentAttachment({
    required String url,
    required String fileName,
    required String assignmentTitle,
    Function(double)? onProgress,
  }) async {
    // Sanitize the assignment title for folder name
    final sanitizedTitle = assignmentTitle
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    // Create a subfolder for assignments
    Directory appDir;
    if (Platform.isAndroid) {
      try {
        // Try external storage first
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          appDir = Directory('${externalDir.path}/Download/RadiantApp/Assignments');
        } else {
          throw Exception('External storage not available');
        }
      } catch (e) {
        // Fallback to app documents
        final documentsDir = await getApplicationDocumentsDirectory();
        appDir = Directory(path.join(documentsDir.path, 'RadiantApp', 'Assignments'));
      }
    } else if (Platform.isIOS) {
      final documentsDir = await getApplicationDocumentsDirectory();
      appDir = Directory(path.join(documentsDir.path, 'Assignments'));
    } else {
      final downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      appDir = Directory(path.join(downloadsDir.path, 'RadiantApp', 'Assignments'));
    }

    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    // Use assignment title in filename if not already present
    final finalFileName = fileName.contains(sanitizedTitle) 
        ? fileName 
        : '${sanitizedTitle}_$fileName';

    return await downloadFile(
      url: url,
      fileName: finalFileName,
      customPath: appDir.path,
      onProgress: onProgress,
    );
  }

  /// Get a unique file path by adding a number suffix if file already exists
  Future<String> _getUniqueFilePath(String originalPath) async {
    if (!await File(originalPath).exists()) {
      return originalPath;
    }

    final directory = path.dirname(originalPath);
    final extension = path.extension(originalPath);
    final baseName = path.basenameWithoutExtension(originalPath);

    int counter = 1;
    String newPath;
    
    do {
      newPath = path.join(directory, '$baseName($counter)$extension');
      counter++;
    } while (await File(newPath).exists());

    return newPath;
  }

  /// Get human readable file size
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get the display name for the storage location
  static Future<String> getStorageLocationName() async {
    if (Platform.isAndroid) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          return 'Device storage > Download folder';
        }
      } catch (e) {
        // Fallback
      }
      return 'App documents folder';
    } else if (Platform.isIOS) {
      return 'Files app > On My iPhone';
    } else {
      return 'Downloads folder';
    }
  }

}

/// Custom exception for file download operations
class FileDownloadException implements Exception {
  final String message;
  
  const FileDownloadException(this.message);
  
  @override
  String toString() => 'FileDownloadException: $message';
}