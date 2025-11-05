package nodove.com.community.dto

import nodove.com.community.domain.Post
import java.time.LocalDateTime

data class PostCreateRequest(
    val title: String,
    val content: String,
    val excerpt: String? = null,
    val categoryId: Long,
    val tags: List<String> = emptyList()
)

data class PostUpdateRequest(
    val title: String?,
    val content: String?,
    val excerpt: String?,
    val categoryId: Long?,
    val tags: List<String>?
)

data class PostResponse(
    val id: Long,
    val title: String,
    val content: String,
    val excerpt: String?,
    val author: AuthorInfo,
    val category: String,
    val tags: List<String>,
    val viewCount: Int,
    val likeCount: Int,
    val isLiked: Boolean = false,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun fromEntity(post: Post, isLiked: Boolean = false): PostResponse {
            return PostResponse(
                id = post.id!!,
                title = post.title,
                content = post.content,
                excerpt = post.excerpt,
                author = AuthorInfo(
                    id = post.authorId,
                    userNick = post.authorNickname
                ),
                category = post.category.name,
                tags = post.tags,
                viewCount = post.viewCount,
                likeCount = post.likeCount,
                isLiked = isLiked,
                createdAt = post.createdAt!!,
                updatedAt = post.updatedAt!!
            )
        }
    }
}

data class PostSummaryResponse(
    val id: Long,
    val title: String,
    val excerpt: String?,
    val author: AuthorInfo,
    val category: String,
    val viewCount: Int,
    val likeCount: Int,
    val createdAt: LocalDateTime
) {
    companion object {
        fun fromEntity(post: Post): PostSummaryResponse {
            return PostSummaryResponse(
                id = post.id!!,
                title = post.title,
                excerpt = post.excerpt,
                author = AuthorInfo(
                    id = post.authorId,
                    userNick = post.authorNickname
                ),
                category = post.category.name,
                viewCount = post.viewCount,
                likeCount = post.likeCount,
                createdAt = post.createdAt!!
            )
        }
    }
}

data class AuthorInfo(
    val id: String,
    val userNick: String
)

data class PostListResponse(
    val posts: List<PostSummaryResponse>,
    val pagination: PaginationInfo
)

data class PaginationInfo(
    val page: Int,
    val limit: Int,
    val total: Long,
    val totalPages: Int
)
