import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import '../polls/polls_list_screen.dart';
import '../forum/forum_categories_screen.dart';
import '../../providers/dashboard_provider.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/user_model.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PremiumDashboardTab(onTabChange: (index) => setState(() => _currentIndex = index)),
      const PollsTab(),
      const ForumTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                    enabled: false,
                    child: Text('Hallo, ${authProvider.user?.displayName ?? 'User'}!'),
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
      body: screens[_currentIndex],
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

// Premium Dashboard Tab
class PremiumDashboardTab extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const PremiumDashboardTab({super.key, this.onTabChange});

  @override
  State<PremiumDashboardTab> createState() => _PremiumDashboardTabState();
}

class _PremiumDashboardTabState extends State<PremiumDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, authProvider, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: () => dashboardProvider.refreshData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(authProvider.user),
                
                const SizedBox(height: 24),
                
                // Premium Stats Cards
                _buildPremiumStatsGrid(dashboardProvider),
                
                const SizedBox(height: 24),
                
                // Trending Section
                _buildTrendingSection(dashboardProvider),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActionsSection(context),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/nga_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Willkommen zurück! 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.verificationStatus ?? 'Status',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsGrid(DashboardProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingGrid();
    }

    if (provider.error != null) {
      return _buildErrorCard(provider);
    }

    final stats = provider.stats;
    if (stats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen width
            int crossAxisCount = 2;
            double childAspectRatio = 0.85;
            
            if (constraints.maxWidth < 600) {
              // Mobile: 2 columns, taller cards
              crossAxisCount = 2;
              childAspectRatio = 0.75;
            } else if (constraints.maxWidth < 900) {
              // Tablet: 3 columns
              crossAxisCount = 3;
              childAspectRatio = 0.8;
            } else {
              // Desktop: 4 columns
              crossAxisCount = 4;
              childAspectRatio = 0.9;
            }
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildPremiumStatCard(
                  title: 'Community',
                  icon: Icons.people_rounded,
                  primaryStat: '${stats.totalUsers}',
                  primaryLabel: 'Nutzer',
                  secondaryStats: [
                    StatItem('0', 'Neu'),
                    StatItem('0%', 'OK'),
                    StatItem('0', 'On'),
                  ],
                  color: const Color(0xFF2196F3),
                ),
                
                _buildPremiumStatCard(
                  title: 'Votes',
                  icon: Icons.how_to_vote_rounded,
                  primaryStat: '${stats.totalVotes}',
                  primaryLabel: 'Stimmen',
                  secondaryStats: [
                    StatItem('${stats.activePolls}', 'Aktiv'),
                    StatItem('${stats.engagementRate}%', 'Rate'),
                    StatItem('${stats.totalVotes}', 'Total'),
                  ],
                  color: AppColors.primary,
                ),
                
                _buildPremiumStatCard(
                  title: 'Forum',
                  icon: Icons.forum_rounded,
                  primaryStat: '${stats.totalPosts}',
                  primaryLabel: 'Posts',
                  secondaryStats: [
                    StatItem('${stats.totalCategories}', 'Kat'),
                    StatItem('0', 'Kom'),
                    StatItem('${stats.totalPosts}', 'All'),
                  ],
                  color: const Color(0xFF9C27B0),
                ),
                
                _buildPremiumStatCard(
                  title: 'Activity',
                  icon: Icons.trending_up_rounded,
                  primaryStat: '${stats.engagementRate}%',
                  primaryLabel: 'Rate',
                  secondaryStats: [
                    StatItem(_getTrendText(stats.engagementRate), 'Trend'),
                    StatItem(_getAvgVotesPerUser(stats), 'Ø'),
                    StatItem(_getEngagementLevel(stats.engagementRate), 'Level'),
                  ],
                  color: const Color(0xFF4CAF50),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard({
    required String title,
    required IconData icon,
    required String primaryStat,
    required String primaryLabel,
    required List<StatItem> secondaryStats,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced from 20
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32, // Reduced from 40
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10), // Reduced from 12
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16, // Reduced from 20
                  ),
                ),
                
                const SizedBox(width: 8), // Reduced from 12
                
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12, // Reduced from 14
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced from 20
            
            // Primary Stat
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  primaryStat,
                  style: TextStyle(
                    fontSize: 28, // Reduced from 32
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 2), // Reduced from 4
            
            Text(
              primaryLabel,
              style: TextStyle(
                fontSize: 11, // Reduced from 13
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12), // Reduced from 20
            
            // Secondary Stats
            Container(
              padding: const EdgeInsets.only(top: 12), // Reduced from 16
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: secondaryStats.map((stat) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        FittedBox(
                          child: Text(
                            stat.value,
                            style: const TextStyle(
                              fontSize: 12, // Reduced from 14
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        FittedBox(
                          child: Text(
                            stat.label,
                            style: TextStyle(
                              fontSize: 8, // Reduced from 10
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )),
    );
  }

  Widget _buildErrorCard(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadDashboardData(),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(DashboardProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                const Text(
                  'Trending Abstimmungen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            if (provider.trendingPolls.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.poll_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Noch keine Trending-Abstimmungen',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...provider.trendingPolls.asMap().entries.map((entry) => 
                _buildTrendingItem(entry.value, entry.key + 1)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(TrendingPoll poll, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'von ${poll.creatorName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4CAF50), const Color(0xFF4CAF50).withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${poll.totalVotes} Stimmen',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Reduced from 24
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, // Reduced from 40
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 18, // Reduced from 20
                  ),
                ),
                
                const SizedBox(width: 12),
                
                const Text(
                  'Schnellaktionen',
                  style: TextStyle(
                    fontSize: 16, // Reduced from 18
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16), // Reduced from 20
            
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Flexible(
                      child: _buildQuickActionButton(
                        'Abstimmen',
                        Icons.how_to_vote_rounded,
                        AppColors.primary,
                        () => widget.onTabChange?.call(1),
                        constraints.maxWidth,
                      ),
                    ),
                    const SizedBox(width: 12), // Reduced from 16
                    Flexible(
                      child: _buildQuickActionButton(
                        'Diskutieren',
                        Icons.forum_rounded,
                        AppColors.secondary,
                        () => widget.onTabChange?.call(2),
                        constraints.maxWidth,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions for calculating real secondary stats
  String _getTrendText(int engagementRate) {
    if (engagementRate > 50) return '↗ Hoch';
    if (engagementRate > 20) return '→ Mittel';
    if (engagementRate > 0) return '↘ Niedrig';
    return '→ Neu';
  }

  String _getAvgVotesPerUser(DashboardStats stats) {
    if (stats.totalUsers == 0) return '0';
    final avg = stats.totalVotes / stats.totalUsers;
    return avg.toStringAsFixed(1);
  }

  String _getEngagementLevel(int engagementRate) {
    if (engagementRate > 70) return 'Sehr hoch';
    if (engagementRate > 50) return 'Hoch';
    if (engagementRate > 30) return 'Mittel';
    if (engagementRate > 10) return 'Niedrig';
    return 'Sehr niedrig';
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double availableWidth,
  ) {
    // Calculate responsive dimensions
    double buttonHeight = availableWidth < 400 ? 60 : 70;
    double iconSize = availableWidth < 400 ? 20 : 24;
    double fontSize = availableWidth < 400 ? 12 : 14;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: buttonHeight,
        padding: const EdgeInsets.all(12), // Reduced from 16
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 6), // Reduced from 8
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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
    return const ProfileScreen();
  }
}

// Helper class for secondary stats
class StatItem {
  final String value;
  final String label;
  
  StatItem(this.value, this.label);
}