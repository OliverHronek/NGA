import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/app_colors.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#007AFF';

  final List<String> _colors = [
    '#007AFF', '#FF6B6B', '#4ECDC4', '#45B7D1',
    '#96CEB4', '#FFEAA7', '#DDA0DD', '#98D8C8',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('📂 Kategorie erstellen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Neue Kategorie',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Erstelle eine neue Diskussionskategorie für das NGA Forum.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name Field
                CustomTextField(
                  label: 'Kategorie-Name',
                  hint: 'z.B. "Klimaschutz" oder "Bildungspolitik"',
                  controller: _nameController,
                  prefixIcon: Icons.category,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name ist erforderlich';
                    }
                    if (value.length < 3) {
                      return 'Name muss mindestens 3 Zeichen haben';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description Field
                CustomTextField(
                  label: 'Beschreibung (optional)',
                  hint: 'Worum geht es in dieser Kategorie?',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                ),

                const SizedBox(height: 24),

                // Color Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farbe wählen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colors.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.textPrimary : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Error Message
                Consumer<ForumProvider>(
                  builder: (context, forumProvider, child) {
                    if (forumProvider.error != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                forumProvider.error!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Create Button
                Consumer<ForumProvider>(
                  builder: (context, forumProvider, child) {
                    return CustomButton(
                      text: 'Kategorie erstellen',
                      onPressed: _createCategory,
                      isLoading: forumProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final success = await forumProvider.createCategory(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
        ? _descriptionController.text.trim() 
        : null,
      color: _selectedColor,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Kategorie erfolgreich erstellt!'),
          backgroundColor: AppColors.accent,
        ),
      );
      
      Navigator.of(context).pop(); // Zurück zur Kategorien-Liste
    }
  }
}
