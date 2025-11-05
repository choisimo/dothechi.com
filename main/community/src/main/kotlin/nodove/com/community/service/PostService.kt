package nodove.com.community.service

import nodove.com.community.domain.Post
import nodove.com.community.domain.PostLike
import nodove.com.community.dto.*
import nodove.com.community.repository.CategoryRepository
import nodove.com.community.repository.PostLikeRepository
import nodove.com.community.repository.PostRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class PostService(
    private val postRepository: PostRepository,
    private val categoryRepository: CategoryRepository,
    private val postLikeRepository: PostLikeRepository
) {

    @Transactional
    fun createPost(request: PostCreateRequest, userId: String, userNickname: String): PostResponse {
        val category = categoryRepository.findById(request.categoryId)
            .orElseThrow { IllegalArgumentException("카테고리를 찾을 수 없습니다.") }

        val post = Post(
            title = request.title,
            content = request.content,
            excerpt = request.excerpt ?: generateExcerpt(request.content),
            authorId = userId,
            authorNickname = userNickname,
            category = category,
            tags = request.tags.toMutableList()
        )

        val savedPost = postRepository.save(post)

        // 카테고리 게시물 수 증가
        category.postCount++
        categoryRepository.save(category)

        return PostResponse.fromEntity(savedPost)
    }

    fun getPost(postId: Long, userId: String?): PostResponse {
        val post = postRepository.findById(postId)
            .orElseThrow { IllegalArgumentException("게시물을 찾을 수 없습니다.") }

        if (post.deletedAt != null) {
            throw IllegalArgumentException("삭제된 게시물입니다.")
        }

        val isLiked = userId?.let { postLikeRepository.existsByPostIdAndUserId(postId, it) } ?: false

        return PostResponse.fromEntity(post, isLiked)
    }

    @Transactional
    fun incrementViewCount(postId: Long) {
        val post = postRepository.findById(postId)
            .orElseThrow { IllegalArgumentException("게시물을 찾을 수 없습니다.") }

        post.incrementViewCount()
        postRepository.save(post)
    }

    @Transactional
    fun updatePost(postId: Long, request: PostUpdateRequest, userId: String): PostResponse {
        val post = postRepository.findById(postId)
            .orElseThrow { IllegalArgumentException("게시물을 찾을 수 없습니다.") }

        if (post.authorId != userId) {
            throw IllegalArgumentException("게시물을 수정할 권한이 없습니다.")
        }

        if (post.deletedAt != null) {
            throw IllegalArgumentException("삭제된 게시물은 수정할 수 없습니다.")
        }

        request.title?.let { post.title = it }
        request.content?.let {
            post.content = it
            post.excerpt = request.excerpt ?: generateExcerpt(it)
        }
        request.tags?.let { post.tags = it.toMutableList() }

        if (request.categoryId != null && request.categoryId != post.category.id) {
            // 기존 카테고리 게시물 수 감소
            val oldCategory = post.category
            oldCategory.postCount--
            categoryRepository.save(oldCategory)

            // 새 카테고리 설정 및 게시물 수 증가
            val newCategory = categoryRepository.findById(request.categoryId)
                .orElseThrow { IllegalArgumentException("카테고리를 찾을 수 없습니다.") }
            post.category = newCategory
            newCategory.postCount++
            categoryRepository.save(newCategory)
        }

        val updatedPost = postRepository.save(post)
        return PostResponse.fromEntity(updatedPost)
    }

    @Transactional
    fun deletePost(postId: Long, userId: String) {
        val post = postRepository.findById(postId)
            .orElseThrow { IllegalArgumentException("게시물을 찾을 수 없습니다.") }

        if (post.authorId != userId) {
            throw IllegalArgumentException("게시물을 삭제할 권한이 없습니다.")
        }

        post.softDelete()
        postRepository.save(post)

        // 카테고리 게시물 수 감소
        val category = post.category
        category.postCount--
        categoryRepository.save(category)
    }

    fun getPosts(page: Int, limit: Int, categoryId: Long?, sort: String): PostListResponse {
        val pageable = PageRequest.of(
            page - 1,
            limit,
            when (sort) {
                "popular" -> Sort.by(Sort.Direction.DESC, "viewCount")
                "likes" -> Sort.by(Sort.Direction.DESC, "likeCount")
                else -> Sort.by(Sort.Direction.DESC, "createdAt")
            }
        )

        val postPage = if (categoryId != null) {
            postRepository.findByCategoryId(categoryId, pageable)
        } else {
            postRepository.findByDeletedAtIsNull(pageable)
        }

        val posts = postPage.content.map { PostSummaryResponse.fromEntity(it) }
        val pagination = PaginationInfo(
            page = page,
            limit = limit,
            total = postPage.totalElements,
            totalPages = postPage.totalPages
        )

        return PostListResponse(posts, pagination)
    }

    fun getLatestPosts(limit: Int): List<PostSummaryResponse> {
        val posts = postRepository.findLatestPosts(PageRequest.of(0, limit))
        return posts.map { PostSummaryResponse.fromEntity(it) }
    }

    fun getRecommendedPosts(limit: Int): List<PostSummaryResponse> {
        val posts = postRepository.findRecommendedPosts(PageRequest.of(0, limit))
        return posts.map { PostSummaryResponse.fromEntity(it) }
    }

    @Transactional
    fun toggleLike(postId: Long, userId: String): Boolean {
        val post = postRepository.findById(postId)
            .orElseThrow { IllegalArgumentException("게시물을 찾을 수 없습니다.") }

        val existingLike = postLikeRepository.findByPostIdAndUserId(postId, userId)

        return if (existingLike != null) {
            // 좋아요 취소
            postLikeRepository.delete(existingLike)
            post.decrementLikeCount()
            postRepository.save(post)
            false
        } else {
            // 좋아요 추가
            val like = PostLike(postId = postId, userId = userId)
            postLikeRepository.save(like)
            post.incrementLikeCount()
            postRepository.save(post)
            true
        }
    }

    fun searchPosts(query: String, page: Int, limit: Int, categoryId: Long?): PostListResponse {
        val pageable = PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "createdAt"))

        val postPage = if (categoryId != null) {
            postRepository.searchPostsByCategory(query, categoryId, pageable)
        } else {
            postRepository.searchPosts(query, pageable)
        }

        val posts = postPage.content.map { PostSummaryResponse.fromEntity(it) }
        val pagination = PaginationInfo(
            page = page,
            limit = limit,
            total = postPage.totalElements,
            totalPages = postPage.totalPages
        )

        return PostListResponse(posts, pagination)
    }

    private fun generateExcerpt(content: String, maxLength: Int = 200): String {
        return if (content.length > maxLength) {
            content.substring(0, maxLength) + "..."
        } else {
            content
        }
    }
}
