import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_client/core/ai/ai_providers.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/posts_providers.dart';
import '../../auth/data/providers/auth_providers.dart';
import '../../auth/domain/dto/auth_status.dart';

class PostEditorPage extends ConsumerStatefulWidget {
  final int? postId; // 수정 시 사용

  const PostEditorPage({super.key, this.postId});

  @override
  ConsumerState<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends ConsumerState<PostEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  List<String> _selectedTags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final content = _contentController.text;
    if (content.length > 50) {
      // 50자 이상일 때 AI 분석 시작
      ref.read(aiWritingAssistantProvider.notifier).generateTags(content);
      ref
          .read(aiWritingAssistantProvider.notifier)
          .classifyCategory(_titleController.text, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiWritingState = ref.watch(aiWritingAssistantProvider);
    final aiUsageState = ref.watch(aiUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postId == null ? '게시물 작성' : '게시물 수정'),
        elevation: 1,
        actions: [
          // AI 도우미 버튼
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAIAssistantDialog(context),
            tooltip: 'AI 도우미',
          ),
          // 저장 버튼
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _savePost,
                  child: const Text('저장'),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // AI 사용량 표시
            if (aiUsageState.dailyRequests > 0)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Text(
                  'AI 기능 사용: ${aiUsageState.dailyRequests}/10 (무료)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 입력 필드
                    _buildTitleField(aiWritingState),
                    const SizedBox(height: 16),

                    // AI 제안 제목들
                    if (aiWritingState.suggestedTitles.isNotEmpty)
                      _buildSuggestedTitles(aiWritingState.suggestedTitles),

                    // 카테고리 선택
                    _buildCategorySelector(aiWritingState),
                    const SizedBox(height: 16),

                    // 내용 입력 필드
                    _buildContentField(),
                    const SizedBox(height: 16),

                    // AI 제안 태그들
                    if (aiWritingState.suggestedTags.isNotEmpty)
                      _buildSuggestedTags(aiWritingState.suggestedTags),

                    // 선택된 태그들
                    if (_selectedTags.isNotEmpty) _buildSelectedTags(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAIFloatingButtons(context),
    );
  }

  Widget _buildTitleField(AIWritingState aiState) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: '제목',
        hintText: '게시물 제목을 입력하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (aiState.isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => _suggestTitles(),
              tooltip: '제목 제안',
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '제목을 입력해주세요';
        }
        return null;
      },
      maxLines: 2,
    );
  }

  Widget _buildSuggestedTitles(List<String> titles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 4),
            Text(
              'AI 제안 제목',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: titles.map((title) {
            return ActionChip(
              label: Text(title),
              onPressed: () {
                _titleController.text = title;
              },
              avatar: const Icon(Icons.add, size: 16),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategorySelector(AIWritingState aiState) {
    final categories = [
      {'id': 'tech', 'name': '기술'},
      {'id': 'life', 'name': '라이프'},
      {'id': 'food', 'name': '음식'},
      {'id': 'travel', 'name': '여행'},
      {'id': 'entertainment', 'name': '엔터테인먼트'},
      {'id': 'sports', 'name': '스포츠'},
      {'id': 'education', 'name': '교육'},
      {'id': 'health', 'name': '건강'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (aiState.detectedCategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 12, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'AI 추천: ${_getCategoryName(aiState.detectedCategory!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('카테고리를 선택하세요'),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'],
              child: Text(category['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return '카테고리를 선택해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: '내용',
        hintText: '게시물 내용을 입력하세요...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignLabelWithHint: true,
      ),
      maxLines: 15,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildSuggestedTags(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: Colors.purple.shade600),
            const SizedBox(width: 4),
            Text(
              'AI 제안 태그',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (!_selectedTags.contains(tag)) {
                      _selectedTags.add(tag);
                    }
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              avatar: isSelected
                  ? const Icon(Icons.check, size: 16)
                  : const Icon(Icons.add, size: 16),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '선택된 태그',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedTags.remove(tag);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAIFloatingButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'ai_chatbot',
          onPressed: () => _showAIChatBot(context),
          tooltip: 'AI 도우미 채팅',
          child: const Icon(Icons.smart_toy),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'ai_improve',
          onPressed: () => _improveContent(),
          tooltip: '내용 개선',
          child: const Icon(Icons.auto_fix_high),
        ),
      ],
    );
  }

  void _suggestTitles() {
    final content = _contentController.text;
    if (content.trim().isNotEmpty) {
      ref.read(aiWritingAssistantProvider.notifier).suggestTitles(content);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 내용을 입력해주세요')),
      );
    }
  }

  void _improveContent() async {
    final content = _contentController.text;
    if (content.trim().isNotEmpty) {
      await ref
          .read(aiWritingAssistantProvider.notifier)
          .improveContent(content);
      final improvedContent =
          ref.read(aiWritingAssistantProvider).improvedContent;

      if (improvedContent != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('내용 개선 제안'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('개선된 내용:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(improvedContent),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  _contentController.text = improvedContent;
                  Navigator.pop(context);
                },
                child: const Text('적용'),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 내용을 입력해주세요')),
      );
    }
  }

  void _showAIAssistantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI 도우미'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('제목 제안'),
              subtitle: const Text('내용을 바탕으로 제목을 제안합니다'),
              onTap: () {
                Navigator.pop(context);
                _suggestTitles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_fix_high),
              title: const Text('내용 개선'),
              subtitle: const Text('문법과 표현을 다듬어줍니다'),
              onTap: () {
                Navigator.pop(context);
                _improveContent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('태그 생성'),
              subtitle: const Text('적절한 태그를 자동 생성합니다'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(aiWritingAssistantProvider.notifier)
                    .generateTags(_contentController.text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI 채팅'),
              subtitle: const Text('궁금한 것을 물어보세요'),
              onTap: () {
                Navigator.pop(context);
                _showAIChatBot(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showAIChatBot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AIChatBotBottomSheet(scrollController: scrollController),
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      // Check authentication
      final authState = ref.read(authNotifierProvider);
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        context.push('/user/login');
        return;
      }

      // Validate category
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리를 선택해주세요')),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        final repository = ref.read(postsRepositoryProvider);

        if (widget.postId == null) {
          // Create new post
          await repository.createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _selectedCategory!,
            tags: _selectedTags,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('게시물이 작성되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
            // Invalidate posts cache to refresh list
            ref.invalidate(latestPostsProvider);
            context.pop(true); // Return true to indicate success
          }
        } else {
          // Update existing post
          await repository.updatePost(
            id: widget.postId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _selectedCategory!,
            tags: _selectedTags,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('게시물이 수정되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
            // Invalidate specific post cache
            ref.invalidate(postProvider(widget.postId!));
            ref.invalidate(latestPostsProvider);
            context.pop(true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('저장 실패: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  String _getCategoryName(String categoryId) {
    const categoryMap = {
      'tech': '기술',
      'life': '라이프',
      'food': '음식',
      'travel': '여행',
      'entertainment': '엔터테인먼트',
      'sports': '스포츠',
      'education': '교육',
      'health': '건강',
    };
    return categoryMap[categoryId] ?? categoryId;
  }
}

class AIChatBotBottomSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const AIChatBotBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<AIChatBotBottomSheet> createState() =>
      _AIChatBotBottomSheetState();
}

class _AIChatBotBottomSheetState extends ConsumerState<AIChatBotBottomSheet> {
  final _messageController = TextEditingController();
  final _messagesScrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatBotProvider);

    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Icon(Icons.smart_toy, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'AI 도우미',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(aiChatBotProvider.notifier).clearChat();
                },
                icon: const Icon(Icons.clear_all),
                tooltip: '대화 내역 지우기',
              ),
            ],
          ),
        ),

        // 메시지 목록
        Expanded(
          child: chatState.messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.smart_toy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '안녕하세요! 궁금한 것을 물어보세요.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• 글쓰기 팁\n• 커뮤니티 사용법\n• 기능 안내',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _messagesScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatState.messages[index];
                    return ChatBubble(message: message);
                  },
                ),
        ),

        // 로딩 인디케이터
        if (chatState.isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('AI가 답변을 생성중입니다...'),
              ],
            ),
          ),

        // 메시지 입력
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendMessage(_messageController.text),
                icon: const Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      ref.read(aiChatBotProvider.notifier).sendMessage(message);
      _messageController.clear();

      // 메시지 전송 후 스크롤을 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messagesScrollController.hasClients) {
          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
