import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExportJsonScreen extends StatefulWidget {
  const ExportJsonScreen({Key? key}) : super(key: key);

  @override
  State<ExportJsonScreen> createState() => _ExportJsonScreenState();
}

class _ExportJsonScreenState extends State<ExportJsonScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> exportFirestoreToJson(String collectionName) async {
    try {
      setState(() => isLoading = true);

      // 1️⃣ Fetch Firestore data
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      if (snapshot.docs.isEmpty) {
        throw "Collection is empty or does not exist";
      }

      final List<Map<String, dynamic>> jsonList = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data(),
        };
      }).toList();

      // 2️⃣ Convert to pretty JSON
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(jsonList);

      // 3️⃣ Save directly to Downloads (NO PERMISSION REQUIRED)
      final file = File(
        '/storage/emulated/0/Download/$collectionName.json',
      );

      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloaded to Downloads/$collectionName.json"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Firestore to JSON")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Firestore Collection Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Enter collection name"),
                          ),
                        );
                      } else {
                        exportFirestoreToJson(
                          _controller.text.trim(),
                        );
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Download JSON"),
            ),
          ],
        ),
      ),
    );
  }
}
