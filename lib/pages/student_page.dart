import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_student_firebase/classes/student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  //ดึงข้อมูล firebase
  final CollectionReference _studentsCollection = FirebaseFirestore.instance
      .collection('students');

  Widget _buidStudentAvatar(String imgURL, {double radius = 30.0}) {
    // Check Format
    if (imgURL.startsWith('https://') || imgURL.startsWith('http://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.deepPurple,
        backgroundImage: NetworkImage(imgURL),
      );
    }
    // If Fail return Icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, size: radius, color: Colors.white),
    );
  }

  // Method Add & Update Student
  void _showStudentFormDialog({Student? student}) {
    final isEditing = student != null;

    // Text Field Controller
    final studenIdController = TextEditingController(
      text: student?.studentId ?? '',
    );
    final nameController = TextEditingController(text: student?.name ?? '');
    final majorController = TextEditingController(text: student?.major ?? '');
    final gpaController = TextEditingController(
      text: student?.gpa.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: student?.imageUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'แก้ไข' : 'เพิ่มข้อมูล'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // TextField กรอกข้อมูล
                    TextField(
                      key: const Key('studentIdKey'),
                      controller: studenIdController,
                      decoration: InputDecoration(labelText: 'รหัสนักศึกษา'),
                      keyboardType: TextInputType.number,
                      enabled: !isEditing,
                    ),
                    TextField(
                      key: const Key('nameKey'),
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'ชื่อนักศึกษา'),
                      keyboardType: TextInputType.name,
                    ),
                    TextField(
                      key: const Key('majorKey'),
                      controller: majorController,
                      decoration: InputDecoration(labelText: 'สาขาวิชา'),
                      keyboardType: TextInputType.name,
                    ),
                    TextField(
                      key: const Key('gpaKey'),
                      controller: gpaController,
                      decoration: InputDecoration(labelText: 'เกรดเฉลี่ย'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TextField(
                      key: const Key('imageKey'),
                      controller: imageUrlController,
                      decoration: InputDecoration(labelText: 'รูปภาพ'),
                    ),
                  ],
                ),
              ),
              // ปุ่มบันทึก / เพิ่มข้อมูล
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //Arrage
                    final String studenId = studenIdController.text.trim();
                    final String name = nameController.text.trim();
                    final String major = majorController.text.trim();
                    final double gpa =
                        double.tryParse(gpaController.text.trim()) ?? 0.0;
                    final String imageUrl = imageUrlController.text.trim();

                    // Validation
                    if (studenId.isEmpty || name.isEmpty || major.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง')),
                      );
                      return;
                    }

                    final studentData = {
                      'studentId': studenId,
                      'name': name,
                      'major': major,
                      'gpa': gpa,
                      'imageUrl': imageUrl,
                    };

                    try {
                      if (isEditing) {
                        // Edit
                        await _studentsCollection
                            .doc(student.id)
                            .update(studentData);
                      } else {
                        // Add
                        await _studentsCollection.add(studentData);
                      }
                      // Show Information
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'แก้ไขข้อมูลเรียบร้อยแล้ว'
                                  : 'เพิ่มข้อมูลเรียบร้อยแล้ว',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  child: Text(isEditing ? 'บันทึก' : 'เพิ่มข้อมูล'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายชื่อนักศึกษา'), centerTitle: true),
      body: StreamBuilder(
        stream: _studentsCollection.snapshots(),
        builder: (context, snapshot) {
          // CHECK ERROR ในการเชื่อมต่อ
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'สถานะ: เกิดข้อผิดพลาดในการเชื่อมต่อ: ${snapshot.error}',
              ),
            );
          }
          // ระหว่างที่รอ read แสดง loading icon
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // เช็คว่ามีข้อมูลใน firestore หรือไม่
          final List<DocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'สถานะ: ไม่มีข้อมูลในฐานข้อมูล',
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            );
          }
          // แสดงข้อมูล
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final student = Student.fromFireStore(docs[index]);
              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(
                    vertical: 8.0,
                    horizontal: 14.0,
                  ),
                  child: ListTile(
                    leading: _buidStudentAvatar(student.imageUrl, radius: 25.0),
                    title: Text(student.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('รหัสนักศึกษา: ${student.studentId}'),
                        Text('สาขาวิชา: ${student.major}'),
                        //การแสดง GPA ที่แตกต่าง GPA > 3.25
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.0,
                            horizontal: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: student.gpa >= 3.25
                                ? Colors.green.shade700
                                : Colors.orange.shade500,
                          ),
                          child: Text(
                            'GPA: ${student.gpa}',
                            style: TextStyle(
                              color: student.gpa >= 3.25
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text('ปุ่ม'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStudentFormDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
