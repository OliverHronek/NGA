import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/poll_model.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  DateTime? _endDate;
  bool _isPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('📝 Abstimmung erstellen'),
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
                              'Neue Abstimmung',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Erstelle eine neue Abstimmung für die NGA-Community. Stelle eine wichtige Frage und lass andere ihre Meinung äußern!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                CustomTextField(
                  label: 'Titel der Abstimmung',
                  hint: 'z.B. "Welche Klimaschutz-Maßnahme ist am wichtigsten?"',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Titel ist erforderlich';
                    }
                    if (value.length < 10) {
                      return 'Titel muss mindestens 10 Zeichen haben';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description
                CustomTextField(
                  label: 'Beschreibung (optional)',
                  hint: 'Weitere Details zur Abstimmung...',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                ),

                const SizedBox(height: 24),

                // Options Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.list, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            const Text(
                              'Antwortmöglichkeiten',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Option Fields
                        ..._optionControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'Option ${index + 1}',
                                      hintText: 'Antwortmöglichkeit eingeben',
                                      prefixIcon: Icon(
                                        Icons.radio_button_unchecked,
                                        color: AppColors.pollColors[index % AppColors.pollColors.length],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (index < 2 && (value == null || value.isEmpty)) {
                                        return 'Mindestens 2 Optionen erforderlich';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (index >= 2) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _removeOption(index),
                                    icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                        
                        // Add Option Button
                        if (_optionControllers.length < 6)
                          OutlinedButton.icon(
                            onPressed: _addOption,
                            icon: const Icon(Icons.add),
                            label: const Text('Option hinzufügen'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Settings Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.settings, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Einstellungen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // End Date
                        InkWell(
                          onTap: _selectEndDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textHint),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, color: AppColors.textSecondary),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Enddatum (optional)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _endDate != null
                                        ? '${_endDate!.day}.${_endDate!.month}.${_endDate!.year}'
                                        : 'Kein Enddatum',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (_endDate != null)
                                  IconButton(
                                    onPressed: () => setState(() => _endDate = null),
                                    icon: const Icon(Icons.clear, color: AppColors.error),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Public Switch
                        Row(
                          children: [
                            const Icon(Icons.public, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Öffentliche Abstimmung',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Für alle NGA-Mitglieder sichtbar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPublic,
                              onChanged: (value) => setState(() => _isPublic = value),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Error Message
                Consumer<PollProvider>(
                  builder: (context, pollProvider, child) {
                    if (pollProvider.error != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pollProvider.error!,
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
                Consumer<PollProvider>(
                  builder: (context, pollProvider, child) {
                    return CustomButton(
                      text: 'Abstimmung erstellen',
                      onPressed: _createPoll,
                      isLoading: pollProvider.isLoading,
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

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (index >= 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

    // Options sammeln (nur nicht-leere)
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens 2 Antwortmöglichkeiten erforderlich'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pollRequest = CreatePollRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
        ? _descriptionController.text.trim() 
        : null,
      options: options,
      endDate: _endDate,
      isPublic: _isPublic,
    );

    final pollProvider = Provider.of<PollProvider>(context, listen: false);
    final success = await pollProvider.createPoll(pollRequest);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Abstimmung erfolgreich erstellt!'),
          backgroundColor: AppColors.accent,
        ),
      );
      
      Navigator.of(context).pop(); // Zurück zur Polls-Liste
    }
  }
}