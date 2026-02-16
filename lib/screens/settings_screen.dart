import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final serverUrl = prefs.getString('server_url') ?? 'http://localhost:3818';
    setState(() {
      _serverUrlController.text = serverUrl;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _serverUrlController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _serverUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://localhost:3818',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ],
            ),
    );
  }
}
