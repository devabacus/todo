// manifest: entity
import 'dart:async';
import 'package:todo_client/todo_client.dart';
import '../interfaces/category_remote_datasource_service.dart';

class CategoryRemoteDataSource implements ICategoryRemoteDataSource {
  final Client _client;

  CategoryRemoteDataSource(this._client);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final categories = await _client.category.getCategories();
      return categories;
    } catch (e) {
      print('Ошибка получения: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesSince(DateTime? since) async {
    try {
      final categories = await _client.category.getCategoriesSince(since);
      return categories;
    } catch (e) {
      print('Ошибка получения c $since: $e');
      rethrow;
    }
  }

  @override
  Future<Category?> getCategoryById(UuidValue id) async {
    try {
      final category = await _client.category.getCategoryById(id);
      return category;
    } catch (e) {
      print('Ошибка получения по ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    print('🚀 Remote: Отправляем на сервер: ${_client.host}');

    try {
      final result = await _client.category.createCategory(category);
      print('✅ Remote: Успешно создано на сервере');
      return result;
    } catch (e) {
      print('❌ Remote: Ошибка создания на сервере: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateCategory(Category category) async {
    try {
      final result = await _client.category.updateCategory(category);
      return result;
    } catch (e) {
      print('Ошибка обновления: $e');
      rethrow;
    }
  }

  @override
  Stream<CategorySyncEvent> watchEvents() {
    try {
      return _client.category.watchEvents();
    } catch (e) {
      print('❌ Ошибка подписки на события сервера: $e');
      return Stream.value(CategorySyncEvent(type: SyncEventType.create));
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      await _client.category.getCategories(limit: 1);
      return true;
    } catch (e) {
      print('Проверка подключения неудачна: $e');
      return false;
    }
  }

  @override
  Future<List<Category>> syncCategories(List<Category> localCategories) async {
    try {
      final serverCategories = await getCategories();

      print(
        'Синхронизация: локальных ${localCategories.length}, серверных ${serverCategories.length}',
      );
      return serverCategories;
    } catch (e) {
      print('Ошибка синхронизации: $e');
      return localCategories;
    }
  }
}

