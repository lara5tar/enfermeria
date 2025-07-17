import 'package:get/get.dart';

class SearchController extends GetxController {
  final searchQuery = ''.obs;
  final searchResults = <String>[].obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    performSearch();
  }

  void performSearch() {
    // Lógica de búsqueda aquí
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    // Simulación de resultados de búsqueda
    searchResults.value = [
      'Resultado 1: ${searchQuery.value}',
      'Resultado 2: ${searchQuery.value}',
      'Resultado 3: ${searchQuery.value}',
    ];
  }
}
