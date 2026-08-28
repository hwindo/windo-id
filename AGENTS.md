# Repository Guidelines

## Project Structure & Module Organization

Windo ID is a Rails 8 portfolio and blog application. Core application code lives in `app/`: models in `app/models`, controllers in `app/controllers`, views in `app/views`, helpers in `app/helpers`, jobs in `app/jobs`, and Stimulus controllers in `app/javascript/controllers`. Tailwind entry styles are in `app/assets/tailwind/application.css`; additional stylesheets live in `app/assets/stylesheets`. Database migrations and schemas are under `db/`. Tests are under `test/`. Deployment and runtime files include `Dockerfile`, `bin/docker-entrypoint`, `config/deploy.yml`, and `config/storage.yml`. See `CLAUDE.md` for deeper architecture notes.

## Build, Test, and Development Commands

- `bin/setup`: install dependencies and prepare the app.
- `bin/dev`: run the Rails server with the Tailwind watcher; prefer this for local development.
- `bin/rails server`: run Rails only.
- `bin/rails db:prepare`: create, migrate, or prepare the database.
- `bin/rails tailwindcss:build`: compile Tailwind CSS once.
- `bin/rubocop`: run Ruby style checks with Rails Omakase rules.
- `bin/brakeman`: run Rails security analysis.
- `bin/rails test`: run tests after the current test infrastructure is completed.

## Coding Style & Naming Conventions

Follow standard Rails conventions: snake_case files and methods, PascalCase classes, plural controller names, and RESTful route/action naming. Keep controllers thin and place reusable model behavior in concerns such as `app/models/concerns/taggable_concern.rb`. Use two-space indentation for Ruby, ERB, JavaScript, and CSS. Prefer existing Hotwire, Stimulus, Tailwind, and Rails helper patterns over introducing new frontend frameworks.

## Testing Guidelines

The project uses Rails test conventions under `test/`, but test setup is currently incomplete. Before relying on `bin/rails test`, restore the Rails test railtie, add `test/test_helper.rb`, and provide missing fixtures such as `test/fixtures/users.yml`. Name model tests like `test/models/post_test.rb` and keep tests close to the behavior they verify.

## Commit & Pull Request Guidelines

Recent history uses short Conventional Commit-style subjects, for example `fix: Railway volume permissions for Active Storage uploads`, `feat(tags): add tom-select and tags`, and `chore: update brakeman to 7.1.0`. Use concise imperative subjects with scopes when helpful. Pull requests should include a clear summary, linked issue when applicable, screenshots for UI changes, migration notes for database changes, and verification results such as `bin/rubocop`, `bin/brakeman`, or focused Rails tests.

## Security & Configuration Tips

Authentication is custom, not Devise; review `app/controllers/concerns/authentication.rb` before changing session or password behavior. Action Text and Active Storage uploads depend on persistent storage, especially `/data/storage` on Railway. Do not commit credentials; use Rails credentials or deployment environment variables.
