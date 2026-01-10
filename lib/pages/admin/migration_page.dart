import 'package:flutter/material.dart';
import '../../utils/migration_utils.dart';

class MigrationPage extends StatefulWidget {
  const MigrationPage({super.key});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  bool _running = false;
  String _status = "Not started";

  Future<void> _runMigration() async {
    setState(() {
      _running = true;
      _status = "Running...";
    });
    try {
      await migrateItemsAndBranchMenus();
      setState(() {
        _status = "✅ Migration complete";
      });
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Run Migration")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _running ? null : _runMigration,
              child: const Text("Run Migration Script"),
            ),
          ],
        ),
      ),
    );
  }
}
