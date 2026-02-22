package nodove.com.community.service

import jakarta.transaction.Transactional
import nodove.com.community.domain.comment.Comment
import nodove.com.community.dto.request.CreateCommentRequest
import nodove.com.community.dto.request.UpdateCommentRequest
import nodove.com.community.dto.response.CommentListResponse
import nodove.com.community.dto.response.CommentResponse
import nodove.com.community.exception.ForbiddenException
import nodove.com.community.exception.ResourceNotFoundException
import nodove.com.community.repository.CommentLikeRepository
import nodove.com.community.repository.CommentRepository
import nodove.com.community.repository.PostRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service

@Service
@Transactional
class CommentService(
    private val commentRepository: CommentRepository,
    private val postRepository: PostRepository,
    private val commentLikeRepository: CommentLikeRepository
) {
    fun getComments(postId: Long, page: Int, limit: Int, requestUserId: String?): CommentListResponse {
        val pageable = PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.ASC, "createdAt"))
        val commentPage = commentRepository.findAllByPostIdAndDeletedAtIsNullAndParentIdIsNull(postId, pageable)

        val comments = commentPage.content.map { comment ->
            val replies = commentRepository.findAllByParentIdAndDeletedAtIsNull(comment.id)
                .map { reply ->
                    val replyLiked = requestUserId?.let {
                        commentLikeRepository.existsByCommentIdAndUserId(reply.id, it)
                    } ?: false
                    CommentResponse.from(reply, emptyList(), replyLiked)
                }
            val isLiked = requestUserId?.let {
                commentLikeRepository.existsByCommentIdAndUserId(comment.id, it)
            } ?: false
            CommentResponse.from(comment, replies, isLiked)
        }

        return CommentListResponse(
            comments = comments,
            totalCount = commentPage.totalElements,
            page = page,
            limit = limit
        )
    }

    fun createComment(postId: Long, request: CreateCommentRequest, userId: String, userNick: String, userEmail: String): CommentResponse {
        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            ?: throw ResourceNotFoundException("게시물을 찾을 수 없습니다. id=$postId")

        val comment = commentRepository.save(
            Comment(
                content = request.content,
                authorId = userId,
                authorNick = userNick,
                authorEmail = userEmail,
                postId = postId
            )
        )
        postRepository.incrementCommentCount(postId)
        return CommentResponse.from(comment)
    }

    fun replyToComment(commentId: Long, request: CreateCommentRequest, userId: String, userNick: String, userEmail: String): CommentResponse {
        val parentComment = commentRepository.findByIdAndDeletedAtIsNull(commentId)
            ?: throw ResourceNotFoundException("댓글을 찾을 수 없습니다. id=$commentId")

        val reply = commentRepository.save(
            Comment(
                content = request.content,
                authorId = userId,
                authorNick = userNick,
                authorEmail = userEmail,
                postId = parentComment.postId,
                parentId = commentId
            )
        )
        postRepository.incrementCommentCount(parentComment.postId)
        return CommentResponse.from(reply)
    }

    fun updateComment(commentId: Long, request: UpdateCommentRequest, userId: String): CommentResponse {
        val comment = commentRepository.findByIdAndDeletedAtIsNull(commentId)
            ?: throw ResourceNotFoundException("댓글을 찾을 수 없습니다. id=$commentId")
        if (comment.authorId != userId) throw ForbiddenException("댓글을 수정할 권한이 없습니다.")
        comment.content = request.content
        return CommentResponse.from(commentRepository.save(comment))
    }

    fun deleteComment(commentId: Long, userId: String) {
        val comment = commentRepository.findByIdAndDeletedAtIsNull(commentId)
            ?: throw ResourceNotFoundException("댓글을 찾을 수 없습니다. id=$commentId")
        if (comment.authorId != userId) throw ForbiddenException("댓글을 삭제할 권한이 없습니다.")
        comment.softDelete()
        commentRepository.save(comment)
        postRepository.decrementCommentCount(comment.postId)
    }

    fun likeComment(commentId: Long, userId: String) {
        commentRepository.findByIdAndDeletedAtIsNull(commentId)
            ?: throw ResourceNotFoundException("댓글을 찾을 수 없습니다. id=$commentId")
        if (commentLikeRepository.existsByCommentIdAndUserId(commentId, userId)) return
        commentLikeRepository.save(nodove.com.community.domain.like.CommentLike(commentId = commentId, userId = userId))
        commentRepository.incrementLikeCount(commentId)
    }

    fun unlikeComment(commentId: Long, userId: String) {
        if (!commentLikeRepository.existsByCommentIdAndUserId(commentId, userId)) return
        commentLikeRepository.deleteByCommentIdAndUserId(commentId, userId)
        commentRepository.decrementLikeCount(commentId)
    }
}
