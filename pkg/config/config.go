package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds the application's configuration fields
type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
}

type ServerConfig struct {
	Port            int
	ReadTimeoutSec  int
	WriteTimeoutSec int
	Environment     string // e.g., "development", "production"
}

type DatabaseConfig struct {
	Driver string
	DSN    string
}

func LoadConfig(envPath string) (*Config, error) {
	err := godotenv.Load(envPath)
	if err != nil {
		fmt.Println("Warning: .env file not found, using system environment variables")
	}

	dbDSN := os.Getenv("DB_DSN")
	if dbDSN == "" {
		return nil, fmt.Errorf("missing required environment variable: DB_DSN")
	}

	cfg := &Config{
		Server: ServerConfig{
			Port:            getEnvAsInt("SERVER_PORT", 8080),
			ReadTimeoutSec:  getEnvAsInt("SERVER_READ_TIMEOUT", 10),
			WriteTimeoutSec: getEnvAsInt("SERVER_WRITE_TIMEOUT", 10),
			Environment:     getEnv("SERVER_ENV", "development"),
		},
		Database: DatabaseConfig{
			Driver: getEnv("DB_DRIVER", "postgres"),
			DSN:    dbDSN,
		},
	}

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getEnvAsInt(key string, fallback int) int {
	valueStr := os.Getenv(key)
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return fallback
}
