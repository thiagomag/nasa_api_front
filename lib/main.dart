import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Neos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NeosScreen(),
    );
  }
}

class NeosScreen extends StatefulWidget {
  final http.Client? client;  // Novo parâmetro opcional
  const NeosScreen({super.key, this.client});  // Modifica o construtor para aceitar client

  @override
  _NeosScreenState createState() => _NeosScreenState();
}

class _NeosScreenState extends State<NeosScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<dynamic> neos = [];

  Future<void> fetchNeos(String startDate, String endDate) async {
    final client = widget.client ?? http.Client();  // Use o client fornecido ou crie um novo
    final url = Uri.parse('http://localhost:8080/api/neos');  // Backend URL

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "start_date": startDate,
        "end_date": endDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        neos = data['neosByDateList'];
      });
    } else {
      throw Exception('Failed to load NEOs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NASA NEOs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date (yyyy-mm-dd)'),
            ),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: 'End Date (yyyy-mm-dd)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                fetchNeos(_startDateController.text, _endDateController.text);
              },
              child: Text('Fetch NEOs'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: neos.length,
                itemBuilder: (context, index) {
                  final neoByDate = neos[index];
                  final date = neoByDate['date'];
                  final neosList = neoByDate['neos'];

                  return ExpansionTile(
                    title: Text('Date: $date'),
                    children: neosList.map<Widget>((neo) {
                      return ListTile(
                        title: Text(neo['name']),
                        subtitle: Text(
                          'ID: ${neo['id']}\n'
                              'Magnitude: ${neo['absolute_magnitude_h']}\n'
                              'Hazardous: ${neo['is_potentially_hazardous_asteroid'] ? 'Yes' : 'No'}\n'
                              'Diameter (km): ${neo['estimated_diameter']['kilometers']['estimated_diameter_min']} - ${neo['estimated_diameter']['kilometers']['estimated_diameter_max']}\n'
                              'Close approach date: ${neo['close_approach_data'][0]['close_approach_date_full']}',
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}