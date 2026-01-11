package nodove.com.community.dto

import nodove.com.community.entity.Post
import java.time.LocalDateTime

data class PostDto(
    val id: Long,
    val title: String,
    val content: String,
    val category: String,
    val authorId: Long,
    val authorName: String,
    val authorAvatar: String?,
    val viewCount: Int,
    val likeCount: Int,
    val commentCount: Int,
    val thumbnailUrl: String?,
    val isPinned: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun from(post: Post): PostDto = PostDto(
            id = post.id,
            title = post.title,
            content = post.content,
            category = post.category,
            authorId = post.authorId,
            authorName = post.authorName,
            authorAvatar = post.authorAvatar,
            viewCount = post.viewCount,
            likeCount = post.likeCount,
            commentCount = post.commentCount,
            thumbnailUrl = post.thumbnailUrl,
            isPinned = post.isPinned,
            createdAt = post.createdAt,
            updatedAt = post.updatedAt
        )
    }
}

data class CreatePostRequest(
    val title: String,
    val content: String,
    val category: String,
    val thumbnailUrl: String? = null
)

data class UpdatePostRequest(
    val title: String? = null,
    val content: String? = null,
    val category: String? = null,
    val thumbnailUrl: String? = null
)

data class PostListResponse(
    val posts: List<PostDto>,
    val page: Int,
    val limit: Int,
    val totalPages: Int,
    val totalCount: Long,
    val hasNext: Boolean
)
