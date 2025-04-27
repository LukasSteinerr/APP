import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/xtream_connection.dart';
import '../providers/connections_provider.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import '../widgets/simple_placeholder.dart';
import '../widgets/loading_overlay.dart';
import '../utils/validators.dart';
import 'main_screen.dart';

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
  bool _isPreloading = false;
  String? _errorMessage;

  // Preloading steps
  final List<String> _preloadingSteps = [
    'Connecting to server...',
    'Loading Live TV categories...',
    'Loading Movies categories...',
    'Loading TV Shows categories...',
    'Preloading initial content...',
  ];
  int _currentPreloadStep = 0;

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

    return Stack(
      children: [
        Scaffold(
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
                              : Text(
                                AppStrings.save,
                                style: AppTextStyles.button,
                              ),
                    ),

                    const SizedBox(height: AppPaddings.medium),

                    // Cancel Button
                    OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
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
        ),
        // Show loading overlay during preloading
        if (_isPreloading)
          LoadingOverlay(
            message: 'Setting up your connection',
            loadingSteps: _preloadingSteps,
            currentStep: _currentPreloadStep,
          ),
      ],
    );
  }

  // Preload data for the newly added connection
  Future<void> _preloadData() async {
    debugPrint('===== ADD CONNECTION: Starting _preloadData() =====');
    try {
      // Get the latest connections
      debugPrint('ADD CONNECTION: Getting ConnectionsProvider');
      final connectionsProvider = Provider.of<ConnectionsProvider>(
        context,
        listen: false,
      );

      // Get the content provider
      debugPrint('ADD CONNECTION: Getting ContentProvider');
      final contentProvider = Provider.of<ContentProvider>(
        context,
        listen: false,
      );

      // Show preloading overlay
      debugPrint('ADD CONNECTION: Showing preloading overlay');
      setState(() {
        _isLoading = false;
        _isPreloading = true;
        _currentPreloadStep = 0;
      });

      // Set the connection in the content provider
      debugPrint('ADD CONNECTION: Getting connections list');
      final connections = connectionsProvider.connections;
      debugPrint('ADD CONNECTION: Found ${connections.length} connections');

      if (connections.isNotEmpty) {
        // Get the most recently added connection
        final latestConnection = connections.first;
        debugPrint(
          'ADD CONNECTION: Setting connection: ${latestConnection.name}',
        );
        contentProvider.setConnection(latestConnection);

        // Update step
        debugPrint('ADD CONNECTION: Updating preload step to 1');
        setState(() {
          _currentPreloadStep = 1;
        });

        // Preload all data
        debugPrint('ADD CONNECTION: Starting data preloading');
        final success = await contentProvider.preloadAllData();
        debugPrint(
          'ADD CONNECTION: Preloading completed with success=$success',
        );

        if (success && mounted) {
          // Navigate to the main screen
          debugPrint('ADD CONNECTION: Navigating to MainScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // If preloading failed, still navigate but show an error
          debugPrint('ADD CONNECTION: Preloading failed or widget unmounted');
          if (mounted) {
            debugPrint(
              'ADD CONNECTION: Navigating back and showing error snackbar',
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Some content could not be preloaded. You may experience delays when switching tabs.',
                ),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // If no connections found, just go back
        debugPrint('ADD CONNECTION: No connections found');
        if (mounted) {
          debugPrint('ADD CONNECTION: Navigating back');
          Navigator.pop(context);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('===== ADD CONNECTION ERROR =====');
      debugPrint('Error during preloading: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('================================');

      if (mounted) {
        debugPrint(
          'ADD CONNECTION: Navigating back and showing error snackbar',
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during setup: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          if (widget.connection == null) {
            // Only preload data for new connections
            await _preloadData();
          } else {
            Navigator.pop(context);
          }
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
