# GovInfo

> 🏛️ **Get your government information delivered straight to your phone**

[![Go 1.21+](https://img.shields.io/badge/Go-1.21+-00ADD8?style=flat&logo=go)](https://golang.org/)
[![PostgreSQL 13+](https://img.shields.io/badge/PostgreSQL-13+-336791?style=flat&logo=postgresql&logoColor=white)](https://postgresql.org/)
[![Twilio SMS](https://img.shields.io/badge/Twilio-SMS-F22F46?style=flat&logo=twilio&logoColor=white)](https://twilio.com/)
[![Docker](https://img.shields.io/docker/:govinfo-blue?style=flat)](https://hub.docker.com/r/tingeytime/govinfo)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

GovInfo is an opt-in SMS service that delivers personalized government information based on your address. Stay informed about your elected officials, upcoming legislation, and local government activities—all through simple text messages.

## ✨ Features

- **📍 Location-Based Information**: Get details about your House Representatives, Senators, and Governor by address
- **📱 SMS Interface**: Receive information via text messages with simple opt-in/opt-out
- **⏰ Scheduled Updates**: Weekly updates on legislation and representative activities
- **🔒 Privacy-First**: Explicit opt-in required, easy opt-out anytime
- **🏛️ Comprehensive Coverage**: Federal and state-level government information

## 🚀 Quick Start

### Prerequisites

- [Go 1.21+](https://golang.org/dl/)
- [PostgreSQL 13+](https://www.postgresql.org/download/)
- [Twilio Account](https://www.twilio.com/try-twilio) with SMS capabilities

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/govinfo.git
   cd govinfo
   ```

2. **Start local database**
   ```bash
   docker-compose up -d postgres
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Twilio credentials and database URL
   ```

4. **Run database migrations**
   ```bash
   go run cmd/migrate/main.go
   ```

5. **Start the API server**
   ```bash
   go run cmd/api/main.go
   ```

6. **Run the batch job (separate terminal)**
   ```bash
   go run cmd/batch/main.go
   ```

## 🏗️ Architecture

GovInfo uses a clean, scalable architecture designed for reliability and performance:

```
    [HTTP API] ←→ [handlers] ←→ [services] ←→ [database]
         ↑               ↓
     [Twilio] ←← [batch job scheduler]
```

### Tech Stack

- **Backend**: Go with standard library and minimal dependencies
- **Database**: PostgreSQL for reliable data storage
- **SMS Provider**: Twilio for message delivery
- **Deployment**: Static binaries with systemd (production) / Docker Compose (development)

## 📦 Project Structure

```
govinfo/
├── cmd/
│   ├── api/           # REST API server
│   ├── batch/         # Weekly batch job
│   └── migrate/       # Database migrations
├── internal/
│   ├── services/      # Business logic layer
│   ├── models/        # Database models
│   ├── handlers/      # HTTP request handlers
│   └── config/        # Configuration management
├── migrations/        # SQL migration files
├── docker-compose.yml # Local development setup
└── README.md
```

## 🔧 Configuration

Set the following environment variables:

```bash
# Database
DATABASE_URL=postgres://user:pass@localhost:5432/govinfo

# Twilio
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_twilio_number

# Server
PORT=8080
HOST=localhost
ENV=development
```

## 📱 User Journey

1. **Opt-in**: Text your address to the service number
2. **Verification**: Receive confirmation and welcome message
3. **Weekly Updates**: Get personalized government information
4. **Manage Preferences**: Update address or frequency anytime
5. **Opt-out**: Simple text command to unsubscribe

### Example SMS Flow

```
User: "123 Main St, Anytown, NY 12345"
Bot:  "Welcome to GovInfo! You'll receive weekly updates about your representatives. Reply STOP to opt-out anytime."

Weekly: "Your Rep: John Smith voted on H.R. 1234 (Infrastructure Bill). Sen. Jane Doe introduced S. 567 (Climate Act). More: govinfo.com/details"
```

## 🛠️ Development

### Running Tests

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run integration tests (requires running database)
go test -tags=integration ./...
```

### Database Operations

```bash
# Create new migration
go run cmd/migrate/main.go create add_user_preferences

# Run migrations
go run cmd/migrate/main.go up

# Rollback migration
go run cmd/migrate/main.go down
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/subscribe` | Opt-in a new user |
| DELETE | `/users/{id}/subscription` | Opt-out user |
| PUT | `/users/{id}/preferences` | Update user preferences |
| POST | `/webhooks/twilio` | Handle incoming SMS |

## 🚀 Deployment

### Production Deployment (Recommended)

1. **Build static binaries**
   ```bash
   CGO_ENABLED=0 GOOS=linux go build -o bin/api cmd/api/main.go
   CGO_ENABLED=0 GOOS=linux go build -o bin/batch cmd/batch/main.go
   ```

2. **Deploy to VPS**
   ```bash
   # Copy binaries and set up systemd services
   # See deployment/ directory for systemd service files
   ```

3. **Set up PostgreSQL**
   ```bash
   # Install and configure PostgreSQL on your VPS
   # Run migrations in production
   ```

### Container Deployment (Alternative)

```bash
# Build and deploy with Docker
docker build -t govinfo .
docker run -d --name govinfo-api govinfo
```

## 📊 Monitoring & Observability

- **Health Checks**: `/health` endpoint for service monitoring
- **Metrics**: Prometheus metrics for delivery rates and API performance  
- **Logging**: Structured JSON logging with different levels
- **Alerting**: Monitor opt-out rates and delivery failures

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Roadmap

- [ ] **Phase 1**: Core SMS functionality with basic government data
- [ ] **Phase 2**: Enhanced data sources and real-time updates
- [ ] **Phase 3**: Web dashboard for user management
- [ ] **Phase 4**: Advanced filtering and personalization
- [ ] **Phase 5**: Multi-language support

## 🔒 Privacy & Compliance

- **TCPA Compliant**: Explicit opt-in required for all messaging
- **Data Minimization**: Only store necessary user information
- **Easy Opt-out**: Clear unsubscribe process in every message
- **Audit Trail**: Complete logging of consent and communications

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/govinfo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/govinfo/discussions)

---

**Made with ❤️ for civic engagement**