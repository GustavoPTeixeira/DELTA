import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should render identifier, password fields, and login button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Usuário ou E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('LOGAR'), findsOneWidget);
      expect(find.text('Esqueceu sua senha?'), findsOneWidget);
      expect(
        find.text('Ainda não tem conta? Registre-se aqui.'),
        findsOneWidget,
      );
    });

    testWidgets('should show inline validation errors when submitting empty login form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.tap(find.text('LOGAR'));
      await tester.pump();

      expect(find.text('Informe seu usuário ou e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when eye icon is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('should open password reset dialog and validate email input inline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.tap(find.text('Esqueceu sua senha?'));
      await tester.pumpAndSettle();

      expect(find.text('Recuperar Senha'), findsOneWidget);

      await tester.tap(find.text('ENVIAR'));
      await tester.pump();

      expect(find.text('O e-mail é obrigatório'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextFormField),
        ),
        'invalid-email',
      );
      await tester.tap(find.text('ENVIAR'));
      await tester.pump();

      expect(find.text('Por favor, digite um e-mail válido.'), findsOneWidget);
    });

    testWidgets('should navigate to RegisterScreen when register link is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.tap(find.text('Ainda não tem conta? Registre-se aqui.'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Novo Cadastro'), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('should render all registration fields and default to Student role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Nome de Usuário'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Tipo de Perfil'), findsOneWidget);
      expect(find.text('Estudante'), findsOneWidget);
      expect(find.text('REGISTRAR'), findsOneWidget);
    });

    testWidgets('should show inline validation errors when submitting invalid inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      await tester.tap(find.text('REGISTRAR'));
      await tester.pump();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('O nome de usuário é obrigatório'), findsOneWidget);
      expect(find.text('O email é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Maria');
      await tester.enterText(fields.at(1), 'maria silva');
      await tester.enterText(fields.at(2), 'maria.email.com');
      await tester.enterText(fields.at(3), '123');

      await tester.tap(find.text('REGISTRAR'));
      await tester.pump();

      expect(find.text('Não use espaços no nome de usuário'), findsOneWidget);
      expect(find.text('Digite um email válido com @'), findsOneWidget);
      expect(
        find.text('A senha deve ter no mínimo 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should allow selecting Teacher role in the profile dropdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<UserRole>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Professor').last);
      await tester.pumpAndSettle();

      expect(find.text('Professor'), findsOneWidget);
    });
  });
}