/**
 * NHR_CS_PropertyRateBatchInvoker
 *
 * NHR_CS_PropertyRateBatch をスケジュールトリガーフロー / 自動起動フロー から
 * 起動するための Invocable ラッパークラス。
 *
 * 1クラスに @InvocableMethod は1つしか定義できないため、
 * バッチ本体とは別ファイルとして分離している。
 *
 * 【フローでの呼び出し方】
 *   1. スケジュールトリガーフロー or 自動起動フローを作成
 *   2. 「アクション」要素を追加 → カテゴリ「CS物件」
 *   3. アクション「物件把握率・受注率バッチ起動」を選択
 *   4. 入力パラメータ:
 *      - 全件モード (fullRecalc): true=全件 / false(または未指定)=差分（過去24h）
 *      - バッチサイズ (batchSize): 省略時 200
 *
 * 【推奨スケジュール】
 *   - 月〜土 夜間: fullRecalc = false（差分モード）
 *   - 日曜   夜間: fullRecalc = true （全件モード、削除起因のズレをリカバリ）
 */
public with sharing class NHR_CS_PropertyRateBatchInvoker {

    /** バッチサイズのデフォルト値 */
    private static final Integer DEFAULT_BATCH_SIZE = 200;

    // ============================================================
    // フロー入出力
    // ============================================================

    public class FlowInput {
        @InvocableVariable(
            label='全件モード'
            description='true=全件再計算、false(未指定)=差分モード（過去24h内に更新された物件のみ）'
            required=false)
        public Boolean fullRecalc;

        @InvocableVariable(
            label='バッチサイズ'
            description='1回の execute で処理するレコード数。省略時は200。'
            required=false)
        public Integer batchSize;
    }

    public class FlowOutput {
        @InvocableVariable(
            label='ジョブID'
            description='起動した AsyncApexJob の Id')
        public String jobId;
    }

    // ============================================================
    // Invocable Method
    // ============================================================

    /**
     * Flow / Process Builder から起動するエントリポイント。
     * Bulk 呼び出し対応のため List で受ける（通常は1件のみ渡される）。
     */
    @InvocableMethod(
        label='物件把握率・受注率バッチ起動'
        description='NHR_CS_PropertyRateBatch をスケジュール起動する。fullRecalc=true で全件、false（または省略）で差分モード。'
        category='CS物件')
    public static List<FlowOutput> runBatch(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        // 入力なしでもデフォルト（差分モード・size=200）で1回起動
        if (inputs == null || inputs.isEmpty()) {
            results.add(executeOne(false, DEFAULT_BATCH_SIZE));
            return results;
        }

        for (FlowInput fi : inputs) {
            Boolean fullRecalc = (fi != null && fi.fullRecalc != null) ? fi.fullRecalc : false;
            Integer batchSize  = (fi != null && fi.batchSize  != null && fi.batchSize > 0)
                                    ? fi.batchSize : DEFAULT_BATCH_SIZE;
            results.add(executeOne(fullRecalc, batchSize));
        }
        return results;
    }

    /** 1件分のバッチ起動 */
    private static FlowOutput executeOne(Boolean fullRecalc, Integer batchSize) {
        FlowOutput o = new FlowOutput();
        o.jobId = String.valueOf(
            Database.executeBatch(new NHR_CS_PropertyRateBatch(fullRecalc), batchSize)
        );
        return o;
    }
}