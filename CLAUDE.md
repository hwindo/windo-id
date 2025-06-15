# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is **Windo ID**, a personal portfolio/blog website built with Rails 8.0. It combines a professional landing page with a content management system for blog posts, featuring custom authentication and modern Rails architecture.

## Common Development Commands

### Server & Development
- `bin/dev` - Start development server with Tailwind CSS watcher (recommended)
- `bin/setup` - Complete application setup (dependencies, database, server)
- `bin/rails server` - Start Rails server only

### Database Operations
- `bin/rails db:prepare` - Setup database or run migrations
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:seed` - Load seed data
- `bin/rails db:reset` - Drop, recreate, and seed database

### Asset Management
- `bin/rails tailwindcss:watch` - Watch and build Tailwind CSS
- `bin/rails tailwindcss:build` - Build Tailwind CSS once

### Code Quality & Testing
- `bin/rubocop` - Run Ruby linting with Rails Omakase rules
- `bin/rubocop -a` - Auto-correct Ruby style issues
- `bin/brakeman` - Run security vulnerability analysis
- `bin/rails test` - Run tests (currently needs setup - see Testing section)

### Deployment
- `bin/kamal deploy` - Deploy with Kamal
- `bin/kamal setup` - Initial deployment setup

## Architecture Overview

### Core Models
- **User**: Authentication with bcrypt, owns posts and sessions
- **Post**: Blog posts with draft/published status, Action Text content, featured images
- **Session**: Custom session management with IP/user agent tracking
- **Current**: Thread-safe current user access via ActiveSupport::CurrentAttributes

### Authentication System
- Custom cookie-based authentication (not Devise)
- Rate limiting on login attempts (10 per 3 minutes)
- Token-based password reset system
- Session tracking with IP/user agent for security

### Key Features
- **Blog system**: Draft/published workflow with rich text editing
- **Portfolio website**: Professional landing page with glitch effect animations
- **Content management**: User-generated posts with media uploads
- **Public/private access**: Drafts only visible to authenticated users

### Technology Stack
- **Backend**: Rails 8.0, PostgreSQL (production), SQLite (development)
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, Action Text
- **Deployment**: Kamal with Docker, SSL via Let's Encrypt
- **Background jobs**: Solid Queue, Solid Cache, Solid Cable

## File Organization

### Key Directories
- `app/controllers/concerns/authentication.rb` - Custom authentication logic
- `app/models/current.rb` - Thread-safe current user pattern
- `app/views/posts/` - Blog post templates and partials
- `config/deploy.yml` - Kamal deployment configuration
- `config/routes.rb` - Routes including blog at /blog path

### Important Configuration
- Authentication concern provides `allow_unauthenticated_access` for public pages
- Posts controller shows only published posts to unauthenticated users
- Tailwind CSS configured with typography plugin for blog content

## Testing Setup (Needs Configuration)

**Current Status**: Test infrastructure is incomplete and needs setup before tests will run.

**Required fixes**:
1. Uncomment `require "rails/test_unit/railtie"` in `config/application.rb:15`
2. Create `test/test_helper.rb`
3. Create `test/fixtures/users.yml` (referenced by existing tests)

**Test commands once fixed**:
- `bin/rails test` - Run all tests
- `bin/rails test:models` - Run model tests only
- `bin/rails test test/models/post_test.rb` - Run specific test file

## Development Notes

- Use `bin/dev` for development to run both Rails server and Tailwind watcher
- The application uses custom authentication - check `authentication.rb` concern for session handling
- Blog posts support both draft and published states via enum
- Rich text content uses Action Text with file attachments via Active Storage
- Rate limiting is implemented on login attempts for security