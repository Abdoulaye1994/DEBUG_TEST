// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:debug_mode/main.dart' as app; // Remplacez par le nom de votre app

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests d\'intégration E2E', () {
    testWidgets('Test complet de l\'application', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'écran principal s'affiche
      expect(find.text('Liste des étudiants'), findsOneWidget);
      expect(find.text('Calculer la moyenne de la classe'), findsOneWidget);

      // Vérifier que tous les étudiants sont affichés
      expect(find.text('Nom: Alice'), findsOneWidget);
      expect(find.text('Nom: Bob'), findsOneWidget);
      expect(find.text('Nom: Charlie'), findsOneWidget);
      expect(find.text('Nom: David'), findsOneWidget);
      expect(find.text('Nom: Eve'), findsOneWidget);

      // Test du calcul de moyenne
      await tester.tap(find.text('Calculer la moyenne de la classe'));
      await tester.pumpAndSettle();

      // Vérifier que le dialog s'affiche avec la bonne moyenne
      expect(find.text('Moyenne des étudiants'), findsOneWidget);
      expect(find.textContaining('14.35'), findsOneWidget);

      // Fermer le dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test de navigation vers les détails
      await tester.tap(find.text('Nom: Alice').first);
      await tester.pumpAndSettle();

      // Vérifier la page de détails
      expect(find.text('Détails de l\'étudiant'), findsOneWidget);
      expect(find.text('Nom de l\'étudiant : Alice'), findsOneWidget);
      expect(find.text('Moyenne : 17.25'), findsOneWidget);

      // Retour à l'écran principal
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Vérifier le retour
      expect(find.text('Liste des étudiants'), findsOneWidget);
    });

    testWidgets('Test navigation vers tous les étudiants', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test de navigation pour chaque étudiant
      final etudiants = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
      final moyennes = ['17.25', '16.5', '11.75', '12.75', '13.5'];

      for (int i = 0; i < etudiants.length; i++) {
        // Naviguer vers les détails de l'étudiant
        await tester.tap(find.text('Nom: ${etudiants[i]}').first);
        await tester.pumpAndSettle();

        // Vérifier les détails
        expect(find.text('Nom de l\'étudiant : ${etudiants[i]}'), findsOneWidget);
        expect(find.text('Moyenne : ${moyennes[i]}'), findsOneWidget);

        // Retourner
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    });
  });
}