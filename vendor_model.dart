import 'package:uuid/uuid.dart';

class VendorModel {
  late final String uuid;
  final String name;
  final String phoneNumber;

  VendorModel({
    String? uuid,
    required this.name,
    this.phoneNumber = '',
  }) : uuid = uuid ?? const Uuid().v4();

  factory VendorModel.fromMap(Map<String, dynamic> data, String documentId) {
    return VendorModel(
      uuid: documentId,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
}