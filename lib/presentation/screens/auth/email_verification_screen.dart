import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? verificationToken;

  const EmailVerificationScreen({
    super.key,
    this.verificationToken,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerifying = false;
  bool _verificationComplete = false;
  String? _verificationMessage;
  bool _verificationSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.verificationToken != null) {
      _verifyEmail();
    }
  }

  Future<void> _verifyEmail() async {
    if (widget.verificationToken == null) return;

    setState(() {
      _isVerifying = true;
      _verificationMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyEmail(widget.verificationToken!);

    setState(() {
      _isVerifying = false;
      _verificationComplete = true;
      _verificationSuccess = success;
      _verificationMessage = success 
          ? 'Ihre Email-Adresse wurde erfolgreich bestätigt!'
          : authProvider.error ?? 'Verifizierung fehlgeschlagen';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Email-Verifizierung'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _verificationComplete
                      ? (_verificationSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1))
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _verificationComplete
                      ? (_verificationSuccess ? Icons.check_circle : Icons.error)
                      : Icons.email,
                  size: 64,
                  color: _verificationComplete
                      ? (_verificationSuccess ? Colors.green : Colors.red)
                      : AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _verificationComplete
                    ? (_verificationSuccess ? 'Verifizierung erfolgreich!' : 'Verifizierung fehlgeschlagen')
                    : 'Email wird verifiziert...',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Loading or Result
              if (_isVerifying) ...[
                const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bitte warten...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else if (_verificationComplete) ...[
                // Success/Error Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _verificationSuccess 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _verificationSuccess 
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _verificationMessage ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: _verificationSuccess ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                if (_verificationSuccess) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Zur Hauptseite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ] else ...[
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          authProvider.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Neue Bestätigungs-Email wurde gesendet'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Neue Email anfordern'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: const Text('Später versuchen'),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Manual verification option if no token provided
                const Text(
                  'Kein Verifizierungs-Token erhalten?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    authProvider.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bestätigungs-Email wurde gesendet'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Bestätigungs-Email senden'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
