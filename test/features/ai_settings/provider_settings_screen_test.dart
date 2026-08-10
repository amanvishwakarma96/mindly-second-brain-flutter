import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/web_key_warning.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_provider_settings_screen.dart';
import 'package:mindly/screens/web/settings/web_provider_settings_screen.dart';

import '../../helpers/in_memory_secret_store.dart';

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
  testWidgets('web settings show exact key warning before key acceptance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebProviderSettingsScreen(controller: _controller(isWeb: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(webApiKeyWarning), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save / rotate key'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save / rotate key'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('native settings do not show the web-only key warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MobileProviderSettingsScreen(
          controller: _controller(isWeb: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(webApiKeyWarning), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: DesktopProviderSettingsScreen(
          controller: _controller(isWeb: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(webApiKeyWarning), findsNothing);
  });
}
