package services

import (
	"errors"
	"os"
	"time"

	"paralelo/internal/core/domain"
	"paralelo/internal/core/ports"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type userService struct {
	repo ports.UserRepository
}

// NewUserService crea una nueva instancia del servicio
func NewUserService(repo ports.UserRepository) ports.UserService {
	return &userService{repo: repo}
}

// Register crea un nuevo usuario con contraseña hasheada
func (s *userService) Register(user *domain.User) (*domain.User, error) {
	// Verificar si el email ya existe
	existing, _ := s.repo.FindByEmail(user.Email)
	if existing != nil {
		return nil, errors.New("el email ya está registrado")
	}

	// Hashear contraseña
	hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("error al procesar la contraseña")
	}
	user.Password = string(hashed)

	// Rol por defecto
	if user.Rol == "" {
		user.Rol = "usuario"
	}

	return s.repo.Create(user)
}

// Login autentica un usuario y devuelve un JWT
func (s *userService) Login(email, password string) (string, error) {
	user, err := s.repo.FindByEmail(email)
	if err != nil || user == nil {
		return "", errors.New("credenciales inválidas")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return "", errors.New("credenciales inválidas")
	}

	// Generar JWT
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "secret_default_cambiar_en_produccion"
	}

	claims := jwt.MapClaims{
		"sub":   user.ID,
		"email": user.Email,
		"rol":   user.Rol,
		"exp":   time.Now().Add(24 * time.Hour).Unix(),
		"iat":   time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString([]byte(secret))
	if err != nil {
		return "", errors.New("error al generar el token")
	}

	return tokenStr, nil
}

func (s *userService) GetAll() ([]domain.User, error) {
	return s.repo.FindAll()
}

func (s *userService) GetByID(id int) (*domain.User, error) {
	user, err := s.repo.FindByID(id)
	if err != nil {
		return nil, errors.New("usuario no encontrado")
	}
	return user, nil
}

func (s *userService) Update(id int, user *domain.User) (*domain.User, error) {
	existing, err := s.repo.FindByID(id)
	if err != nil || existing == nil {
		return nil, errors.New("usuario no encontrado")
	}

	// Si se cambia la contraseña, hashearla
	if user.Password != "" {
		hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		if err != nil {
			return nil, errors.New("error al procesar la contraseña")
		}
		user.Password = string(hashed)
	}

	return s.repo.Update(id, user)
}

func (s *userService) Delete(id int) error {
	existing, err := s.repo.FindByID(id)
	if err != nil || existing == nil {
		return errors.New("usuario no encontrado")
	}
	return s.repo.Delete(id)
}
