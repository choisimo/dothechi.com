import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../posts/data/providers/posts_providers.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../auth/domain/dto/auth_status.dart';
import '../../../ai/presentation/ai_widgets.dart';
import 'section_title.dart';
import 'horizontal_category_list.dart';
import 'horizontal_post_list.dart';
import 'vertical_post_list.dart';

class IndexPage extends ConsumerWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final latestPostsAsync = ref.watch(latestPostsProvider());
    final recommendedPostsAsync = ref.watch(recommendedPostsProvider());
    final popularCategoriesAsync = ref.watch(popularCategoriesProvider());

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Nodove Community',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (authState is AuthAuthenticated) {
                context.push('/post/create');
              } else {
                context.push('/user/login');
              }
            },
            tooltip: '글쓰기',
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI 도우미 기능이 준비중입니다!')),
              );
            },
            tooltip: 'AI 도우미',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  if (authState is AuthAuthenticated) {
                    context.push('/user/profile');
                  } else {
                    context.push('/user/login');
                  }
                  break;
                case 'login':
                  context.push('/user/login');
                  break;
                case 'logout':
                  ref.read(authNotifierProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (context) {
              if (authState is AuthAuthenticated) {
                return [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text('${authState.user.userNick}님'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('로그아웃'),
                      ],
                    ),
                  ),
                ];
              } else {
                return [
                  const PopupMenuItem(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.login),
                        SizedBox(width: 8),
                        Text('로그인'),
                      ],
                    ),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestPostsProvider);
          ref.invalidate(recommendedPostsProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(popularCategoriesProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // AI 스마트 검색
              const SmartSearchWidget(),
              const SizedBox(height: 8),

              // AI 맞춤 추천 섹션 (로그인한 사용자만)
              if (authState is AuthAuthenticated) ...[
                const AIRecommendationSection(),
                const SizedBox(height: 24),
              ],

              // 트렌딩 토픽 섹션
              const TrendingTopicsSection(),
              const SizedBox(height: 24),

              // 추천 게시물 섹션
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(title: '추천 게시물'),
              ),
              recommendedPostsAsync.when(
                data: (posts) => HorizontalPostList(posts: posts),
                loading: () => const _LoadingShimmer(height: 200),
                error: (error, stack) => _ErrorWidget(
                  message: '추천 게시물을 불러올 수 없습니다',
                  onRetry: () => ref.invalidate(recommendedPostsProvider),
                ),
              ),
              const SizedBox(height: 24),

              // 인기 카테고리 섹션
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(title: '인기 카테고리'),
              ),
              popularCategoriesAsync.when(
                data: (categories) =>
                    HorizontalCategoryList(categories: categories),
                loading: () => const _LoadingShimmer(height: 80),
                error: (error, stack) => _ErrorWidget(
                  message: '카테고리를 불러올 수 없습니다',
                  onRetry: () => ref.invalidate(popularCategoriesProvider),
                ),
              ),
              const SizedBox(height: 24),

              // 최신 글 섹션
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(title: '최신 글'),
              ),
              latestPostsAsync.when(
                data: (posts) => VerticalPostList(posts: posts),
                loading: () => const _LoadingShimmer(height: 400),
                error: (error, stack) => _ErrorWidget(
                  message: '최신 글을 불러올 수 없습니다',
                  onRetry: () => ref.invalidate(latestPostsProvider),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (authState is AuthAuthenticated) {
            context.push('/post/create');
          } else {
            context.push('/user/login');
          }
        },
        tooltip: '글쓰기',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  final double height;

  const _LoadingShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
