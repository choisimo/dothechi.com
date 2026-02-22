package nodove.com.community.exception

class ResourceNotFoundException(message: String) : RuntimeException(message)
class UnauthorizedException(message: String = "인증이 필요합니다.") : RuntimeException(message)
class ForbiddenException(message: String = "권한이 없습니다.") : RuntimeException(message)
class DuplicateLikeException(message: String = "이미 좋아요를 눌렀습니다.") : RuntimeException(message)
class BadRequestException(message: String) : RuntimeException(message)
