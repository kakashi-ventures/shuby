---
paths:
  - "test/**/*.rb"
---

# Rails Testing Conventions

## Framework
- Use **Minitest** (not RSpec) — this is the project standard
- Use **fixtures** (not factories) for test data — see `test/fixtures/`
- Tests run with parallel execution enabled

## Multi-tenancy Setup
- Use `switch_account(account)` to set the tenant context in tests
- Test both scoped access (correct account) and cross-account isolation (wrong account returns nothing/403)

## System Tests
- Use Capybara with Selenium WebDriver
- System tests live in `test/system/`
- Test user-facing flows end-to-end

## External APIs
- WebMock is configured to disable external HTTP requests
- Stub all external API calls (OpenAI, payment processors, etc.)
- Use `stub_request` for HTTP mocking

## Test Organization
- Mirror the app directory structure: `test/models/`, `test/controllers/`, `test/system/`
- One test file per class/module
- Use descriptive test method names: `test "user cannot access other account's children"`

## Assertions
- Prefer specific assertions (`assert_equal`, `assert_includes`) over generic `assert`
- Use `assert_difference` for create/destroy actions
- Use `assert_no_difference` to verify side-effect-free operations
