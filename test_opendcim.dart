// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const MaterialApp(home: TestAPI()));
// }

// class TestAPI extends StatefulWidget {
//   const TestAPI({super.key});

//   @override
//   State<TestAPI> createState() => _TestAPIState();
// }

// class _TestAPIState extends State<TestAPI> {
//   String result = "טוען נתונים...";

//   @override
//   void initState() {
//     super.initState();
//     fetchDevices();
//   }

//   Future<void> fetchDevices() async {
//     try {
//       final response = await http.get(
//       Uri.parse('http://opendcim.localhost/api/v1/device'),
//       headers: {'Content-Type': 'application/json'},
// );


//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         setState(() {
//           result = jsonEncode(jsonData);
//         });
//       } else {
//         setState(() {
//           result = 'שגיאה: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         result = 'שגיאה כללית: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('בדיקת חיבור ל-OpenDCIM')),
//       body: Center(child: Text(result)),
//     );
//   }
// }
