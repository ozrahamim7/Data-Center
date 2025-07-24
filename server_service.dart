import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srv_hub/models/server_model.dart';

class ServerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'servers';

  // Get all servers
  Stream<List<ServerModel>> getServers() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all servers as a future (not stream)
  Future<List<ServerModel>> getAllServers() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => ServerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get a specific server
  Future<ServerModel?> getServer(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return ServerModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Add a new server
  Future<String> addServer(ServerModel server) async {
    final docRef = await _firestore.collection(_collection).add(server.toMap());
    return docRef.id;
  }

  // Update a server
  Future<void> updateServer(ServerModel server) async {
    await _firestore
        .collection(_collection)
        .doc(server.uuid)
        .update(server.toMap());
  }

  // Delete a server
  Future<void> deleteServer(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Import multiple servers at once
  Future<int> importServers(List<ServerModel> servers) async {
    try {
      int importedCount = 0;
      WriteBatch batch = _firestore.batch();
      for (var server in servers) {
        if (server.uuid.isNotEmpty) {
          final docSnapshot =
              await _firestore.collection(_collection).doc(server.uuid).get();

          if (docSnapshot.exists) {
            // Update existing server
            batch.update(
                _firestore.collection(_collection).doc(server.uuid),
                server.toMap());
          } else {
            // Create new server with provided UUID
            batch.set(
                _firestore.collection(_collection).doc(server.uuid),
                server.toMap());
          }
        } else {
          // Create new server with auto-generated ID
          final docRef = _firestore.collection(_collection).doc();
          server.uuid = docRef.id;
          batch.set(docRef, server.toMap());
        }

        importedCount++;
      }

      // Commit the batch
      await batch.commit();

      return importedCount;
    } catch (e) {
      print('Error importing servers: $e');
      rethrow;
    }
  }
}
