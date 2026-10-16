# syntax=docker/dockerfile:1
# This image is experimental and intentionally NOT auto-built.
# Keep each GHCR layer < 10 GB (the model is ~18.7 GB).
FROM ubuntu:24.04 AS model_chunks

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl coreutils && rm -rf /var/lib/apt/lists/*

ARG HF_REVISION=d7c96e816759b50ba7d0afe3a9e36deb7b096f16
ARG EXPECTED_SHA256=aefb0b5a93362b8880e2639c15ea807220351c7abfa8e0f6903ca25f31844981
ARG MODEL_FILENAME=gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-Q4_K_M.gguf
RUN mkdir -p /model-parts &&     curl --fail --location --silent --show-error --retry 4 --retry-delay 8       "https://huggingface.co/llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF/resolve/${HF_REVISION}/${MODEL_FILENAME}?download=true"       | split --bytes=2000000000 --numeric-suffixes=0 --suffix-length=2 - /model-parts/chunk- &&     test "$(find /model-parts -type f -name 'chunk-*' | wc -l)" -eq 10 &&     echo "${EXPECTED_SHA256}  -" | sha256sum --check < <(cat /model-parts/chunk-*)

# Each COPY below creates a separate ~2 GB layer, below GHCR's 10 GB/layer limit.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda
LABEL org.opencontainers.image.source="https://github.com/haruzio825-design/honmaru-ortenzya-build"
LABEL org.opencontainers.image.title="Honmaru Ortenzya comparison"
LABEL org.opencontainers.image.description="Baked Gemma 4 Ortenzya 31B Q4_K_M split into registry-safe layers"

COPY --from=model_chunks /model-parts/chunk-00 /opt/ortenzya/chunk-00
COPY --from=model_chunks /model-parts/chunk-01 /opt/ortenzya/chunk-01
COPY --from=model_chunks /model-parts/chunk-02 /opt/ortenzya/chunk-02
COPY --from=model_chunks /model-parts/chunk-03 /opt/ortenzya/chunk-03
COPY --from=model_chunks /model-parts/chunk-04 /opt/ortenzya/chunk-04
COPY --from=model_chunks /model-parts/chunk-05 /opt/ortenzya/chunk-05
COPY --from=model_chunks /model-parts/chunk-06 /opt/ortenzya/chunk-06
COPY --from=model_chunks /model-parts/chunk-07 /opt/ortenzya/chunk-07
COPY --from=model_chunks /model-parts/chunk-08 /opt/ortenzya/chunk-08
COPY --from=model_chunks /model-parts/chunk-09 /opt/ortenzya/chunk-09

COPY start-ortenzya.sh /app/start-ortenzya.sh
EXPOSE 8080
ENTRYPOINT ["/bin/sh", "/app/start-ortenzya.sh"]
