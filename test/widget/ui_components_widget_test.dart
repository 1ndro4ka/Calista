import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calista/core/widgets/app_button.dart';
import 'package:calista/core/widgets/app_text_field.dart';
import 'package:calista/core/widgets/empty_state.dart';
import 'package:calista/core/widgets/error_state.dart';
import 'package:calista/core/widgets/category_chip.dart';
import 'package:calista/core/widgets/skill_chip.dart';

void main() {
  group('UI Components Widget Tests', () {
    testWidgets('AppButton handles tap and loading state', (tester) async {
      bool tapped = false;

      // Normal state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Войти',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Войти'), findsOneWidget);
      await tester.tap(find.text('Войти'));
      expect(tapped, isTrue);

      // Loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Войти',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppTextField shows label and enters text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              label: 'Имя',
              hint: 'Введите имя',
            ),
          ),
        ),
      );

      expect(find.text('Имя'), findsOneWidget);
      expect(find.text('Введите имя'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Адильжан');
      expect(controller.text, equals('Адильжан'));
    });

    testWidgets('EmptyState displays title and action', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Нет данных',
              message: 'Попробуйте обновить страницу',
              actionLabel: 'Обновить',
              onAction: () => actionPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Нет данных'), findsOneWidget);
      expect(find.text('Попробуйте обновить страницу'), findsOneWidget);
      expect(find.text('Обновить'), findsOneWidget);

      await tester.tap(find.text('Обновить'));
      expect(actionPressed, isTrue);
    });

    testWidgets('ErrorState displays message and retry action', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Ошибка сети',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Ошибка сети'), findsOneWidget);
      await tester.tap(find.text('Повторить попытку'));
      expect(retryPressed, isTrue);
    });

    testWidgets('CategoryChip and SkillChip respond to tap', (tester) async {
      bool catTapped = false;
      bool skillTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CategoryChip(
                  label: 'Дизайн',
                  isSelected: true,
                  onTap: () => catTapped = true,
                ),
                SkillChip(
                  label: 'Flutter',
                  isSelected: false,
                  onTap: () => skillTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Дизайн'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);

      await tester.tap(find.text('Дизайн'));
      expect(catTapped, isTrue);

      await tester.tap(find.text('Flutter'));
      expect(skillTapped, isTrue);
    });
  });
}
