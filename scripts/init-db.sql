-- =============================================================
-- dothechi.com — Database Initialization Script
-- Applied automatically by MariaDB docker-entrypoint-initdb.d
-- Note: The 'community' database is already created by
--       MYSQL_DATABASE env var; this script adds tables.
-- JPA ddl-auto=update handles schema evolution in dev.
-- This script ensures baseline schema + seed data exist.
-- =============================================================

USE community;

-- ----------------------------------------------------------------
-- AUTH SERVICE tables  (auth service uses ddl-auto=none in prod)
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`    VARCHAR(255) NOT NULL UNIQUE,
    `email`      VARCHAR(255) NOT NULL UNIQUE,
    `password`   VARCHAR(255) NOT NULL,
    `user_name`  VARCHAR(255),
    `user_nick`  VARCHAR(255) NOT NULL,
    `user_role`  VARCHAR(50)  NOT NULL DEFAULT 'ROLE_USER',
    `is_active`  TINYINT(1)   NOT NULL DEFAULT 0,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME,
    PRIMARY KEY (`id`),
    INDEX `idx_user_email` (`email`),
    INDEX `idx_user_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_block` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`      BIGINT       NOT NULL,
    `blocked_by`   BIGINT       NOT NULL,
    `reason`       VARCHAR(500) NOT NULL,
    `blocked_at`   DATETIME     NOT NULL,
    `unblocked_at` DATETIME,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_user_block_user`       FOREIGN KEY (`user_id`)    REFERENCES `user`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_user_block_blocked_by` FOREIGN KEY (`blocked_by`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_login_history` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT       NOT NULL,
    `login_time` DATETIME,
    `ip_address` VARCHAR(100),
    `device`     VARCHAR(255),
    `is_success` TINYINT(1)   NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_login_history_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    INDEX `idx_login_history_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_status` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `status`      VARCHAR(100) NOT NULL,
    `description` VARCHAR(500) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- COMMUNITY SERVICE tables
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `categories` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(50)  NOT NULL UNIQUE,
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `is_active`   TINYINT(1)   NOT NULL DEFAULT 1,
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `posts` (
    `id`            BIGINT       NOT NULL AUTO_INCREMENT,
    `title`         VARCHAR(200) NOT NULL,
    `content`       TEXT         NOT NULL,
    `excerpt`       VARCHAR(500),
    `author_id`     VARCHAR(255) NOT NULL,
    `author_nick`   VARCHAR(50)  NOT NULL,
    `author_email`  VARCHAR(255) NOT NULL,
    `category_id`   BIGINT       NOT NULL,
    `view_count`    BIGINT       NOT NULL DEFAULT 0,
    `like_count`    BIGINT       NOT NULL DEFAULT 0,
    `comment_count` BIGINT       NOT NULL DEFAULT 0,
    `is_pinned`     TINYINT(1)   NOT NULL DEFAULT 0,
    `is_deleted`    TINYINT(1)   NOT NULL DEFAULT 0,
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_posts_category` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`),
    INDEX `idx_posts_author_id`   (`author_id`),
    INDEX `idx_posts_category_id` (`category_id`),
    INDEX `idx_posts_created_at`  (`created_at`),
    INDEX `idx_posts_deleted_at`  (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `post_tags` (
    `post_id` BIGINT      NOT NULL,
    `tag`     VARCHAR(50) NOT NULL,
    CONSTRAINT `fk_post_tags_post` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE,
    INDEX `idx_post_tags_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `comments` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `content`      TEXT         NOT NULL,
    `author_id`    VARCHAR(255) NOT NULL,
    `author_nick`  VARCHAR(50)  NOT NULL,
    `author_email` VARCHAR(255) NOT NULL,
    `post_id`      BIGINT       NOT NULL,
    `parent_id`    BIGINT,
    `like_count`   BIGINT       NOT NULL DEFAULT 0,
    `is_deleted`   TINYINT(1)   NOT NULL DEFAULT 0,
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`   DATETIME,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_comments_post`   FOREIGN KEY (`post_id`)   REFERENCES `posts`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comments_parent` FOREIGN KEY (`parent_id`) REFERENCES `comments`(`id`) ON DELETE SET NULL,
    INDEX `idx_comments_post_id`    (`post_id`),
    INDEX `idx_comments_author_id`  (`author_id`),
    INDEX `idx_comments_parent_id`  (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `post_likes` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `post_id`    BIGINT       NOT NULL,
    `user_id`    VARCHAR(255) NOT NULL,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_post_likes_post_user` (`post_id`, `user_id`),
    CONSTRAINT `fk_post_likes_post` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `comment_likes` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `comment_id` BIGINT       NOT NULL,
    `user_id`    VARCHAR(255) NOT NULL,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_comment_likes_comment_user` (`comment_id`, `user_id`),
    CONSTRAINT `fk_comment_likes_comment` FOREIGN KEY (`comment_id`) REFERENCES `comments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- Seed data — default categories
-- ----------------------------------------------------------------

INSERT IGNORE INTO `categories` (`name`, `description`, `is_active`) VALUES
    ('general',      '일반 게시판',      1),
    ('announcement', '공지사항',         1),
    ('question',     '질문 & 답변',      1),
    ('free',         '자유 게시판',      1),
    ('tech',         '기술 토론',        1),
    ('showcase',     '프로젝트 쇼케이스', 1);
