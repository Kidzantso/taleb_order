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
    final firestore = FirebaseFirestore.instance;
    final dateFormat = DateFormat('dd/MM/yy');

    return Scaffold(
      appBar: AppBar(title: const Text("View Workers")),
      body: Column(
        children: [
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
                  DropdownMenuItem(value: "kitchen", child: Text("Kitchen")),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                if (_filterRole != "all") {
                  docs = docs.where((d) => d['role'] == _filterRole).toList();
                }

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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: SizedBox(
                        width: constraints.maxWidth, // ✅ full width
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey.shade200,
                          ),
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Role")),
                            DataColumn(label: Text("Date")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final createdAt = data['created_at'] as Timestamp?;
                            final formattedDate = createdAt != null
                                ? dateFormat.format(createdAt.toDate())
                                : "N/A";

                            String roleLetter = "";
                            switch (data['role']) {
                              case "manager":
                                roleLetter = "M";
                                break;
                              case "waiter":
                                roleLetter = "W";
                                break;
                              case "customer":
                                roleLetter = "C";
                                break;
                              case "admin":
                                roleLetter = "A";
                                break;
                              case "kitchen":
                                roleLetter = "K";
                                break;
                            }

                            return DataRow(
                              cells: [
                                DataCell(
                                  Tooltip(
                                    message: data['full_name'] ?? "",
                                    child: Text(
                                      data['full_name'] ?? "",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(roleLetter)),
                                DataCell(Text(formattedDate)),
                                DataCell(
                                  Center(
                                    child: data['role'] == "admin"
                                        ? const Text("-")
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    "Confirm Delete",
                                                  ),
                                                  content: Text(
                                                    "Delete ${data['full_name']}?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await firestore
                                                    .collection('users')
                                                    .doc(doc.id)
                                                    .delete();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "${data['full_name']} deleted ✅",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
