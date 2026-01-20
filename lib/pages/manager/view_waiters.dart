import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewWaitersPage extends StatefulWidget {
  const ViewWaitersPage({super.key});

  @override
  State<ViewWaitersPage> createState() => _ViewWaitersPageState();
}

class _ViewWaitersPageState extends State<ViewWaitersPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _sortBy = "alphabetical";
  String? _branchId;

  @override
  void initState() {
    super.initState();
    _loadManagerBranch();
  }

  Future<void> _loadManagerBranch() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final managerDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        _branchId = managerDoc.data()?['branch_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');

    return Scaffold(
      appBar: AppBar(title: const Text("View Waiters")),
      body: _branchId == null
          ? const Center(child: Text("No branch assigned"))
          : Column(
              children: [
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .where('role', isEqualTo: 'waiter')
                        .where('branch_id', isEqualTo: _branchId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      // Apply sorting
                      if (_sortBy == "alphabetical") {
                        docs.sort(
                          (a, b) =>
                              a['full_name'].toString().toLowerCase().compareTo(
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
                                columnSpacing: 40,
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.grey.shade200,
                                ),
                                columns: const [
                                  DataColumn(label: Text("Name")),
                                  DataColumn(label: Text("Date")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                rows: docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final createdAt =
                                      data['created_at'] as Timestamp?;
                                  final formattedDate = createdAt != null
                                      ? dateFormat.format(createdAt.toDate())
                                      : "N/A";

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
                                      DataCell(Text(formattedDate)),
                                      DataCell(
                                        Center(
                                          child: IconButton(
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
                                                await _firestore
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
