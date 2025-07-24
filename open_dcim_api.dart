// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// class OpenDCIMApi {
//   static const String baseUrl = 'http://opendcim.localhost/api/v1';

//   // שליפת שרתים מ-OpenDCIM
//   static Future<List<Map<String, dynamic>>> fetchServers() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/device'));

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         return List<Map<String, dynamic>>.from(json['device']);
//       } else {
//         throw Exception('Failed to load devices');
//       }
//     } catch (e) {
//       print('Error fetching devices: $e');
//       return [];
//     }
//   }

//   // שליחת שרת ל-OpenDCIM
//   static Future<bool> sendServer(Map<String, dynamic> data) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/device'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data),
//       );
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error sending device: $e');
//       return false;
//     }
//   }

//   /// 🟣 פונקציית סנכרון דו-כיווני
//   static Future<void> syncFromOpenDCIMToFirebase() async {
//     final firestore = FirebaseFirestore.instance;

//     // 1. שליפת נתונים מ-Firebase
//     final firebaseSnapshot = await firestore.collection('servers').get();
//     final firebaseServers = firebaseSnapshot.docs.map((doc) => doc.data()).toList();

//     // 2. שליפת נתונים מ-OpenDCIM
//     final dcimServers = await fetchServers();

//     final Set<String> firebaseUUIDs = firebaseServers.map((s) => s['uuid'] as String).toSet();
//     final Set<String> dcimUUIDs = dcimServers.map((s) => s['uuid'] as String).toSet();

//     // 3. שרתים מ-OpenDCIM שלא קיימים בפיירבייס → להוסיף לפיירבייס
//     for (var server in dcimServers) {
//       if (!firebaseUUIDs.contains(server['uuid'])) {
//         await firestore.collection('servers').add(server);
//         print('✅ Added server to Firebase: ${server['uuid']}');
//       }
//     }

//     // 4. שרתים מפיירבייס שלא קיימים ב-OpenDCIM → לשלוח ל-OpenDCIM
//     for (var server in firebaseServers) {
//       if (!dcimUUIDs.contains(server['uuid'])) {
//         final success = await sendServer(server);
//         print(success
//             ? '✅ Sent new server to OpenDCIM: ${server['uuid']}'
//             : '❌ Failed to send server: ${server['uuid']}');
//       }
//     }

//     print('🔁 סנכרון הסתיים');
//   }
// }
