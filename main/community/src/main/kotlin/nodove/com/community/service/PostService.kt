package nodove.com.community.service

import jakarta.transaction.Transactional
import nodove.com.community.domain.post.Post
import nodove.com.community.dto.request.CreatePostRequest
import nodove.com.community.dto.request.UpdatePostRequest
import nodove.com.community.dto.response.PaginationResponse
import nodove.com.community.dto.response.PostListResponse
import nodove.com.community.dto.response.PostResponse
import nodove.com.community.exception.ForbiddenException
import nodove.com.community.exception.ResourceNotFoundException
import nodove.com.community.repository.PostLikeRepository
import nodove.com.community.repository.PostRepository
import nodove.com.community.util.JwtTokenUtil
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service

@Service
@Transactional
class PostService(
    private val postRepository: PostRepository,
    private val categoryService: CategoryService,
    private val postLikeRepository: PostLikeRepository,
    private val jwtTokenUtil: JwtTokenUtil
) {
    fun getPosts(page: Int, limit: Int, categoryName: String?, sort: String, requestUserId: String?): PostListResponse {
        val pageable = when (sort) {
            "popular" -> PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "likeCount"))
            "views" -> PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "viewCount"))
            else -> PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "createdAt"))
        }

        val postPage = if (categoryName != null) {
            val category = categoryService.getOrCreateCategory(categoryName)
            postRepository.findAllByDeletedAtIsNullAndCategory(category, pageable)
        } else {
            postRepository.findAllByDeletedAtIsNull(pageable)
        }

        val likedPostIds = if (requestUserId != null) {
            postLikeRepository.findAllByUserId(requestUserId, PageRequest.of(0, Int.MAX_VALUE))
                .map { it.postId }.toSet()
        } else emptySet()

        val posts = postPage.content.map { PostResponse.from(it, it.id in likedPostIds) }
        return PostListResponse(
            posts = posts,
            pagination = PaginationResponse(
                page = page,
                limit = limit,
                total = postPage.totalElements,
                totalPages = postPage.totalPages
            )
        )
    }

    fun getPost(id: Long, requestUserId: String?): PostResponse {
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            ?: throw ResourceNotFoundException("게시물을 찾을 수 없습니다. id=$id")
        postRepository.incrementViewCount(id)
        val isLiked = requestUserId?.let { postLikeRepository.existsByPostIdAndUserId(id, it) } ?: false
        return PostResponse.from(post, isLiked)
    }

    fun createPost(request: CreatePostRequest, userId: String, userNick: String, userEmail: String): PostResponse {
        val category = categoryService.getOrCreateCategory(request.category)
        val post = postRepository.save(
            Post(
                title = request.title,
                content = request.content,
                excerpt = request.content.take(200),
                authorId = userId,
                authorNick = userNick,
                authorEmail = userEmail,
                category = category,
                tags = request.tags.toMutableList()
            )
        )
        return PostResponse.from(post)
    }

    fun updatePost(id: Long, request: UpdatePostRequest, userId: String): PostResponse {
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            ?: throw ResourceNotFoundException("게시물을 찾을 수 없습니다. id=$id")
        if (post.authorId != userId) throw ForbiddenException("게시물을 수정할 권한이 없습니다.")

        request.title?.let { post.title = it }
        request.content?.let {
            post.content = it
            post.excerpt = it.take(200)
        }
        request.category?.let { post.category = categoryService.getOrCreateCategory(it) }
        request.tags?.let { post.tags = it.toMutableList() }

        return PostResponse.from(postRepository.save(post))
    }

    fun deletePost(id: Long, userId: String) {
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            ?: throw ResourceNotFoundException("게시물을 찾을 수 없습니다. id=$id")
        if (post.authorId != userId) throw ForbiddenException("게시물을 삭제할 권한이 없습니다.")
        post.softDelete()
        postRepository.save(post)
    }

    fun getRecommendedPosts(limit: Int, requestUserId: String?): List<PostResponse> {
        val posts = postRepository.findRecommendedPosts(PageRequest.of(0, limit))
        val likedPostIds = if (requestUserId != null) {
            postLikeRepository.findAllByUserId(requestUserId, PageRequest.of(0, Int.MAX_VALUE))
                .map { it.postId }.toSet()
        } else emptySet()
        return posts.map { PostResponse.from(it, it.id in likedPostIds) }
    }

    fun getLatestPosts(limit: Int, requestUserId: String?): List<PostResponse> {
        val posts = postRepository.findLatestPosts(PageRequest.of(0, limit))
        val likedPostIds = if (requestUserId != null) {
            postLikeRepository.findAllByUserId(requestUserId, PageRequest.of(0, Int.MAX_VALUE))
                .map { it.postId }.toSet()
        } else emptySet()
        return posts.map { PostResponse.from(it, it.id in likedPostIds) }
    }

    fun searchPosts(query: String, page: Int, limit: Int, categoryName: String?, requestUserId: String?): PostListResponse {
        val pageable = PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "createdAt"))
        val postPage = if (categoryName != null) {
            val category = categoryService.getOrCreateCategory(categoryName)
            postRepository.searchByTitleOrContentAndCategory(query, category, pageable)
        } else {
            postRepository.searchByTitleOrContent(query, pageable)
        }

        val likedPostIds = if (requestUserId != null) {
            postLikeRepository.findAllByUserId(requestUserId, PageRequest.of(0, Int.MAX_VALUE))
                .map { it.postId }.toSet()
        } else emptySet()

        return PostListResponse(
            posts = postPage.content.map { PostResponse.from(it, it.id in likedPostIds) },
            pagination = PaginationResponse(
                page = page,
                limit = limit,
                total = postPage.totalElements,
                totalPages = postPage.totalPages
            )
        )
    }

    fun getSearchSuggestions(query: String, limit: Int): List<String> {
        return postRepository.findTitleSuggestions(query, PageRequest.of(0, limit))
    }
}
