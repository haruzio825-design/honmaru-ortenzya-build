# Ortenzya trial container: code-only image. GGUF is downloaded on first start.
# Known CUDA-12 llama.cpp build. Validate Salad node driver compatibility at first launch.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda12-b10454

LABEL org.opencontainers.image.title="Honmaru Ortenzya trial"
LABEL org.opencontainers.image.description="Independent llama.cpp server for Ortenzya 31B Q4_K_M comparison"
LABEL org.opencontainers.image.source="https://github.com/haruzio825-design/honmaru-ortenzya-build"

EXPOSE 8080

ENTRYPOINT ["/app/llama-server"]
CMD ["-hf", "llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF:Q4_K_M", "--no-mmproj", "--ctx-size", "16384", "--parallel", "1", "-ngl", "999", "--alias", "gemma-4-31b-it", "--host", "::", "--port", "8080", "--reasoning", "off", "-v"]
