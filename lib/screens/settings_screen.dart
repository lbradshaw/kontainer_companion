import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, String>> _servers = [];
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
      final List<dynamic> raw = json.decode(urlsJson);
      // Migration: if old format (list of strings), convert to list of maps
      List<Map<String, String>> servers;
      if (raw.isNotEmpty && raw.first is String) {
        servers = raw.map((e) => {"name": "", "url": e.toString()}).toList();
        await prefs.setString('server_urls', json.encode(servers));
      } else {
        servers = raw
            .map((e) => (e is Map<String, dynamic>)
                ? {
                    "name": e["name"]?.toString() ?? "",
                    "url": e["url"]?.toString() ?? ""
                  }
                : {"name": "", "url": e.toString()})
            .toList();
      }
      setState(() {
        _servers = servers;
        _selectedIdx = (selectedIdx >= 0 && selectedIdx < servers.length)
            ? selectedIdx
            : 0;
        _isLoading = false;
      });
    } else {
      // Only migrate if both server_urls and server_url are missing
      final singleUrl = prefs.getString('server_url');
      if (singleUrl != null) {
        await prefs.setString(
            'server_urls',
            json.encode([
              {"name": "", "url": singleUrl}
            ]));
        await prefs.setInt('selected_server_url_idx', 0);
        setState(() {
          _servers = [
            {"name": "", "url": singleUrl}
          ];
          _selectedIdx = 0;
          _isLoading = false;
        });
      } else {
        // No URLs at all, use default
        await prefs.setString(
            'server_urls',
            json.encode([
              {"name": "", "url": 'http://localhost:3818'}
            ]));
        await prefs.setInt('selected_server_url_idx', 0);
        setState(() {
          _servers = [
            {"name": "", "url": 'http://localhost:3818'}
          ];
          _selectedIdx = 0;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUrls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_urls', json.encode(_servers));
    await prefs.setInt('selected_server_url_idx', _selectedIdx);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  void _addUrl() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                  labelText: 'URL', hintText: 'http://localhost:3818'),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'url': urlController.text.trim(),
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result['url']!.isNotEmpty) {
      setState(() {
        _servers.add({'name': result['name'] ?? '', 'url': result['url']!});
        _selectedIdx = _servers.length - 1;
      });
      await _saveUrls();
    }
  }

  void _editUrl(int idx) async {
    final nameController =
        TextEditingController(text: _servers[idx]['name'] ?? '');
    final urlController =
        TextEditingController(text: _servers[idx]['url'] ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                  labelText: 'URL', hintText: 'http://localhost:3818'),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'url': urlController.text.trim(),
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result['url']!.isNotEmpty) {
      setState(() {
        _servers[idx] = {'name': result['name'] ?? '', 'url': result['url']!};
      });
      await _saveUrls();
    }
  }

  void _deleteUrl(int idx) async {
    if (_servers.length == 1) return; // Don't allow deleting last URL
    setState(() {
      _servers.removeAt(idx);
      if (_selectedIdx >= _servers.length) {
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
                    itemCount: _servers.length,
                    itemBuilder: (context, idx) {
                      final name = _servers[idx]['name'] ?? '';
                      final url = _servers[idx]['url'] ?? '';
                      return Dismissible(
                        key: ValueKey(url),
                        direction: _servers.length == 1
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        onDismissed: (_) => _deleteUrl(idx),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(name.isNotEmpty ? name : url),
                          subtitle: null,
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
                        label: const Text('Add Server'),
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
