import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tote.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ToteDetailScreen extends StatefulWidget {
  final Tote? tote;
  final int? parentId; // For creating sub-containers

  const ToteDetailScreen({Key? key, this.tote, this.parentId}) : super(key: key);

  @override
  State<ToteDetailScreen> createState() => _ToteDetailScreenState();
}

class _ToteDetailScreenState extends State<ToteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _itemsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  
  List<Uint8List> _images = [];
  List<String> _imageMimeTypes = []; // Track MIME types for new images
  List<int> _imageIds = []; // Track image IDs from backend
  List<int> _deletedImageIds = []; // Track which images to delete
  bool _isLoading = false;
  bool _isEditing = false;
  int _originalImageCount = 0;
  Tote? _parentTote; // Store parent info when creating sub-container

  @override
  void initState() {
    super.initState();
    if (widget.tote != null) {
      _loadToteData();
      _isEditing = true;
    } else if (widget.parentId != null) {
      _loadParentData();
    }
  }

  Future<void> _loadParentData() async {
    try {
      final parent = await _apiService.getTote(widget.parentId!);
      setState(() {
        _parentTote = parent;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parent: $e')),
        );
      }
    }
  }

  Future<void> _loadToteData() async {
    if (widget.tote == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch fresh data from the server
      final freshTote = await _apiService.getTote(widget.tote!.id);
      
      setState(() {
        _nameController.text = freshTote.name;
        _locationController.text = freshTote.location ?? '';
        _itemsController.text = freshTote.items;
        _images = List.from(freshTote.images);
        _imageMimeTypes = []; // Clear MIME types (existing images already in DB)
        _imageIds = List.from(freshTote.imageIds);
        _originalImageCount = freshTote.images.length;
        _deletedImageIds.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading kontainer: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        // Store both bytes and MIME type
        setState(() {
          _images.add(bytes);
          // XFile.mimeType gives us the MIME type (e.g., "image/jpeg")
          _imageMimeTypes.add(image.mimeType ?? 'image/jpeg');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      for (var image in images) {
        final bytes = await image.readAsBytes();
        setState(() {
          _images.add(bytes);
          _imageMimeTypes.add(image.mimeType ?? 'image/jpeg');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      // If this is an existing image (has an ID), track it for deletion
      if (index < _imageIds.length && _imageIds[index] > 0) {
        _deletedImageIds.add(_imageIds[index]);
        _imageIds.removeAt(index);
      } else {
        // This is a new image (not yet saved to backend)
        // Calculate its index in _imageMimeTypes (after existing images)
        final mimeTypeIndex = index - _originalImageCount;
        if (mimeTypeIndex >= 0 && mimeTypeIndex < _imageMimeTypes.length) {
          _imageMimeTypes.removeAt(mimeTypeIndex);
        }
      }
      _images.removeAt(index);
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.accentColor),
              title: const Text('Take Photo', style: TextStyle(color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.accentColor),
              title: const Text('Choose from Gallery', style: TextStyle(color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.accentColor),
              title: const Text('Choose Multiple', style: TextStyle(color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
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

  Future<void> _saveTote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        // Track deleted count before clearing
        final deletedCount = _deletedImageIds.length;
        
        // First, delete any removed images
        if (_deletedImageIds.isNotEmpty) {
          for (final imageId in _deletedImageIds) {
            await _apiService.deleteImage(imageId);
          }
          _deletedImageIds.clear();
        }
        
        // Update existing tote - only send name and items
        final toteUpdate = Tote(
          id: widget.tote!.id,
          name: _nameController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          items: _itemsController.text,
          qrCode: widget.tote!.qrCode,
          images: [], // Don't send existing images in update
        );
        await _apiService.updateTote(toteUpdate);
        
        // Add new images separately if any were added
        // _imageMimeTypes only contains MIME types for NEW images (not existing ones)
        if (_imageMimeTypes.isNotEmpty) {
          // Get only the new images (those added after loading)
          final startIndex = _originalImageCount - deletedCount;
          final newImages = _images.sublist(startIndex);
          await _apiService.addImagesToTote(widget.tote!.id, newImages, _imageMimeTypes);
        }
        
        // Reload tote data to get fresh state from server
        final updatedTote = await _apiService.getTote(widget.tote!.id);
        setState(() {
          _images = updatedTote.images;
          _originalImageCount = _images.length;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kontainer updated successfully')),
          );
        }
      }else {
        // Create new tote with all images
        final tote = Tote(
          id: 0,
          name: _nameController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          items: _itemsController.text,
          qrCode: '',
          images: _images,
        );
        await _apiService.createTote(
          tote,
          imageMimeTypes: _imageMimeTypes,
          parentId: widget.parentId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kontainer created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving kontainer: $e'),
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

  Future<void> _deleteTote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Kontainer', style: TextStyle(color: AppTheme.textColor)),
        content: const Text(
          'Are you sure you want to delete this kontainer?',
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

    if (confirmed == true && widget.tote != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.deleteTote(widget.tote!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kontainer deleted successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting kontainer: $e'),
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
        title: Text(
          _isEditing
              ? 'Edit Kontainer'
              : (widget.parentId != null ? 'New Sub-Container' : 'New Kontainer')
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.dangerColor),
              onPressed: _isLoading ? null : _deleteTote,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Parent breadcrumb for sub-container creation
                    if (widget.parentId != null && _parentTote != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: Color(0xFF2196F3), width: 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Creating Sub-Container for:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                '← ${_parentTote!.name} (${_parentTote!.qrCode})',
                                style: const TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Kontainer Name',
                        labelStyle: const TextStyle(color: AppTheme.accentColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.accentColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.dangerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.dangerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g., Garage, Basement, Storage Unit A',
                        hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
                        labelStyle: const TextStyle(color: AppTheme.accentColor),
                        prefixIcon: const Icon(Icons.location_on, color: AppTheme.accentColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.accentColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemsController,
                      style: const TextStyle(color: AppTheme.textColor),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Items (one per line)',
                        labelStyle: const TextStyle(color: AppTheme.accentColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.accentColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.dangerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppTheme.dangerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Images',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showImageOptions,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Images'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: AppTheme.backgroundColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_images.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Center(
                          child: Text(
                            'No images added',
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
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _showFullImage(_images[index]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: MemoryImage(_images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.dangerColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    
                    // Add Sub-Container button (only when editing a top-level container)
                    if (_isEditing && widget.tote != null && widget.tote!.depth == 0) ...[
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ToteDetailScreen(
                                parentId: widget.tote!.id,
                              ),
                            ),
                          );
                          if (result == true) {
                            // Optionally reload to show updated children count
                            _loadToteData();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Sub-Container'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentColor,
                          side: const BorderSide(color: AppTheme.accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveTote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Update Kontainer' : 'Create Kontainer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
