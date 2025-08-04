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
      
      // Detect file type from multiple sources
      String extension = path.extension(fileName);
      String baseFileName = path.basenameWithoutExtension(fileName);
      
      // If no extension in filename, try to detect from Content-Type header
      if (extension.isEmpty) {
        final contentType = response.headers['content-type'] ?? '';
        extension = _getExtensionFromContentType(contentType);
        print('🔄 Detected extension from Content-Type: $extension');
      }
      
      // If still no extension, try to detect from URL
      if (extension.isEmpty) {
        extension = _getExtensionFromUrl(url);
        print('🔄 Detected extension from URL: $extension');
      }
      
      // Final fallback - analyze first few bytes for common file signatures
      if (extension.isEmpty) {
        extension = _detectExtensionFromFileSignature(response.bodyBytes);
        print('🔄 Detected extension from file signature: $extension');
      }
      
      // Default to .bin only as absolute last resort
      if (extension.isEmpty) {
        extension = '.bin';
        print('🔄 No extension detected, defaulting to .bin');
      }
      
      // Update filename if we detected an extension
      if (path.extension(fileName).isEmpty && extension.isNotEmpty) {
        baseFileName = fileName;
      }
      
      // Save file using file_saver to Downloads directory
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

  /// Get file extension from Content-Type header
  String _getExtensionFromContentType(String contentType) {
    final mimeToExt = {
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
      'application/vnd.ms-powerpoint': '.ppt',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation': '.pptx',
      'text/plain': '.txt',
      'text/csv': '.csv',
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'image/gif': '.gif',
      'image/bmp': '.bmp',
      'image/webp': '.webp',
      'application/zip': '.zip',
      'application/x-rar-compressed': '.rar',
      'application/x-7z-compressed': '.7z',
      'audio/mpeg': '.mp3',
      'audio/wav': '.wav',
      'video/mp4': '.mp4',
      'video/quicktime': '.mov',
      'application/json': '.json',
      'application/xml': '.xml',
      'text/html': '.html',
      'text/css': '.css',
      'application/javascript': '.js',
    };
    
    // Extract the main content type (remove charset, etc.)
    final mainContentType = contentType.split(';').first.trim().toLowerCase();
    return mimeToExt[mainContentType] ?? '';
  }

  /// Try to detect extension from URL path
  String _getExtensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final urlPath = uri.path;
      if (urlPath.isNotEmpty) {
        final extension = path.extension(urlPath);
        if (extension.isNotEmpty) {
          return extension;
        }
      }
    } catch (e) {
      // Ignore URL parsing errors
    }
    return '';
  }

  /// Detect file type from file signature (magic numbers)
  String _detectExtensionFromFileSignature(List<int> bytes) {
    if (bytes.length < 4) return '';
    
    // Check first few bytes for common file signatures
    final signature = bytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    
    // Common file signatures
    if (signature.startsWith('504b0304')) return '.zip'; // ZIP files (also DOCX, XLSX, PPTX)
    if (signature.startsWith('25504446')) return '.pdf'; // PDF
    if (signature.startsWith('d0cf11e0')) return '.doc'; // DOC, XLS, PPT (OLE files)
    if (signature.startsWith('ffd8ff')) return '.jpg'; // JPEG
    if (signature.startsWith('89504e47')) return '.png'; // PNG
    if (signature.startsWith('47494638')) return '.gif'; // GIF
    if (signature.startsWith('424d')) return '.bmp'; // BMP
    if (signature.startsWith('52494646')) return '.wav'; // WAV
    if (signature.startsWith('49443303') || signature.startsWith('fffb')) return '.mp3'; // MP3
    if (signature.startsWith('00000020667479706d703432') || signature.startsWith('00000018667479706d703432')) return '.mp4'; // MP4
    
    // For Office documents that are ZIP-based, try to detect more specifically
    if (signature.startsWith('504b0304')) {
      // This could be DOCX, XLSX, PPTX - we'd need to look inside the ZIP
      // For now, let's assume it's a Word document if it came from Google Drive
      return '.docx';
    }
    
    return '';
  }

}

/// Custom exception for file download operations
class FileDownloadException implements Exception {
  final String message;
  
  const FileDownloadException(this.message);
  
  @override
  String toString() => 'FileDownloadException: $message';
}