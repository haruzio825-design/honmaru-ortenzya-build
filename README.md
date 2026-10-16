# honmaru-ortenzya-build — experimental only

**現行QATサーバー `honmaru-gemma4-baked` とは完全に別の比較試験用リポジトリです。**
会話・日記・手記・APIキーをここへ置かないでください。

## 現在の状況（未デプロイ）
- [x] 独立した公開リポジトリ
- [x] モデル組込型の試作 `Dockerfile`（**未ビルド・未テスト**）
- [x] 手動・読み取り専用のモデル事前検証 `.github/workflows/preflight.yml`
- [ ] HFの実GGUFファイル名・revision・SHA256を検証
- [ ] イメージビルド用容量・GPUランタイム互換性を検証
- [ ] イメージを新しいGHCRタグへビルド・プッシュ
- [ ] SaladCloudに別コンテナグループとして追加（**既存QATは編集しない**）
- [ ] 4090上で16Kコンテキストのメモリ・品質テスト

## モデル
- `llmfan46/gemma-4-Ortenzya-The-Creative-Wordsmith-31B-it-uncensored-heretic-GGUF`
- Q4_K_M 約18.7GB。Dockerfileに現在書いてあるモデル名は**仮置き**です。ファイル名とチェックサムの一致を確認する前にビルドしないでください。
- CUDA向け llama.cpp `ghcr.io/ggml-org/llama.cpp:server-cuda` を想定。イメージの対応GPUドライバとGemma4対応状況は未確認。

## 次に実施する安全な操作
GitHub Actions → `Ortenzya preflight (no GPU, no download)` → `Run workflow` で、モデル一覧とハッシュ、ランナー空き容量を出力します。**モデル本体はダウンロードしません。** ActionsはGitHub側の実行時間や使用量に計上されうるので、実行前にアカウントの利用条件を確認してください。

## ビルド上の注意
- 標準のGitHub-hosted runnerは容量が小さく、大型モデルとコンテナレイヤーをそのままビルドすると失敗しやすい。
- ファイルを含むイメージが19GB以上になりうるため、GHCRのアップロード時間と容量、ビルド時間、GHCRの公開設定とSaladからのpull可否も確認する。
- **起動時に毎回19GBをダウンロードさせない**ための「ビルド時にモデル埋込」方式を計画中。
- ダウンロードとモデル起動は未実施。GPU費用は発生していない。
- イメージビルド・SaladCloudデプロイはいずれも別途確認後に進める。

## 比較試験条件
既存モデルを基準に、4振りの固有呼称／個体差、別行動と知識共有の境界、私的出来事の秘匿、帰宅場面、反復、文章自然さを評価します。試験用チェックポイントは必ずコピーを使用し、本編記録に混ぜません。
