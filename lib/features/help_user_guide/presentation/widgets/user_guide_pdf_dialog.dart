import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../help_guide_screen.dart';
import 'user_guide_pdf_service.dart';

class UserGuidePdfDialog extends StatefulWidget {
  final List<HelpTopic> topics;
  final bool isAdmin;
  final HelpTopic? initialSingleTopic;

  const UserGuidePdfDialog({
    super.key,
    required this.topics,
    required this.isAdmin,
    this.initialSingleTopic,
  });

  static Future<void> show(
    BuildContext context, {
    required List<HelpTopic> topics,
    required bool isAdmin,
    HelpTopic? initialSingleTopic,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 920,
            height: 780,
            child: UserGuidePdfDialog(
              topics: topics,
              isAdmin: isAdmin,
              initialSingleTopic: initialSingleTopic,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<UserGuidePdfDialog> createState() => _UserGuidePdfDialogState();
}

class _UserGuidePdfDialogState extends State<UserGuidePdfDialog> {
  final ValueNotifier<Uint8List?> _pdfBytesNotifier = ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> _isGeneratingNotifier = ValueNotifier<bool>(true);

  late bool _exportSingleTopicOnly;

  @override
  void initState() {
    super.initState();
    _exportSingleTopicOnly = widget.initialSingleTopic != null;
    _generatePdf();
  }

  @override
  void dispose() {
    _pdfBytesNotifier.dispose();
    _isGeneratingNotifier.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    _isGeneratingNotifier.value = true;
    final bytes = await UserGuidePdfService.generateUserGuidePdf(
      topics: widget.topics,
      isAdmin: widget.isAdmin,
      singleTopic: _exportSingleTopicOnly ? widget.initialSingleTopic : null,
    );

    if (mounted) {
      _pdfBytesNotifier.value = bytes;
      _isGeneratingNotifier.value = false;
    }
  }

  Future<void> _downloadPdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final topicSlug = _exportSingleTopicOnly && widget.initialSingleTopic != null
        ? widget.initialSingleTopic!.id
        : 'Full_Manual';
    final filename = '${AppConstants.appName}_User_Guide_$topicSlug.pdf';

    final savedPath = await UserGuidePdfService.savePdfToDownloads(
      pdfBytes: pdfBytes,
      filename: filename,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath != null
                ? 'User Guide PDF saved to Downloads: $savedPath'
                : 'PDF downloaded successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _sharePdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final topicSlug = _exportSingleTopicOnly && widget.initialSingleTopic != null
        ? widget.initialSingleTopic!.id
        : 'Full_Manual';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${AppConstants.appName}_User_Guide_$topicSlug.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _pdfBytesNotifier,
      builder: (context, pdfBytes, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              _exportSingleTopicOnly && widget.initialSingleTopic != null
                  ? 'User Guide PDF - ${widget.initialSingleTopic!.title}'
                  : 'Full User Manual & Operating Guide PDF',
              style: AppTypography.cardTitle,
            ),
            backgroundColor: AppColors.surface,
            elevation: 1,
            actions: [
              if (widget.initialSingleTopic != null) ...[
                Row(
                  children: [
                    Text(
                      'Full Manual',
                      style: AppTypography.secondary.copyWith(fontSize: 12),
                    ),
                    Switch(
                      value: _exportSingleTopicOnly,
                      activeTrackColor: AppColors.accent,
                      onChanged: (val) {
                        setState(() {
                          _exportSingleTopicOnly = val;
                        });
                        _generatePdf();
                      },
                    ),
                    Text(
                      'Selected Topic Only',
                      style: AppTypography.secondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const VerticalDivider(indent: 12, endIndent: 12, width: 24),
              ],
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.accent),
                tooltip: 'Save PDF to Downloads',
                onPressed: pdfBytes == null ? null : _downloadPdfFile,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.accent),
                tooltip: 'Share PDF Document',
                onPressed: pdfBytes == null ? null : _sharePdfFile,
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: _isGeneratingNotifier,
            builder: (context, isGenerating, _) {
              if (isGenerating || pdfBytes == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generating User Manual PDF...'),
                    ],
                  ),
                );
              }
              return PdfPreview(
                build: (format) => pdfBytes,
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
              );
            },
          ),
        );
      },
    );
  }
}
