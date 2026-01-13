package nodove.com.community.controller

import nodove.com.community.dto.ErrorResponse
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {

    private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgument(e: IllegalArgumentException): ResponseEntity<ErrorResponse> {
        logger.warn("IllegalArgumentException: ${e.message}")
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ErrorResponse(error = "BAD_REQUEST", message = e.message ?: "Invalid request"))
    }

    @ExceptionHandler(NoSuchElementException::class)
    fun handleNotFound(e: NoSuchElementException): ResponseEntity<ErrorResponse> {
        logger.warn("NoSuchElementException: ${e.message}")
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse(error = "NOT_FOUND", message = e.message ?: "Resource not found"))
    }

    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDenied(e: AccessDeniedException): ResponseEntity<ErrorResponse> {
        logger.warn("AccessDeniedException: ${e.message}")
        return ResponseEntity
            .status(HttpStatus.FORBIDDEN)
            .body(ErrorResponse(error = "FORBIDDEN", message = e.message ?: "Access denied"))
    }

    @ExceptionHandler(Exception::class)
    fun handleGeneral(e: Exception): ResponseEntity<ErrorResponse> {
        logger.error("Unexpected error: ${e.message}", e)
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse(error = "INTERNAL_ERROR", message = "An unexpected error occurred"))
    }
}
