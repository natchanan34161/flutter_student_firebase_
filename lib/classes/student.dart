import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String studentId;
  final String name;
  final String major;
  final double gpa;
  final String imageUrl;
  final String id;

  Student({
    required this.studentId,
    required this.name,
    required this.major,
    required this.gpa,
    required this.imageUrl,
    required this.id,
  });

  //ดึงข้อมูล แปลง firebase => Object
  factory Student.fromFireStore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      studentId: data['studentId'],
      name: data['name'],
      major: data['major'],
      gpa: data['gpa'],
      imageUrl: data['imageUrl'],
      id: doc.id,
    );
  }

  // up ขึ้นไป Save -> แปลง object ให้เป็น firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'major': major,
      'gpa': gpa,
      'imageUrl': imageUrl,
    };
  }
  
}