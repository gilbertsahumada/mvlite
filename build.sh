#!/usr/bin/env bash
set -euo pipefail

# Build mvlite by compiling within the aptos-core workspace.
# This is required because the aptos-* crates have workspace-internal
# deps that can't be resolved from outside the workspace.
#
# The script:
#   1. Clones aptos-core at the last Apache 2.0 commit (shallow)
#   2. Symlinks mvlite as a workspace member
#   3. Compiles with cargo build -p mvlite
#   4. Copies the binary to ./target/

APTOS_CORE_DIR=".aptos-core"
APTOS_COMMIT="e33e3c1b9e8c4780b488df66fed58ee990de8b16"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== mvlite build ==="
echo ""

# Step 1: Clone aptos-core if not present
if [ ! -d "$SCRIPT_DIR/$APTOS_CORE_DIR" ]; then
    echo "Cloning aptos-core at Apache 2.0 commit $APTOS_COMMIT..."
    git clone --depth 1 https://github.com/aptos-labs/aptos-core.git "$SCRIPT_DIR/$APTOS_CORE_DIR" 2>/dev/null || true
    cd "$SCRIPT_DIR/$APTOS_CORE_DIR"
    git fetch --depth 1 origin "$APTOS_COMMIT"
    git checkout "$APTOS_COMMIT"
    cd "$SCRIPT_DIR"
    echo "Done."
else
    echo "Using cached aptos-core at $APTOS_CORE_DIR"
fi

# Step 2: Add mvlite as workspace member (idempotent)
cd "$SCRIPT_DIR/$APTOS_CORE_DIR"
if ! grep -q '"mvlite"' Cargo.toml; then
    # Add mvlite to workspace members
    sed -i.bak 's/"vm-validator",/"vm-validator",\n    "mvlite",/' Cargo.toml
    rm -f Cargo.toml.bak
    echo "Added mvlite to workspace members."
fi

# Step 3: Symlink mvlite src into aptos-core
rm -rf "$SCRIPT_DIR/$APTOS_CORE_DIR/mvlite"
mkdir -p "$SCRIPT_DIR/$APTOS_CORE_DIR/mvlite"
cp "$SCRIPT_DIR/Cargo.toml" "$SCRIPT_DIR/$APTOS_CORE_DIR/mvlite/Cargo.toml"
ln -sf "$SCRIPT_DIR/src" "$SCRIPT_DIR/$APTOS_CORE_DIR/mvlite/src"

# Step 4: Build
echo ""
echo "Building mvlite..."
cargo build -p mvlite --release 2>&1 | tail -5

# Step 5: Copy binary
mkdir -p "$SCRIPT_DIR/target"
cp "$SCRIPT_DIR/$APTOS_CORE_DIR/target/release/mvlite" "$SCRIPT_DIR/target/mvlite"

echo ""
echo "Build complete: ./target/mvlite"
echo "Run: ./target/mvlite start --port 8090"
