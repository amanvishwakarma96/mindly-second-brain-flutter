import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/features/text_capture/application/text_capture_service.dart';
import 'package:mindly/features/text_capture/data/ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/screens/desktop/capture/desktop_text_capture_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_text_capture_screen.dart';
import 'package:mindly/screens/web/capture/web_text_capture_screen.dart';

import '../helpers/in_memory_secret_store.dart';

void main() {
  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileTextCaptureScreen.screenKey,
    ScreenFamily.desktop: DesktopTextCaptureScreen.screenKey,
    ScreenFamily.web: WebTextCaptureScreen.screenKey,
  }.entries) {
    testWidgets('${entry.key.name} routes to its own text capture screen', (
      tester,
    ) async {
      final database = MindlyDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final store = InMemorySecretStore();
      final spendStore = SecureSpendStore(store);
      final controller = TextCaptureController(
        TextCaptureService(
          memoryRepository: MemoryRepository(database),
          keyService: ProviderKeyService(
            repository: ProviderKeyRepository(store),
            isWeb: entry.key == ScreenFamily.web,
          ),
          capsRepository: spendStore,
          spendLedger: spendStore,
          spendGuard: SpendGuard(spendStore),
          costEstimator: const CostEstimator(),
          transport: const _NeverCalledTransport(),
        ),
      );

      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          textCaptureControllerOverride: controller,
        ),
      );
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.textCapture);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
      final otherKeys = <Key>{
        MobileTextCaptureScreen.screenKey,
        DesktopTextCaptureScreen.screenKey,
        WebTextCaptureScreen.screenKey,
      }..remove(entry.value);
      for (final key in otherKeys) {
        expect(find.byKey(key), findsNothing);
      }
    });
  }
}

class _NeverCalledTransport implements AiProviderTransport {
  const _NeverCalledTransport();

  @override
  Future<AiProviderResponse> extract({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
  }) {
    throw StateError('Transport should not run while testing route selection.');
  }
}
