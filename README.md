# PixelVault-Back

Backend API para PixelVault – una plataforma de descubrimiento de videojuegos y gestión de favoritos. Construido con Ruby on Rails 8.1 y PostgreSQL, proporciona endpoints autenticados con JWT para usuarios y administradores, y actúa como proxy para la base de datos de videojuegos [RAWG](https://rawg.io/apidocs).

## Características

- Registro e inicio de sesión de usuarios (tokens JWT)
- Autenticación de administradores (separada de los usuarios regulares)
- Gestión de juegos favoritos y sus categorías (CRUD)
- Categorización de favoritos (categorías administradas por administradores)
- Endpoints proxy para la API de RAWG (lista de juegos, detalles, géneros, plataformas, etc.)
- CORS configurado para el desarrollo del frontend (`http://localhost:5173`)

## Requisitos

- **Ruby** 3.2 o superior (se recomienda 3.3)
- **PostgreSQL** 14+
- **Bundler** (gema)
- **Una clave de API de RAWG** – obtenida en [RAWG](https://rawg.io/apidocs)

## Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/alexei377mx/PixelVault-Back.git
```

### 2. Instalar las dependencias de Ruby

```bash
bundle install
```

### 3. Configurar las variables de entorno

Crea un archivo `.env` en la raíz del proyecto con la siguiente variable:

```env
RAWG_API_KEY=tu_clave_rawg_api_aqui
```

### 4. Configurar la base de datos

Crear, migrar y sembrar la base de datos:

```bash
bin/rails db:create db:migrate db:seed
```

## Ejecutar el servidor

Inicia el servidor de desarrollo de Rails:

```bash
bin/rails server
```

La API estará disponible en `http://localhost:3000`.

## Pruebas

Ejecutar toda la suite de pruebas:

```bash
bin/rails test
```

Para ejecutar un archivo de prueba específico:

```bash
bin/rails test test/controllers/games_controller_test.rb
```

El proyecto también incluye:

- **RuboCop** para linting: `bin/rubocop -A`
- **Brakeman** para análisis de seguridad: `bin/brakeman`
- **Bundler‑Audit** para vulnerabilidades de gemas: `bin/bundler-audit`

Hay un pipeline de CI definido en `config/ci.rb`; puedes ejecutarlo con `bin/ci`.

## Resumen de la API

Todos los endpoints devuelven JSON. La autenticación es requerida para la mayoría de las acciones, excepto para los listados públicos de juegos y los endpoints de autenticación.

### Endpoints públicos

| Método | Endpoint          | Descripción                                     |
|--------|-------------------|-------------------------------------------------|
| GET    | `/games`          | Listar juegos (paginado, búsqueda, filtros)     |
| GET    | `/games/:id`      | Obtener detalles de un juego                    |
| GET    | `/genres`         | Listar todos los géneros                        |
| GET    | `/platforms`      | Listar todas las plataformas                    |
| POST   | `/register`       | Registrar un nuevo usuario                      |
| POST   | `/login`          | Iniciar sesión como usuario regular             |
| POST   | `/admin/login`    | Iniciar sesión como administrador               |

### Endpoints autenticados (requieren `Authorization: Bearer <token>`)

| Método | Endpoint                 | Descripción                                   |
|--------|--------------------------|-----------------------------------------------|
| GET    | `/favorites`             | Listar los favoritos del usuario actual       |
| POST   | `/favorites`             | Agregar un juego a favoritos                  |
| PUT    | `/favorites/:game_id`    | Actualizar la categoría de un favorito        |
| DELETE | `/favorites/:game_id`    | Eliminar un favorito                          |
| GET    | `/categories`            | Listar todas las categorías (público)         |
| POST   | `/categories`            | Crear una nueva categoría (solo admin)        |
| PUT    | `/categories/:id`        | Actualizar una categoría (solo admin)         |
| DELETE | `/categories/:id`        | Eliminar una categoría (solo admin)           |

> **Nota:** El `:game_id` en las rutas de favoritos es el ID del juego de RAWG (entero), no el ID local de registro.

## Archivos de configuración

- **CORS**: `config/initializers/cors.rb` – actualmente permite `http://localhost:5173`.
- **Base de datos**: `config/database.yml` – usa PostgreSQL. Ajustar las credenciales según sea necesario.
