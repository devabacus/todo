// manifest: entity
// === generated_start:base ===
import 'package:drift/drift.dart';
import 'package:todo/core/services/logger/logger_service.dart';
import 'package:todo_client/todo_client.dart' as serverpod;
import 'package:uuid/uuid_value.dart';

import '../../../../../../core/data/datasources/local/database.dart';
import '../tables/extensions/task_table_extension.dart';
import '../../../models/task/task_model.dart';
import '../../../models/extensions/task_model_extension.dart';
import '../../../../../../core/data/datasources/local/database_types.dart';
import '../daos/task/task_dao.dart';
import '../interfaces/task_local_datasource_service.dart';

class TaskLocalDataSource implements ITaskLocalDataSource {
  final TaskDao _taskDao;
  final LoggerService logger;

  TaskLocalDataSource(this._taskDao, this.logger);

  @override
  Future<List<TaskModel>> getTasks({
    required int userId,
    required String customerId,
  }) async {
    final tasks = await _taskDao.getTasks(
      userId: userId,
      customerId: customerId,
    );
    return tasks.toModels();
  }

  @override
  Stream<List<TaskModel>> watchTasks({
    required int userId,
    required String customerId,
  }) {
    return _taskDao
        .watchTasks(userId: userId, customerId: customerId)
        .map((list) => list.toModels());
  }

  @override
  Future<TaskModel?> getTaskById(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    try {
      final task = await _taskDao.getTaskById(
        id,
        userId: userId,
        customerId: customerId,
      );
      return task?.toModel();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByIds(
    List<String> ids, {
    required int userId,
    required String customerId,
  }) async {
    final tasksData = await _taskDao.getTasksByIds(
      ids,
      userId: userId,
      customerId: customerId,
    );
    return tasksData.toModels();
  }

  @override
  Future<String> createTask(TaskModel task) {
    final companion = task.toCompanion().copyWith(
      syncStatus: const Value(SyncStatus.local),
    );
    return _taskDao.createTask(companion);
  }

  @override
  Future<bool> updateTask(TaskModel task) {
    final companion = task.toCompanionWithId().copyWith(
      syncStatus: const Value(SyncStatus.local),
    );
    return _taskDao.updateTaskById(
      task.id,
      companion,
      userId: task.userId,
      customerId: task.customerId,
    );
  }

  @override
  Future<bool> deleteTask(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    final companion = TaskTableCompanion(
      isDeleted: Value(true),
      lastModified: Value(DateTime.now()),
      syncStatus: Value(SyncStatus.local),
    );
    final result = await _taskDao.updateTaskById(
      id,
      companion,
      userId: userId,
      customerId: customerId,
    );
    return result;
  }

  /// получаем из базы данных все записи, которые не синхронизированы
  @override
  Future<List<TaskTableData>> getAllLocalChanges({
    required int userId,
    required String customerId,
  }) {
    return (_taskDao.select(_taskDao.taskTable)..where(
          (t) =>
              (t.syncStatus.equals(SyncStatus.synced.name)).not() &
              t.userId.equals(userId) &
              t.customerId.equals(customerId),
        ))
        .get();
  }

  @override
  Future<void> physicallyDeleteTask(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    await _taskDao.physicallyDeleteTask(
      id,
      userId: userId,
      customerId: customerId,
    );
  }

  @override
  Future<void> insertOrUpdateFromServer(
    dynamic serverChange,
    SyncStatus status,
  ) async {
    await _taskDao.db
        .into(_taskDao.taskTable)
        .insertOnConflictUpdate(
          (serverChange as serverpod.Task).toCompanion(status),
        );
  }

  @override
  Future<List<TaskTableData>> reconcileServerChanges(
    List<dynamic> serverChanges, {
    required int userId,
    required String customerId,
  }) async {
    final allLocalChanges = await getAllLocalChanges(
      userId: userId,
      customerId: customerId,
    );
    // создаем map где ключ - id, значение - TaskTableData, это нужно для быстрого доступа к записям
    final localChangesMap = {for (var c in allLocalChanges) c.id: c};

    await _taskDao.db.transaction(() async {
      for (final serverChange in serverChanges as List<serverpod.Task>) {
        // если серверная запись не принадлежит текущему пользователю и клиенту, то пропускаем
        if (serverChange.userId != userId ||
            serverChange.customerId.toString() != customerId) {
          continue;
        }

        // получаем локальную запись
        final localRecord =
            await (_taskDao.select(_taskDao.taskTable)..where(
                  (t) =>
                      t.id.equals(serverChange.id.toString()) &
                      t.userId.equals(userId) &
                      t.customerId.equals(customerId),
                ))
                .getSingleOrNull();

        // если локальной записи нет, то создаем и сразу ставим статус synced
        if (localRecord == null) {
          if (!serverChange.isDeleted) {
            await insertOrUpdateFromServer(serverChange, SyncStatus.synced);
            logger.info('    -> СОЗДАНО с сервера: "${serverChange.id}"');
          }
          continue;
        }

        // получаем время последнего изменения локальной и серверной записей
        final serverTime = serverChange.lastModified;
        final localTime = localRecord.lastModified;

        // если серверная запись удалена
        if (serverChange.isDeleted) {
          if (localTime.isAfter(serverTime) &&
              localRecord.syncStatus == SyncStatus.local) {
            logger.info(
              '    -> КОНФЛИКТ: Локальная версия "${localRecord.id}" новее серверного "надгробия". Локальное изменение побеждает.',
            );
          } else {
            logger.info(
              '    -> ✅ Серверное "надгробие" новее или нет локального конфликта. Удаляем локальную запись: ID=${localRecord.id}, Title="${localRecord.id}".',
            );
            await physicallyDeleteTask(
              localRecord.id,
              userId: userId,
              customerId: customerId,
            );
            localChangesMap.remove(localRecord.id);
          }
          
        } else { // если серверная запись не удалена
        // если локальная запись создана не синхронизирована или удалена
          if (localRecord.syncStatus == SyncStatus.local ||
              localRecord.isDeleted) {
            if (serverTime.isAfter(localTime)) {
              logger.info(
                '    -> КОНФЛИКТ: Сервер новее для "${serverChange.id}". Применяем серверные изменения.',
              );
              await insertOrUpdateFromServer(serverChange, SyncStatus.synced);
              localChangesMap.remove(localRecord.id);
            } else {
              
              logger.info(
                '    -> КОНФЛИКТ: Локальная версия новее для "${localRecord.id}". Она будет отправлена на сервер.',
              );
            }
          } else {
            await insertOrUpdateFromServer(serverChange, SyncStatus.synced);
            logger.info('    -> ОБНОВЛЕНО с сервера: "${serverChange.id}"');
          }
        }
      }
    });
    return localChangesMap.values.toList();
  }

  @override
  Future<void> handleSyncEvent(
    dynamic event, {
    required int userId,
    required String customerId,
  }) async {
    if (event is! serverpod.TaskSyncEvent) return;

    switch (event.type) {
      case serverpod.SyncEventType.create:
      case serverpod.SyncEventType.update:
        if (event.task != null &&
            event.task!.userId == userId &&
            event.task!.customerId == UuidValue.fromString(customerId)) {
          await insertOrUpdateFromServer(event.task!, SyncStatus.synced);
          logger.info(
            '  -> (Real-time) СОЗДАНА/ОБНОВЛЕНА: "${event.task!.id}"',
          );
        }
        break;
    }
  }

  // === generated_end:base ===
}
