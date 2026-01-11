-- Posts and Categories Schema Migration
-- Version: V1.0
-- Description: Create initial posts and categories tables

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    post_count INT NOT NULL DEFAULT 0,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_categories_slug (slug),
    INDEX idx_categories_is_active (is_active),
    INDEX idx_categories_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Posts table
CREATE TABLE IF NOT EXISTS posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    category VARCHAR(50) NOT NULL,
    author_id BIGINT NOT NULL,
    author_name VARCHAR(50) NOT NULL,
    author_avatar VARCHAR(255),
    view_count INT NOT NULL DEFAULT 0,
    like_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    thumbnail_url VARCHAR(500),
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_posts_category (category),
    INDEX idx_posts_author_id (author_id),
    INDEX idx_posts_created_at (created_at DESC),
    INDEX idx_posts_is_pinned (is_pinned),
    INDEX idx_posts_like_count (like_count DESC),
    INDEX idx_posts_view_count (view_count DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default categories
INSERT INTO categories (slug, name, description, sort_order) VALUES
    ('general', '일반', '일반적인 토론 및 대화', 1),
    ('notice', '공지', '공지사항 및 안내', 0),
    ('question', '질문', '궁금한 것을 질문하세요', 2),
    ('tip', '팁/정보', '유용한 팁과 정보 공유', 3),
    ('discussion', '토론', '다양한 주제에 대한 토론', 4),
    ('showcase', '작품', '자신의 작품 및 프로젝트 공유', 5)
ON DUPLICATE KEY UPDATE name = VALUES(name);
