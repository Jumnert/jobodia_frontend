import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';

import 'cv_builder_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetStorage>(), MockSpec<ImagePicker>()])
void main() {
  late MockGetStorage mockStorage;
  late MockImagePicker mockPicker;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();
    mockPicker = MockImagePicker();

    when(mockStorage.read(any)).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  CvBuilderController makeController() {
    final c = CvBuilderController(storage: mockStorage, picker: mockPicker);
    // Do NOT call onInit -- it requires SecureStorageService and
    // ProfileController which are not available in unit tests.
    return c;
  }

  group('CvBuilderController', () {
    group('validation', () {
      test('generateCv sets error when full name is empty', () {
        final c = makeController();
        c.fullNameController.text = '';
        c.workExperiences.first.companyController.text = 'Acme';

        c.generateCv();

        expect(c.generateError.value, contains('full name'));
        expect(c.isGenerated.value, isFalse);
      });

      test('generateCv sets error when no work/edu entries have content', () {
        final c = makeController();
        c.fullNameController.text = 'John Doe';

        c.generateCv();

        expect(c.generateError.value, contains('work experience or education'));
        expect(c.isGenerated.value, isFalse);
      });
    });

    test('nextStep advances stepIndex', () {
      final c = makeController();
      expect(c.stepIndex.value, 0);

      c.nextStep();
      expect(c.stepIndex.value, 1);

      c.nextStep();
      expect(c.stepIndex.value, 2);
    });

    test('nextStep at step 2 triggers generateCv', () {
      final c = makeController();
      c.stepIndex.value = 2;
      c.fullNameController.text = '';
      c.nextStep();
      expect(c.stepIndex.value, 2);
      expect(c.generateError.value, isNotEmpty);
    });

    test('previousStep goes back', () {
      final c = makeController();
      c.stepIndex.value = 2;
      c.previousStep();
      expect(c.stepIndex.value, 1);
      c.previousStep();
      expect(c.stepIndex.value, 0);
    });

    test('previousStep does not go below 0', () {
      final c = makeController();
      c.previousStep();
      expect(c.stepIndex.value, 0);
    });

    test('selectTemplate updates selectedTemplateIndex', () {
      final c = makeController();
      expect(c.selectedTemplateIndex.value, 0);

      c.selectTemplate(2);
      expect(c.selectedTemplateIndex.value, 2);
    });

    test('addSkill and removeSkill manage the skills list', () {
      final c = makeController();
      c.skillController.text = 'Flutter';
      c.addSkill();
      expect(c.skills, contains('Flutter'));

      c.removeSkill('Flutter');
      expect(c.skills, isEmpty);
    });

    test('addSkill ignores duplicates', () {
      final c = makeController();
      c.skillController.text = 'Flutter';
      c.addSkill();
      c.skillController.text = 'Flutter';
      c.addSkill();
      expect(c.skills.length, 1);
    });

    test('addSkill ignores empty input', () {
      final c = makeController();
      c.skillController.text = '';
      c.addSkill();
      expect(c.skills, isEmpty);
    });

    test('addWorkExperience adds an entry', () {
      final c = makeController();
      expect(c.workExperiences.length, 1);
      c.addWorkExperience();
      expect(c.workExperiences.length, 2);
    });

    test('addEducation adds an entry', () {
      final c = makeController();
      expect(c.educations.length, 1);
      c.addEducation();
      expect(c.educations.length, 2);
    });

    test('validation helper checks name presence', () {
      final c = makeController();
      // Empty name + empty work/edu => first error is name
      c.fullNameController.text = '';
      c.generateCv();
      expect(c.generateError.value, contains('full name'));
    });

    test('validation requires at least one work or education entry', () {
      final c = makeController();
      c.fullNameController.text = 'Valid Name';
      // No work or education content.
      c.generateCv();
      expect(c.generateError.value, contains('work experience or education'));
    });

    test('validation passes with name and work experience', () {
      final c = makeController();
      c.fullNameController.text = 'Valid Name';
      c.workExperiences.first.companyController.text = 'Acme';
      c.workExperiences.first.roleController.text = 'Developer';

      // generateCv will try to call SecureStorageService.to which is not
      // registered, so it will throw. But validation should pass — the
      // generateError should be empty after _validate returns null.
      // We can't fully test generateCv without registering SecureStorageService,
      // but we can verify the validation logic directly by checking the error
      // state stays empty up to the persist step.
      try {
        c.generateCv();
      } catch (_) {
        // Expected: SecureStorageService not found.
      }

      // generateError was set to '' before the persist call.
      expect(c.generateError.value, isEmpty);
    });
  });
}
