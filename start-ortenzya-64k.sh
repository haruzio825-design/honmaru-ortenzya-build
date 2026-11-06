#!/bin/sh
# 64K test: preserve the original GGUF and server alias; change only context
# capacity, KV-cache precision, and low-memory inference settings.
# Environment overrides allow GPU-fit diagnosis without another image build.
set -eu
umask 077

target=/tmp/ortenzya-Q4_K_M.gguf
tmp="${target}.partial"
expected="aefb0b5a93362b8880e2639c15ea807220351c7abfa8e0f6903ca25f31844981"

: "${ORTENZYA_CTX_SIZE:=65536}"
: "${ORTENZYA_GPU_LAYERS:=999}"
: "${ORTENZYA_CACHE_K:=q4_0}"
: "${ORTENZYA_CACHE_V:=q4_0}"
: "${ORTENZYA_CPU_KV:=0}"

printf '[ortenzya-64k] Assembling original GGUF on local disk...\n'
rm -f "$tmp"
cat /opt/ortenzya/chunk-* > "$tmp"
echo "$expected  $tmp" | sha256sum -c -
mv -f "$tmp" "$target"

printf '[ortenzya-64k] ctx=%s gpu_layers=%s cache_k=%s cache_v=%s cpu_kv=%s\n' \
  "$ORTENZYA_CTX_SIZE" "$ORTENZYA_GPU_LAYERS" \
  "$ORTENZYA_CACHE_K" "$ORTENZYA_CACHE_V" "$ORTENZYA_CPU_KV"

set -- /app/llama-server \
  -m "$target" \
  --no-mmproj \
  --ctx-size "$ORTENZYA_CTX_SIZE" \
  --parallel 1 \
  -ngl "$ORTENZYA_GPU_LAYERS" \
  --cache-type-k "$ORTENZYA_CACHE_K" \
  --cache-type-v "$ORTENZYA_CACHE_V" \
  --flash-attn on \
  -b 512 -ub 128 \
  --alias gemma-4-31b-it \
  --host :: \
  --port 8080 \
  --reasoning off \
  -v

case "$ORTENZYA_CPU_KV" in
  0|false|off) ;;
  1|true|on) set -- "$@" --no-kv-offload ;;
  *) echo "[ortenzya-64k] Invalid ORTENZYA_CPU_KV: $ORTENZYA_CPU_KV" >&2; exit 2 ;;
esac

printf '[ortenzya-64k] Verified GGUF; starting llama-server...\n'
exec "$@"
