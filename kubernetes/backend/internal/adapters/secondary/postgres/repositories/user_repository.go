package repositories

import (
	"database/sql"
	"errors"
	"time"

	"paralelo/internal/core/domain"
	"paralelo/internal/core/ports"
)

type postgresUserRepo struct {
	db *sql.DB
}

// NewPostgresUserRepository crea el adaptador secundario de PostgreSQL
func NewPostgresUserRepository(db *sql.DB) ports.UserRepository {
	return &postgresUserRepo{db: db}
}

func (r *postgresUserRepo) Create(user *domain.User) (*domain.User, error) {
	query := `
		INSERT INTO usuarios (nombre, email, password, rol, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, nombre, email, rol, created_at, updated_at`

	now := time.Now()
	row := r.db.QueryRow(query, user.Nombre, user.Email, user.Password, user.Rol, now, now)

	created := &domain.User{}
	err := row.Scan(&created.ID, &created.Nombre, &created.Email, &created.Rol,
		&created.CreatedAt, &created.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return created, nil
}

func (r *postgresUserRepo) FindAll() ([]domain.User, error) {
	query := `SELECT id, nombre, email, rol, created_at, updated_at FROM usuarios ORDER BY id`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []domain.User
	for rows.Next() {
		var u domain.User
		if err := rows.Scan(&u.ID, &u.Nombre, &u.Email, &u.Rol, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func (r *postgresUserRepo) FindByID(id int) (*domain.User, error) {
	query := `SELECT id, nombre, email, rol, created_at, updated_at FROM usuarios WHERE id = $1`
	row := r.db.QueryRow(query, id)

	u := &domain.User{}
	err := row.Scan(&u.ID, &u.Nombre, &u.Email, &u.Rol, &u.CreatedAt, &u.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, errors.New("usuario no encontrado")
	}
	if err != nil {
		return nil, err
	}
	return u, nil
}

func (r *postgresUserRepo) FindByEmail(email string) (*domain.User, error) {
	query := `SELECT id, nombre, email, password, rol, created_at, updated_at FROM usuarios WHERE email = $1`
	row := r.db.QueryRow(query, email)

	u := &domain.User{}
	err := row.Scan(&u.ID, &u.Nombre, &u.Email, &u.Password, &u.Rol, &u.CreatedAt, &u.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return u, nil
}

func (r *postgresUserRepo) Update(id int, user *domain.User) (*domain.User, error) {
	query := `
		UPDATE usuarios
		SET nombre = COALESCE(NULLIF($1, ''), nombre),
		    email  = COALESCE(NULLIF($2, ''), email),
		    password = CASE WHEN $3 != '' THEN $3 ELSE password END,
		    rol    = COALESCE(NULLIF($4, ''), rol),
		    updated_at = $5
		WHERE id = $6
		RETURNING id, nombre, email, rol, created_at, updated_at`

	row := r.db.QueryRow(query, user.Nombre, user.Email, user.Password, user.Rol, time.Now(), id)

	updated := &domain.User{}
	err := row.Scan(&updated.ID, &updated.Nombre, &updated.Email, &updated.Rol,
		&updated.CreatedAt, &updated.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return updated, nil
}

func (r *postgresUserRepo) Delete(id int) error {
	_, err := r.db.Exec(`DELETE FROM usuarios WHERE id = $1`, id)
	return err
}
