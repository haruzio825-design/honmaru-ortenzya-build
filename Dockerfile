# syntax=docker/dockerfile:1
# EXPERIMENTAL / NOT YET BUILT OR TESTED.
# Download the verified, revision-pinned GGUF DURING image build, not at GPU startup.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ARG HF_REVISION
ARG EXPECTED_SHA256
ARG MODEL_FILE=gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-Q4_K_M.gguf

LABEL org.opencontainers.image.title="Honmaru Ortenzya trial"
LABEL org.opencontainers.image.description="Independent 31B Q4_K_M creative-writing comparison model"
LABEL org.opencontainers.image.source="https://github.com/haruzio825-design/honmaru-ortenzya-build"

# Exact filename verified from the Hugging Face model files listing.
# The selected model revision must be obtained by scripts/model_preflight.py.
ADD https://huggingface.co/llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF/resolve/${HF_REVISION}/${MODEL_FILE} /models/ortenzya-Q4_K_M.gguf

# Stop rather than publish if the model changed or the downloaded blob is corrupt.
RUN test -n "${EXPECTED_SHA256}" && \
    echo "${EXPECTED_SHA256}  /models/ortenzya-Q4_K_M.gguf" | sha256sum -c -

EXPOSE 8080
ENTRYPOINT ["/app/llama-server"]
CMD ["-m", "/models/ortenzya-Q4_K_M.gguf", "--no-mmproj", "--ctx-size", "16384", "--parallel", "1", "-ngl", "999", "--alias", "gemma-4-31b-it", "--host", "::", "--port", "8080", "--reasoning", "off", "-v"]
