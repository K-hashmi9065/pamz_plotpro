import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/storage/hive_service.dart';
import 'package:land_investment_and_sales_management/shared/providers/navigation_providers.dart';
import 'package:land_investment_and_sales_management/features/settings/presentation/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveService.settingsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        currentRoleProvider.overrideWithValue(UserRole.admin),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsScreen(),
        ),
      ),
    );
  }

  group('SettingsScreen - PDF Header Branding Widget Tests', () {
    testWidgets('renders PDF & Document Branding card with default header PAMZ PlotPro', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('PDF & Document Branding'), findsOneWidget);
      expect(find.text('PDF Header / Organization Name *'), findsOneWidget);
      expect(find.text('Save Header'), findsOneWidget);
      expect(find.text('Reset Default'), findsOneWidget);
      expect(find.text('LIVE PDF HEADER PREVIEW'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('editing and saving header updates state and preview', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField).last;
      await tester.enterText(inputFinder, 'Wasi Property');
      await tester.pumpAndSettle();

      final saveButtonFinder = find.text('Save Header');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Wasi Property'), findsWidgets);
      expect(HiveService.getPdfHeaderTitle(), equals('Wasi Property'));

      // Test reset button
      final resetButtonFinder = find.text('Reset Default');
      await tester.tap(resetButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('PAMZ PlotPro'), findsWidgets);
      expect(HiveService.getPdfHeaderTitle(), equals('PAMZ PlotPro'));
    });
  });
}
