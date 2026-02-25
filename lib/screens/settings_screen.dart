import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _serverUrls = [];
  int _selectedIdx = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Migration: if only single URL exists, migrate
    final urlsJson = prefs.getString('server_urls');
    final selectedIdx = prefs.getInt('selected_server_url_idx') ?? 0;
    if (urlsJson != null) {
      final List<String> urls = (json.decode(urlsJson) as List<dynamic>).map((e) => e.toString()).toList();
      setState(() {
        _serverUrls = urls;
        _selectedIdx = (selectedIdx >= 0 && selectedIdx < urls.length) ? selectedIdx : 0;
        _isLoading = false;
      });
    } else {
      // Only migrate if both server_urls and server_url are missing
      final singleUrl = prefs.getString('server_url');
      if (singleUrl != null) {
        await prefs.setString('server_urls', json.encode([singleUrl]));
        await prefs.setInt('selected_server_url_idx', 0);
        setState(() {
          _serverUrls = [singleUrl];
          _selectedIdx = 0;
          _isLoading = false;
        });
      } else {
        // No URLs at all, use default
        await prefs.setString('server_urls', json.encode(['http://localhost:3818']));
        await prefs.setInt('selected_server_url_idx', 0);
        setState(() {
          _serverUrls = ['http://localhost:3818'];
          _selectedIdx = 0;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUrls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_urls', json.encode(_serverUrls));
    await prefs.setInt('selected_server_url_idx', _selectedIdx);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  void _addUrl() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'http://localhost:3818'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _serverUrls.add(result.trim());
        _selectedIdx = _serverUrls.length - 1;
      });
      await _saveUrls();
    }
  }

  void _editUrl(int idx) async {
    final controller = TextEditingController(text: _serverUrls[idx]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'http://localhost:3818'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _serverUrls[idx] = result.trim();
      });
      await _saveUrls();
    }
  }

  void _deleteUrl(int idx) async {
    if (_serverUrls.length == 1) return; // Don't allow deleting last URL
    setState(() {
      _serverUrls.removeAt(idx);
      if (_selectedIdx >= _serverUrls.length) {
        _selectedIdx = 0;
      }
    });
    await _saveUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _serverUrls.length,
                    itemBuilder: (context, idx) {
                      return Dismissible(
                        key: ValueKey(_serverUrls[idx]),
                        direction: _serverUrls.length == 1 ? DismissDirection.none : DismissDirection.endToStart,
                        onDismissed: (_) => _deleteUrl(idx),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(_serverUrls[idx]),
                          leading: Radio<int>(
                            value: idx,
                            groupValue: _selectedIdx,
                            onChanged: (val) {
                              setState(() {
                                _selectedIdx = val!;
                              });
                              _saveUrls();
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editUrl(idx),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIdx = idx;
                            });
                            _saveUrls();
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addUrl,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Server URL'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _saveUrls,
                        child: const Text('Save Settings'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
