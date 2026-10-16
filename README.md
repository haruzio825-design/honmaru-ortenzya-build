# honmaru-ortenzya-build

**EXPERIMENTAL. NO AUTOMATIC BUILD.** QAT版の `honmaru-gemma4-baked` とは別の、Ortenzya比較用コンテナのソースです。本丸の会話・日記・手記・APIキー等をこの公開リポジトリに追加しないでください。

## Status — 2026-10-16
- [x] 独立した公開GitHubリポジトリ
- [x] 2回目の読み取り専用HF preflightは成功。リビジョン・容量・SHA256を確認
- [x] **10層に分けた**Dockerfileと、起動時に結合・整合性検査するシェルスクリプト
- [x] **手動実行のみ**のGHCRビルド/アップロードWorkflowを追加
- [x] 約19GBモデルのダウンロードとDockerイメージ作成（GitHub Actions #2 成功）
- [x] DockerイメージのGHCRアップロード（レジストリのmanifestプッシュ成功）
- [ ] GHCRパッケージの公開範囲・SaladCloudからのpull認証を確認
- [ ] SaladCloudに**新規**コンテナグループとしてデプロイ（**未実行**）
- [ ] RTX 4090上で16,384トークンの適合性・品質を検証（**未実行**）

## Verified GGUF
- Repo: `llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF`
- File: `gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-Q4_K_M.gguf`
- Revision: `d7c96e816759b50ba7d0afe3a9e36deb7b096f16`
- Size: **18,687,062,592 bytes** (18.69 GB = 17.40 GiB)
- SHA256: `aefb0b5a93362b8880e2639c15ea807220351c7abfa8e0f6903ca25f31844981`
- Preflight run: https://github.com/haruzio825-design/honmaru-ortenzya-build/actions/runs/38847164117

## GHCR limit & packaging
GitHub Container Registry accepts **at most 10GB per image layer** and **10 minutes upload per layer**. See https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry .

So the Dockerfile:
1. Streams the pinned HF model to **10 separate chunks of up to 2,000,000,000 bytes**, verifying the original model SHA256.
2. Copies chunks individually to the published image, creating ten smaller layers.
3. During each Salad instance startup, **reassembles the 18.69 GB model** to `/tmp/ortenzya-Q4_K_M.gguf` on local scratch disk, verifies SHA256, and only then starts the GPU server.
4. Avoids repeatedly redownloading the model from HF when the Salad image is already present.

Consequences: startup scratch space must have room for 18.69 GB **in addition to** the model layers. Image pull, concatenation, sha256, and llama.cpp warmup take time; first boot requires probe/timeout validation on Salad. RTX 4090 VRAM 24GB and 16K context may not fit with `-ngl 999`; fall back to lower context or fewer offloaded layers in the **trial** deployment only. These details are **not yet validated on a GPU**.

## Published image (built, NOT yet tested on GPU)
Workflow: https://github.com/haruzio825-design/honmaru-ortenzya-build/actions/workflows/build-image.yml

This workflow is `workflow_dispatch` only, and requires the confirmation text `BUILD_19GB`. It checks for >=55 GB available root disk space, uses the pinned HF revision and hash, and published to:
`ghcr.io/haruzio825-design/honmaru-ortenzya:trial-q4km-20261016`

- Successful workflow run: https://github.com/haruzio825-design/honmaru-ortenzya-build/actions/runs/38849850709
- Registry manifest digest (from Actions push log): `sha256:d40bc77d73468cf421fba58da1f9fb930670b23c2059c9aec32cffb6394bca32`
- Wall time: 10m 21s. No Salad deployment / GPU startup performed.

**Do not trigger the build again:** the trial image exists in GHCR. Check the package's actual visibility before deploying. First-publish GHCR packages default to Private even with a public source repository. Public packages allow unauthenticated pulling, but publication is an irreversible visibility decision; private-pull auth is an alternative. The code-only repository does **not** contain model weights or user data.

The Docker configuration is a technical **prototype**. A green build proves it has been packaged and pushed, **not** that the server loads successfully on RTX 4090.

## SaladCloud protection
- Do **NOT** edit or replace existing `honmaru-gemma4-baked`.
- Do **NOT** use its QAT container group, old model path, or existing STATE/W​EB_DATA/diaries.
- When the trial image is built, deploy separately; give it a separate Access Domain, API key, and copied *test* application state. Do not reuse the source runtime checkpoint directly.
- Existing API model alias `gemma-4-31b-it` is retained inside the **trial** endpoint for compatibility; this does not mean it is the QAT weights.
- In Salad duplicate config, remove existing hardcoded **Command** from the original group. The new image has its own ENTRYPOINT with model reconstruction, and keeping the old command risks incorrect startup.
- Observe startup health, GPU memory, and cloud spend before initiating long text generation.

## Planned evaluation
Compare on four-sword identity and personal knowledge boundaries, off-screen autonomy, previously completed action retention, private intimate events staying private, scene changes and similarity loops. **No real canon log is modified during trial.**
