// manifest: startProject
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

import '../../generated/protocol.dart';

mixin AuthContextMixin on Endpoint {
  /// Метод возвращает кортеж (userId, customerId)
  Future<({int userId, UuidValue customerId})> getAuthenticatedUserContext(
    Session session,
  ) async {
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован.');
    }

    // определяем клиента по id пользователя 
    final customerUser = await CustomerUser.db.findFirstRow(
      session,
      where: (cu) => cu.userId.equals(userId),
    );

    // Если пользователь не привязан ни к одному клиенту 
    if (customerUser == null) {
      throw Exception('Пользователь $userId не привязан ни к одному клиенту (customer).');
    }

    return (
      userId: userId,
      customerId: customerUser.customerId,
    );
  }
}