import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required String folderPath,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate a unique filename if not provided
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      
      // Create reference to the file location
      final ref = _storage.ref().child('$folderPath/$fileName');
      
      // Create upload task
      final uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Upload file from bytes (useful for web)
  Future<String> uploadFileFromBytes({
    required Uint8List bytes,
    required String folderPath,
    required String fileName,
    String? mimeType,
    Function(double)? onProgress,
  }) async {
    try {
      // Create reference to the file location
      final ref = _storage.ref().child('$folderPath/$fileName');
      
      // Set metadata if mime type is provided
      SettableMetadata? metadata;
      if (mimeType != null) {
        metadata = SettableMetadata(contentType: mimeType);
      }
      
      // Create upload task
      final uploadTask = metadata != null 
          ? ref.putData(bytes, metadata)
          : ref.putData(bytes);
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Upload assignment PDF
  Future<String> uploadAssignmentPDF({
    required File file,
    required String facultyId,
    required String assignmentTitle,
    Function(double)? onProgress,
  }) async {
    // Sanitize assignment title for filename
    final sanitizedTitle = assignmentTitle
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${sanitizedTitle}.pdf';
    
    return await uploadFile(
      file: file,
      folderPath: 'assignments/$facultyId',
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Upload class material
  Future<String> uploadClassMaterial({
    required File file,
    required String facultyId,
    required String subject,
    Function(double)? onProgress,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    
    return await uploadFile(
      file: file,
      folderPath: 'class_materials/$facultyId/$subject',
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw StorageException('Failed to delete file: ${e.toString()}');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw StorageException('Failed to get file metadata: ${e.toString()}');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  Future<int?> getFileSize(String downloadUrl) async {
    try {
      final metadata = await getFileMetadata(downloadUrl);
      return metadata.size;
    } catch (e) {
      return null;
    }
  }

  /// List files in a folder
  Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw StorageException('Failed to list files: ${e.toString()}');
    }
  }

  /// Validate file type and size
  bool validateFile(File file, {
    List<String>? allowedExtensions,
    int? maxSizeInBytes,
  }) {
    // Check file extension
    if (allowedExtensions != null) {
      final extension = path.extension(file.path).toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return false;
      }
    }
    
    // Check file size
    if (maxSizeInBytes != null) {
      final fileSize = file.lengthSync();
      if (fileSize > maxSizeInBytes) {
        return false;
      }
    }
    
    return true;
  }

  /// Get human readable file size
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}