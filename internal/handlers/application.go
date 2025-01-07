package handlers

import (
	"automated-printers.astanait.net/pkg/config"
	"log/slog"
)

type Application struct {
	Config *config.Config
	Logger *slog.Logger
}

func NewApplication(cfg *config.Config, logger *slog.Logger) Application {
	return Application{
		Config: cfg,
		Logger: logger,
	}
}
