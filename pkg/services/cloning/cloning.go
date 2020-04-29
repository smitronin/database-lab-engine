/*
2019 © Postgres.ai
*/

// Package cloning provides a cloning service.
package cloning

import (
	"context"
	"time"

	"github.com/pkg/errors"

	"gitlab.com/postgres-ai/database-lab/pkg/client/dblabapi/types"
	"gitlab.com/postgres-ai/database-lab/pkg/log"
	"gitlab.com/postgres-ai/database-lab/pkg/models"
	"gitlab.com/postgres-ai/database-lab/pkg/services/provision"
	"gitlab.com/postgres-ai/database-lab/pkg/services/provision/resources"
)

const (
	// ModeBase defines a base mode of cloning.
	ModeBase = "base"

	// ModeMock defines a mock mode of cloning.
	ModeMock = "mock"

	// cloneDiffSize defines a default clone size.
	cloneDiffSize = 10
)

// Config contains a cloning configuration.
type Config struct {
	Mode           string `yaml:"mode"`
	MaxIdleMinutes uint   `yaml:"maxIdleMinutes"`
	AccessHost     string `yaml:"accessHost"`
}

type cloning struct {
	Config *Config
}

// Cloning defines a Cloning service interface.
type Cloning interface {
	Run(ctx context.Context) error

	CreateClone(*types.CloneCreateRequest) (*models.Clone, error)
	DestroyClone(string) error
	GetClone(string) (*models.Clone, error)
	UpdateClone(string, *types.CloneUpdateRequest) (*models.Clone, error)
	ResetClone(string) error

	GetInstanceState() (*models.InstanceStatus, error)
	GetSnapshots() ([]models.Snapshot, error)
	GetClones() []*models.Clone
}

// CloneWrapper represents a cloning service wrapper.
type CloneWrapper struct {
	clone   *models.Clone
	session *resources.Session

	timeCreatedAt time.Time
	timeStartedAt time.Time

	username string
	password string

	snapshot models.Snapshot
}

// NewCloning returns a cloning interface depends on configuration mode.
func NewCloning(config *Config, provision provision.Provision) (Cloning, error) {
	switch config.Mode {
	case "", ModeBase:
		log.Dbg("Using base cloning mode.")
		return NewBaseCloning(config, provision), nil
	case ModeMock:
		log.Dbg("Using mock cloning mode.")
		return nil, nil
	}

	return nil, errors.New("unsupported mode specified")
}

// NewCloneWrapper constructs a new CloneWrapper.
func NewCloneWrapper(clone *models.Clone) *CloneWrapper {
	w := &CloneWrapper{
		clone: clone,
	}

	return w
}

// IsProtected checks if clone is protected.
func (cw CloneWrapper) IsProtected() bool {
	return cw.clone != nil && cw.clone.Protected
}
