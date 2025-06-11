# GovInfo Makefile
# Variables
GO_VERSION := 1.21
BINARY_NAME := govinfo
BINARY_PATH := ./bin
API_BINARY := $(BINARY_PATH)/api
BATCH_BINARY := $(BINARY_PATH)/batch
MIGRATE_BINARY := $(BINARY_PATH)/migrate

# Docker compose profiles
COMPOSE_DEV := docker-compose
COMPOSE_TEST := docker-compose --profile test
COMPOSE_ADMIN := docker-compose --profile admin

# Build flags
BUILD_FLAGS := -ldflags="-w -s"
BUILD_FLAGS_DEV := -race

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## Development Commands
.PHONY: setup
setup: ## Initial project setup
	@echo "Setting up GovInfo development environment..."
	@mkdir -p $(BINARY_PATH)
	@cp .env.example .env
	@echo "✅ Created .env file (please edit with your credentials)"
	@$(COMPOSE_DEV) up -d postgres
	@echo "⏳ Waiting for database to be ready..."
	@sleep 5
	@make migrate-up
	@echo "🎉 Setup complete! Run 'make dev' to start developing"

.PHONY: dev
dev: ## Start development environment
	@$(COMPOSE_DEV) up -d postgres
	@echo "🚀 Starting development servers..."
	@echo "API will be available at http://localhost:8080"

.PHONY: dev-full
dev-full: ## Start full development environment with admin tools
	@$(COMPOSE_ADMIN) up -d
	@echo "🚀 Full development environment started!"
	@echo "API: http://localhost:8080"
	@echo "pgAdmin: http://localhost:8080 (admin@govinfo.dev / admin)"

.PHONY: stop
stop: ## Stop all services
	@$(COMPOSE_DEV) down
	@echo "🛑 All services stopped"

.PHONY: clean
clean: ## Clean up containers and volumes
	@$(COMPOSE_DEV) down -v --remove-orphans
	@docker system prune -f
	@echo "🧹 Cleanup complete"

## Build Commands
.PHONY: build
build: build-api build-batch build-migrate ## Build all binaries

.PHONY: build-api
build-api: ## Build API server binary
	@echo "🔨 Building API server..."
	@CGO_ENABLED=0 GOOS=linux go build $(BUILD_FLAGS) -o $(API_BINARY) ./cmd/api
	@echo "✅ API binary built: $(API_BINARY)"

.PHONY: build-batch
build-batch: ## Build batch job binary
	@echo "🔨 Building batch job..."
	@CGO_ENABLED=0 GOOS=linux go build $(BUILD_FLAGS) -o $(BATCH_BINARY) ./cmd/batch
	@echo "✅ Batch binary built: $(BATCH_BINARY)"

.PHONY: build-migrate
build-migrate: ## Build migration tool binary
	@echo "🔨 Building migration tool..."
	@CGO_ENABLED=0 GOOS=linux go build $(BUILD_FLAGS) -o $(MIGRATE_BINARY) ./cmd/migrate
	@echo "✅ Migration binary built: $(MIGRATE_BINARY)"

.PHONY: build-dev
build-dev: ## Build binaries with development flags (race detection)
	@echo "🔨 Building development binaries..."
	@go build $(BUILD_FLAGS_DEV) -o $(API_BINARY) ./cmd/api
	@go build $(BUILD_FLAGS_DEV) -o $(BATCH_BINARY) ./cmd/batch
	@go build $(BUILD_FLAGS_DEV) -o $(MIGRATE_BINARY) ./cmd/migrate
	@echo "✅ Development binaries built"

## Database Commands
.PHONY: migrate-up
migrate-up: ## Run database migrations
	@echo "📊 Running migrations..."
	@go run ./cmd/migrate up
	@echo "✅ Migrations complete"

.PHONY: migrate-down
migrate-down: ## Rollback last migration
	@echo "📊 Rolling back migration..."
	@go run ./cmd/migrate down
	@echo "✅ Migration rolled back"

.PHONY: migrate-create
migrate-create: ## Create new migration (usage: make migrate-create NAME=add_user_table)
	@if [ -z "$(NAME)" ]; then echo "❌ Please provide NAME: make migrate-create NAME=your_migration_name"; exit 1; fi
	@go run ./cmd/migrate create $(NAME)
	@echo "✅ Migration created: $(NAME)"

.PHONY: db-reset
db-reset: ## Reset database (WARNING: destroys all data)
	@echo "⚠️  This will destroy all data. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@$(COMPOSE_DEV) down postgres
	@docker volume rm govinfo_postgres_data || true
	@$(COMPOSE_DEV) up -d postgres
	@sleep 5
	@make migrate-up
	@echo "🔄 Database reset complete"

## Testing Commands
.PHONY: test
test: ## Run all tests
	@echo "🧪 Running tests..."
	@go test -v ./...

.PHONY: test-cover
test-cover: ## Run tests with coverage report
	@echo "🧪 Running tests with coverage..."
	@go test -v -cover -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@echo "📊 Coverage report generated: coverage.html"

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "🧪 Starting test database..."
	@$(COMPOSE_TEST) up -d postgres_test
	@sleep 5
	@echo "🧪 Running integration tests..."
	@DATABASE_URL=postgres://dev:devpass@localhost:5433/govinfo_test?sslmode=disable go test -tags=integration -v ./...
	@$(COMPOSE_TEST) stop postgres_test

.PHONY: test-watch
test-watch: ## Run tests in watch mode (requires entr)
	@echo "👀 Watching for changes... (press Ctrl+C to stop)"
	@find . -name "*.go" | entr -c make test

## Code Quality Commands
.PHONY: fmt
fmt: ## Format Go code
	@echo "🎨 Formatting code..."
	@go fmt ./...
	@echo "✅ Code formatted"

.PHONY: lint
lint: ## Run linter
	@echo "🔍 Running linter..."
	@golangci-lint run
	@echo "✅ Linting complete"

.PHONY: vet
vet: ## Run go vet
	@echo "🔍 Running go vet..."
	@go vet ./...
	@echo "✅ Vet complete"

.PHONY: check
check: fmt vet lint test ## Run all code quality checks

## Dependency Commands
.PHONY: deps
deps: ## Download and tidy dependencies
	@echo "📦 Managing dependencies..."
	@go mod download
	@go mod tidy
	@echo "✅ Dependencies updated"

.PHONY: deps-update
deps-update: ## Update all dependencies
	@echo "📦 Updating dependencies..."
	@go get -u ./...
	@go mod tidy
	@echo "✅ Dependencies updated"

## Docker Commands
.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "🐳 Building Docker image..."
	@docker build -t govinfo:latest .
	@echo "✅ Docker image built"

.PHONY: docker-run
docker-run: ## Run application in Docker
	@echo "🐳 Running in Docker..."
	@$(COMPOSE_DEV) --profile api up -d

## Deployment Commands
.PHONY: deploy-build
deploy-build: ## Build production binaries
	@echo "🚀 Building for production..."
	@mkdir -p $(BINARY_PATH)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS) -o $(API_BINARY) ./cmd/api
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS) -o $(BATCH_BINARY) ./cmd/batch
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS) -o $(MIGRATE_BINARY) ./cmd/migrate
	@echo "✅ Production binaries built"

.PHONY: deploy-package
deploy-package: deploy-build ## Create deployment package
	@echo "📦 Creating deployment package..."
	@tar -czf govinfo-$(shell date +%Y%m%d-%H%M%S).tar.gz -C $(BINARY_PATH) .
	@echo "✅ Deployment package created"

## Utility Commands
.PHONY: logs
logs: ## Show application logs
	@$(COMPOSE_DEV) logs -f

.PHONY: db-shell
db-shell: ## Connect to database shell
	@$(COMPOSE_DEV) exec postgres psql -U dev -d govinfo

.PHONY: generate
generate: ## Run go generate
	@echo "⚙️ Running go generate..."
	@go generate ./...
	@echo "✅ Code generation complete"

.PHONY: install-tools
install-tools: ## Install development tools
	@echo "🔧 Installing development tools..."
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@go install github.com/air-verse/air@latest
	@echo "✅ Development tools installed"

.PHONY: run-api
run-api: ## Run API server directly
	@echo "🚀 Starting API server..."
	@go run ./cmd/api

.PHONY: run-batch
run-batch: ## Run batch job directly
	@echo "⚙️ Running batch job..."
	@go run ./cmd/batch

.PHONY: watch
watch: ## Run API with hot reload (requires air)
	@echo "👀 Starting API with hot reload..."
	@air -c .air.toml