import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_provider_settings_screen.dart';
import 'package:mindly/screens/web/settings/web_provider_settings_screen.dart';

import '../helpers/in_memory_secret_store.dart';

ProviderSettingsController _controller({required bool isWeb}) {
  final store = InMemorySecretStore();
  return ProviderSettingsController(
    keyService: ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: isWeb,
    ),
    capsRepository: SecureSpendStore(store),
  );
}

void main() {
  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileProviderSettingsScreen.screenKey,
    ScreenFamily.desktop: DesktopProviderSettingsScreen.screenKey,
    ScreenFamily.web: WebProviderSettingsScreen.screenKey,
  }.entries) {
    testWidgets(
      '${entry.key.name} routes to its own provider settings screen',
      (tester) async {
        await tester.pumpWidget(
          MindlyApp(
            screenFamilyOverride: entry.key,
            providerSettingsControllerOverride: _controller(
              isWeb: entry.key == ScreenFamily.web,
            ),
          ),
        );
        Navigator.of(
          tester.element(find.byType(Scaffold).first),
        ).pushNamed(AppRoutes.providerSettings);
        await tester.pumpAndSettle();

        expect(find.byKey(entry.value), findsOneWidget);
      },
    );
  }
}
