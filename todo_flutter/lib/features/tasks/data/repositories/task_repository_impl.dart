// manifest: entity
// === generated_start:base ===
import '../../domain/entities/extensions/task_entity_extension.dart';
import '../../data/datasources/local/tables/extensions/task_table_extension.dart';
import 'package:todo_client/todo_client.dart' as serverpod;

import '../../../../core/data/datasources/local/database.dart';
import '../../../../core/sync/base_sync_repository.dart';
import '../../domain/entities/task/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../core/data/datasources/local/database_types.dart';
import '../datasources/local/interfaces/task_local_datasource_service.dart';
import '../../../../core/data/datasources/local/interfaces/sync_metadata_local_datasource_service.dart';
import '../datasources/remote/interfaces/task_remote_datasource_service.dart';
import '../models/extensions/task_model_extension.dart';
import '../../../../core/services/logger/logger_service.dart';

class TaskRepositoryImpl extends BaseSyncRepository
    implements ITaskRepository {
  final ITaskLocalDataSource _localDataSource;
  final ITaskRemoteDataSource _remoteDataSource;

  @override
  String get entityTypeName => 'Task';
  @override
  String get entityType => 'tasks_user_$userId';

  TaskRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    ISyncMetadataLocalDataSource syncMetadataDataSource,
    LoggerService logger,
    int userId,
    String customerId,
  ) : super(
        userId,
        customerId,
        syncMetadataDataSource: syncMetadataDataSource,
        logger: logger,
      ) {
    logger.info(
      '✅ TaskRepositoryImpl: Создан экземпляр для userId: $userId',
    );
    initEventBasedSync();
  }

  @override
  Future<List<serverpod.Task>> getChangesFromServer(DateTime? since) {
    return _remoteDataSource.getTasksSince(since);
  }

  @override
  Future<List<dynamic>> reconcileChanges(List<dynamic> serverChanges) async {
    return _localDataSource.reconcileServerChanges(
      serverChanges,
      userId: userId,
      customerId: customerId,
    );
  }

  @override
  Future<void> pushLocalChanges(List<dynamic> localChangesToPush) async {
    for (final localChange in localChangesToPush as List<TaskTableData>) {
      if (localChange.isDeleted) {
        try {
          // если запись локально удалена, то сначала отправляем на сервер
          await _syncUpdateToServer(localChange.toModel().toEntity());
          // затем физически удаляем
          await _localDataSource.physicallyDeleteTask(
            localChange.id,
            userId: userId,
            customerId: customerId,
          );
          logger.info(
            '    -> ✅ Удаление "${localChange.id}" синхронизировано с сервером.',
          );
        } catch (e, st) {
          logger.error(
            '    -> ⚠️ Не удалось синхронизировать удаление ID: ${localChange.id}. Повторим позже.',
            e,
            st,
          );
        }
      } else if (localChange.syncStatus == SyncStatus.local) {
        try {
          // это самый простой сценарий, когда локальная запись просто создана
          final entity = localChange.toModel().toEntity();
          final serverRecord = await _remoteDataSource.getTaskById(
            serverpod.UuidValue.fromString(entity.id),
          );
          if (serverRecord != null && !serverRecord.isDeleted) {
            // если запись существует на сервере, то обновляем
            await _syncUpdateToServer(entity);
          } else {
            // если записи нет на сервере, то создаем
            await _syncCreateToServer(entity);
          }
          logger.info(
            '    -> ✅ Изменение "${localChange.id}" синхронизировано с сервером.',
          );
        } catch (e, st) {
          logger.error(
            '    -> ⚠️ Не удалось синхронизировать изменение ID: ${localChange.id}. Повторим позже.',
            e,
            st,
          );
        }
      }
    }
  }

  @override
  Stream<serverpod.TaskSyncEvent> watchEvents() =>
      _remoteDataSource.watchEvents();

  @override
  Future<void> handleSyncEvent(dynamic event) async {
    await _localDataSource.handleSyncEvent(
      event,
      userId: userId,
      customerId: customerId,
    );
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return _localDataSource
        .watchTasks(userId: userId, customerId: customerId)
        .map((models) => models.toEntities());
  }

  @override
  Future<String> createTask(TaskEntity task) async {
    final taskWithUser = task.copyWith(
      userId: userId,
      customerId: customerId,
      lastModified: DateTime.now().toUtc(),
    );
    final id = await _localDataSource.createTask(
      taskWithUser.toModel(),
    );
    syncWithServer().catchError(
      (e, st) => logger.error(
        '⚠️ Фоновая синхронизация после создания не удалась',
        e,
        st,
      ),
    );
    return id;
  }

  @override
  Future<bool> updateTask(TaskEntity task) async {
    logger.info('🚀 Обновление категории ${task.id}');
    // накидываем пользователя клиента и текущее время
    final taskWithUser = task.copyWith(
      userId: userId,
      customerId: customerId,
      lastModified: DateTime.now().toUtc(),
    );
    // обновляем локально
    final result = await _localDataSource.updateTask(
      taskWithUser.toModel(),
    );
    // запускаем фоновую синхронизацию, сразу не можем пушать, потому что могли быть изменения на сервере. Конфликты разрешаются в отдельном методе reconcileChanges
    syncWithServer().catchError(
      (e, st) => logger.error(
        '⚠️ Фоновая синхронизация после обновления не удалась',
        e,
        st,
      ),
    );
    return result;
  }

  @override
  Future<bool> deleteTask(String id) async {
    final result = await _localDataSource.deleteTask(
      id,
      userId: userId,
      customerId: customerId,
    );
    syncWithServer().catchError(
      (e, st) => logger.error(
        '⚠️ Фоновая синхронизация после удаления не удалась',
        e,
        st,
      ),
    );
    return result;
  }

  @override
  Future<List<TaskEntity>> getTasks() async => _localDataSource
      .getTasks(userId: userId, customerId: customerId)
      .then((models) => models.toEntities());

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final model = await _localDataSource.getTaskById(
      id,
      userId: userId,
      customerId: customerId,
    );
    return model?.toEntity();
  }

  @override
  Future<List<TaskEntity>> getTasksByIds(List<String> ids) async {
    ;
    final models = await _localDataSource.getTasksByIds(
      ids,
      userId: userId,
      customerId: customerId,
    );
    return models.toEntities();
  }

  Future<void> _syncCreateToServer(TaskEntity task) async {
    try {
      final serverTask = task.toServerpodTask();
      final syncedTask = await _remoteDataSource.createTask(
        serverTask,
      );
      await _localDataSource.insertOrUpdateFromServer(
        syncedTask,
        SyncStatus.synced,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncUpdateToServer(TaskEntity task) async {
    try {
      final serverTask = task.toServerpodTask();
      await _remoteDataSource.updateTask(serverTask);
      await _localDataSource.insertOrUpdateFromServer(
        serverTask,
        SyncStatus.synced,
      );
    } catch (e) {
      rethrow;
    }
  }

  // === generated_end:base ===
}
