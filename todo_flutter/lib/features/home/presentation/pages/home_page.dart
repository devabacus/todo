// manifest: startProject

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/services/logger/logger_provider.dart';

import '../../../../core/providers/serverpod_client_provider.dart';
import '../../../auth/domain/providers/auth_usecase_providers.dart';
import '../../../auth/presentation/providers/auth_state_providers.dart';
import '../../../configuration/presentation/routing/configuration_routes_constants.dart';
import '../widgets/settings_display_section.dart';
import '../widgets/simple_file_upload.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {


  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    final client = ref.watch(serverpodClientProvider);
    final logger = ref.watch(loggerServiceProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('T2 Demo')),
        body: const Center(child: Text('Пожалуйста, войдите в систему')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('T2 Demo Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: () {
              context.push(ConfigurationRoutes.configurationPath);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выход',
            onPressed: () async {
              await ref.read(signOutUseCaseProvider)();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Добавляем виджет загрузки файлов
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тест загрузки файлов',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SimpleFileUpload(client: client, logger: logger),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Остальные виджеты
            const SettingsDisplaySection(),
          ],
        ),
      ),
    );
  }
}
