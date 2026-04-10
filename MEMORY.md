# MEMORY.md — NHR_Pro Auto Memory Index

> 配置場所: `~/.claude/projects/<project>/memory/MEMORY.md`
> セッション開始時に自動ロード（最大200行）。

---

## プロジェクト基本情報
- プロジェクト: NHR_Pro / APIバージョン: 66.0
- Apex命名: `NHR_<モジュール>_<機能><種別>`
- LWC命名: `nhr_<module>_<feature>`（スネークケース）
- 主要モジュール: ST（スチール）, EN（建材）, JU（KPI）, DX, SL, CS

## アーキテクチャ原則
- SOQL → NHR_Dao に集約
- 定数 → NHR_Constant に集約
- Batchは複数段階で連鎖実行
- Triggerは薄く、Handler に委譲

## 開発中の作業ログ
<!-- Claudeが自動更新するエリア -->

## 学習・修正メモ
<!-- セッションで指摘を受けた内容が蓄積される -->

## トピックファイル一覧
| ファイル名 | 内容 |
|---|---|
| `module-st.md` | STモジュール固有のロジック・注意点 |
| `module-en.md` | ENモジュール固有のロジック・注意点 |
| `batch-patterns.md` | Batch連鎖パターンの詳細 |
| `custom-objects.md` | カスタムオブジェクトのフィールド詳細 |
| `flow-inventory.md` | Flow一覧と重複防止メモ |
