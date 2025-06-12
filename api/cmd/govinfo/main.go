package main

import (
	"fmt"
	"log"

	"go.uber.org/zap"

	"github.com/tingeytime/govinfo/api/internal/config"
	"github.com/tingeytime/govinfo/api/internal/server"
)

func main() {
    cfg := config.Load()
    cfg.Logger = logger

	logger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("can't initialize zap logger: %v", err)
	}
	defer logger.Sync()

	logger.Info("Starting GovInfo API", zap.String("port", cfg.Port))

	if err := server.Start(cfg, logger); err != nil {
		logger.Fatal("server failed", zap.Error(err))
	}
}
