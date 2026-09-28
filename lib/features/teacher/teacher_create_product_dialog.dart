import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/media_image.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/database_repository.dart';

class TeacherCreateProductDialog extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final VoidCallback onProductCreated;

  const TeacherCreateProductDialog({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.onProductCreated,
  });

  @override
  State<TeacherCreateProductDialog> createState() => _TeacherCreateProductDialogState();
}

class _TeacherCreateProductDialogState extends State<TeacherCreateProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '100');
  final TextEditingController _imageUrlController = TextEditingController();
  final DatabaseRepository _db = DatabaseRepository();
  final Uuid _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isAllGroups = true;
  final Set<String> _selectedGroupIds = {};
  bool _isLoading = false;
  String? _nameError;
  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (picked != null) {
      setState(() {
        _selectedImagePath = picked.path;
        _imageUrlController.text = picked.path;
      });
    }
  }

  Future<void> _createProduct() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (name.isEmpty) {
      setState(() => _nameError = l10n.requiredField);
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narx 0 dan katta bo‘lishi kerak')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final productId = 'prod_${_uuid.v4().substring(0, 8)}';
    final product = ProductModel(
      productId: productId,
      teacherId: widget.teacherId,
      teacherName: widget.teacherName,
      groupIds: _isAllGroups ? ['all'] : _selectedGroupIds.toList(),
      name: name,
      imageUrl: _selectedImagePath != null
          ? _selectedImagePath!
          : (_imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=800&auto=format&fit=crop&q=80'),
      price: price,
      active: true,
      createdAt: DateTime.now(),
    );

    await _db.createProduct(product);

    if (mounted) {
      widget.onProductCreated();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productCreatedSuccess),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = _db.getTeacherGroups(widget.teacherId);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.addProduct,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n.productName,
              hintText: l10n.productNameHint,
              controller: _nameController,
              isRequired: true,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: l10n.productPrice,
              controller: _priceController,
              keyboardType: TextInputType.number,
              isRequired: true,
              prefixIcon: const Icon(Icons.star, color: AppColors.starGold, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.productImageUrl,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardAlt : Colors.white,
                  borderRadius: AppStyles.roundedMedium,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: _selectedImagePath == null && _imageUrlController.text.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Galereyadan rasm tanlang',
                              style: GoogleFonts.outfit(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: AppStyles.roundedMedium,
                        child: MediaImage(
                          imageUrl: _selectedImagePath ?? _imageUrlController.text.trim(),
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                          placeholder: const Center(
                            child: Icon(Icons.card_giftcard, size: 40),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.productVisibility,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(l10n.allMyGroups)),
                    selected: _isAllGroups,
                    onSelected: (_) => setState(() => _isAllGroups = true),
                    selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                    labelStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: _isAllGroups ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(l10n.selectedGroupsOnly)),
                    selected: !_isAllGroups,
                    onSelected: (_) => setState(() => _isAllGroups = false),
                    selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                    labelStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: !_isAllGroups ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),

            if (!_isAllGroups) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: groups.map((g) {
                  final isSelected = _selectedGroupIds.contains(g.groupId);
                  return FilterChip(
                    label: Text(g.name),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedGroupIds.add(g.groupId);
                        } else {
                          _selectedGroupIds.remove(g.groupId);
                        }
                      });
                    },
                    selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: l10n.addProduct,
                    onPressed: _isLoading ? null : _createProduct,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
