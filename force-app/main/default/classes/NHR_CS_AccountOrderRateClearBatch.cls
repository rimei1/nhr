/**
 * NHR_CS_AccountOrderRateClearBatch  (Batch 2 / 2: 空白クリア)
 * --------------------------------------------------------------------
 * NHR_CS_AccountOrderRateBatch (Batch1) の finish() から連鎖起動される。
 *
 * 目的:
 *   Batch1 で触っていない (= 現時点で property__c にも property_account__c にも
 *   参照されていない) Account のうち、受注率 6 項目のいずれかが non-null なものを
 *   null に戻す (過去に関連があったが現在は関連が無くなったケース)。
 *
 * クエリ設計:
 *   WHERE (6 項目いずれか != null) AND Id NOT IN :processedAccountIds
 *   → OR のみで semi-join 併用なし、Bind Set のみで安全。
 *   processedAccountIds が極端に大きい場合 (>数万) は上限超過の恐れがあるが、
 *   Bind Variable Set の上限は現行 100,000 件なので通常運用で問題なし。
 *
 * アーキテクチャ:
 *   - Batch1 と同一ファミリーの自己完結バッチ (NHR_Dao/NHR_Constant 不使用)
 *   - Database.Stateful でクリア件数をカウント
 *
 * 実行:
 *   通常は Batch1 の finish() から自動起動。
 *   手動起動する場合:
 *     Database.executeBatch(
 *       new NHR_CS_AccountOrderRateClearBatch(new Set<Id>()), 200
 *     );
 *   (空 Set を渡すと 6 項目 non-null 全件を null クリアする)
 */
global without sharing class NHR_CS_AccountOrderRateClearBatch
    implements Database.Batchable<sObject>, Database.Stateful {

    /** Batch1 で処理済みの AccountId 集合 (このバッチでは除外対象) */
    global Set<Id> processedAccountIds;

    global Integer totalScanned = 0;
    global Integer totalCleared = 0;
    global Integer totalErrors  = 0;
    global List<String> errorMessages = new List<String>();

    global NHR_CS_AccountOrderRateClearBatch(Set<Id> processedIds) {
        this.processedAccountIds = (processedIds == null) ? new Set<Id>() : processedIds;
    }

    // =============================================================
    // start
    // =============================================================
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> exclude = this.processedAccountIds;

        // WHERE は OR の連鎖のみ (semi-join なし) なので制約違反しない
        return Database.getQueryLocator([
            SELECT Id,
                   CS_ThisFY_DirectOrderRate__c,
                   CS_PreFY_DirectOrderRate__c,
                   CS_ThisFY_Interior_WinRate__c,
                   CS_PreFY_Interior_WinRate__c,
                   CS_ThisFY_Strategy_Win_Rate__c,
                   CS_PreFY_Strategy_Win_Rate__c
            FROM Account
            WHERE Id NOT IN :exclude
              AND (   CS_ThisFY_DirectOrderRate__c    != null
                   OR CS_PreFY_DirectOrderRate__c     != null
                   OR CS_ThisFY_Interior_WinRate__c   != null
                   OR CS_PreFY_Interior_WinRate__c    != null
                   OR CS_ThisFY_Strategy_Win_Rate__c  != null
                   OR CS_PreFY_Strategy_Win_Rate__c   != null )
        ]);
    }

    // =============================================================
    // execute
    // =============================================================
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        if (scope == null || scope.isEmpty()) return;
        totalScanned += scope.size();

        List<Account> toUpdate = new List<Account>();
        for (Account a : scope) {
            Boolean changed = false;
            if (a.CS_ThisFY_DirectOrderRate__c   != null) { a.CS_ThisFY_DirectOrderRate__c   = null; changed = true; }
            if (a.CS_PreFY_DirectOrderRate__c    != null) { a.CS_PreFY_DirectOrderRate__c    = null; changed = true; }
            if (a.CS_ThisFY_Interior_WinRate__c  != null) { a.CS_ThisFY_Interior_WinRate__c  = null; changed = true; }
            if (a.CS_PreFY_Interior_WinRate__c   != null) { a.CS_PreFY_Interior_WinRate__c   = null; changed = true; }
            if (a.CS_ThisFY_Strategy_Win_Rate__c != null) { a.CS_ThisFY_Strategy_Win_Rate__c = null; changed = true; }
            if (a.CS_PreFY_Strategy_Win_Rate__c  != null) { a.CS_PreFY_Strategy_Win_Rate__c  = null; changed = true; }
            if (changed) toUpdate.add(a);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult r = results[i];
                if (r.isSuccess()) {
                    totalCleared++;
                } else {
                    totalErrors++;
                    if (errorMessages.size() < 50) {
                        errorMessages.add(
                            toUpdate[i].Id + ': ' + r.getErrors()[0].getMessage()
                        );
                    }
                }
            }
        }
    }

    // =============================================================
    // finish
    // =============================================================
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,
            '[NHR_CS_AccountOrderRateClearBatch] '
            + 'scanned=' + totalScanned
            + ' cleared=' + totalCleared
            + ' errors=' + totalErrors
        );
        if (totalErrors > 0) {
            System.debug(LoggingLevel.WARN, 'Errors (first 50): ' + errorMessages);
        }
    }
}