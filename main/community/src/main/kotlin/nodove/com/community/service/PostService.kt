package nodove.com.community.service

import nodove.com.community.dto.*
import nodove.com.community.entity.Post
import nodove.com.community.repository.PostRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class PostService(
    private val postRepository: PostRepository
) {

    fun getPosts(page: Int, limit: Int, category: String?, sort: String): PostListResponse {
        val sortOrder = when (sort) {
            "latest" -> Sort.by(Sort.Direction.DESC, "createdAt")
            "popular" -> Sort.by(Sort.Direction.DESC, "viewCount", "likeCount")
            "comments" -> Sort.by(Sort.Direction.DESC, "commentCount")
            else -> Sort.by(Sort.Direction.DESC, "createdAt")
        }

        val pageable = PageRequest.of(page - 1, limit, sortOrder)
        val postPage = if (category.isNullOrBlank()) {
            postRepository.findAll(pageable)
        } else {
            postRepository.findByCategory(category, pageable)
        }

        return PostListResponse(
            posts = postPage.content.map { PostDto.from(it) },
            page = page,
            limit = limit,
            totalPages = postPage.totalPages,
            totalCount = postPage.totalElements,
            hasNext = postPage.hasNext()
        )
    }

    @Transactional
    fun getPost(id: Long): PostDto {
        val post = postRepository.findById(id)
            .orElseThrow { NoSuchElementException("Post not found with id: $id") }
        
        postRepository.incrementViewCount(id)
        
        return PostDto.from(post)
    }

    @Transactional
    fun createPost(request: CreatePostRequest, authorId: Long, authorName: String, authorAvatar: String?): PostDto {
        val post = Post(
            title = request.title,
            content = request.content,
            category = request.category,
            authorId = authorId,
            authorName = authorName,
            authorAvatar = authorAvatar,
            thumbnailUrl = request.thumbnailUrl
        )
        
        val savedPost = postRepository.save(post)
        return PostDto.from(savedPost)
    }

    @Transactional
    fun updatePost(id: Long, request: UpdatePostRequest, authorId: Long): PostDto {
        val post = postRepository.findById(id)
            .orElseThrow { NoSuchElementException("Post not found with id: $id") }
        
        if (post.authorId != authorId) {
            throw IllegalAccessException("You don't have permission to update this post")
        }
        
        request.title?.let { post.title = it }
        request.content?.let { post.content = it }
        request.category?.let { post.category = it }
        request.thumbnailUrl?.let { post.thumbnailUrl = it }
        
        val updatedPost = postRepository.save(post)
        return PostDto.from(updatedPost)
    }

    @Transactional
    fun deletePost(id: Long, authorId: Long) {
        val post = postRepository.findById(id)
            .orElseThrow { NoSuchElementException("Post not found with id: $id") }
        
        if (post.authorId != authorId) {
            throw IllegalAccessException("You don't have permission to delete this post")
        }
        
        postRepository.delete(post)
    }

    fun getRecommendedPosts(limit: Int): List<PostDto> {
        val pageable = PageRequest.of(0, limit)
        return postRepository.findRecommended(pageable).map { PostDto.from(it) }
    }

    fun getLatestPosts(limit: Int): List<PostDto> {
        val pageable = PageRequest.of(0, limit)
        return postRepository.findLatest(pageable).map { PostDto.from(it) }
    }

    fun searchPosts(keyword: String, page: Int, limit: Int): PostListResponse {
        val pageable = PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "createdAt"))
        val postPage = postRepository.searchByKeyword(keyword, pageable)
        
        return PostListResponse(
            posts = postPage.content.map { PostDto.from(it) },
            page = page,
            limit = limit,
            totalPages = postPage.totalPages,
            totalCount = postPage.totalElements,
            hasNext = postPage.hasNext()
        )
    }

    @Transactional
    fun likePost(id: Long) {
        postRepository.incrementLikeCount(id)
    }

    @Transactional
    fun unlikePost(id: Long) {
        postRepository.decrementLikeCount(id)
    }
}
