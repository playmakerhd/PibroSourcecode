import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/utils/view_utils.dart';

/// Reusable attachment management component
class AttachmentManager extends GetxController {
  final RxList<String> selectedFiles = <String>[].obs;
  final RxList<String> fileNames = <String>[].obs;
  final RxBool isLoading = false.obs;

  static const int maxFileSize = 20 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  /// Pick files with validation
  Future<void> pickFiles() async {
    try {
      isLoading.value = true;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (_validateFile(file)) {
            await _processFile(file);
          }
        }
      }
    } catch (e) {
      showSnackbarMessage(
        message: AppStrings.genericErrorMessage.tr,
        isSuccess: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate file size and type
  bool _validateFile(PlatformFile file) {
    if (file.size > maxFileSize) {
      showSnackbarMessage(
        message: 'File ${file.name} is too large. Maximum size is 20MB.',
        isSuccess: false,
      );
      return false;
    }

    final extension = file.extension?.toLowerCase();
    if (extension == null || !allowedExtensions.contains(extension)) {
      showSnackbarMessage(
        message:
            'File ${file.name} has unsupported format. Only ${allowedExtensions.join(', ')} are allowed.',
        isSuccess: false,
      );
      return false;
    }

    return true;
  }

  /// Process file to base64
  Future<void> _processFile(PlatformFile file) async {
    try {
      Uint8List? bytes;

      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        final ioFile = File(file.path!);
        bytes = await ioFile.readAsBytes();
      }

      if (bytes != null) {
        final base64String = base64Encode(bytes);
        selectedFiles.add(base64String);
        fileNames.add(file.name);
      }
    } catch (e) {
      showSnackbarMessage(
        message: 'Failed to process file ${file.name}',
        isSuccess: false,
      );
    }
  }

  /// Remove file at index
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      fileNames.removeAt(index);
    }
  }

  /// Clear all files
  void clearFiles() {
    selectedFiles.clear();
    fileNames.clear();
  }

  /// Check if files are selected
  bool get hasFiles => selectedFiles.isNotEmpty;

  /// Get file count
  int get fileCount => selectedFiles.length;
}

/// Widget to display file attachments
class AttachmentDisplay extends StatelessWidget {
  final AttachmentManager manager;
  final String? title;
  final bool showAddButton;

  const AttachmentDisplay({
    super.key,
    required this.manager,
    this.title,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Styles.mediumTextStyle(),
          ),
          const SizedBox(height: 8),
        ],
        if (showAddButton)
          Obx(() => ElevatedButton.icon(
                onPressed: manager.isLoading.value ? null : manager.pickFiles,
                icon: manager.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file),
                label: Text(manager.hasFiles
                    ? 'Add More Files (${manager.fileCount})'
                    : 'Select Files'),
              )),
        const SizedBox(height: 8),
        Obx(() => manager.hasFiles
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: manager.fileCount,
                itemBuilder: (context, index) {
                  final fileName = manager.fileNames[index];
                  final isImage = fileName.toLowerCase().endsWith('.jpg') ||
                      fileName.toLowerCase().endsWith('.jpeg') ||
                      fileName.toLowerCase().endsWith('.png');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Icon(
                        isImage ? Icons.image : Icons.picture_as_pdf,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        _getFileSize(manager.selectedFiles[index]),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => manager.removeFile(index),
                      ),
                    ),
                  );
                },
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  String _getFileSize(String base64String) {
    final bytes = base64String.length * 0.75; // Approximate size
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
