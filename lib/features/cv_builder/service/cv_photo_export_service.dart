import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:saver_gallery/saver_gallery.dart';

enum CvPhotoExportStatus { saved, denied, permanentlyDenied, unsupported }

class CvPhotoExportResult {
  const CvPhotoExportResult({required this.status, this.pageCount = 0});

  final CvPhotoExportStatus status;
  final int pageCount;
}

/// Converts the real PDF pages to high-resolution PNGs and adds them to the
/// system photo library. The PDF itself remains available through Share PDF.
class CvPhotoExportService {
  const CvPhotoExportService();

  Future<CvPhotoExportResult> savePdfPages({
    required Uint8List pdfBytes,
    required String fileStem,
  }) async {
    final permission = await _requestAddPermission();
    if (permission != CvPhotoExportStatus.saved) {
      return CvPhotoExportResult(status: permission);
    }

    var pageCount = 0;
    await for (final page in Printing.raster(pdfBytes, dpi: 180)) {
      pageCount++;
      final png = await page.toPng();
      final result = await SaverGallery.saveImage(
        png,
        quality: 100,
        fileName: '${fileStem}_page_$pageCount.png',
        albumPath: 'Jobodia CVs',
        skipIfExists: false,
      );
      if (!result.isSuccess) {
        throw StateError(result.errorMessage ?? 'Photo library save failed.');
      }
    }

    return CvPhotoExportResult(
      status: CvPhotoExportStatus.saved,
      pageCount: pageCount,
    );
  }

  Future<CvPhotoExportStatus> _requestAddPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      if (status.isGranted || status.isLimited) {
        return CvPhotoExportStatus.saved;
      }
      return status.isPermanentlyDenied || status.isRestricted
          ? CvPhotoExportStatus.permanentlyDenied
          : CvPhotoExportStatus.denied;
    }

    if (Platform.isAndroid) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk >= 29) return CvPhotoExportStatus.saved;

      final status = await Permission.storage.request();
      if (status.isGranted) return CvPhotoExportStatus.saved;
      return status.isPermanentlyDenied
          ? CvPhotoExportStatus.permanentlyDenied
          : CvPhotoExportStatus.denied;
    }

    return CvPhotoExportStatus.unsupported;
  }
}
