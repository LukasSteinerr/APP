import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connections_provider.dart';
import '../utils/constants.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  // Helper method to add a test connection
  Future<void> _addTestConnection() async {
    final provider = Provider.of<ConnectionsProvider>(context, listen: false);
    final success = await provider.addConnection(
      name: 'Test Connection ${DateTime.now().millisecondsSinceEpoch}',
      serverUrl: 'test.server.com',
      username: 'testuser',
      password: 'testpass',
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection added successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
    }
  }

  // Helper method to delete the first connection
  Future<void> _deleteFirstConnection() async {
    final provider = Provider.of<ConnectionsProvider>(context, listen: false);
    if (provider.connections.isEmpty) return;

    final success = await provider.deleteConnection(
      provider.connections.first.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
    }
  }

  // Helper method to delete all connections
  Future<void> _deleteAllConnections() async {
    final provider = Provider.of<ConnectionsProvider>(context, listen: false);
    if (provider.connections.isEmpty) return;

    final success = await provider.deleteAllConnections();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All connections deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
    }
  }

  // Helper method to delete a specific connection
  Future<void> _deleteConnection(String id) async {
    final provider = Provider.of<ConnectionsProvider>(context, listen: false);
    await provider.deleteConnection(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ConnectionsProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Connections: ${provider.connections.length}',
                  style: AppTextStyles.headline2,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addTestConnection,
                  child: const Text('Add Test Connection'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      provider.connections.isEmpty
                          ? null
                          : _deleteFirstConnection,
                  child: const Text('Delete First Connection'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      provider.connections.isEmpty
                          ? null
                          : _deleteAllConnections,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete All Connections'),
                ),
                const SizedBox(height: 16),
                const Text('Connections List:', style: AppTextStyles.headline3),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.connections.isEmpty
                          ? const Center(child: Text('No connections found'))
                          : ListView.builder(
                            itemCount: provider.connections.length,
                            itemBuilder: (context, index) {
                              final connection = provider.connections[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(connection.name),
                                  subtitle: Text(
                                    '${connection.serverUrl}\nAdded: ${connection.addedDate.toString().substring(0, 16)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed:
                                        () => _deleteConnection(connection.id),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
