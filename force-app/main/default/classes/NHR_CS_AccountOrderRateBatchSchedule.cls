/**
 * NHR_CS_AccountOrderRateBatchSchedule
 * --------------------------------------------------------------------
 * 毎日夜間に NHR_CS_AccountOrderRateBatch (Batch1) をキックする Schedulable。
 * Batch1 が終了すると自動で NHR_CS_AccountOrderRateClearBatch (Batch2) が連鎖起動。
 *
 * スケジュール方法:
 *   (A) System Scheduler (匿名 Apex):
 *       String cron = '0 0 2 * * ?';  // 毎日 02:00 JST
 *       System.schedule(
 *         'NHR_CS_AccountOrderRateBatch_Nightly',
 *         cron,
 *         new NHR_CS_AccountOrderRateBatchSchedule()
 *       );
 *
 *   (B) Flow (Schedule-Triggered Flow) から Apex Action として呼ぶ場合:
 *       runBatchFromFlow() を @InvocableMethod で提供しているので
 *       そちらをアクションに設定する。
 */
global without sharing class NHR_CS_AccountOrderRateBatchSchedule
    implements Schedulable {

    /** 標準のバッチサイズ。AggregateResult を複数投げるため 200。*/
    @TestVisible
    private static final Integer BATCH_SIZE = 200;

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), BATCH_SIZE);
    }

    /**
     * Schedule-Triggered Flow から呼ぶエントリポイント。
     */
    @InvocableMethod(
        label='CS 取引先 受注率バッチ 実行'
        description='NHR_CS_AccountOrderRateBatch を起動します。'
    )
    public static void runBatchFromFlow() {
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), BATCH_SIZE);
    }
}