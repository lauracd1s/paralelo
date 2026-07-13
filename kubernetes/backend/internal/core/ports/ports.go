package ports

import "paralelo/internal/core/domain"

// ---- PUERTOS PRIMARIOS (driven by the application) ----

// UserService define los casos de uso de Usuario
type UserService interface {
	Register(user *domain.User) (*domain.User, error)
	Login(email, password string) (string, error) // retorna JWT
	GetAll() ([]domain.User, error)
	GetByID(id int) (*domain.User, error)
	Update(id int, user *domain.User) (*domain.User, error)
	Delete(id int) error
}

// ---- PUERTOS SECUNDARIOS (driving the infrastructure) ----

// UserRepository define las operaciones de persistencia
type UserRepository interface {
	Create(user *domain.User) (*domain.User, error)
	FindAll() ([]domain.User, error)
	FindByID(id int) (*domain.User, error)
	FindByEmail(email string) (*domain.User, error)
	Update(id int, user *domain.User) (*domain.User, error)
	Delete(id int) error
}
