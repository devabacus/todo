// manifest: entity
// === generated_start:base ===
import 'package:drift/drift.dart';
import 'package:todo/core/services/logger/logger_service.dart';
import 'package:todo_client/todo_client.dart' as serverpod;
import 'package:uuid/uuid_value.dart';

import '../../../../../../core/data/datasources/local/database.dart';
import '../tables/extensions/category_table_extension.dart';
import '../../../models/category/category_model.dart';
import '../../../models/extensions/category_model_extension.dart';
import '../../../../../../core/data/datasources/local/database_types.dart';
import '../daos/category/category_dao.dart';
import '../interfaces/category_local_datasource_service.dart';

class CategoryLocalDataSource implements ICategoryLocalDataSource {
  final CategoryDao _categoryDao;
  final LoggerService logger;

  CategoryLocalDataSource(this._categoryDao, this.logger);

  @override
  Future<List<CategoryModel>> getCategories({
    required int userId,
    required String customerId,
  }) async {
    final categories = await _categoryDao.getCategories(
      userId: userId,
      customerId: customerId,
    );
    return categories.toModels();
  }

  @override
  Stream<List<CategoryModel>> watchCategories({
    required int userId,
    required String customerId,
  }) {
    return _categoryDao
        .watchCategories(userId: userId, customerId: customerId)
        .map((list) => list.toModels());
  }

  @override
  Future<CategoryModel?> getCategoryById(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    try {
      final category = await _categoryDao.getCategoryById(
        id,
        userId: userId,
        customerId: customerId,
      );
      return category?.toModel();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CategoryModel>> getCategoriesByIds(
    List<String> ids, {
    required int userId,
    required String customerId,
  }) async {
    final categoriesData = await _categoryDao.getCategoriesByIds(
      ids,
      userId: userId,
      customerId: customerId,
    );
    return categoriesData.toModels();
  }

  @override
  Future<String> createCategory(CategoryModel category) {
    final companion = category.toCompanion().copyWith(
      syncStatus: const Value(SyncStatus.local),
    );
    return _categoryDao.createCategory(companion);
  }

  @override
  Future<bool> updateCategory(CategoryModel category) {
    final companion = category.toCompanionWithId().copyWith(
      syncStatus: const Value(SyncStatus.local),
    );
    return _categoryDao.updateCategoryById(
      category.id,
      companion,
      userId: category.userId,
      customerId: category.customerId,
    );
  }

  @override
  Future<bool> deleteCategory(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    final companion = CategoryTableCompanion(
      isDeleted: Value(true),
      lastModified: Value(DateTime.now()),
      syncStatus: Value(SyncStatus.local),
    );
    final result = await _categoryDao.updateCategoryById(
      id,
      companion,
      userId: userId,
      customerId: customerId,
    );
    return result;
  }

  /// получаем из базы данных все записи, которые не синхронизированы
  @override
  Future<List<CategoryTableData>> getAllLocalChanges({
    required int userId,
    required String customerId,
  }) {
    return (_categoryDao.select(_categoryDao.categoryTable)..where(
          (t) =>
              (t.syncStatus.equals(SyncStatus.synced.name)).not() &
              t.userId.equals(userId) &
              t.customerId.equals(customerId),
        ))
        .get();
  }

  @override
  Future<void> physicallyDeleteCategory(
    String id, {
    required int userId,
    required String customerId,
  }) async {
    await _categoryDao.physicallyDeleteCategory(
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
    await _categoryDao.db
        .into(_categoryDao.categoryTable)
        .insertOnConflictUpdate(
          (serverChange as serverpod.Category).toCompanion(status),
        );
  }

  @override
  Future<List<CategoryTableData>> reconcileServerChanges(
    List<dynamic> serverChanges, {
    required int userId,
    required String customerId,
  }) async {
    final allLocalChanges = await getAllLocalChanges(
      userId: userId,
      customerId: customerId,
    );
    // создаем map где ключ - id, значение - CategoryTableData, это нужно для быстрого доступа к записям
    final localChangesMap = {for (var c in allLocalChanges) c.id: c};

    await _categoryDao.db.transaction(() async {
      for (final serverChange in serverChanges as List<serverpod.Category>) {
        // если серверная запись не принадлежит текущему пользователю и клиенту, то пропускаем
        if (serverChange.userId != userId ||
            serverChange.customerId.toString() != customerId) {
          continue;
        }

        // получаем локальную запись
        final localRecord =
            await (_categoryDao.select(_categoryDao.categoryTable)..where(
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
            await physicallyDeleteCategory(
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
    if (event is! serverpod.CategorySyncEvent) return;

    switch (event.type) {
      case serverpod.SyncEventType.create:
      case serverpod.SyncEventType.update:
        if (event.category != null &&
            event.category!.userId == userId &&
            event.category!.customerId == UuidValue.fromString(customerId)) {
          await insertOrUpdateFromServer(event.category!, SyncStatus.synced);
          logger.info(
            '  -> (Real-time) СОЗДАНА/ОБНОВЛЕНА: "${event.category!.id}"',
          );
        }
        break;
    }
  }

  // === generated_end:base ===
}
