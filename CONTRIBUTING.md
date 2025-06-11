# Contributing to GovInfo

Thank you for your interest in contributing to GovInfo! We welcome contributions from developers of all skill levels. This guide will help you get started.

## 🎯 Ways to Contribute

- **🐛 Bug Reports**: Found a bug? Let us know!
- **✨ Feature Requests**: Have an idea? We'd love to hear it!
- **📝 Documentation**: Help improve our docs
- **🔧 Code Contributions**: Fix bugs or implement new features
- **🧪 Testing**: Help us improve test coverage
- **🎨 UI/UX**: Improve user experience and design

## 🚀 Getting Started

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/govinfo.git
cd govinfo

# Add the original repository as upstream
git remote add upstream https://github.com/ORIGINAL_OWNER/govinfo.git
```

### 2. Set Up Development Environment

```bash
# Start the development database
docker-compose up -d postgres

# Copy environment configuration
cp .env.example .env
# Edit .env with your development credentials

# Install dependencies and run migrations
go mod download
go run cmd/migrate/main.go up

# Verify everything works
go test ./...
```

### 3. Create a Branch

```bash
# Create a new branch for your feature/fix
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

## 📋 Development Guidelines

### Code Style

We follow standard Go conventions:

```bash
# Format your code
go fmt ./...

# Run the linter
golangci-lint run

# Ensure tests pass
go test ./...
```

### Git Commit Messages

Use clear, descriptive commit messages following conventional commits:

```
feat: add user preference update endpoint
fix: resolve SMS delivery retry logic
docs: update API documentation
test: add integration tests for batch jobs
refactor: extract SMS service into separate package
```

### Testing Requirements

- **Unit Tests**: All new functions should have unit tests
- **Integration Tests**: Test database interactions and external APIs
- **Coverage**: Aim for >80% test coverage on new code

```bash
# Run specific test packages
go test ./internal/services/...

# Run with coverage
go test -cover ./...

# Run integration tests (requires running database)
go test -tags=integration ./internal/handlers/...
```

## 🏗️ Architecture Guidelines

### Project Structure

Follow our established patterns:

```
internal/
├── handlers/     # HTTP request handlers (thin layer)
├── services/     # Business logic (where most logic lives)
├── models/       # Database models and structs
├── config/       # Configuration management
└── utils/        # Shared utilities
```

### Service Layer Pattern

Keep handlers thin, put logic in services:

```go
// Good: Thin handler
func (h *UserHandler) Subscribe(w http.ResponseWriter, r *http.Request) {
    var req SubscribeRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid JSON", http.StatusBadRequest)
        return
    }
    
    user, err := h.userService.Subscribe(req.PhoneNumber, req.Address)
    if err != nil {
        // Handle error appropriately
        return
    }
    
    json.NewEncoder(w).Encode(user)
}

// Business logic in service
func (s *UserService) Subscribe(phone, address string) (*User, error) {
    // Validation, database operations, SMS sending, etc.
}
```

### Database Guidelines

- Use migrations for all schema changes
- Write efficient queries (avoid N+1 problems)
- Handle transactions properly
- Use appropriate indexes

```go
// Create migrations with descriptive names
go run cmd/migrate/main.go create add_user_preferences_table
```

## 🐛 Reporting Bugs

When reporting bugs, please include:

1. **Environment**: Go version, OS, database version
2. **Steps to Reproduce**: Clear, numbered steps
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Error Messages**: Full error messages and stack traces
6. **Additional Context**: Screenshots, logs, etc.

### Bug Report Template

```markdown
**Environment**
- Go version: 1.21.0
- OS: Ubuntu 22.04
- Database: PostgreSQL 15.2

**Steps to Reproduce**
1. Start the API server
2. Send POST request to `/users/subscribe` with invalid phone number
3. Observe the response

**Expected Behavior**
Should return 400 Bad Request with clear error message

**Actual Behavior**
Returns 500 Internal Server Error

**Error Messages**
```
2024/01/15 10:30:45 ERROR: invalid phone number format
panic: runtime error: invalid memory address
```

**Additional Context**
This happens only with phone numbers containing special characters.
```

## ✨ Feature Requests

When requesting features:

1. **Use Case**: Describe the problem you're solving
2. **Proposed Solution**: Your idea for how to solve it
3. **Alternatives**: Other solutions you've considered
4. **Additional Context**: Screenshots, mockups, etc.

## 📝 Documentation

Help us improve documentation:

- **README**: Keep installation and usage instructions up to date
- **API Docs**: Document new endpoints and parameters
- **Code Comments**: Add comments for complex logic
- **Examples**: Provide usage examples

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows Go conventions (`go fmt`, `golangci-lint`)
- [ ] Tests pass locally (`go test ./...`)
- [ ] New code has tests
- [ ] Documentation is updated
- [ ] Commit messages are clear

### Submitting

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub with:
   - Clear title and description
   - Reference any related issues
   - Include testing instructions
   - Add screenshots for UI changes

3. **Respond to feedback** promptly and professionally

### Pull Request Template

```markdown
## Description
Brief description of changes and why they're needed.

## Type of Change
- [ ] Bug fix
- [ ] New feature  
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)

## Related Issues
Fixes #123
Related to #456
```

## 🧪 Testing Guidelines

### Test Structure

```go
func TestUserService_Subscribe(t *testing.T) {
    tests := []struct {
        name        string
        phone       string
        address     string
        wantErr     bool
        expectedErr string
    }{
        {
            name:    "valid subscription",
            phone:   "+1234567890",
            address: "123 Main St, City, State 12345",
            wantErr: false,
        },
        {
            name:        "invalid phone format",
            phone:       "invalid",
            address:     "123 Main St, City, State 12345",
            wantErr:     true,
            expectedErr: "invalid phone number format",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### Integration Tests

Tag integration tests that require external dependencies:

```go
//go:build integration

func TestUserHandler_Subscribe_Integration(t *testing.T) {
    // Test with real database
}
```

## 🏷️ Issue Labels

We use these labels to organize issues:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to docs
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `question`: Further information is requested
- `priority:high`: High priority issue
- `priority:low`: Low priority issue

## 💬 Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Request Comments**: Code-specific discussions

## 📜 Code of Conduct

### Our Standards

- **Be Respectful**: Treat everyone with respect and kindness
- **Be Inclusive**: Welcome people of all backgrounds and identities
- **Be Collaborative**: Work together constructively
- **Be Professional**: Maintain professionalism in all interactions

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling, insulting, or derogatory comments
- Personal or political attacks
- Publishing private information without permission

## 🎉 Recognition

Contributors will be recognized in:

- **README**: Contributors section
- **Release Notes**: Major contributions highlighted
- **GitHub**: Contributor graphs and statistics

## ❓ Questions?

If you have questions about contributing:

1. Check existing [GitHub Issues](https://github.com/OWNER/govinfo/issues)
2. Start a [GitHub Discussion](https://github.com/OWNER/govinfo/discussions)
3. Review this guide and the README

Thank you for contributing to GovInfo! 🎉