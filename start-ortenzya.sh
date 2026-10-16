#!/bin/sh
# Model parts are baked in the image. Reassemble only on startup and verify.
set -eu
umask 077
target=/tmp/ortenzya-Q4_K_M.gguf
tmp="${target}.partial"
expected="aefb0b5a93362b8880e2639c15ea807220351c7abfa8e0f6903ca25f31844981"
printf '[ortenzya] Assembling baked GGUF chunks on local disk...\n'
rm -f "$tmp"
cat /opt/ortenzya/chunk-* > "$tmp"
echo "$expected  $tmp" | sha256sum -c -
mv -f "$tmp" "$target"
printf '[ortenzya] Verified GGUF, starting llama-server...\n'
exec /app/llama-server   -m "$target"   --no-mmproj   --ctx-size 16384   --parallel 1   -ngl 999   --alias gemma-4-31b-it   --host ::   --port 8080   --reasoning off -v
