import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/screens/desktop/insights/desktop_insights_screen.dart';
import 'package:mindly/screens/mobile/insights/mobile_insights_screen.dart';
import 'package:mindly/screens/web/insights/web_insights_screen.dart';

void main() {
  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileInsightsScreen.screenKey,
    ScreenFamily.desktop: DesktopInsightsScreen.screenKey,
    ScreenFamily.web: WebInsightsScreen.screenKey,
  }.entries) {
    testWidgets('${entry.key.name} routes to its own insights screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          insightControllerOverride: const _FakeInsightController(),
        ),
      );
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.insights);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
      final otherKeys = <Key>{
        MobileInsightsScreen.screenKey,
        DesktopInsightsScreen.screenKey,
        WebInsightsScreen.screenKey,
      }..remove(entry.value);
      for (final key in otherKeys) {
        expect(find.byKey(key), findsNothing);
      }
      expect(find.textContaining('Nothing needs'), findsWidgets);
    });
  }
}

class _FakeInsightController implements InsightController {
  const _FakeInsightController();

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async => const [];

  @override
  Future<CostEstimate?> estimateTier3(Tier3ProviderProfile profile) async => null;

  @override
  Future<Tier3GenerationOutcome> generateTier3(
    Tier3ProviderProfile profile,
  ) async => const Tier3GenerationOutcome(
    kind: Tier3GenerationOutcomeKind.providerFailure,
    estimate: null,
  );

  @override
  Future<List<ProactiveInsight>> load() async => const [];

  @override
  Future<Set<InsightKind>> mutedKinds() async => const <InsightKind>{};

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async =>
      const [];

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) async =>
      null;
}
