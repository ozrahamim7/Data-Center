import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srv_hub/models/equipment_model.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'equipments';

  // Get all equipment as a stream
  Stream<List<EquipmentModel>> getEquipments() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EquipmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all equipment as a future (not stream)
  Future<List<EquipmentModel>> getAllEquipments() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => EquipmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Add a new equipment item
  Future<String> addEquipment(EquipmentModel equipment) async {
    final docRef = await _firestore.collection(_collection).add(equipment.toMap());
    return docRef.id;
  }

  // Update an existing equipment item
  Future<void> updateEquipment(EquipmentModel equipment) async {
    await _firestore.collection(_collection).doc(equipment.uuid).update(equipment.toMap());
  }

  // Delete an equipment item
  Future<void> deleteEquipment(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Import multiple equipment items
  Future<int> importEquipments(List<EquipmentModel> equipments) async {
    int count = 0;
    for (var equipment in equipments) {
      await addEquipment(equipment);
      count++;
    }
    return count;
  }
}
