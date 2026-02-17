---
paths:
  - "app/controllers/**/*.rb"
---

# Rails Controller Conventions

## Authentication & Authorization
- Use `before_action :authenticate_user!` for protected routes
- Use Pundit policies for authorization: `authorize @resource`
- Always scope resources via `current_account`

## Resource Scoping
- Load resources through the account scope: `current_account.children.find(params[:id])`
- Never use unscoped `Model.find(params[:id])` for tenant data

## Turbo Stream Responses
- Use `respond_to` with `format.turbo_stream` for interactive actions (create, update, destroy)
- Fall back to `format.html` for non-Turbo requests
- Keep Turbo Stream responses minimal — update only the affected DOM elements

## REST Conventions
- Follow standard REST actions: index, show, new, create, edit, update, destroy
- Use `before_action :set_resource` for DRY resource loading
- Keep controllers thin — delegate business logic to models or services

## Error Handling
- Use `rescue_from` for common error types at the application level
- Flash messages for user-facing feedback
- Redirect after successful mutations (POST/PATCH/DELETE)
