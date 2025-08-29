import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debug_mode/main.dart'; // adapte si ton projet n'a pas le même nom

void main() {
  // ===== TESTS UNITAIRES =====
  group('Tests unitaires', () {
    test('Etudiant doit être créé correctement', () {
      final etudiant = Etudiant(nom: 'Alice', moyenne: 17.25);
      expect(etudiant.nom, 'Alice');
      expect(etudiant.moyenne, 17.25);
    });

    test('calculateMoyenne doit calculer la moyenne correctement', () {
      final pageAccueil = PageAccueil();
      final etudiants = [
        Etudiant(nom: 'Alice', moyenne: 17.0),
        Etudiant(nom: 'Bob', moyenne: 13.0),
        Etudiant(nom: 'Charlie', moyenne: 10.0),
      ];
      final moyenne = pageAccueil.calculateMoyenne(etudiants);
      expect(moyenne, 13.333333333333334);
    });

    test('calculateMoyenne avec un seul étudiant', () {
      final pageAccueil = PageAccueil();
      final etudiants = [Etudiant(nom: 'Alice', moyenne: 15.0)];
      final moyenne = pageAccueil.calculateMoyenne(etudiants);
      expect(moyenne, 15.0);
    });

    test('calculateMoyenne avec liste vide doit retourner NaN', () {
      final pageAccueil = PageAccueil();
      final etudiants = <Etudiant>[];
      final moyenne = pageAccueil.calculateMoyenne(etudiants);
      expect(moyenne.isNaN, true);
    });
  });

  // ===== TESTS DE WIDGETS =====
  group('Tests de widgets', () {
    testWidgets('MonApplication doit afficher PageAccueil', (WidgetTester tester) async {
      await tester.pumpWidget(MonApplication());
      expect(find.text('Liste des étudiants'), findsOneWidget);
      expect(find.text('Liste des étudiants et de leurs moyennes :'), findsOneWidget);
      expect(find.text('Calculer la moyenne de la classe'), findsOneWidget);
    });

    testWidgets('PageAccueil doit afficher la liste des étudiants', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PageAccueil()));
      expect(find.text('Nom: Alice'), findsOneWidget);
      expect(find.text('Nom: Bob'), findsOneWidget);
      expect(find.text('Nom: Charlie'), findsOneWidget);
      expect(find.text('Nom: David'), findsOneWidget);
      expect(find.text('Nom: Eve'), findsOneWidget);
    });

    testWidgets('Bouton calculer moyenne doit afficher dialog', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PageAccueil()));
      await tester.tap(find.text('Calculer la moyenne de la classe'));
      await tester.pumpAndSettle();
      expect(find.text('Moyenne des étudiants'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Dialog doit se fermer quand OK est pressé', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PageAccueil()));
      await tester.tap(find.text('Calculer la moyenne de la classe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Tap sur étudiant doit naviguer vers DetailPage', (WidgetTester tester) async {
      await tester.pumpWidget(MonApplication());
      await tester.tap(find.text('Nom: Alice').first);
      await tester.pumpAndSettle();
      expect(find.text('Détails de l\'étudiant'), findsOneWidget);
      expect(find.text('Nom de l\'étudiant : Alice'), findsOneWidget);
    });

    testWidgets('DetailPage doit afficher les bonnes informations', (WidgetTester tester) async {
      final etudiant = Etudiant(nom: 'Test', moyenne: 15.5);
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) => DetailPage()),
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => DetailPage(),
              settings: RouteSettings(arguments: etudiant),
            );
          }
          return null;
        },
      ));
      expect(find.text('Détails de l\'étudiant'), findsOneWidget);
      expect(find.text('Nom de l\'étudiant : Test'), findsOneWidget);
      expect(find.text('Moyenne : 15.5'), findsOneWidget);
    });
  });

  // ===== TESTS D'INTÉGRATION =====
  group('Tests d\'intégration', () {
    testWidgets('Flow complet : affichage -> calcul moyenne -> fermeture dialog', (WidgetTester tester) async {
      await tester.pumpWidget(MonApplication());
      expect(find.text('Liste des étudiants'), findsOneWidget);
      await tester.tap(find.text('Calculer la moyenne de la classe'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Flow complet : navigation vers détails et retour', (WidgetTester tester) async {
      await tester.pumpWidget(MonApplication());
      expect(find.text('Nom: Alice'), findsOneWidget);
      await tester.tap(find.text('Nom: Alice').first);
      await tester.pumpAndSettle();
      expect(find.text('Nom de l\'étudiant : Alice'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Liste des étudiants'), findsOneWidget);
    });

    testWidgets('Test intégration calcul moyenne avec valeurs réelles', (WidgetTester tester) async {
      await tester.pumpWidget(MonApplication());
      await tester.tap(find.text('Calculer la moyenne de la classe'));
      await tester.pumpAndSettle();
      expect(find.textContaining('14.35'), findsOneWidget); // moyenne attendue
    });
  });
}
