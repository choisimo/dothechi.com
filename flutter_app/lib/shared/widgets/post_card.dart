import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_theme.dart';
import '../../features/posts/domain/models/post.dart';

/// Modern Post Card Widget
/// Card-based layout with soft shadows, rounded corners
/// Optimized for readability and touch interaction
class PostCard extends StatelessWidget {
  final Post post;
  final bool showFullContent;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.showFullContent = false,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: onTap ?? () => context.push('/post/${post.id}'),
          borderRadius: AppRadius.card,
          child: Padding(
            padding: AppSpacing.cardPaddingLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Author info + timestamp
                _buildHeader(context),
                const SizedBox(height: AppSpacing.md),

                // Title
                _buildTitle(),
                const SizedBox(height: AppSpacing.sm),

                // Content preview
                _buildContent(),

                // Tags (if any)
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildTags(),
                ],

                const SizedBox(height: AppSpacing.base),

                // Divider
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),

                // Action bar: Like, Comment, Share
                _buildActionBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar
        _UserAvatar(
          name: post.author.userNick,
          imageUrl: null,
          size: 40,
        ),
        const SizedBox(width: AppSpacing.md),

        // Author name + timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author.userNick,
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _CategoryChip(category: post.category),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _formatRelativeTime(post.createdAt),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
        ),

        // More options
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 20),
          color: AppColors.textMuted,
          onPressed: () => _showMoreOptions(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      post.title,
      style: AppTypography.headlineSmall,
      maxLines: showFullContent ? null : 2,
      overflow: showFullContent ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildContent() {
    final content = post.excerpt ?? post.content;
    return Text(
      content,
      style: AppTypography.bodyMedium.copyWith(height: 1.6),
      maxLines: showFullContent ? null : 3,
      overflow: showFullContent ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: post.tags.take(4).map((tag) => _TagChip(tag: tag)).toList(),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      children: [
        // Like button
        _ActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(post.likeCount),
          isActive: post.isLiked,
          activeColor: AppColors.like,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.lg),

        // Comment button
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(post.commentCount),
          onTap: onComment ?? () => context.push('/post/${post.id}'),
        ),
        const SizedBox(width: AppSpacing.lg),

        // View count
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              _formatCount(post.viewCount),
              style: AppTypography.labelSmall,
            ),
          ],
        ),

        const Spacer(),

        // Share button
        IconButton(
          icon: const Icon(Icons.share_outlined, size: 20),
          color: AppColors.textMuted,
          onPressed: onShare,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
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
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('저장하기'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('공유하기'),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.error),
              title: Text('신고하기', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}천';
    }
    return count.toString();
  }
}

/// Circular User Avatar with fallback to initials
class _UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const _UserAvatar({
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.4,
                ),
              ),
            )
          : null,
    );
  }
}

/// Category chip with colored background
class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.categoryBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.categoryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Tag chip with subtle styling
class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        '#$tag',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.tagText,
        ),
      ),
    );
  }
}

/// Reusable action button with icon and label
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? (activeColor ?? AppColors.primary) : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exported UserAvatar for use elsewhere
class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return _UserAvatar(name: name, imageUrl: imageUrl, size: size);
  }
}

/// Exported CategoryChip for use elsewhere
class CategoryChip extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _CategoryChip(category: category),
    );
  }
}

/// Exported TagChip for use elsewhere
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _TagChip(tag: tag),
    );
  }
}
