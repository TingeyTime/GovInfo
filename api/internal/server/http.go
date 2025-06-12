package server

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"go.uber.org/zap"
	"github.com/tingeytime/govinfo/api/internal/config"
)

func Start(cfg *config.Config, logger *zap.Logger) error {
	r := chi.NewRouter()

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		logger.Info("Health check called")
		fmt.Fprintln(w, "OK")
	})

	addr := ":" + cfg.Port
	logger.Info("Server listening", zap.String("addr", addr))
	return http.ListenAndServe(addr, r)
}
