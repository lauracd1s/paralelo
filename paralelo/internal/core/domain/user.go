package domain

import "time"

// User es la entidad central del dominio
type User struct {
	ID        int       `json:"id"`
	Nombre    string    `json:"nombre"`
	Email     string    `json:"email"`
	Password  string    `json:"password,omitempty"`
	Rol       string    `json:"rol"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
