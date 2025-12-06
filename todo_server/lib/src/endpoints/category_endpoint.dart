// manifest: entity
import 'package:serverpod/serverpod.dart';
import 'package:todo_server/src/generated/protocol.dart';
import 'shared/auth_context_mixin.dart';
import 'user_manager_endpoint.dart';

const _categoryChannelBase = 'todo_category_events_for_user_';

class CategoryEndpoint extends Endpoint with AuthContextMixin {
  
  Future<void> _notifyChange(Session session, CategorySyncEvent event, AuthenticatedUserContext authContext) async { 
    final channel = '$_categoryChannelBase${authContext.userId}-${authContext.customerId.uuid}'; 
    await session.messages.postMessage(channel, event);
    session.log('🔔 Событие ${event.type.name} отправлено в канал "$channel"');
  }

  Future<Category> createCategory(Session session, Category category) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final existingCategory = await Category.db.findFirstRow(
      session,
      where: (c) => c.id.equals(category.id) & c.userId.equals(userId) & c.customerId.equals(customerId),
    );

    final serverCategory = category.copyWith(
        userId: userId,
        customerId: customerId,
        lastModified: DateTime.now().toUtc(),
        isDeleted: false,
    );

    if (existingCategory != null) {
      session.log('ℹ️ "createCategory" вызван для существующего ID. Выполняется обновление (воскрешение).');
      final updatedCategory = await Category.db.updateRow(session, serverCategory);

      await _notifyChange(session, CategorySyncEvent(
          type: SyncEventType.update, 
          category: updatedCategory,
      ), authContext); 
      return updatedCategory;

    } else {
      final createdCategory = await Category.db.insertRow(session, serverCategory);
      await _notifyChange(session, CategorySyncEvent(
          type: SyncEventType.create,
          category: createdCategory,
      ), authContext); 
      return createdCategory;
    }
  }

  Future<List<Category>> getCategories(Session session, {int? limit}) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    return await Category.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
      limit: limit
    );
  }     

  Future<Category?> getCategoryById(Session session, UuidValue id) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;
    
    return await Category.db.findFirstRow(
      session,
      where: (c) => c.id.equals(id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
  }

  Future<List<Category>> getCategoriesSince(Session session, DateTime? since) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    if (since == null) {
      return getCategories(session);
    }
    return await Category.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & (c.lastModified >= since),
      orderBy: (c) => c.lastModified,
    );
  }

  Future<bool> updateCategory(Session session, Category category) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    // Проверяем наличие категории в базе сервера
    final originalCategory = await Category.db.findFirstRow(
      session,
      where: (c) => c.id.equals(category.id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
    // Если категории нет, возвращаем false
    if (originalCategory == null) {
      return false; 
    }

    // если категория есть, 
    final serverCategory = category.copyWith(
      userId: userId,
      customerId: customerId,
      lastModified: DateTime.now().toUtc(),
    );
    try {
      await Category.db.updateRow(session, serverCategory);
      await _notifyChange(session, CategorySyncEvent(
        type: SyncEventType.update,
        category: serverCategory,
      ), authContext);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Stream<CategorySyncEvent> watchEvents(Session session) async* {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final channel = '$_categoryChannelBase$userId-${customerId.uuid}'; 
    session.log('🟢 Клиент (user: $userId, customer: ${customerId.uuid}) подписался на события в канале "$channel"');
    try {
      await for (var event in session.messages.createStream<CategorySyncEvent>(channel)) {
        session.log('🔄 Пересылаем событие ${event.type.name} клиенту (user: $userId, customer: ${customerId.uuid})');
        yield event;
      }
    } finally {
      session.log('🔴 Клиент (user: $userId, customer: ${customerId.uuid}) отписался от канала "$channel"');
    }
  }   
    
}          