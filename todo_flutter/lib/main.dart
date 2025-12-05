// manifest: startProject

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todo/features/configuration/domain/providers/configuration/configuration_dependencies_provider.dart';
import 'package:todo/features/configuration/presentation/user_settings/groups/groups_list.dart';
import 'package:todo/core/dependencies/configuration_dependencies_impl.dart';
import 'package:todo/features/settings_definitions/app_groups_list.dart';

import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // подгружаем переменные окружения
  await dotenv.load(fileName: ".env");

  // Создаём список групп настроек напрямую (без временного контейнера)
  final appGroups = createAppSettingGroups();

  runApp(
    ProviderScope(
      overrides: [
        // 1. Внедряем реализацию зависимостей (БД, Serverpod)
        configurationDependenciesProvider.overrideWith(
          (ref) => ConfigurationDependenciesImpl(ref),
        ),
        // 2. Внедряем конкретный список групп настроек вместо заглушки
        settingGroupsProvider.overrideWithValue(appGroups),
      ],
      child: App(),
    ),
  );
}
