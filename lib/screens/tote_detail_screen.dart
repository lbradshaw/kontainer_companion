import 'package:flutter/material.dart';
import '../models/tote.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ToteDetailScreen extends StatefulWidget {
  final int toteId;

  const ToteDetailScreen({super.key, required this.toteId});

  @override
  State<ToteDetailScreen> createState() => _ToteDetailScreenState();
}

class _ToteDetailScreenState extends State<ToteDetailScreen> {
  final ApiService _apiService = ApiService();
  Tote? _tote;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTote();
  }

  Future<void> _loadTote() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tote = await _apiService.getTote(widget.toteId);
      setState(() {
        _tote = tote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tote'),
        content: const Text('Are you sure you want to delete this tote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteTote(widget.toteId);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tote Details'),
        actions: [
          if (_tote != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTote,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTote,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tote == null) {
      return const Center(child: Text('Tote not found'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _tote!.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 16),
        const Text(
          'Items:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(_tote!.items),
        const SizedBox(height: 24),
        if (_tote!.qrCode != null) ...[
          const Text(
            'QR Code:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(
                Uri.parse(_tote!.qrCode!).data!.contentAsBytes(),
                width: 200,
                height: 200,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
