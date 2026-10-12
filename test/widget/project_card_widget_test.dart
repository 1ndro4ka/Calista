import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calista/core/widgets/project_card.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

void main() {
  testWidgets('ProjectCard renders details and responds to interactions', (tester) async {
    final now = DateTime.now();
    final project = Project(
      id: 'p_test',
      ownerId: 'u1',
      title: 'Сервис Calista для учебных команд',
      description: 'Краткое описание проекта для проверки карточки в виджет-тесте',
      category: 'Разработка',
      requiredSkills: ['Flutter', 'Dart', 'Firebase'],
      maxMembers: 5,
      memberCount: 3,
      deadline: now.add(const Duration(days: 20)),
      createdAt: now,
      updatedAt: now,
      status: 'open',
    );

    bool cardTapped = false;
    bool favoriteToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCard(
            project: project,
            isFavorite: false,
            onTap: () => cardTapped = true,
            onFavoriteToggle: () => favoriteToggled = true,
          ),
        ),
      ),
    );

    // Verify Title and Description
    expect(find.text('Сервис Calista для учебных команд'), findsOneWidget);
    expect(find.text('Краткое описание проекта для проверки карточки в виджет-тесте'), findsOneWidget);

    // Verify Category and Member count
    expect(find.text('Разработка'), findsOneWidget);
    expect(find.text('3 / 5 участников'), findsOneWidget);

    // Verify Skills
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);

    // Test card tap
    await tester.tap(find.text('Сервис Calista для учебных команд'));
    expect(cardTapped, isTrue);

    // Test favorite tap
    await tester.tap(find.byIcon(Icons.bookmark_border));
    expect(favoriteToggled, isTrue);
  });
}
