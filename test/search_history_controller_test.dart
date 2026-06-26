import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/search/controller/search_controller.dart';

import 'search_history_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetStorage>()])
void main() {
  late MockGetStorage mockStorage;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();

    when(mockStorage.read<List>('recentSearches')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  group('JobSearchController (search history)', () {
    JobSearchController makeController() {
      final c = JobSearchController(storage: mockStorage);
      c.onInit();
      return c;
    }

    test('initial state — empty recent searches', () {
      final c = makeController();
      expect(c.recentSearches, isEmpty);
    });

    test('addSearch adds a query to the list', () {
      final c = makeController();
      c.addSearch('Flutter developer');
      expect(c.recentSearches.length, 1);
      expect(c.recentSearches.first, 'Flutter developer');
    });

    test('addSearch inserts most recent first', () {
      final c = makeController();
      c.addSearch('first');
      c.addSearch('second');

      expect(c.recentSearches.first, 'second');
      expect(c.recentSearches.last, 'first');
    });

    test('addSearch deduplicates existing queries', () {
      final c = makeController();
      c.addSearch('Flutter');
      c.addSearch('Dart');
      c.addSearch('Flutter'); // duplicate

      expect(c.recentSearches.length, 2);
      expect(c.recentSearches.first, 'Flutter'); // moved to front
      expect(c.recentSearches.last, 'Dart');
    });

    test('addSearch trims whitespace', () {
      final c = makeController();
      c.addSearch('  Flutter  ');
      expect(c.recentSearches.first, 'Flutter');
    });

    test('addSearch ignores empty queries', () {
      final c = makeController();
      c.addSearch('');
      c.addSearch('   ');
      expect(c.recentSearches, isEmpty);
    });

    test('addSearch maintains max 5 entries', () {
      final c = makeController();
      c.addSearch('one');
      c.addSearch('two');
      c.addSearch('three');
      c.addSearch('four');
      c.addSearch('five');
      c.addSearch('six');

      expect(c.recentSearches.length, 5);
      expect(c.recentSearches.first, 'six');
      expect(c.recentSearches.contains('one'), isFalse); // oldest evicted
    });

    test('removeSearch removes a specific query', () {
      final c = makeController();
      c.addSearch('Flutter');
      c.addSearch('Dart');
      c.removeSearch('Flutter');

      expect(c.recentSearches.length, 1);
      expect(c.recentSearches.first, 'Dart');
    });

    test('clearAll empties the list', () {
      final c = makeController();
      c.addSearch('Flutter');
      c.addSearch('Dart');
      c.clearAll();

      expect(c.recentSearches, isEmpty);
    });

    test('operations persist to storage', () {
      final c = makeController();
      c.addSearch('Flutter');
      verify(mockStorage.write('recentSearches', any)).called(1);
    });

    test('loads stored searches on init', () {
      when(
        mockStorage.read<List>('recentSearches'),
      ).thenReturn(['stored1', 'stored2']);

      final c = JobSearchController(storage: mockStorage);
      c.onInit();

      expect(c.recentSearches.length, 2);
      expect(c.recentSearches, ['stored1', 'stored2']);
    });
  });
}
