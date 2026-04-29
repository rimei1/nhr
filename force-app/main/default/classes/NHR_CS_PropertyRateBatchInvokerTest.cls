/**
 * NHR_CS_PropertyRateBatchInvokerTest
 *
 * Flow 起動ラッパーのテスト。
 * バッチ本体のロジックは NHR_CS_PropertyRateBatchTest 側で網羅されているため、
 * ここでは Invoker の引数処理（null安全、デフォルト値、複数入力）のみを検証する。
 */
@IsTest
private class NHR_CS_PropertyRateBatchInvokerTest {

    // ============================================================
    // ケース1: 入力あり（全件モード）
    // ============================================================
    @IsTest
    static void test_runBatch_withInput_fullMode() {
        Account acc = new Account(Name = 'Acc-元請-Inv1');
        insert acc;

        property__c p = new property__c(
            Name = 'P-Inv1',
            zyutyusaki__c = acc.Id
        );
        insert p;

        NHR_CS_PropertyRateBatchInvoker.FlowInput fi
            = new NHR_CS_PropertyRateBatchInvoker.FlowInput();
        fi.fullRecalc = true;
        fi.batchSize  = 200;

        Test.startTest();
        List<NHR_CS_PropertyRateBatchInvoker.FlowOutput> outs
            = NHR_CS_PropertyRateBatchInvoker.runBatch(
                new List<NHR_CS_PropertyRateBatchInvoker.FlowInput>{ fi }
            );
        Test.stopTest();

        System.assertEquals(1, outs.size(), '1件入力に対して1件出力');
        System.assertNotEquals(null, outs[0].jobId, 'jobId 返却');

        property__c after = [
            SELECT CS_PropertyCoverageRate__c FROM property__c WHERE Id = :p.Id
        ];
        System.assertEquals(20.00, after.CS_PropertyCoverageRate__c,
            '全件モードでバッチが実行された');
    }

    // ============================================================
    // ケース2: 入力 null（デフォルトで差分モード起動）
    // ============================================================
    @IsTest
    static void test_runBatch_nullInput_defaultDiffMode() {
        Test.startTest();
        List<NHR_CS_PropertyRateBatchInvoker.FlowOutput> outs
            = NHR_CS_PropertyRateBatchInvoker.runBatch(null);
        Test.stopTest();

        System.assertEquals(1, outs.size(), '入力nullでもデフォルトで1件起動');
        System.assertNotEquals(null, outs[0].jobId, 'jobId 返却');
    }

    // ============================================================
    // ケース3: 入力空リスト
    // ============================================================
    @IsTest
    static void test_runBatch_emptyList_defaultDiffMode() {
        Test.startTest();
        List<NHR_CS_PropertyRateBatchInvoker.FlowOutput> outs
            = NHR_CS_PropertyRateBatchInvoker.runBatch(
                new List<NHR_CS_PropertyRateBatchInvoker.FlowInput>()
            );
        Test.stopTest();

        System.assertEquals(1, outs.size(), '空リストでもデフォルトで1件起動');
        System.assertNotEquals(null, outs[0].jobId, 'jobId 返却');
    }

    // ============================================================
    // ケース4: FlowInput のフィールド null（デフォルト値で起動）
    // ============================================================
    @IsTest
    static void test_runBatch_nullFields_useDefaults() {
        NHR_CS_PropertyRateBatchInvoker.FlowInput fi
            = new NHR_CS_PropertyRateBatchInvoker.FlowInput();
        // fullRecalc / batchSize ともに null

        Test.startTest();
        List<NHR_CS_PropertyRateBatchInvoker.FlowOutput> outs
            = NHR_CS_PropertyRateBatchInvoker.runBatch(
                new List<NHR_CS_PropertyRateBatchInvoker.FlowInput>{ fi }
            );
        Test.stopTest();

        System.assertNotEquals(null, outs[0].jobId,
            'フィールドnullでもデフォルトで起動');
    }

    // ============================================================
    // ケース5: batchSize に 0 や負数 → デフォルト200にフォールバック
    // ============================================================
    @IsTest
    static void test_runBatch_invalidBatchSize_fallbackToDefault() {
        NHR_CS_PropertyRateBatchInvoker.FlowInput fi
            = new NHR_CS_PropertyRateBatchInvoker.FlowInput();
        fi.fullRecalc = false;
        fi.batchSize  = 0;  // 無効値

        Test.startTest();
        List<NHR_CS_PropertyRateBatchInvoker.FlowOutput> outs
            = NHR_CS_PropertyRateBatchInvoker.runBatch(
                new List<NHR_CS_PropertyRateBatchInvoker.FlowInput>{ fi }
            );
        Test.stopTest();

        System.assertNotEquals(null, outs[0].jobId,
            'batchSize=0 でもデフォルト200で起動される');
    }
}