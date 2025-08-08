# FrankenPHP Note Extension

Go-based FrankenPHP extension providing Apache-style note functionality. Allows setting, getting, and managing notes (key-value pairs) that persist during a single request, similar to Apache's `apache_note` functions.

## Features

- Go-based extension with CGO exports
- Apache-compatible API
- Thread-safe storage with mutex protection
- JSON export for logging
- Built-in Caddy integration

## API

- `frankenphp_note(string $key, ?string $value = null): string` - Set or get a note
- `frankenphp_note_clear(): int` - Clear all notes
- `frankenphp_note_get_all(): string` - Get all notes as JSON

## Installation

First, if not already done, follow the instructions to install a ZTS version of libphp and xcaddy. Then, use xcaddy to build FrankenPHP with the frankenphp-note module:

```bash
CGO_ENABLED=1 \
XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
CGO_CFLAGS=$(php-config --includes) \
CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
xcaddy build \
    --output frankenphp \
    --with github.com/Nova-Static/frankenphp-note-extension \
    --with github.com/dunglas/frankenphp/caddy \
    --with github.com/dunglas/mercure/caddy \
    --with github.com/dunglas/vulcain/caddy
    # Add extra Caddy modules and FrankenPHP extensions here
```

That's all! Your custom FrankenPHP build contains the frankenphp-note extension.

### Alternative: Local Build

For development, you can also use the provided build script:

```bash
./build.sh
```

## Usage

### Basic Example

```php
<?php
// Set notes
$userId = frankenphp_note('user_id', '12345');
$requestType = frankenphp_note('request_type', 'api');

// Get notes
$userId = frankenphp_note('user_id'); // Returns '12345'

// Clear all notes
frankenphp_note_clear();

// Export as JSON
$allNotes = frankenphp_note_get_all();
```

### Logging Example

```php
<?php
frankenphp_note('request_id', uniqid());
frankenphp_note('user_agent', $_SERVER['HTTP_USER_AGENT'] ?? '');
frankenphp_note('ip_address', $_SERVER['REMOTE_ADDR'] ?? '');

// ... application logic ...

$notes = json_decode(frankenphp_note_get_all(), true);
error_log(sprintf(
    "Request completed - ID: %s, User-Agent: %s, IP: %s",
    $notes['request_id'] ?? 'unknown',
    $notes['user_agent'] ?? 'unknown',
    $notes['ip_address'] ?? 'unknown'
));
```

### Caddy Configuration

```caddyfile
{
    frankenphp_note
}

:2015 {
    root * /var/www/html
    php_server
}
```

## Development

### Test Go Extension

```bash
go build -buildmode=c-shared -o libfrankenphp_note.so frankenphp_note.go
./demo.sh
```

## Thread Safety

Notes are stored per-request with proper synchronization. Automatically cleared between requests.

## License

MIT License
