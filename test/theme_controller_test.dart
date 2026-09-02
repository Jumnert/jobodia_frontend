import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

import 'theme_controller_test.mocks.dart';

@GenerateMocks([GetStorage])
void main() {
  late MockGetStorage mockStorage;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();

    when(mockStorage.read<bool>('isDarkMode')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  ThemeController makeController() {
    final c = ThemeController(storage: mockStorage);
    c.onInit();
    return c;
  }

  group('ThemeController', () {
    test('initial state — light mode by default', () {
      final c = makeController();
      expect(c.isDarkMode.value, isFalse);
      expect(c.themeMode, ThemeMode.light);
    });

    test('toggleTheme switches to dark mode', () {
      final c = makeController();
      c.toggleTheme(true);

      expect(c.isDarkMode.value, isTrue);
      expect(c.themeMode, ThemeMode.dark);
    });

    test('toggleTheme switches back to light mode', () {
      final c = makeController();
      c.toggleTheme(true);
      c.toggleTheme(false);

      expect(c.isDarkMode.value, isFalse);
      expect(c.themeMode, ThemeMode.light);
    });

    test('toggleTheme persists choice to storage', () {
      final c = makeController();
      c.toggleTheme(true);

      verify(mockStorage.write('isDarkMode', true)).called(1);

      c.toggleTheme(false);
      verify(mockStorage.write('isDarkMode', false)).called(1);
    });

    test('loads stored dark mode on init', () {
      when(mockStorage.read<bool>('isDarkMode')).thenReturn(true);

      final c = ThemeController(storage: mockStorage);
      c.onInit();

      expect(c.isDarkMode.value, isTrue);
      expect(c.themeMode, ThemeMode.dark);
    });

    test('loads stored light mode on init', () {
      when(mockStorage.read<bool>('isDarkMode')).thenReturn(false);

      final c = ThemeController(storage: mockStorage);
      c.onInit();

      expect(c.isDarkMode.value, isFalse);
      expect(c.themeMode, ThemeMode.light);
    });
  });
}
