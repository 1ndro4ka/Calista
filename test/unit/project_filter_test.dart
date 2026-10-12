import 'package:flutter_test/flutter_test.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

void main() {
  group('Project Search & Filtering Logic Tests', () {
    final now = DateTime.now();

    final sampleProjects = [
      Project(
        id: 'p1',
        ownerId: 'u1',
        title: 'Разработка сервиса Calista',
        description: 'Мобильное приложение для команд на Flutter и Firebase',
        category: 'Разработка',
        requiredSkills: ['Flutter', 'Dart', 'Firebase'],
        maxMembers: 4,
        memberCount: 2,
        deadline: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Project(
        id: 'p2',
        ownerId: 'u2',
        title: 'Дизайн интерфейса онлайн-школы',
        description: 'Создание UX/UI дизайна в Figma для студенческой платформы',
        category: 'Дизайн',
        requiredSkills: ['Figma', 'UI/UX'],
        maxMembers: 3,
        memberCount: 1,
        deadline: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Project(
        id: 'p3',
        ownerId: 'u3',
        title: 'Анализ данных курса',
        description: 'Исследование данных с помощью Python и SQL',
        category: 'Аналитика',
        requiredSkills: ['Python', 'SQL', 'Аналитика'],
        maxMembers: 6,
        memberCount: 3,
        deadline: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
    ];

    test('Search filters correctly by title case-insensitive', () {
      final query = 'calista';
      final results = sampleProjects.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.requiredSkills.any((s) => s.toLowerCase().contains(query));
      }).toList();

      expect(results.length, equals(1));
      expect(results.first.id, equals('p1'));
    });

    test('Search filters correctly by skills', () {
      final query = 'python';
      final results = sampleProjects.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.requiredSkills.any((s) => s.toLowerCase().contains(query));
      }).toList();

      expect(results.length, equals(1));
      expect(results.first.id, equals('p3'));
    });

    test('Filter by Category isolates correct category', () {
      final selectedCategory = 'Дизайн';
      final results = sampleProjects.where((p) => p.category == selectedCategory).toList();

      expect(results.length, equals(1));
      expect(results.first.title, contains('Дизайн'));
    });

    test('Filter by Team Capacity ranges works accurately', () {
      // '2-3'
      final cap23 = sampleProjects.where((p) => p.maxMembers >= 2 && p.maxMembers <= 3).toList();
      expect(cap23.map((e) => e.id), contains('p2'));

      // '4-5'
      final cap45 = sampleProjects.where((p) => p.maxMembers >= 4 && p.maxMembers <= 5).toList();
      expect(cap45.map((e) => e.id), contains('p1'));

      // '6+'
      final cap6plus = sampleProjects.where((p) => p.maxMembers >= 6).toList();
      expect(cap6plus.map((e) => e.id), contains('p3'));
    });

    test('Filter by upcoming deadline within 30 days', () {
      final upcoming = sampleProjects.where((p) {
        final diff = p.deadline.difference(now).inDays;
        return diff >= 0 && diff <= 30;
      }).toList();

      // p1 (10 days) and p3 (5 days) match, p2 (45 days) does not
      expect(upcoming.length, equals(2));
      expect(upcoming.map((e) => e.id), containsAll(['p1', 'p3']));
      expect(upcoming.map((e) => e.id), isNot(contains('p2')));
    });
  });
}
