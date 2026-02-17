Run relevant tests and RuboCop for changed files.

## Instructions

1. Run `git diff --name-only` and `git diff --cached --name-only` to detect all changed files (staged + unstaged)
2. For each changed Ruby file, find its corresponding test file:
   - `app/models/foo.rb` → `test/models/foo_test.rb`
   - `app/controllers/foo_controller.rb` → `test/controllers/foo_controller_test.rb`
   - `app/services/foo_service.rb` → `test/services/foo_service_test.rb`
   - If a test file was directly changed, include it
3. Run `bin/rails test <test_files>` for all identified test files that exist
4. Run `bin/rubocop <changed_ruby_files>` on all modified `.rb` files
5. Report results clearly:
   - Tests: pass/fail count, any failures with details
   - RuboCop: offense count, auto-fixable vs manual
   - If all green, say so clearly
6. If there are failures, suggest specific fixes
