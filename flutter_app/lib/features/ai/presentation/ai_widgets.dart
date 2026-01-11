import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/ai_recommendation_service.dart';
import '../domain/models/ai_models.dart';

class AIPostSummaryWidget extends ConsumerWidget {
  final String postContent;
  final int postId;

  const AIPostSummaryWidget({
    super.key,
    required this.postContent,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use content analysis for summary (local AI)
    final analysisAsync = ref.watch(contentAnalysisProvider(postContent));

    return analysisAsync.when(
      data: (analysis) {
        final keywords = (analysis['keywords'] as List<String>?) ?? [];
        if (keywords.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'AI 키워드',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: keywords
                    .take(5)
                    .map((keyword) => Chip(
                          label: Text(keyword),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                          ),
                          backgroundColor: Colors.blue.shade100,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI 분석 중...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class AIPostCard extends ConsumerWidget {
  final RecommendedPost post;
  final VoidCallback? onTap;

  const AIPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excerpt = post.excerpt ??
        (post.content.length > 100
            ? '${post.content.substring(0, 100)}...'
            : post.content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap ??
            () {
              // Navigate to post detail
              context.push('/posts/${post.id}');
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Excerpt
              Text(
                excerpt,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Recommendation reason
              if (post.recommendationReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 12, color: Colors.purple.shade600),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          post.recommendationReason!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Meta information
              Row(
                children: [
                  // Author
                  Text(
                    post.authorName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${post.viewCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_up_outlined,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  // AI recommendation badge
                  if (post.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 10, color: Colors.purple.shade700),
                          const SizedBox(width: 2),
                          Text(
                            'AI 추천',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIRecommendationSection extends ConsumerWidget {
  const AIRecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(personalizedPostsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple.shade600),
              const SizedBox(width: 8),
              Text(
                'AI 맞춤 추천',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        recommendationsAsync.when(
          data: (posts) => posts.isEmpty
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          '더 많은 활동을 하시면\nAI가 맞춤 콘텐츠를 추천해드려요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 12),
                        child: AIPostCard(post: post),
                      );
                    },
                  ),
                ),
          loading: () => Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI 추천을 불러올 수 없습니다',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Similar posts widget to show at the bottom of post detail page
class SimilarPostsSection extends ConsumerWidget {
  final int postId;

  const SimilarPostsSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarPostsAsync = ref.watch(similarPostsProvider(postId));

    return similarPostsAsync.when(
      data: (posts) {
        if (posts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.recommend, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '관련 글',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...posts.map((post) => _SimilarPostTile(post: post)),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SimilarPostTile extends StatelessWidget {
  final SimilarPost post;

  const _SimilarPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/posts/${post.id}'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${(post.similarity * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        post.excerpt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}

/// Trending topics widget
class TrendingTopicsSection extends ConsumerWidget {
  const TrendingTopicsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTopicsProvider);

    return trendingAsync.when(
      data: (topics) {
        if (topics.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '트렌딩 토픽',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics
                    .map((topic) => _TrendingTopicChip(topic: topic))
                    .toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TrendingTopicChip extends StatelessWidget {
  final TrendingTopic topic;

  const _TrendingTopicChip({required this.topic});

  @override
  Widget build(BuildContext context) {
    final isGrowing = topic.growth > 0;

    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(topic.topic),
          const SizedBox(width: 4),
          Icon(
            isGrowing ? Icons.trending_up : Icons.trending_flat,
            size: 14,
            color: isGrowing ? Colors.green : Colors.grey,
          ),
          if (isGrowing)
            Text(
              '+${(topic.growth * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
              ),
            ),
        ],
      ),
      onPressed: () {
        // Navigate to search with this topic
        // You could implement topic-based search here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${topic.topic}" 검색 결과 보기')),
        );
      },
      backgroundColor: Colors.orange.shade50,
      side: BorderSide(color: Colors.orange.shade200),
    );
  }
}

class SmartSearchWidget extends ConsumerStatefulWidget {
  const SmartSearchWidget({super.key});

  @override
  ConsumerState<SmartSearchWidget> createState() => _SmartSearchWidgetState();
}

class _SmartSearchWidgetState extends ConsumerState<SmartSearchWidget> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(aISearchNotifierProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart search input
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '궁금한 것을 자연어로 물어보세요...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.auto_awesome, color: Colors.purple.shade600),
                    onPressed: () => _showAISearchHelp(),
                    tooltip: 'AI 검색 도움말',
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(aISearchNotifierProvider.notifier)
                            .clearSearch();
                        setState(() {});
                      },
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade300, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: _performAISearch,
          ),

          // AI search suggestions
          if (_focusNode.hasFocus && _searchController.text.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb,
                          size: 16, color: Colors.purple.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'AI 검색 예시',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildSearchSuggestion('Flutter 성능 최적화 방법'),
                      _buildSearchSuggestion('상태 관리 비교'),
                      _buildSearchSuggestion('앱 배포 과정'),
                      _buildSearchSuggestion('디자인 패턴 추천'),
                    ],
                  ),
                ],
              ),
            ),

          // Search results
          searchState.when(
            data: (response) {
              if (response == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과 (${response.totalCount}건)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (response.suggestedQueries.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: response.suggestedQueries
                          .map((q) => ActionChip(
                                label: Text(q),
                                onPressed: () {
                                  _searchController.text = q;
                                  _performAISearch(q);
                                },
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...response.posts.map((post) => ListTile(
                        onTap: () => context.push('/posts/${post.id}'),
                        title: Text(post.title),
                        subtitle: Text(
                          post.excerpt ?? post.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('검색 오류: $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestion(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        _performAISearch(suggestion);
      },
      labelStyle: TextStyle(
        fontSize: 12,
        color: Colors.purple.shade700,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.purple.shade300),
    );
  }

  void _performAISearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(aISearchNotifierProvider.notifier).search(query);
      _focusNode.unfocus();
    }
  }

  void _showAISearchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI 스마트 검색'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI가 당신의 질문을 이해하고 최적의 답변을 찾아드립니다.'),
            SizedBox(height: 16),
            Text('예시:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• "Flutter에서 상태 관리 어떻게 해?"'),
            Text('• "앱 성능을 개선하는 방법은?"'),
            Text('• "디자인 패턴 중 뭐가 좋을까?"'),
            Text('• "초보자를 위한 팁이 있나?"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
