import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:field_link/features/media/presentation/cubit/media_uploader_cubit.dart';

/// A widget that allows users to pick photos, videos, and documents.
/// Shows a bottom sheet with options when tapped.
class MediaPicker extends StatelessWidget {
  const MediaPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaUploaderCubit, MediaUploaderState>(
      builder: (context, state) {
        final selectedFiles = state is MediaUploaderInProcess ? state.selectedFiles : <File>[];
        final isUploading = state is MediaUploaderInProcess ? state.isUploading : false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!isUploading)
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: () => _showPickerOptions(context),
                    tooltip: 'Add attachment',
                  ),
              ],
            ),
            if (selectedFiles.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = selectedFiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildFileTile(context, file, isUploading),
                    );
                  },
                ),
              ),
            if (state is MediaUploaderInProcess && state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFileTile(BuildContext context, File file, bool isUploading) {
    final fileName = file.path.split('/').last.toLowerCase();
    final isImage = _isImageFile(fileName);
    final isVideo = _isVideoFile(fileName);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: isImage
                ? Image.file(file, width: 100, height: 100, fit: BoxFit.cover)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getFileIcon(fileName),
                          size: 36,
                          color: isVideo ? Colors.purple : Colors.blue,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            fileName.length > 12
                                ? '${fileName.substring(0, 10)}...'
                                : fileName,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (!isUploading)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => context.read<MediaUploaderCubit>().removeFile(file),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        if (isUploading)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Photos'),
                  subtitle: const Text('Select from gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickPhotos(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _takePhoto(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.purple),
                  title: const Text('Video'),
                  subtitle: const Text('Record or select video'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickVideo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.orange),
                  title: const Text('Document'),
                  subtitle: const Text('PDF, Word, Excel, etc.'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickDocument(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhotos(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty && context.mounted) {
      final files = pickedFiles.map((e) => File(e.path)).toList();
      context.read<MediaUploaderCubit>().addFiles(files);
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && context.mounted) {
      context.read<MediaUploaderCubit>().addFiles([File(pickedFile.path)]);
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      context.read<MediaUploaderCubit>().addFiles([File(pickedFile.path)]);
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'zip'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty && context.mounted) {
      final files = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
      if (files.isNotEmpty) {
        context.read<MediaUploaderCubit>().addFiles(files);
      }
    }
  }

  bool _isImageFile(String fileName) {
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.webp');
  }

  bool _isVideoFile(String fileName) {
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv');
  }

  IconData _getFileIcon(String fileName) {
    if (_isVideoFile(fileName)) return Icons.videocam;
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    }
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (fileName.endsWith('.zip')) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }
}
