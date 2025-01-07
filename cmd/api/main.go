package main

import (
	"automated-printers.astanait.net/pkg/config"
	"database/sql"
	"flag"
	"fmt"
	"log"
	"log/slog"
	"net/http"
	"os"
	"time"

	"automated-printers.astanait.net/internal/handlers"

	_ "github.com/lib/pq"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))

	cfg, err := config.LoadConfig("config.env")
	if err != nil {
		log.Fatalf("cannot load config: %v", err)
	}

	flag.IntVar(&cfg.Server.Port, "port", 4000, "API server port")
	flag.StringVar(&cfg.Server.Environment, "env", "development", "Environment (development|staging|production)")
	flag.Parse()

	app := handlers.NewApplication(cfg, logger)

	db, err := sql.Open(cfg.Database.Driver, cfg.Database.DSN)
	if err != nil {
		log.Fatal("Cannot connect to DB:", err)
	}
	defer db.Close()

	server := &http.Server{
		Addr:              fmt.Sprintf(":%d", cfg.Server.Port),
		Handler:           app.Routes(),
		ReadTimeout:       time.Duration(cfg.Server.ReadTimeoutSec) * time.Second,
		WriteTimeout:      time.Duration(cfg.Server.WriteTimeoutSec) * time.Second,
		ReadHeaderTimeout: 5 * time.Second,
	}

	logger.Info("starting server", "addr", server.Addr, "env", cfg.Server.Environment)
	err = server.ListenAndServe()
	logger.Error(err.Error())
	os.Exit(1)
}
