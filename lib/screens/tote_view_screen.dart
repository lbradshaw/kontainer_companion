import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/tote.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import 'tote_detail_screen.dart';

class ToteViewScreen extends StatefulWidget {
  final Tote tote;

  const ToteViewScreen({Key? key, required this.tote}) : super(key: key);

  @override
  State<ToteViewScreen> createState() => _ToteViewScreenState();
}

class _ToteViewScreenState extends State<ToteViewScreen> {
  final ApiService _apiService = ApiService();
  late Tote _currentTote;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTote = widget.tote;
    _loadToteData();
  }

  Future<void> _loadToteData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final freshTote = await _apiService.getTote(widget.tote.id);
      setState(() {
        _currentTote = freshTote;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tote: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFullImage(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(imageData),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToteDetailScreen(tote: _currentTote),
      ),
    );

    if (result == true) {
      // Reload tote data after edit
      _loadToteData();
    }
  }

  Future<void> _deleteTote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Tote', style: TextStyle(color: AppTheme.textColor)),
        content: const Text(
          'Are you sure you want to delete this tote?',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.deleteTote(_currentTote.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tote deleted successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting tote: $e'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Tote Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.accentColor),
            onPressed: _isLoading ? null : _navigateToEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.dangerColor),
            onPressed: _isLoading ? null : _deleteTote,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
          : RefreshIndicator(
              onRefresh: _loadToteData,
              color: AppTheme.accentColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tote Name
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Name',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTote.name,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items List
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTote.items.isNotEmpty
                                ? _currentTote.items
                                : 'No items listed',
                            style: TextStyle(
                              color: _currentTote.items.isNotEmpty
                                  ? AppTheme.textColor
                                  : AppTheme.textSecondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Code (if available)
                    if (_currentTote.qrCode != null && _currentTote.qrCode!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QR Code',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentTote.qrCode!,
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 16,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Images
                    const Text(
                      'Images',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentTote.images.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Center(
                          child: Text(
                            'No images',
                            style: TextStyle(color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _currentTote.images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullImage(_currentTote.images[index]),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: MemoryImage(_currentTote.images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
