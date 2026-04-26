# CLAUDE.md — NHR_Pro プロジェクト（Salesforce開発）

> Claude Codeが毎セッション自動で読み込む永続的な指示書。
> リポジトリルート `/` に配置する。

---

## 1. プロジェクト概要

| 項目                   | 内容                                                                            |
| ---------------------- | ------------------------------------------------------------------------------- |
| プロジェクト名         | NHR_Pro                                                                         |
| リポジトリ             | https://github.com/rimei1/nhr                                                   |
| APIバージョン          | **66.0**（sfdx-project.json 参照）                                              |
| パッケージディレクトリ | `force-app`                                                                     |
| 外部連携               | MuleSoft Anypoint Platform（Named Credential: `MuleSoft_Anypoint_Platform_US`） |

---

## 2. 命名規則（最重要）

### Apexクラス

```
NHR_<モジュール>_<機能><種別>
```

| 種別               | 命名例                                  |
| ------------------ | --------------------------------------- |
| コントローラ       | `NHR_EN_SalesReportCtrl`                |
| バッチ             | `NHR_ST_OppSnapshotDashboardBatch`      |
| バッチスケジューラ | `NHR_CS_PerceptualMappingBatchSchedule` |
| テスト             | `NHR_EN_SalesReportCtrlTest`            |
| TriggerHandler     | `NHR_XxxTriggerHandler`                 |

- プレフィックス **`NHR_`** は全Apexクラスに必須

### Auraコンポーネント

```
NHR_<モジュール>_<機能>
例: NHR_EN_OrderAmountList, NHR_ST_QuantityRatio
```

### LWCコンポーネント

```
nhr_<module>_<feature>（スネークケース・全小文字）
例: nhr_dx_osaka_path
```

### Trigger

```
Triggerは薄く保ち、NHR_<Object>TriggerHandler へ全ロジックを委譲
```

### Flow

```
<モジュール>_<機能>
例: Account_ENTargetUpdate, CS_PerceptualMapping
```

---

## 3. モジュール構成

| モジュール | 業務内容                                             | Apex数 |
| ---------- | ---------------------------------------------------- | ------ |
| **ST**     | スチール業務（鉄鋼受注・納品・経営ダッシュボード）   | 44     |
| **EN**     | エン業務（建材・建具 営業管理・受注報告・Excel出力） | 42     |
| **JU**     | JU業務（BPO KPI/KGI管理・カテゴリレポート）          | 7      |
| **DX**     | DX業務（組織別受注更新・大阪Path管理）               | 6      |
| **SL**     | SL業務（営業管理）                                   | 5      |
| **CS**     | CS業務（パーセプションマッピング・顧客関係）         | 4      |

**新規クラスは必ず該当モジュールプレフィックスを付ける。**

---

## 4. アーキテクチャパターン

### レイヤー構成

```
Trigger
  └── TriggerHandler
        └── Ctrl（AuraまたはVFコントローラ）
```

### Batchクラスの標準実装

```apex
// global + Database.Stateful を基本とする
global without sharing class NHR_XX_YYYBatch
    implements Database.Batchable<sObject>, Database.Stateful {

    global NHR_XX_YYYBatch() {}
    global Database.QueryLocator start(Database.BatchableContext BC) { ... }
    global void execute(Database.BatchableContext BC, List<sObject> scope) { ... }
    global void finish(Database.BatchableContext BC) {
        // 次のBatchを連鎖起動: Database.executeBatch(new NHR_XX_YYYBatch2(), 200);
    }
}
```

- バッチは複数段階に分けて**連鎖実行**するパターンが多い（Batch → Batch2 → Batch3...）
- バッチ名定数は `独自バッチの中` に `BATCHNAME_XX` 形式で追加する

### Ctrlクラスの標準実装

- VFページ向け: `get;set;` プロパティ + `ApexPages.currentPage().getParameters()` でパラメータ取得
- Aura向け: `@AuraEnabled` メソッド

### TriggerHandlerパターン

```apex
// Trigger（薄く保つ）
trigger NHR_XxxTrigger on Xxx__c (after insert, after update) {
    NHR_XxxTriggerHandler handler = new NHR_XxxTriggerHandler();
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.handleAfterInsert(Trigger.newMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}

// Handler（ロジックを書く）
public with sharing class NHR_XxxTriggerHandler {
    public void handleAfterInsert(Map<Id, Xxx__c> newMap) { ... }
    public void handleAfterUpdate(Map<Id, Xxx__c> newMap, Map<Id, Xxx__c> oldMap) { ... }
}
```

---

## 5. 主要カスタムオブジェクト

| オブジェクト                              | 用途                       |
| ----------------------------------------- | -------------------------- |
| `en_yojitsu__c`                           | EN業務 予実管理            |
| `FormCreation__c`                         | レポート帳票データ         |
| `ST_ManagementDashboard__c`               | スチール経営ダッシュボード |
| `ST_Opportunity_Snapshot__c`              | 商談スナップショット（ST） |
| `ST_yojitsu__c`                           | スチール予実               |
| `KGIPlansResults__c`                      | KGI計画・実績              |
| `BudgetSubmission__c`                     | 予算申請                   |
| `BuildApp_KPI__c`                         | KPI管理                    |
| `BA_Perception__c`                        | パーセプション分析         |
| `DepartmentMaster__c`                     | 部署マスタ                 |
| `DepCategory__c` / `DepCategoryMaster__c` | 部署カテゴリ               |

### Opportunityの主要レコードタイプ

| DeveloperName          | 用途                                  |
| ---------------------- | ------------------------------------- |
| `en_zenekonsh`         | EN ゼネコン商談                       |
| `Jukankyo` / `NT`      | 住環境・NT（ファイル添付Trigger対象） |
| `RecordType_SteelCons` | スチール建設                          |
| `JU_NewTactics`        | JU 新戦術                             |

---

## 6. 開発ツール・コマンド

```bash
# デプロイ（全体）
sf project deploy start -d force-app/main/default

# 特定クラスのみデプロイ
sf project deploy start -m ApexClass:NHR_XX_YYYCtrl

# テスト実行（全体）
sf apex run test --test-level RunLocalTests --wait 10

# 特定クラスのテスト
sf apex run test -n NHR_XX_YYYCtrlTest --wait 10

# org を開く
sf org open

# Batch手動起動（匿名Apex）
Database.executeBatch(new NHR_XX_YYYBatch(), 200);

# Prettierフォーマット
npm run prettier

# ESLint
npm run lint
```

- **コミット前**: husky + lint-staged が自動でPrettier・ESLint・LWC Jestを実行する

---

## 7. コーディングルール

### Apex

- `with sharing` を基本とする（Batchや特別な理由がある場合のみ `without sharing`）
- Bulkify必須: ループ内でのSOQL・DML実行禁止
- `System.debug()` は開発時のみ。本番デプロイ前に削除

### テストクラス

- カバレッジ目標: **75%以上**（本番デプロイ要件）
- テストデータは `NHR_TestDataFactory` を活用
- `@isTest` + `@TestSetup` パターンを使用

### Flow

- 複雑なロジックはApexに移譲し、FlowはUI・トリガー起点に留める
- 現在 **339本** 存在するため、新規作成前に重複確認必須

---

## 8. 禁止事項

- `NHR_` プレフィックスなしの新規Apexクラス作成
- Trigger内への直接ロジック記述（必ずHandlerに委譲）
- APIバージョン `66.0` 未満での新規メタデータ作成

---

## 9. よく使うプロンプトパターン

```
# 新規Batchクラス作成
「NHR_{モジュール}_{機能}Batch を作成してください。
 処理内容: ○○、対象オブジェクト: ○○、バッチサイズ: 200
 独自バッチの中 に BATCHNAME_XX も追加してください」

# 新規Ctrlクラス作成（Aura向け）
「NHR_{モジュール}_{機能}Ctrl（Aura向け）を作成してください。
 取得条件: ○○

# Trigger + Handler セット作成
「{Object}__c の afterInsert/afterUpdate を処理する
 Trigger + TriggerHandler を NHR命名規則で作成してください
 処理内容: ○○」

# 既存クラスへの機能追加
「NHR_{モジュール}_{機能}Ctrl の {メソッド名} に
 {条件} の処理を追加してください。
```
