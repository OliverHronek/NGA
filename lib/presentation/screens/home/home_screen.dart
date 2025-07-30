import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import '../polls/polls_list_screen.dart';
import '../forum/forum_categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const PollsTab(),
    const ForumTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        //title: const Text('🇦🇹 Next Generation Austria'),
        title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nga_logo_small.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Next Generation Austria',
                    style: GoogleFonts.roboto(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
                      actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text('Hallo, ${authProvider.user?.displayName ?? 'User'}!'),
                    enabled: false,
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Abmelden'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: 'Abstimmungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Willkommen, ${authProvider.user?.displayName ?? 'Unbekannt'}! 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gestalte Österreichs Zukunft mit deiner Stimme!',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          const Text(
            'Schnellübersicht',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Aktive Abstimmungen',
                  count: '12',
                  icon: Icons.poll,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Forum Diskussionen',
                  count: '45',
                  icon: Icons.forum,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'Neueste Aktivitäten',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildActivityCard(
            title: 'Neue Abstimmung: Klimaschutz-Maßnahmen',
            subtitle: 'Stimme jetzt ab über wichtige Umweltpolitik',
            icon: Icons.poll,
            time: 'vor 2 Stunden',
          ),
          
          _buildActivityCard(
            title: 'Forum: Diskussion über Bildungsreform',
            subtitle: '23 neue Kommentare in der Bildungsdiskussion',
            icon: Icons.forum,
            time: 'vor 4 Stunden',
          ),
          
          _buildActivityCard(
            title: 'Umfrage beendet: Öffentlicher Verkehr',
            subtitle: '89% für den Ausbau des ÖV-Netzes',
            icon: Icons.check_circle,
            time: 'vor 1 Tag',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// Placeholder Tabs
class PollsTab extends StatelessWidget {
  const PollsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PollsListScreen();
  }
}

// Forum TAB:
class ForumTab extends StatelessWidget {
  const ForumTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForumCategoriesScreen();
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Profil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Coming Soon! 👤'),
        ],
      ),
    );
  }
}