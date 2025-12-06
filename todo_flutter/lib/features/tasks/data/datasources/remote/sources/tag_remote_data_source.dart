// manifest: entity
import 'dart:async';
import 'package:todo_client/todo_client.dart';
import '../interfaces/tag_remote_datasource_service.dart';

class TagRemoteDataSource implements ITagRemoteDataSource {
  final Client _client;

  TagRemoteDataSource(this._client);

  @override
  Future<List<Tag>> getTags() async {
    try {
      final tags = await _client.tag.getTags();
      return tags;
    } catch (e) {
      print('Ошибка получения: $e');
      rethrow;
    }
  }

  @override
  Future<List<Tag>> getTagsSince(DateTime? since) async {
    try {
      final tags = await _client.tag.getTagsSince(since);
      return tags;
    } catch (e) {
      print('Ошибка получения c $since: $e');
      rethrow;
    }
  }

  @override
  Future<Tag?> getTagById(UuidValue id) async {
    try {
      final tag = await _client.tag.getTagById(id);
      return tag;
    } catch (e) {
      print('Ошибка получения по ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    print('🚀 Remote: Отправляем на сервер: ${_client.host}');

    try {
      final result = await _client.tag.createTag(tag);
      print('✅ Remote: Успешно создано на сервере');
      return result;
    } catch (e) {
      print('❌ Remote: Ошибка создания на сервере: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateTag(Tag tag) async {
    try {
      final result = await _client.tag.updateTag(tag);
      return result;
    } catch (e) {
      print('Ошибка обновления: $e');
      rethrow;
    }
  }

  @override
  Stream<TagSyncEvent> watchEvents() {
    try {
      return _client.tag.watchEvents();
    } catch (e) {
      print('❌ Ошибка подписки на события сервера: $e');
      return Stream.value(TagSyncEvent(type: SyncEventType.create));
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      await _client.tag.getTags(limit: 1);
      return true;
    } catch (e) {
      print('Проверка подключения неудачна: $e');
      return false;
    }
  }

  @override
  Future<List<Tag>> syncTags(List<Tag> localTags) async {
    try {
      final serverTags = await getTags();

      print(
        'Синхронизация: локальных ${localTags.length}, серверных ${serverTags.length}',
      );
      return serverTags;
    } catch (e) {
      print('Ошибка синхронизации: $e');
      return localTags;
    }
  }
}

