#!/bin/bash

set -e

echo "Building FrankenPHP with Note Extension"

BUILD_DIR="/tmp/frankenphp-note-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Creating FrankenPHP build..."

cat > "$BUILD_DIR/main.go" << 'EOF'
package main

import (
    caddycmd "github.com/caddyserver/caddy/v2/cmd"
    _ "github.com/caddyserver/caddy/v2/modules/standard"
    _ "github.com/Nova-Static/frankenphp-note-extension"
)

func main() {
    caddycmd.Main()
}
EOF

cat > "$BUILD_DIR/go.mod" << 'EOF'
module frankenphp-note-build

go 1.22

require (
    github.com/caddyserver/caddy/v2 v2.7.6
    github.com/Nova-Static/frankenphp-note-extension v0.0.0
)

replace github.com/Nova-Static/frankenphp-note-extension => ./frankenphp-note
EOF

cp -r . "$BUILD_DIR/frankenphp-note"

cd "$BUILD_DIR"
go mod tidy

echo "Building FrankenPHP..."
CGO_ENABLED=1 \
go build -ldflags='-w -s' -tags=nobadger,nomysql,nopgx -o frankenphp .

cp frankenphp /home/nova/frankenphp-note/

cd /home/nova/frankenphp-note

echo "FrankenPHP built successfully"
echo "Binary: ./frankenphp"

echo "Testing FrankenPHP..."
if ./frankenphp version; then
    echo "Test passed"
else
    echo "Test failed"
fi

rm -rf "$BUILD_DIR"
