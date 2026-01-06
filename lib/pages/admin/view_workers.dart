import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewWorkersPage extends StatefulWidget {
  const ViewWorkersPage({super.key});

  @override
  State<ViewWorkersPage> createState() => _ViewWorkersPageState();
}

class _ViewWorkersPageState extends State<ViewWorkersPage> {
  String _filterRole = "all";
  String _sortBy = "alphabetical";

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text("View Workers")),
      body: Column(
        children: [
          // 🔽 Filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _filterRole,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All")),
                  DropdownMenuItem(value: "manager", child: Text("Managers")),
                  DropdownMenuItem(value: "waiter", child: Text("Waiters")),
                  DropdownMenuItem(value: "customer", child: Text("Customers")),
                ],
                onChanged: (val) => setState(() => _filterRole = val!),
              ),
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
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Apply filter
                if (_filterRole != "all") {
                  docs = docs.where((d) => d['role'] == _filterRole).toList();
                }

                // Apply sorting
                if (_sortBy == "alphabetical") {
                  docs.sort(
                    (a, b) => a['full_name'].toString().toLowerCase().compareTo(
                      b['full_name'].toString().toLowerCase(),
                    ),
                  );
                } else {
                  docs.sort(
                    (a, b) => (a['created_at'] as Timestamp).compareTo(
                      b['created_at'] as Timestamp,
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Role")),
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
                          DataCell(Text(data['role'] ?? "")),
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
