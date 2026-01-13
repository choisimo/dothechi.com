import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../posts/data/providers/posts_providers.dart';
import '../../../posts/domain/models/post.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../auth/domain/dto/auth_status.dart';
import '../../../../shared/widgets/post_card.dart';

/// Main Index Page with modern, human-centric design
/// Thread/Airbnb inspired UI with card-based layout
class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _FeedTab(),
          _ExploreTab(),
          _NotificationsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavBarItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: '탐색',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavBarItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: '알림',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '프로필',
                isActive: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feed Tab - Main content feed
class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final latestPostsAsync = ref.watch(latestPostsProvider());

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Nodove',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search'),
            ),
            IconButton(
              icon: const Icon(Icons.edit_square),
              onPressed: () {
                if (authState is AuthAuthenticated) {
                  context.push('/post/create');
                } else {
                  context.push('/user/login');
                }
              },
            ),
          ],
        ),

        // Welcome Section (for logged-in users)
        if (authState is AuthAuthenticated)
          SliverToBoxAdapter(
            child: _WelcomeSection(userName: authState.user.userNick),
          ),

        // Feed Content
        SliverToBoxAdapter(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(latestPostsProvider);
            },
            child: latestPostsAsync.when(
              data: (posts) => _PostFeed(posts: posts),
              loading: () => const _FeedSkeleton(),
              error: (error, stack) => _ErrorView(
                message: '게시물을 불러올 수 없습니다',
                onRetry: () => ref.invalidate(latestPostsProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome section for authenticated users
class _WelcomeSection extends StatelessWidget {
  final String userName;

  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$userName님! 👋',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘도 좋은 하루 되세요',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wb_sunny_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후에요';
    return '좋은 저녁이에요';
  }
}

/// Post Feed List
class _PostFeed extends StatelessWidget {
  final List<Post> posts;

  const _PostFeed({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _EmptyView(
        icon: Icons.article_outlined,
        title: '아직 게시물이 없어요',
        subtitle: '첫 번째 게시물을 작성해보세요!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            '최신 글',
            style: AppTypography.titleLarge,
          ),
        ),
        ...posts.map((post) => PostCard(post: post)),
        const SizedBox(height: 100), // Bottom padding for nav bar
      ],
    );
  }
}

/// Feed loading skeleton
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => _PostCardSkeleton()),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 100, height: 14),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 60, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SkeletonBox(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          _SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 4),
          _SkeletonBox(width: 200, height: 16),
          const SizedBox(height: 16),
          Row(
            children: [
              _SkeletonBox(width: 60, height: 24),
              const SizedBox(width: 16),
              _SkeletonBox(width: 60, height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Explore Tab
class _ExploreTab extends ConsumerWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final recommendedPostsAsync = ref.watch(recommendedPostsProvider());

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: Text('탐색', style: AppTypography.headlineMedium),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadius.button,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Text(
                          '게시물, 태그, 사용자 검색',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('카테고리', style: AppTypography.titleLarge),
              ),
              categoriesAsync.when(
                data: (categories) => _CategoryGrid(categories: categories),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Recommended Posts
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('추천 글', style: AppTypography.titleLarge),
              ),
              recommendedPostsAsync.when(
                data: (posts) => Column(
                  children: posts.map((post) => PostCard(post: post)).toList(),
                ),
                loading: () => const _FeedSkeleton(),
                error: (_, __) => _ErrorView(
                  message: '추천 글을 불러올 수 없습니다',
                  onRetry: () => ref.invalidate(recommendedPostsProvider),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<dynamic> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    final categoryIcons = {
      'general': Icons.chat_bubble_outline,
      'tech': Icons.computer,
      'life': Icons.favorite_outline,
      'hobby': Icons.sports_esports,
      'qna': Icons.help_outline,
    };

    final categoryColors = {
      'general': AppColors.primary,
      'tech': const Color(0xFF10B981),
      'life': const Color(0xFFEC4899),
      'hobby': const Color(0xFFF59E0B),
      'qna': const Color(0xFF3B82F6),
    };

    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.isEmpty ? 5 : categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final defaultCategories = ['general', 'tech', 'life', 'hobby', 'qna'];
          final categoryId = categories.isEmpty
              ? defaultCategories[index]
              : categories[index].id ??
                  defaultCategories[index % defaultCategories.length];

          return GestureDetector(
            onTap: () => context.push('/category/$categoryId'),
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (categoryColors[categoryId] ?? AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: AppRadius.cardSmall,
                border: Border.all(
                  color: (categoryColors[categoryId] ?? AppColors.primary)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcons[categoryId] ?? Icons.folder_outlined,
                    color: categoryColors[categoryId] ?? AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryId,
                    style: AppTypography.labelSmall.copyWith(
                      color: categoryColors[categoryId] ?? AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Notifications Tab
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: Text('알림', style: AppTypography.headlineMedium),
        ),
        SliverFillRemaining(
          child: _EmptyView(
            icon: Icons.notifications_none,
            title: '새로운 알림이 없어요',
            subtitle: '활동 소식이 있으면 여기에 표시됩니다',
          ),
        ),
      ],
    );
  }
}

/// Profile Tab
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: Text('프로필', style: AppTypography.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
        SliverFillRemaining(
          child: authState is AuthAuthenticated
              ? _ProfileContent(user: authState.user)
              : _LoginPrompt(),
        ),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                UserAvatar(
                  name: user.userNick,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  user.userNick,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(label: '게시물', value: '0'),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _ProfileStat(label: '팔로워', value: '0'),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _ProfileStat(label: '팔로잉', value: '0'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _ProfileMenuItem(
            icon: Icons.article_outlined,
            label: '내 게시물',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.bookmark_border,
            label: '저장한 글',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_border,
            label: '좋아요한 글',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            label: '설정',
            onTap: () {},
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardSmall,
        boxShadow: AppShadows.card,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(label, style: AppTypography.bodyMedium),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardSmall),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '로그인이 필요해요',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '게시물 작성, 좋아요, 댓글 등\n다양한 기능을 이용해보세요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/user/login'),
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/user/join'),
              child: const Text('계정이 없으신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view
class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view with retry
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
