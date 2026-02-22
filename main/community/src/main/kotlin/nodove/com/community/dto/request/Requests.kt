package nodove.com.community.dto.request

data class CreatePostRequest(
    val title: String,
    val content: String,
    val category: String,
    val tags: List<String> = emptyList()
)

data class UpdatePostRequest(
    val title: String?,
    val content: String?,
    val category: String?,
    val tags: List<String>?
)

data class CreateCommentRequest(
    val content: String
)

data class UpdateCommentRequest(
    val content: String
)
