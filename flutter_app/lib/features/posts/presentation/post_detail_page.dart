import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../data/providers/posts_providers.dart';
import '../domain/models/post.dart';
import '../../auth/data/providers/auth_providers.dart';
import '../../auth/domain/dto/auth_status.dart';
import '../../likes/data/providers/likes_providers.dart';
import '../../ai/data/ai_recommendation_service.dart';
import '../../../shared/widgets/post_card.dart';

/// Modern Post Detail Page
/// Clean, readable design with generous whitespace
class PostDetailPage extends ConsumerWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postProvider(postId));
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: postAsync.when(
        data: (post) => _PostDetailContent(
          post: post,
          authState: authState,
        ),
        loading: () => const _PostDetailSkeleton(),
        error: (error, stack) => _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(postProvider(postId)),
          onBack: () => context.pop(),
        ),
      ),
    );
  }
}

class _PostDetailContent extends ConsumerStatefulWidget {
  final Post post;
  final AuthStatus authState;

  const _PostDetailContent({
    required this.post,
    required this.authState,
  });

  @override
  ConsumerState<_PostDetailContent> createState() => _PostDetailContentState();
}

class _PostDetailContentState extends ConsumerState<_PostDetailContent> {
  @override
  void initState() {
    super.initState();
    // Record post view for AI recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userInteractionNotifierProvider.notifier).recordPostView(
            widget.post.id,
            category: widget.post.category,
            tags: widget.post.tags,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _sharePost(context),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Category & Date
                Row(
                  children: [
                    CategoryChip(category: widget.post.category),
                    const Spacer(),
                    Text(
                      _formatDate(widget.post.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  widget.post.title,
                  style: AppTypography.headlineLarge.copyWith(
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Author Info
                _AuthorSection(post: widget.post),
                const SizedBox(height: 24),

                // Divider
                const Divider(height: 1),
                const SizedBox(height: 24),

                // Content
                _ContentSection(content: widget.post.content),
                const SizedBox(height: 24),

                // Tags
                if (widget.post.tags.isNotEmpty) ...[
                  _TagsSection(tags: widget.post.tags),
                  const SizedBox(height: 24),
                ],

                // Divider
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Stats & Actions
                _StatsAndActions(
                  post: widget.post,
                  authState: widget.authState,
                  onLike: () => _toggleLike(),
                  onShare: () => _sharePost(context),
                ),
                const SizedBox(height: 32),

                // Comments Section
                _CommentsSection(post: widget.post),
                const SizedBox(height: 32),

                // Related Posts (AI Recommendations)
                _RelatedPostsSection(postId: widget.post.id),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleLike() async {
    final response = await ref.read(likeNotifierProvider.notifier).toggleLike(
          widget.post.id,
          widget.post.isLiked,
        );

    if (response != null) {
      if (!widget.post.isLiked) {
        ref.read(userInteractionNotifierProvider.notifier).recordPostLike(
              widget.post.id,
              category: widget.post.category,
              tags: widget.post.tags,
            );
      }
      ref.invalidate(postProvider(widget.post.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.post.isLiked ? '좋아요를 취소했습니다' : '좋아요를 눌렀습니다',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _sharePost(BuildContext context) {
    final shareUrl = 'https://dothechi.com/post/${widget.post.id}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('공유하기', style: AppTypography.titleMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.link,
                  label: '링크 복사',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('링크가 복사되었습니다')),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.message_outlined,
                  label: '메시지',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.email_outlined,
                  label: '이메일',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  label: '더보기',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('저장하기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('저장 기능이 준비중입니다')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.error),
              title: Text('신고하기', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 신고'),
        content: const Text('이 게시물을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('신고가 접수되었습니다'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _AuthorSection extends StatelessWidget {
  final Post post;

  const _AuthorSection({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          name: post.author.userNick,
          size: 48,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author.userNick,
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                _formatRelativeTime(post.createdAt),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
          ),
          child: const Text('팔로우'),
        ),
      ],
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}월 ${dateTime.day}일';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    }
    return '방금 전';
  }
}

class _ContentSection extends StatelessWidget {
  final String content;

  const _ContentSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content,
      style: AppTypography.bodyLarge.copyWith(
        height: 1.8,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  final List<String> tags;

  const _TagsSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => TagChip(tag: tag)).toList(),
    );
  }
}

class _StatsAndActions extends StatelessWidget {
  final Post post;
  final AuthStatus authState;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const _StatsAndActions({
    required this.post,
    required this.authState,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.cardSmall,
      ),
      child: Column(
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.visibility_outlined,
                value: post.viewCount,
                label: '조회',
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              _StatItem(
                icon: Icons.favorite,
                value: post.likeCount,
                label: '좋아요',
                isActive: post.isLiked,
                activeColor: AppColors.like,
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              _StatItem(
                icon: Icons.chat_bubble_outline,
                value: post.commentCount,
                label: '댓글',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: post.isLiked ? '좋아요 취소' : '좋아요',
                  isActive: post.isLiked,
                  onTap: authState is AuthAuthenticated
                      ? onLike
                      : () => context.push('/user/login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '댓글 쓰기',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: onShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool isActive;
  final Color? activeColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? (activeColor ?? AppColors.primary) : AppColors.textSecondary;

    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.likeBackground : Colors.transparent,
      borderRadius: AppRadius.button,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.button,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.like : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isActive ? AppColors.like : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  final Post post;

  const _CommentsSection({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                '댓글',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${post.commentCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.cardSmall,
            ),
            child: Row(
              children: [
                UserAvatar(name: 'U', size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '댓글을 입력하세요...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Icon(Icons.send, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Empty state
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '아직 댓글이 없습니다',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '첫 번째 댓글을 남겨보세요!',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedPostsSection extends ConsumerWidget {
  final int postId;

  const _RelatedPostsSection({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedPostsProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 게시물',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 16),
        recommendedAsync.when(
          data: (posts) {
            final filteredPosts =
                posts.where((p) => p.id != postId).take(3).toList();
            if (filteredPosts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: filteredPosts
                  .map((post) => _CompactPostCard(post: post))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CompactPostCard extends StatelessWidget {
  final Post post;

  const _CompactPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardSmall,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/post/${post.id}'),
          borderRadius: AppRadius.cardSmall,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: AppTypography.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            post.author.userNick,
                            style: AppTypography.caption,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.likeCount}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostDetailSkeleton extends StatelessWidget {
  const _PostDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          _SkeletonBox(width: 80, height: 24),
          const SizedBox(height: 20),
          _SkeletonBox(width: double.infinity, height: 32),
          const SizedBox(height: 8),
          _SkeletonBox(width: 250, height: 32),
          const SizedBox(height: 24),
          Row(
            children: [
              _SkeletonBox(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 100, height: 16),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 60, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          ...List.generate(
              5,
              (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SkeletonBox(width: double.infinity, height: 20),
                  )),
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

class _ErrorView extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onBack,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '게시물을 불러올 수 없습니다',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onBack,
                  child: const Text('돌아가기'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
