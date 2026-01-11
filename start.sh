#!/bin/bash
# Restore clawdbot from volume if needed
# Initialize memory system with graceful shutdown

SOURCE="/data/clawdbot-lib"
TARGET="/usr/local/lib/node_modules/clawdbot"
CLAWD_DIR="/root/clawd"
MEMORY_FILE="$CLAWD_DIR/.memory-session"

# Initialize memory session
init_memory() {
    if [ -f "$CLAWD_DIR/memory.js" ]; then
        echo "[boot] Starting memory session..."
        node "$CLAWD_DIR/memory.js" start > "$MEMORY_FILE" 2>&1
        echo "[boot] Memory session started!"
    fi
}

# Graceful shutdown - end memory session
end_memory() {
    if [ -f "$MEMORY_FILE" ] && [ -f "$CLAWD_DIR/memory.js" ]; then
        echo "[shutdown] Ending memory session..."
        SESSION_ID=$(grep "Session started:" "$MEMORY_FILE" | awk '{print $3}')
        if [ -n "$SESSION_ID" ]; then
            node "$CLAWD_DIR/memory.js" end "$SESSION_ID"
        fi
        echo "[shutdown] Memory session saved!"
    fi
    exit 0
}

# Trap signals for graceful shutdown
trap end_memory SIGTERM SIGINT SIGHUP

# Restore clawdbot from volume if needed
if [ -d "$SOURCE" ] && [ ! -d "$TARGET" ]; then
    echo "[boot] Restoring clawdbot from volume..."
    cp -r "$SOURCE" "$TARGET"
    echo "[boot] Done!"
fi

# Start memory session
init_memory

# Run gateway in foreground (trap will catch shutdown)
exec pnpm clawdbot gateway
