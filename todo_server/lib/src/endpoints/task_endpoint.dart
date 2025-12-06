// manifest: entity
import 'package:serverpod/serverpod.dart';
import 'package:todo_server/src/generated/protocol.dart';
import 'shared/auth_context_mixin.dart';
import 'user_manager_endpoint.dart';

const _taskChannelBase = 'todo_task_events_for_user_';

class TaskEndpoint extends Endpoint with AuthContextMixin {
  
  Future<void> _notifyChange(Session session, TaskSyncEvent event, AuthenticatedUserContext authContext) async { 
    final channel = '$_taskChannelBase${authContext.userId}-${authContext.customerId.uuid}'; 
    await session.messages.postMessage(channel, event);
    session.log('🔔 Событие ${event.type.name} отправлено в канал "$channel"');
  }

  Future<Task> createTask(Session session, Task task) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final existingTask = await Task.db.findFirstRow(
      session,
      where: (c) => c.id.equals(task.id) & c.userId.equals(userId) & c.customerId.equals(customerId),
    );

    final serverTask = task.copyWith(
        userId: userId,
        customerId: customerId,
        lastModified: DateTime.now().toUtc(),
        isDeleted: false,
    );

    if (existingTask != null) {
      session.log('ℹ️ "createTask" вызван для существующего ID. Выполняется обновление (воскрешение).');
      final updatedTask = await Task.db.updateRow(session, serverTask);

      await _notifyChange(session, TaskSyncEvent(
          type: SyncEventType.update, 
          task: updatedTask,
      ), authContext); 
      return updatedTask;

    } else {
      final createdTask = await Task.db.insertRow(session, serverTask);
      await _notifyChange(session, TaskSyncEvent(
          type: SyncEventType.create,
          task: createdTask,
      ), authContext); 
      return createdTask;
    }
  }

  Future<List<Task>> getTasks(Session session, {int? limit}) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    return await Task.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
      limit: limit
    );
  }     

  Future<Task?> getTaskById(Session session, UuidValue id) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;
    
    return await Task.db.findFirstRow(
      session,
      where: (c) => c.id.equals(id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
  }

  Future<List<Task>> getTasksSince(Session session, DateTime? since) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    if (since == null) {
      return getTasks(session);
    }
    return await Task.db.find(
      session,
      where: (c) => c.userId.equals(userId) & c.customerId.equals(customerId) & (c.lastModified >= since),
      orderBy: (c) => c.lastModified,
    );
  }

  Future<bool> updateTask(Session session, Task task) async {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    // Проверяем наличие категории в базе сервера
    final originalTask = await Task.db.findFirstRow(
      session,
      where: (c) => c.id.equals(task.id) & c.userId.equals(userId) & c.customerId.equals(customerId) & c.isDeleted.equals(false),
    );
    // Если категории нет, возвращаем false
    if (originalTask == null) {
      return false; 
    }

    // если категория есть, 
    final serverTask = task.copyWith(
      userId: userId,
      customerId: customerId,
      lastModified: DateTime.now().toUtc(),
    );
    try {
      await Task.db.updateRow(session, serverTask);
      await _notifyChange(session, TaskSyncEvent(
        type: SyncEventType.update,
        task: serverTask,
      ), authContext);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Stream<TaskSyncEvent> watchEvents(Session session) async* {
    final authContext = await getAuthenticatedUserContext(session);
    final userId = authContext.userId;
    final customerId = authContext.customerId;

    final channel = '$_taskChannelBase$userId-${customerId.uuid}'; 
    session.log('🟢 Клиент (user: $userId, customer: ${customerId.uuid}) подписался на события в канале "$channel"');
    try {
      await for (var event in session.messages.createStream<TaskSyncEvent>(channel)) {
        session.log('🔄 Пересылаем событие ${event.type.name} клиенту (user: $userId, customer: ${customerId.uuid})');
        yield event;
      }
    } finally {
      session.log('🔴 Клиент (user: $userId, customer: ${customerId.uuid}) отписался от канала "$channel"');
    }
  }   
    
}          