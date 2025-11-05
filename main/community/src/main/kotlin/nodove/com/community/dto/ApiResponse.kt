package nodove.com.community.dto

data class ApiResponse<T>(
    val status: String,
    val message: String,
    val code: String,
    val data: T? = null
)

data class ErrorResponse(
    val status: String = "error",
    val message: String,
    val code: String
)
