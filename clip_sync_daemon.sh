#!/usr/bin/env bash

REPO_DIR="${HOME}/github-snippets"
LAST_HASH=""

get_clip() {
    if command -v termux-clipboard-get &>/dev/null; then
        termux-clipboard-get 2>/dev/null
    elif command -v wl-paste &>/dev/null; then
        wl-paste 2>/dev/null
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o 2>/dev/null
    elif command -v pbpaste &>/dev/null; then
        pbpaste 2>/dev/null
    fi
}

echo "[*] Clipboard auto-push daemon started. Watching for changes..."

while true; do
    CLIP_CONTENT=$(get_clip)
    if [ -n "$CLIP_CONTENT" ]; then
        CURRENT_HASH=$(echo -n "$CLIP_CONTENT" | sha256sum | awk '{print $1}')
        if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            LAST_HASH="$CURRENT_HASH"
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            FILENAME="${REPO_DIR}/auto_clip_${TIMESTAMP}.txt"
            
            echo "$CLIP_CONTENT" > "$FILENAME"
            
            cd "$REPO_DIR"
            git add "$FILENAME"
            git commit -m "Automated clipboard sync: ${TIMESTAMP}"
            git push origin main && echo "[✓] Auto-pushed clipboard content: ${FILENAME}" || echo "[!] Push failed. Ensure remote repository is configured."
        fi
    fi
    sleep 3
done
