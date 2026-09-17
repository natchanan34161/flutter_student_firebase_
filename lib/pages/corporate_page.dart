import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_student_firebase/classes/corporate.dart';

class CorporatePage extends StatefulWidget {
  const CorporatePage({super.key});

  @override
  State<CorporatePage> createState() => _CorporatePageState();
}

class _CorporatePageState extends State<CorporatePage> {
  final CollectionReference _corporatesCollection =
      FirebaseFirestore.instance.collection('corporates');

  void _showCorporateFormDialog({Corporate? corporate}) {
    final isEditing = corporate != null;

    final nameController = TextEditingController(text: corporate?.name ?? '');
    final industryController =
        TextEditingController(text: corporate?.industry ?? '');
    final addressController =
        TextEditingController(text: corporate?.address ?? '');
    final contactEmailController =
        TextEditingController(text: corporate?.contactEmail ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'แก้ไขข้อมูลบริษัท' : 'เพิ่มข้อมูลบริษัท'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'ชื่อบริษัท'),
                    ),
                    TextField(
                      controller: industryController,
                      decoration: const InputDecoration(labelText: 'อุตสาหกรรม'),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'ที่ตั้ง'),
                    ),
                    TextField(
                      controller: contactEmailController,
                      decoration: const InputDecoration(labelText: 'อีเมลติดต่อ'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String industry = industryController.text.trim();
                    final String address = addressController.text.trim();
                    final String contactEmail =
                        contactEmailController.text.trim();

                    if (name.isEmpty ||
                        industry.isEmpty ||
                        address.isEmpty ||
                        contactEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง')),
                      );
                      return;
                    }

                    final corporateData = {
                      'name': name,
                      'industry': industry,
                      'address': address,
                      'contact_email': contactEmail,
                    };

                    try {
                      if (isEditing) {
                        await _corporatesCollection
                            .doc(corporate.id)
                            .update(corporateData);
                      } else {
                        await _corporatesCollection.add(corporateData);
                      }
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
      appBar: AppBar(title: const Text('รายชื่อบริษัท'), centerTitle: true),
      body: StreamBuilder(
        stream: _corporatesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'สถานะ: เกิดข้อผิดพลาดในการเชื่อมต่อ: ${snapshot.error}',
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'สถานะ: ไม่มีข้อมูลในฐานข้อมูล',
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final corporate = Corporate.fromFireStore(docs[index]);
              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 14.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                    title: Text(corporate.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${corporate.industry}'),
                        Text('ที่ตั้ง: ${corporate.address}'),
                        Text('อีเมล: ${corporate.contactEmail}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () =>
                          _showCorporateFormDialog(corporate: corporate),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCorporateFormDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}