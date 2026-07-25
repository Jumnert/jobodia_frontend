import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/confirmation_dialog.dart';
import 'package:jobodia_frontend/core/widgets/platform_ui.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/cv_builder/service/cv_photo_export_service.dart';
import 'package:jobodia_frontend/features/cv_builder/service/cv_pdf_builder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Displays the exact PDF bytes that will be printed or shared.
class CvPreviewScreen extends GetView<CvBuilderController> {
  const CvPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AdaptiveScaffold(
      useHeroBackButton: false,
      appBar: AdaptiveAppBar(title: 'CV preview', useNativeToolbar: false),
      body: Obx(() {
        final cv = controller.generatedCv.value;
        if (cv == null) {
          return _EmptyPreview(onBack: Get.back<void>);
        }

        final filename = _filenameFor(cv);
        return Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: PdfPreview(
                  build: (_) => buildCvPdf(cv),
                  initialPageFormat: PdfPageFormat.a4,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  allowPrinting: false,
                  allowSharing: false,
                  useActions: false,
                  maxPageWidth: 700,
                  pdfFileName: filename,
                  loadingWidget: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 14),
                        Text(
                          'Building your PDF…',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _PreviewActions(cv: cv, filename: filename),
          ],
        );
      }),
    );
  }
}

class _PreviewActions extends StatefulWidget {
  const _PreviewActions({required this.cv, required this.filename});

  final CvData cv;
  final String filename;

  @override
  State<_PreviewActions> createState() => _PreviewActionsState();
}

class _PreviewActionsState extends State<_PreviewActions> {
  bool _busy = false;
  String? _busyAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: _busy ? null : Get.back<void>,
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.border),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _saveToPhotos,
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.border),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: _busy && _busyAction == 'photos'
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.textPrimary,
                      ),
                    )
                  : const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text(
                'Save to Photos',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: _busy ? null : _sharePdf,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: _busy && _busyAction == 'share'
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.ios_share_rounded, size: 20),
              label: const Text(
                'Share PDF',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf() async {
    final confirmed = await showConfirmationDialog(
      title: 'Share your CV?',
      message:
          'This PDF contains your personal details and may include your photo. Continue to the device share sheet?',
      confirmLabel: 'Share PDF',
      cancelLabel: 'Cancel',
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _busyAction = 'share';
    });
    try {
      final Uint8List bytes = await buildCvPdf(widget.cv);
      await Printing.sharePdf(bytes: bytes, filename: widget.filename);
    } on Object {
      Get.snackbar(
        'Export failed',
        'The PDF could not be exported. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyAction = null;
        });
      }
    }
  }

  Future<void> _saveToPhotos() async {
    final confirmed = await showConfirmationDialog(
      title: 'Save CV pages to Photos?',
      message:
          'Jobodia will ask for permission, then convert each PDF page to a high-resolution image and add it to the “Jobodia CVs” album.',
      confirmLabel: 'Continue',
      cancelLabel: 'Cancel',
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _busyAction = 'photos';
    });
    try {
      final bytes = await buildCvPdf(widget.cv);
      final result = await const CvPhotoExportService().savePdfPages(
        pdfBytes: bytes,
        fileStem: _fileStemFor(widget.cv),
      );

      switch (result.status) {
        case CvPhotoExportStatus.saved:
          Get.snackbar(
            'Saved to Photos',
            '${result.pageCount} CV page${result.pageCount == 1 ? '' : 's'} saved to the Jobodia CVs album.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        case CvPhotoExportStatus.denied:
          Get.snackbar(
            'Photo access not allowed',
            'Allow photo access when prompted to save your CV pages.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        case CvPhotoExportStatus.permanentlyDenied:
          final openSettings = await showConfirmationDialog(
            title: 'Allow access in Settings',
            message:
                'Photo access is disabled for Jobodia. Open Settings to allow adding your CV pages to Photos.',
            confirmLabel: 'Open Settings',
            cancelLabel: 'Not now',
          );
          if (openSettings) {
            await openAppSettings();
          }
        case CvPhotoExportStatus.unsupported:
          Get.snackbar(
            'Not supported here',
            'Saving to Photos is available on Android and iOS. You can still share the PDF.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
      }
    } on Object {
      Get.snackbar(
        'Could not save to Photos',
        'The CV pages were not saved. Check available storage and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyAction = null;
        });
      }
    }
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 56,
              color: palette.iconMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No CV generated yet',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Return to the builder and complete the required details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onBack,
              child: const Text('Back to builder'),
            ),
          ],
        ),
      ),
    );
  }
}

String _filenameFor(CvData cv) {
  return '${_fileStemFor(cv)}.pdf';
}

String _fileStemFor(CvData cv) {
  final safeName = cv.fullName.trim().isEmpty
      ? 'jobodia_cv'
      : cv.fullName.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  return '${safeName}_CV';
}
