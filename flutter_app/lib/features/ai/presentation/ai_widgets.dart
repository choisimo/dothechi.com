import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_client/core/ai/ai_providers.dart';

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
    final summaryAsync = ref.watch(postSummaryProvider(postContent));

    return summaryAsync.when(
      data: (summary) => Container(
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
                Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'AI 요약',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
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
              'AI 요약 생성 중...',
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
  final Map<String, dynamic> post;
  final VoidCallback? onTap;

  const AIPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postId = post['id'] as int;
    final title = post['title'] as String;
    final content = post['content'] as String? ?? '';
    final excerpt = post['excerpt'] as String? ??
        (content.length > 100 ? '${content.substring(0, 100)}...' : content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 기본 요약 또는 내용
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

              // AI 요약 (옵션)
              if (content.isNotEmpty && content.length > 100)
                AIPostSummaryWidget(
                  postContent: content,
                  postId: postId,
                ),

              const SizedBox(height: 12),

              // 메타 정보
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '2시간 전', // TODO: 실제 시간 데이터 사용
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '125', // TODO: 실제 조회수 데이터 사용
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  // AI 추천 배지
                  if (post['isRecommended'] == true)
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
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);

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
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        child: AIPostCard(
                          post: post,
                          onTap: () {
                            // TODO: 게시물 상세 페이지로 이동
                          },
                        ),
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

// AI 추천 시스템 프로바이더 (Mock 데이터)
final aiRecommendationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: 실제 AI 추천 API 호출로 대체
  await Future.delayed(const Duration(seconds: 2));

  return [
    {
      'id': 101,
      'title': 'Flutter 개발 최신 트렌드',
      'content': 'Flutter 3.0의 새로운 기능들과 개발 트렌드에 대해 알아보세요...',
      'excerpt':
          'Flutter 3.0의 새로운 기능들과 개발 트렌드에 대해 알아보세요. 성능 개선과 새로운 위젯들이 추가됐습니다.',
      'isRecommended': true,
      'recommendationScore': 0.95,
    },
    {
      'id': 102,
      'title': '효율적인 상태 관리 방법',
      'content': 'Riverpod을 활용한 상태 관리의 모든 것을 다룹니다...',
      'excerpt': 'Riverpod을 활용한 상태 관리의 모든 것을 다룹니다. Provider 패턴부터 고급 사용법까지.',
      'isRecommended': true,
      'recommendationScore': 0.89,
    },
    {
      'id': 103,
      'title': 'AI와 모바일 앱의 미래',
      'content': '인공지능 기술이 모바일 앱 개발에 미치는 영향을 살펴봅니다...',
      'excerpt': '인공지능 기술이 모바일 앱 개발에 미치는 영향을 살펴봅니다. 머신러닝 모델 통합부터 사용자 경험 개선까지.',
      'isRecommended': true,
      'recommendationScore': 0.87,
    },
  ];
});

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
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스마트 검색창
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

          // AI 검색 제안
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
      // TODO: AI 기반 검색 구현
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 검색: "$query"'),
          action: SnackBarAction(
            label: '결과 보기',
            onPressed: () {
              // TODO: 검색 결과 페이지로 이동
            },
          ),
        ),
      );
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
