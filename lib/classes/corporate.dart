import 'package:cloud_firestore/cloud_firestore.dart';

class Corporate {
  final String id;
  final String name;
  final String industry;
  final String address;
  final String contactEmail;

  Corporate({
    required this.id,
    required this.name,
    required this.industry,
    required this.address,
    required this.contactEmail,
  });

  //ดึงข้อมูล แปลง firebase => Object
  factory Corporate.fromFireStore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Corporate(
      id: doc.id,
      name: data['name'] ?? '',
      industry: data['industry'] ?? '',
      address: data['address'] ?? '',
      contactEmail: data['contact_email'] ?? '',
    );
  }

  // up ขึ้นไป Save -> แปลง object ให้เป็น firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'industry': industry,
      'address': address,
      'contact_email': contactEmail,
    };
  }
}
