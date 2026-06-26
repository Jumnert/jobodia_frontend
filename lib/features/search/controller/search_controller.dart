import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class JobSearchController extends GetxController {
  JobSearchController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const _recentsKey = 'recentSearches';
  static const _maxRecents = 5;
  final GetStorage _storage;

  final recentSearches = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void addSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    recentSearches.remove(q); // dedupe
    recentSearches.insert(0, q);
    if (recentSearches.length > _maxRecents) {
      recentSearches.removeRange(_maxRecents, recentSearches.length);
    }
    _persist();
  }

  void removeSearch(String query) {
    recentSearches.remove(query);
    _persist();
  }

  void clearAll() {
    recentSearches.clear();
    _persist();
  }

  void _load() {
    final stored = _storage.read<List>(_recentsKey)?.cast<String>() ?? [];
    recentSearches.assignAll(stored);
  }

  void _persist() {
    _storage.write(_recentsKey, recentSearches.toList());
  }
}
