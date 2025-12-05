// manifest: startProject

import 'package:todo/features/configuration/presentation/user_settings/groups/groups_list.dart';

import 'audio_settings.dart';
import 'profile_settings.dart';
import 'ui_settings.dart';

/// Функция, которая создаёт список групп настроек для приложения.
List<SettingGroup> createAppSettingGroups() {
  return [
    SettingGroup(
      key: 'UI',
      displayName: 'Интерфейс',
      definitions: getUiSettings,
    ),
    SettingGroup(
      key: 'Profile',
      displayName: 'Профиль',
      definitions: getProfileSettings,
    ),
    SettingGroup(
      key: 'Audio',
      displayName: 'Аудио',
      definitions: getAudioSettings,
    ),
  ];
}
