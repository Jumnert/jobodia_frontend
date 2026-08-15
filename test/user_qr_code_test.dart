import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/messaging/model/user_qr_code.dart';

void main() {
  test('Jobodia user QR payload round trips a backend user id', () {
    const userId = '16d67c78-5f25-4e85-b74a-2e57cdf8db79';
    expect(userIdFromQrPayload(userQrPayload(userId)), userId);
  });

  test('QR parser rejects external and malformed payloads', () {
    expect(userIdFromQrPayload('https://example.com/user/123'), isNull);
    expect(userIdFromQrPayload('jobodia://job/123'), isNull);
    expect(userIdFromQrPayload('jobodia://user/'), isNull);
    expect(userIdFromQrPayload(null), isNull);
  });
}
