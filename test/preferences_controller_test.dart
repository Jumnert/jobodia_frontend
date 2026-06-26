import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';

import 'preferences_controller_test.mocks.dart';

@GenerateMocks([GetStorage])
void main() {
  late MockGetStorage mockStorage;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();

    when(mockStorage.read<bool>('hasCompletedPreferences')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  PreferencesController makeController() {
    final c = PreferencesController(storage: mockStorage);
    c.onInit();
    return c;
  }

  group('PreferencesController', () {
    test('initial state — hasCompletedPreferences is false', () {
      final c = makeController();
      expect(c.hasCompletedPreferences, isFalse);
    });

    test('complete() sets hasCompletedPreferences to true', () {
      final c = makeController();
      c.complete();

      // After writing, the next read should return true.
      verify(mockStorage.write('hasCompletedPreferences', true)).called(1);
    });

    test('complete() persists preferences', () {
      final c = makeController();
      c.desiredRole.value = 'Developer';
      c.experienceLevel.value = 'Senior';
      c.preferredLocation.value = 'Remote';

      c.complete();

      verify(
        mockStorage.write('jobPreferences', {
          'desiredRole': 'Developer',
          'experienceLevel': 'Senior',
          'preferredLocation': 'Remote',
        }),
      ).called(1);
    });

    test('hasCompletedPreferences returns correct value when stored', () {
      when(mockStorage.read<bool>('hasCompletedPreferences')).thenReturn(true);

      final c = PreferencesController(storage: mockStorage);
      c.onInit();

      expect(c.hasCompletedPreferences, isTrue);
    });

    test('selectRole sets desiredRole', () {
      final c = makeController();
      c.selectRole('Designer');
      expect(c.desiredRole.value, 'Designer');
    });

    test('selectLevel sets experienceLevel', () {
      final c = makeController();
      c.selectLevel('Senior');
      expect(c.experienceLevel.value, 'Senior');
    });

    test('selectLocation sets preferredLocation', () {
      final c = makeController();
      c.selectLocation('Remote');
      expect(c.preferredLocation.value, 'Remote');
    });

    test('goNext advances currentStep', () {
      final c = makeController();
      expect(c.currentStep.value, 0);

      c.goNext();
      expect(c.currentStep.value, 1);

      c.goNext();
      expect(c.currentStep.value, 2);
    });

    test('goNext does not advance past step 2', () {
      final c = makeController();
      c.currentStep.value = 2;
      c.goNext();
      expect(c.currentStep.value, 2);
    });

    test('goBack decrements currentStep', () {
      final c = makeController();
      c.currentStep.value = 2;
      c.goBack();
      expect(c.currentStep.value, 1);
    });

    test('goBack does not go below 0', () {
      final c = makeController();
      c.goBack();
      expect(c.currentStep.value, 0);
    });

    test('complete() resets currentStep to 0', () {
      final c = makeController();
      c.currentStep.value = 2;
      c.complete();
      expect(c.currentStep.value, 0);
    });
  });
}
