String userQrPayload(String userId) => 'jobodia://user/$userId';

String? userIdFromQrPayload(String? raw) {
  if (raw == null) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null ||
      uri.scheme != 'jobodia' ||
      uri.host != 'user' ||
      uri.pathSegments.length != 1 ||
      uri.pathSegments.first.isEmpty) {
    return null;
  }
  return uri.pathSegments.first;
}
