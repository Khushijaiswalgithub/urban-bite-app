import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class ImportJsonScreen extends StatefulWidget {
  const ImportJsonScreen({Key? key}) : super(key: key);

  @override
  State<ImportJsonScreen> createState() => _ImportJsonScreenState();
}

class _ImportJsonScreenState extends State<ImportJsonScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> importJsonToFirestore(String collectionName) async {
    setState(() => _loading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
        return;
      }

      final PlatformFile file = result.files.first;

      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to read file bytes')),
        );
        return;
      }

      final String content = utf8.decode(file.bytes!);
      final dynamic decoded = jsonDecode(content);

      List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map) {
        items = [decoded];
      } else {
        throw FormatException('JSON must be an object or an array of objects');
      }

      final CollectionReference colRef = FirebaseFirestore.instance.collection(
        collectionName,
      );

      const int batchLimit = 500;
      for (int i = 0; i < items.length; i += batchLimit) {
        final int end = min(i + batchLimit, items.length);
        final batch = FirebaseFirestore.instance.batch();
        final chunk = items.sublist(i, end);

        for (var item in chunk) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('id')) {
              final String id = item['id'].toString();
              final Map<String, dynamic> data = Map.from(item);
              data.remove('id');
              final docRef = colRef.doc(id);
              batch.set(docRef, data);
            } else {
              final docRef = colRef.doc();
              batch.set(docRef, Map.from(item));
            }
          } else {
            throw FormatException('Array elements must be JSON objects');
          }
        }

        await batch.commit();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${items.length} documents into $collectionName',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import JSON to Firestore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Firestore Collection Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            _loading
                ? const SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final collectionName = _controller.text.trim();
                      if (collectionName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a collection name'),
                          ),
                        );
                        return;
                      }
                      await importJsonToFirestore(collectionName);
                    },
                    child: const Text('Import JSON'),
                  ),
          ],
        ),
      ),
    );
  }
}
