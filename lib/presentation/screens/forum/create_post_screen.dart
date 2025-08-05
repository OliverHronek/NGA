import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/forum_model.dart';

class CreatePostScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CreatePostScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('✍️ Neuer Post'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.forum, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            const Text(
                              'Neuen Post erstellen',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kategorie: ${widget.categoryName}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Teile deine Gedanken und starte eine Diskussion!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title Field
                CustomTextField(
                  label: 'Titel',
                  hint: 'Gib deinem Post einen aussagekräftigen Titel',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Titel ist erforderlich';
                    }
                    if (value.length < 5) {
                      return 'Titel muss mindestens 5 Zeichen haben';
                    }
                    if (value.length > 200) {
                      return 'Titel ist zu lang (max. 200 Zeichen)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Content Field
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Inhalt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: 'Schreibe hier deinen Post...\n\nTipps:\n• Bleibe respektvoll und konstruktiv\n• Verwende klare Argumente\n• Beziehe dich auf Fakten',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inhalt ist erforderlich';
                            }
                            if (value.length < 20) {
                              return 'Post muss mindestens 20 Zeichen haben';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Character Counter
                        Align(
                          alignment: Alignment.centerRight,
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _contentController,
                            builder: (context, value, child) {
                              final charCount = value.text.length;
                              final color = charCount < 20 
                                ? AppColors.error 
                                : charCount > 5000 
                                  ? AppColors.error 
                                  : AppColors.textSecondary;
                              
                              return Text(
                                '$charCount / 5000 Zeichen',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Guidelines Card
                Card(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Community-Richtlinien',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildGuideline('Bleibe respektvoll und höflich'),
                        _buildGuideline('Verwende eine sachliche Sprache'),
                        _buildGuideline('Keine persönlichen Angriffe'),
                        _buildGuideline('Beziehe dich auf verlässliche Quellen'),
                        _buildGuideline('Konstruktive Diskussion erwünscht'),
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
                      text: 'Post veröffentlichen',
                      onPressed: _createPost,
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

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.accent)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    final postRequest = CreatePostRequest(
      categoryId: widget.categoryId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final success = await forumProvider.createPost(postRequest);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Post erfolgreich erstellt!'),
          backgroundColor: AppColors.accent,
        ),
      );
      
      Navigator.of(context).pop(); // Zurück zur Posts-Liste
    }
  }
}
