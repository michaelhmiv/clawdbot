#!/bin/bash
# Restore clawdbot from volume if needed

SOURCE="/data/clawdbot-lib"
TARGET="/usr/local/lib/node_modules/clawdbot"

if [ -d "$SOURCE" ] && [ ! -d "$TARGET" ]; then
    echo "[boot] Restoring clawdbot from volume..."
    cp -r "$SOURCE" "$TARGET"
    echo "[boot] Done!"
fi

exec pnpm clawdbot gateway
