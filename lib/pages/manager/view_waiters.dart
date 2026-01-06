import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ✅ for date formatting

class ViewWaitersPage extends StatefulWidget {
  const ViewWaitersPage({super.key});

  @override
  State<ViewWaitersPage> createState() => _ViewWaitersPageState();
}

class _ViewWaitersPageState extends State<ViewWaitersPage> {
  String _sortBy = "alphabetical"; // default sort

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final dateFormat = DateFormat('yyyy-MM-dd'); // ✅ format only date

    return Scaffold(
      appBar: AppBar(title: const Text("View Waiters")),
      body: Column(
        children: [
          // 🔽 Sorting dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(
                    value: "alphabetical",
                    child: Text("Alphabetical"),
                  ),
                  DropdownMenuItem(value: "date", child: Text("By Date")),
                ],
                onChanged: (val) => setState(() => _sortBy = val!),
              ),
            ],
          ),

          // 🔽 Table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'waiter')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Apply sorting
                if (_sortBy == "alphabetical") {
                  docs.sort(
                    (a, b) => a['full_name'].toString().toLowerCase().compareTo(
                      b['full_name'].toString().toLowerCase(),
                    ),
                  );
                } else {
                  docs.sort((a, b) {
                    final aDate = a['created_at'] as Timestamp?;
                    final bDate = b['created_at'] as Timestamp?;
                    if (aDate == null && bDate == null) return 0;
                    if (aDate == null) return 1;
                    if (bDate == null) return -1;
                    return aDate.compareTo(bDate);
                  });
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Created At")),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final createdAt = data['created_at'] as Timestamp?;
                      final formattedDate = createdAt != null
                          ? dateFormat.format(createdAt.toDate())
                          : "N/A";

                      return DataRow(
                        cells: [
                          DataCell(Text(data['full_name'] ?? "")),
                          DataCell(Text(formattedDate)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
