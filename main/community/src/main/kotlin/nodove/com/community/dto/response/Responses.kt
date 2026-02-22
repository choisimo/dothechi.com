package nodove.com.community.dto.response

import nodove.com.community.domain.category.Category
import nodove.com.community.domain.comment.Comment
import nodove.com.community.domain.post.Post
import java.time.LocalDateTime

data class AuthorDto(
    val id: String,
    val userId: String,
    val userNick: String,
    val email: String
)

data class PostResponse(
    val id: Long,
    val title: String,
    val content: String,
    val excerpt: String?,
    val author: AuthorDto,
    val category: String,
    val tags: List<String>,
    val viewCount: Long,
    val likeCount: Long,
    val commentCount: Long,
    val isLiked: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
    val deletedAt: LocalDateTime?
) {
    companion object {
        fun from(post: Post, isLiked: Boolean = false): PostResponse = PostResponse(
            id = post.id,
            title = post.title,
            content = post.content,
            excerpt = post.excerpt ?: post.content.take(200),
            author = AuthorDto(
                id = post.authorId,
                userId = post.authorId,
                userNick = post.authorNick,
                email = post.authorEmail
            ),
            category = post.category.name,
            tags = post.tags,
            viewCount = post.viewCount,
            likeCount = post.likeCount,
            commentCount = post.commentCount,
            isLiked = isLiked,
            createdAt = post.createdAt,
            updatedAt = post.updatedAt,
            deletedAt = post.deletedAt
        )
    }
}

data class PaginationResponse(
    val page: Int,
    val limit: Int,
    val total: Long,
    val totalPages: Int
)

data class PostListResponse(
    val posts: List<PostResponse>,
    val pagination: PaginationResponse
)

data class CommentResponse(
    val id: Long,
    val content: String,
    val author: AuthorDto,
    val postId: Long,
    val parentId: Long?,
    val replies: List<CommentResponse>,
    val likeCount: Long,
    val isLiked: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
    val deletedAt: LocalDateTime?
) {
    companion object {
        fun from(comment: Comment, replies: List<CommentResponse> = emptyList(), isLiked: Boolean = false): CommentResponse = CommentResponse(
            id = comment.id,
            content = if (comment.isDeleted) "삭제된 댓글입니다." else comment.content,
            author = AuthorDto(
                id = comment.authorId,
                userId = comment.authorId,
                userNick = comment.authorNick,
                email = comment.authorEmail
            ),
            postId = comment.postId,
            parentId = comment.parentId,
            replies = replies,
            likeCount = comment.likeCount,
            isLiked = isLiked,
            createdAt = comment.createdAt,
            updatedAt = comment.updatedAt,
            deletedAt = comment.deletedAt
        )
    }
}

data class CommentListResponse(
    val comments: List<CommentResponse>,
    val totalCount: Long,
    val page: Int,
    val limit: Int
)

data class CategoryResponse(
    val id: String,
    val name: String,
    val description: String,
    val postCount: Int,
    val isActive: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun from(category: Category, postCount: Int = 0): CategoryResponse = CategoryResponse(
            id = category.id.toString(),
            name = category.name,
            description = category.description,
            postCount = postCount,
            isActive = category.isActive,
            createdAt = category.createdAt,
            updatedAt = category.updatedAt
        )
    }
}

data class ApiResponse<T>(
    val success: Boolean,
    val data: T? = null,
    val message: String? = null,
    val code: String? = null
) {
    companion object {
        fun <T> ok(data: T, message: String? = null): ApiResponse<T> = ApiResponse(true, data, message)
        fun <T> error(message: String, code: String = "ERROR"): ApiResponse<T> = ApiResponse(false, null, message, code)
    }
}
