import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/xtream_connection.dart';
import '../providers/connections_provider.dart';
import '../utils/constants.dart';
import '../widgets/simple_placeholder.dart';
import '../utils/validators.dart';

class AddConnectionScreen extends StatefulWidget {
  final XtreamConnection? connection;

  const AddConnectionScreen({super.key, this.connection});

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // If editing an existing connection, populate the form fields
    if (widget.connection != null) {
      _nameController.text = widget.connection!.name;
      _serverUrlController.text = widget.connection!.serverUrl;
      _usernameController.text = widget.connection!.username;
      _passwordController.text = widget.connection!.password;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.connection != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editConnection : AppStrings.addConnection,
        ),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.large),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppPaddings.medium),
                    decoration: BoxDecoration(
                      color: const Color(
                        0x19CF6679,
                      ), // 10% opacity of AppColors.error (0xFFCF6679)
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: AppPaddings.large),
                ],

                // Connection Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.connectionName,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                  style: AppTextStyles.body1,
                  validator: Validators.validateConnectionName,
                ),
                const SizedBox(height: AppPaddings.medium),

                // Server URL
                TextFormField(
                  controller: _serverUrlController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.serverUrl,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.card,
                    hintText: 'http://example.com:8080',
                  ),
                  style: AppTextStyles.body1,
                  validator: Validators.validateServerUrl,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: AppPaddings.medium),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.username,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                  style: AppTextStyles.body1,
                  validator: Validators.validateUsername,
                ),
                const SizedBox(height: AppPaddings.medium),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.password,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                  style: AppTextStyles.body1,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),
                const SizedBox(height: AppPaddings.extraLarge),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppPaddings.medium,
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: SimplePlaceholder(width: 20, height: 20),
                          )
                          : Text(AppStrings.save, style: AppTextStyles.button),
                ),

                const SizedBox(height: AppPaddings.medium),

                // Cancel Button
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppPaddings.medium,
                    ),
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveConnection() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<ConnectionsProvider>(context, listen: false);
      bool success;

      // Fix URL format if needed
      String serverUrl = _serverUrlController.text.trim();
      if (!serverUrl.startsWith('http://') &&
          !serverUrl.startsWith('https://')) {
        serverUrl = 'http://$serverUrl';
      }

      if (widget.connection != null) {
        // Update existing connection
        final updatedConnection = XtreamConnection(
          id: widget.connection!.id,
          name: _nameController.text.trim(),
          serverUrl: serverUrl,
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          addedDate: widget.connection!.addedDate,
        );

        success = await provider.updateConnection(updatedConnection);
      } else {
        // Add new connection
        success = await provider.addConnection(
          name: _nameController.text.trim(),
          serverUrl: serverUrl,
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to save connection. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }
}
