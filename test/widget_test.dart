import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nasa_api_front/main.dart';  // Importando o main.dart

class MockClient extends Mock implements http.Client {}

void main() {
  group('NEOs Screen Widget Tests', () {
    testWidgets('should display empty state initially', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verificar se os campos de texto e o botão estão presentes
      expect(find.text('Start Date (yyyy-mm-dd)'), findsOneWidget);
      expect(find.text('End Date (yyyy-mm-dd)'), findsOneWidget);
      expect(find.text('Fetch NEOs'), findsOneWidget);
    });

    testWidgets('should make HTTP request when button is clicked', (WidgetTester tester) async {
      final mockClient = MockClient();

      // Simular uma resposta de sucesso da API
      when(mockClient.post(
        Uri.parse('http://localhost:8080/api/neos'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
        'elementCount': 1,
        'neosByDateList': [
          {
            'date': '2024-08-14',
            'neos': [
              {
                'id': '3448532',
                'name': '(2009 DH39)',
                'absolute_magnitude_h': 18.8,
                'is_potentially_hazardous_asteroid': true,
                'estimated_diameter': {
                  'kilometers': {
                    'estimated_diameter_min': '0.4619074603',
                    'estimated_diameter_max': '1.0328564805',
                  }
                },
                'close_approach_data': [
                  {
                    'close_approach_date_full': '2024-Aug-14 08:31',
                  }
                ]
              }
            ]
          }
        ]
      }), 200));

      // Carregar o widget com o mockClient
      await tester.pumpWidget(MaterialApp(
        home: NeosScreen(client: mockClient),  // Passar o mockClient para o widget
      ));

      // Inserir datas nos campos de texto
      await tester.enterText(find.byType(TextField).at(0), '2024-08-14');
      await tester.enterText(find.byType(TextField).at(1), '2024-08-14');

      // Clicar no botão de busca
      await tester.tap(find.text('Fetch NEOs'));
      await tester.pump();

      // Verificar se a requisição foi chamada
      verify(mockClient.post(
        Uri.parse('http://localhost:8080/api/neos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'start_date': '2024-08-14',
          'end_date': '2024-08-14',
        }),
      )).called(1);

      // Verificar se o resultado foi exibido corretamente
      expect(find.text('(2009 DH39)'), findsOneWidget);
      expect(find.text('ID: 3448532'), findsOneWidget);
      expect(find.text('Magnitude: 18.8'), findsOneWidget);
    });
  });
}
