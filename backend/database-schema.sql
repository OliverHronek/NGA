-- NGA Database Schema for Local Development
-- Run this SQL to create the required tables

-- Users table
CREATE TABLE IF NOT EXISTS users (
	id serial4 NOT NULL,
	username varchar(50) NOT NULL,
	email varchar(100) NOT NULL,
	password_hash varchar(255) NOT NULL,
	first_name varchar(50) NULL,
	last_name varchar(50) NULL,
	birth_date date NULL,
	verified bool DEFAULT false NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	is_verified bool DEFAULT false NULL,
	email_verified_at timestamp NULL,
	verification_token varchar(255) NULL,
	verification_token_expires timestamp NULL,
	is_admin bool DEFAULT false NULL,
	CONSTRAINT users_email_key UNIQUE (email),
	CONSTRAINT users_pkey PRIMARY KEY (id),
	CONSTRAINT users_username_key UNIQUE (username)
);

-- Forum posts table
CREATE TABLE IF NOT EXISTS forum_posts (
	id serial4 NOT NULL,
	category_id int4 NULL,
	user_id int4 NULL,
	title varchar(200) NOT NULL,
	"content" text NOT NULL,
	is_pinned bool DEFAULT false NULL,
	is_locked bool DEFAULT false NULL,
	views_count int4 DEFAULT 0 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT forum_posts_pkey PRIMARY KEY (id),
	CONSTRAINT forum_posts_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.forum_categories(id),
	CONSTRAINT forum_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Forum comments table
CREATE TABLE IF NOT EXISTS forum_comments (
	id serial4 NOT NULL,
	post_id int4 NULL,
	user_id int4 NULL,
	parent_comment_id int4 NULL,
	"content" text NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT forum_comments_pkey PRIMARY KEY (id),
	CONSTRAINT forum_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.forum_comments(id),
	CONSTRAINT forum_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.forum_posts(id) ON DELETE CASCADE,
	CONSTRAINT forum_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Forum reactions table
CREATE TABLE IF NOT EXISTS reactions (
	id serial4 NOT NULL,
	user_id int4 NULL,
	target_type varchar(20) NOT NULL,
	target_id int4 NOT NULL,
	reaction_type varchar(10) DEFAULT 'like'::character varying NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT reactions_pkey PRIMARY KEY (id),
	CONSTRAINT reactions_user_id_target_type_target_id_key UNIQUE (user_id, target_type, target_id),
	CONSTRAINT reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Sample test user (password: 'password123')
INSERT INTO users (username, email, password_hash, first_name, last_name) 
VALUES (
    'testuser',
    'test@nga.at',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdsLH.bJjKfPOm2',
    'Test',
    'User'
) ON CONFLICT (username) DO NOTHING;

-- Sample forum post
INSERT INTO forum_posts (user_id, title, content)
SELECT 
    u.id,
    'Welcome to NGA Forum',
    'This is a test post to demonstrate the forum functionality.'
FROM users u 
WHERE u.username = 'testuser'
ON CONFLICT DO NOTHING;
