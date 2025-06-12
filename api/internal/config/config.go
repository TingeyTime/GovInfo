package config

import (
    "log"
    "os"

	"go.uber.org/zap"

    "github.com/joho/godotenv"
)

type Config struct {
    Port         string
    DBUrl        string
    TwilioSID    string
    TwilioToken  string
    Logger       *zap.Logger
}


func Load() *Config {
    // Load .env if it exists (dev only)
    _ = godotenv.Load()

    return &Config{
        Port:        getEnv("PORT", "8080"),
        DBUrl:       os.Getenv("DATABASE_URL"),
        TwilioSID:   os.Getenv("TWILIO_SID"),
        TwilioToken: os.Getenv("TWILIO_TOKEN"),
    }
}

func getEnv(key, fallback string) string {
    val := os.Getenv(key)
    if val == "" {
        return fallback
    }
    return val
}
