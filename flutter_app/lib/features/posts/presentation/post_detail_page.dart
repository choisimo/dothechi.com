import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/posts_providers.dart';
import '../domain/models/post.dart';
import '../../auth/data/providers/auth_providers.dart';
import '../../auth/domain/dto/auth_status.dart';
import '../../likes/data/providers/likes_providers.dart';
import '../../ai/data/ai_recommendation_service.dart';
import '../../ai/presentation/ai_widgets.dart';

class PostDetailPage extends ConsumerWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postProvider(postId));
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
        elevation: 3,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _sharePost(context, postId);
                  break;
                case 'report':
                  _reportPost(context, postId);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('공유'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report),
                    SizedBox(width: 8),
                    Text('신고'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) => _buildPostContent(context, ref, post, authState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
    );
  }

  Widget _buildPostContent(
      BuildContext context, WidgetRef ref, Post post, AuthStatus authState) {
    // Record post view for AI recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userInteractionNotifierProvider.notifier).recordPostView(
            post.id,
            category: post.category,
            tags: post.tags,
          );
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(postProvider(postId));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리와 작성 시간
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 제목
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // 작성자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    post.author.userNick[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.userNick,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 태그
            if (post.tags.isNotEmpty) ...[
              const Text(
                '태그',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 통계 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.remove_red_eye,
                    label: '조회',
                    count: post.viewCount,
                  ),
                  _buildStatItem(
                    icon: Icons.favorite,
                    label: '좋아요',
                    count: post.likeCount,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  _buildStatItem(
                    icon: Icons.comment,
                    label: '댓글',
                    count: post.commentCount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: authState is AuthAuthenticated
                        ? () => _toggleLike(context, ref, post)
                        : () => context.push('/user/login'),
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : null,
                    ),
                    label: Text(post.isLiked ? '좋아요 취소' : '좋아요'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: post.isLiked ? Colors.red[50] : null,
                      foregroundColor: post.isLiked ? Colors.red : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePost(context, post.id),
                    icon: const Icon(Icons.share),
                    label: const Text('공유'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 댓글 섹션 (추후 구현)
            const Text(
              '댓글',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '댓글 기능이 준비중입니다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI 추천: 유사 게시물 섹션
            SimilarPostsSection(postId: post.id),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '게시물을 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Future<void> _toggleLike(
      BuildContext context, WidgetRef ref, Post post) async {
    final response = await ref.read(likeNotifierProvider.notifier).toggleLike(
          post.id,
          post.isLiked,
        );

    if (response != null) {
      // Record like interaction for AI recommendations
      if (!post.isLiked) {
        ref.read(userInteractionNotifierProvider.notifier).recordPostLike(
              post.id,
              category: post.category,
              tags: post.tags,
            );
      }

      // Refresh post data to update like count and status
      ref.invalidate(postProvider(post.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(post.isLiked ? '좋아요를 취소했습니다' : '좋아요를 눌렀습니다'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('좋아요 처리에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sharePost(BuildContext context, int postId) {
    final shareUrl = 'https://community.nodove.com/posts/$postId';

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('링크 복사'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('링크가 복사되었습니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('공유하기'),
              onTap: () {
                Navigator.pop(context);
                // For web, just copy link. For mobile, use share_plus package
                Clipboard.setData(ClipboardData(text: shareUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('링크가 복사되었습니다')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reportPost(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 신고'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('신고 사유를 선택해주세요:'),
            const SizedBox(height: 16),
            ...['스팸/광고', '욕설/혐오 발언', '허위 정보', '저작권 침해', '기타'].map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport(context, postId, reason);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _submitReport(BuildContext context, int postId, String reason) {
    // TODO: 실제 신고 API 연동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('신고가 접수되었습니다: $reason'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
