// manifest: entity
import 'package:serverpod/serverpod.dart';
import 'package:todo_server/src/generated/protocol.dart';
import 'shared/auth_context_mixin.dart';
import 'user_manager_endpoint.dart';

const _tagChannelBase = 'todo_tag_events_for_user_';

class TagEndpoint extends Endpoint with AuthContextMixin {
  
  Future<void> _notifyChange(Session session, TagSyncEvent event, AuthenticatedUserContext authContext) async { 
    final channel = '$_tagChannelBase${authContext.userId}-${authContext.customerId.uuid}'; 
    await session.messages.postMessage(channel, event);
    session.log('🔔 Событие ${event.type.name} отправлено в канал "$channel"');
  }

  Future<Tag> createTag(Session session, Tag tag) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final existingTag = await Tag.db.findFirstRow(
      session,
      where: (c) => c.id.equals(tag.id) & c.userId.equals(userId) & c.customerId.equals(customerId),
    );

    final serverTag = tag.copyWith(
        userId: userId,
        customerId: customerId,
        lastModified: DateTime.now().toUtc(),
        isDeleted: false,
    );

    if (existingTag != null) {
      session.log('ℹ️ "createTag" вызван для существующего ID. Выполняется обновление (воскрешение).');
      final updatedTag = await Tag.db.updateRow(session, serverTag);

      await _notifyChange(session, TagSyncEvent(
          type: SyncEventType.update, 
          tag: updatedTag,
      ), authContext); 
      return updatedTag;

    } else {
      final createdTag = await Tag.db.insertRow(session, serverTag);
      await _notifyChange(session, TagSyncEvent(
          type: SyncEventType.create,
          tag: createdTag,
      ), authContext); 
      return createdTag;
    }
  }

  Future<List<Tag>> getTags(Session session, {int? limit}) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    return await Tag.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
      limit: limit
    );
  }     

  Future<Tag?> getTagById(Session session, UuidValue id) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;
    
    return await Tag.db.findFirstRow(
      session,
      where: (c) => c.id.equals(id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
  }

  Future<List<Tag>> getTagsSince(Session session, DateTime? since) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    if (since == null) {
      return getTags(session);
    }
    return await Tag.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & (c.lastModified >= since),
      orderBy: (c) => c.lastModified,
    );
  }

  Future<bool> updateTag(Session session, Tag tag) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    // Проверяем наличие категории в базе сервера
    final originalTag = await Tag.db.findFirstRow(
      session,
      where: (c) => c.id.equals(tag.id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
    // Если категории нет, возвращаем false
    if (originalTag == null) {
      return false; 
    }

    // если категория есть, 
    final serverTag = tag.copyWith(
      userId: userId,
      customerId: customerId,
      lastModified: DateTime.now().toUtc(),
    );
    try {
      await Tag.db.updateRow(session, serverTag);
      await _notifyChange(session, TagSyncEvent(
        type: SyncEventType.update,
        tag: serverTag,
      ), authContext);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Stream<TagSyncEvent> watchEvents(Session session) async* {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final channel = '$_tagChannelBase$userId-${customerId.uuid}'; 
    session.log('🟢 Клиент (user: $userId, customer: ${customerId.uuid}) подписался на события в канале "$channel"');
    try {
      await for (var event in session.messages.createStream<TagSyncEvent>(channel)) {
        session.log('🔄 Пересылаем событие ${event.type.name} клиенту (user: $userId, customer: ${customerId.uuid})');
        yield event;
      }
    } finally {
      session.log('🔴 Клиент (user: $userId, customer: ${customerId.uuid}) отписался от канала "$channel"');
    }
  }   
    
}          