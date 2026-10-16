# honmaru-ortenzya-build

比較試験専用の **未検証** サーバー設計。既存の `honmaru-gemma4-baked` (QAT) を変更しません。

## 現在の進捗
- GitHub repository: created.
- `Dockerfile`: experimental llama.cpp CUDA 12 **small code-only image**. **Not built or tested**.
- GGUF is NOT bundled into this image. `-hf` downloads the Q4_K_M model at first startup (about 19 GB).
- GHCR image: **not built or pushed yet**. SaladCloud: **not duplicated or started**.
- **DO NOT point SaladCloud to this Dockerfile or assume it is deployable yet.**

## Planned model
- Hugging Face: `llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF`
- Quantization: `Q4_K_M`; check exact GGUF filename/sharding, license, loader compatibility and VRAM before deployment.
- API model alias to keep client-compatible: `gemma-4-31b-it` (only in the *separate* test endpoint).
- Proposed context: 16384; verify memory use on RTX 4090 24GB first.

## Critical practical limitation
Because model files aren't included, a SaladCloud node without a persistent model cache downloads the entire model on each cold start. This would incur GPU start-up time/cost and can exceed probe thresholds. **For actual trials prefer a tested model-baked image or persistent-download design.** Do not deploy the prototype without deciding this.

## Next steps
1. Confirm exact model GGUF file(s) and runtime compatibility.
2. Prepare a cost-aware, independently named image and build pipeline; keep existing image untouched.
3. Manually run an inexpensive dry build / registry check, then stop.
4. Duplicate Salad container group into a **separately named** deployment, update image and model alias if needed; never edit the QAT group.
5. Compare isolated trial state for dialogue quality, 4-character boundaries, and private-information boundaries. Keep original STATE/diaries/queues intact.

No secrets or private honmaru records are stored in this repository.
