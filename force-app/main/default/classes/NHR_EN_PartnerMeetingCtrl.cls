/**
 * NHR_EN_PartnerMeetingCtrl
 * パートナー会議資料 Excel出力・メール送信 コントローラ
 *
 * 【処理概要】
 *   Aura ボタンから呼び出し → SOQL で商談取得 → 月列振り分け →
 *   Queueable Job をエンキュー → VFページを Excel として自分宛メール送信
 *
 * 【抽出条件】
 *   - レコードタイプ: en_zenekonsh
 *   - 受注確度: Aランク / Bランク / Cランク
 *   - アルミ発注先: ブランク以外
 *   - 受注見込み月: ブランク以外（Date型）
 *   - 受注目標額: ブランク以外
 *
 * 【並び順】
 *   ① 施工会社名昇順 ② 受注見込み月昇順
 *
 * 【金額】
 *   en_zyutyuumokuhyougaku__c は円単位で格納されている前提。
 *   出力時に 1000 で割り、千円単位に変換して渡す。
 */
public with sharing class NHR_EN_PartnerMeetingCtrl {

    // ============================================================
    // クラス内定数（NHR_Dao / NHR_Constant は使用しない）
    // ============================================================
    private static final String       RT_DEVELOPER_NAME = 'en_zenekonsh';
    private static final List<String> TARGET_RANK_LIST  = new List<String>{ 'Aランク', 'Bランク', 'Cランク' };
    public  static final Integer      MAX_DATA_ROWS      = 21;

    /** 円 → 千円単位変換スケール */
    private static final Decimal THOUSAND = 1000;

    // ============================================================
    // 内部データクラス
    // ============================================================

    /** VFページ・メール送信に渡す1行分のデータ */
    public class PartnerRowData {
        @AuraEnabled public String  rank          { get; set; } // 受注確度（「Aランク」等）
        @AuraEnabled public String  bukenName     { get; set; } // 物件名
        @AuraEnabled public String  sekoCompany   { get; set; } // 施工会社
        @AuraEnabled public String  aluminumOrder { get; set; } // アルミ発注先
        @AuraEnabled public String  firstDelivery { get; set; } // 初回納期
        @AuraEnabled public String  completion    { get; set; } // 竣工
        @AuraEnabled public String  sesyu         { get; set; } // 施主
        @AuraEnabled public String  sekkei        { get; set; } // 設計
        @AuraEnabled public Decimal col1Amount    { get; set; } // 当月予定（千円単位）
        @AuraEnabled public Decimal col2Amount    { get; set; } // 翌月予定（千円単位）
        @AuraEnabled public Decimal col3Amount    { get; set; } // 翌々月予定（千円単位）
        @AuraEnabled public Decimal col4Amount    { get; set; } // 翌々月以降合計（千円単位）
    }

    /** Aura へ返すラッパー */
    public class MeetingDataWrapper {
        @AuraEnabled public List<PartnerRowData> rows         { get; set; }
        @AuraEnabled public String               col1Label    { get; set; }
        @AuraEnabled public String               col2Label    { get; set; }
        @AuraEnabled public String               col3Label    { get; set; }
        @AuraEnabled public String               col4Label    { get; set; }
        @AuraEnabled public String               targetMonth  { get; set; }
        @AuraEnabled public String               reporterName { get; set; }
    }

    // ============================================================
    // Aura向けメソッド: データ取得（プレビュー用）
    // ============================================================
    @AuraEnabled(cacheable=true)
    public static MeetingDataWrapper getMeetingData() {
        return buildWrapper(Date.today());
    }

    // ============================================================
    // Aura向けメソッド: Excel生成・メール送信をエンキュー
    // ============================================================
    @AuraEnabled
    public static void enqueueExcelMail() {
        Id     userId      = UserInfo.getUserId();
        String targetMonth = buildTargetMonthLabel(Date.today());
        System.enqueueJob(new PartnerMeetingExcelMailJob(targetMonth, userId));
    }

    // ============================================================
    // VFページ向け: コントローラから呼び出し
    // ============================================================
    public static MeetingDataWrapper getMeetingDataForVF(String targetMonthParam) {
        Date baseDate;
        try {
            baseDate = Date.valueOf(targetMonthParam);
        } catch (Exception e) {
            baseDate = Date.today();
        }
        return buildWrapper(baseDate);
    }

    // ============================================================
    // コアロジック: ラッパー組み立て
    // ============================================================
    @TestVisible
    private static MeetingDataWrapper buildWrapper(Date baseDate) {
        Date m1Start = baseDate.toStartOfMonth();
        Date m2Start = m1Start.addMonths(1);
        Date m3Start = m1Start.addMonths(2);
        Date m4Start = m1Start.addMonths(3);

        MeetingDataWrapper wrapper = new MeetingDataWrapper();
        wrapper.col1Label    = m1Start.month() + '月予定';
        wrapper.col2Label    = m2Start.month() + '月予定';
        wrapper.col3Label    = m3Start.month() + '月予定';
        wrapper.col4Label    = m4Start.month() + '月〜予定';
        wrapper.targetMonth  = baseDate.year() + '年' + baseDate.month() + '月';
        wrapper.reporterName = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Name;

        List<Opportunity> opps = queryOpportunities();

        List<PartnerRowData> rows = new List<PartnerRowData>();
        for (Opportunity opp : opps) {
            PartnerRowData row = new PartnerRowData();
            row.rank          = opp.en_zyutyuukakudo__c;
            row.bukenName     = opp.Name;
            row.sekoCompany   = opp.en_kensetuc__c;
            row.aluminumOrder = opp.EN_AluminumSupplier__c;
            row.firstDelivery = formatDate(opp.en_ukeoityakkouyoteibi__c);
            row.completion    = formatDate(opp.en_ukeoisyunkouyoteibi__c);
            row.sesyu         = opp.en_sesyu__c;
            row.sekkei        = opp.en_sekkeizimusyo__c;
            row.col1Amount    = null;
            row.col2Amount    = null;
            row.col3Amount    = null;
            row.col4Amount    = null;

            Date mikomiduki = opp.EN_zyutyumikomiduki__c;
            if (mikomiduki != null) {
                Date    mikomStart = mikomiduki.toStartOfMonth();
                // No3: 円単位 → 千円単位に変換（小数点以下切り捨て）
                Decimal kingakuSen = toThousands(opp.en_zyutyuumokuhyougaku__c);

                if (mikomStart == m1Start) {
                    row.col1Amount = kingakuSen;
                } else if (mikomStart == m2Start) {
                    row.col2Amount = kingakuSen;
                } else if (mikomStart == m3Start) {
                    row.col3Amount = kingakuSen;
                } else if (mikomStart >= m4Start) {
                    row.col4Amount = (row.col4Amount == null ? 0 : row.col4Amount) + kingakuSen;
                }
            }
            rows.add(row);
        }
        wrapper.rows = rows;
        return wrapper;
    }

    // ============================================================
    // SOQL（クラス内で完結）
    // ============================================================
    private static List<Opportunity> queryOpportunities() {
        Id rtId    = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get(RT_DEVELOPER_NAME)
            .getRecordTypeId();
        Id loginId = UserInfo.getUserId();

        return [
            SELECT
                Id,
                Name,
                en_zyutyuukakudo__c,
                en_kensetuc__c,
                EN_AluminumSupplier__c,
                en_ukeoityakkouyoteibi__c,
                en_ukeoisyunkouyoteibi__c,
                en_sesyu__c,
                en_sekkeizimusyo__c,
                EN_zyutyumikomiduki__c,
                en_zyutyuumokuhyougaku__c
            FROM Opportunity
            WHERE RecordTypeId = :rtId
              AND OwnerId = :loginId
              AND en_zyutyuukakudo__c IN :TARGET_RANK_LIST
              AND EN_AluminumSupplier__c != null
              AND EN_AluminumSupplier__c != ''
              AND EN_zyutyumikomiduki__c != null
              AND en_zyutyuumokuhyougaku__c != null
            ORDER BY
                en_kensetuc__c ASC NULLS LAST,
                EN_zyutyumikomiduki__c ASC NULLS LAST
            LIMIT :MAX_DATA_ROWS
        ];
    }

    // ============================================================
    // ユーティリティ
    // ============================================================

    /**
     * 円単位の金額を千円単位に変換（小数点以下切り捨て）
     * 例: 24,500,000 → 24,500
     *     40,000,000 → 40,000
     * null の場合は null を返す
     */
    @TestVisible
    private static Decimal toThousands(Decimal amount) {
        if (amount == null) return null;
        return (amount / THOUSAND).setScale(0, System.RoundingMode.DOWN);
    }

    private static String formatDate(Date d) {
        if (d == null) return '';
        return d.year() + '.' + d.month() + '.' + d.day();
    }

    private static String buildTargetMonthLabel(Date d) {
        return String.valueOf(d.year()) + '-'
             + String.valueOf(d.month()).leftPad(2, '0') + '-01';
    }

    // ============================================================
    // Queueable クラス（既存パターン準拠）
    // ============================================================
    public class PartnerMeetingExcelMailJob implements Queueable, Database.AllowsCallouts {

        private String targetMonthParam;
        private Id     recipientUserId;

        public PartnerMeetingExcelMailJob(String targetMonthParam, Id recipientUserId) {
            this.targetMonthParam = targetMonthParam;
            this.recipientUserId  = recipientUserId;
        }

        public void execute(QueueableContext ctx) {
            PageReference pr = Page.NHR_EN_PartnerMeetingExcel;
            pr.getParameters().put('targetMonth', targetMonthParam);

            Blob excelBlob = Test.isRunningTest()
                ? Blob.valueOf('TEST_EXCEL_CONTENT')
                : pr.getContent();

            if (excelBlob == null || excelBlob.size() == 0) {
                throw new CalloutException(
                    'Excelファイルの生成に失敗しました。VFページのエラーを確認してください。'
                    + '（targetMonth=' + targetMonthParam + '）'
                );
            }

            User recipient = [
                SELECT Email, Name FROM User WHERE Id = :recipientUserId LIMIT 1
            ];

            Date   baseDate   = Date.valueOf(targetMonthParam);
            String monthLabel = baseDate.year() + '年' + baseDate.month() + '月';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ recipient.Email });
            mail.setSubject('【パートナー会議資料】Excelファイルを送付します（' + monthLabel + '）');
            mail.setPlainTextBody(
                recipient.Name + ' 様\n\n'
                + 'パートナー会議資料の集計が完了しました。\n'
                + '添付のExcelファイルをご確認ください。\n\n'
                + '対象月: ' + monthLabel + '\n\n'
                + '※このメールは自動送信です。'
            );

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName('パートナー会議資料_' + monthLabel + '.xls');
            attach.setBody(excelBlob);
            attach.setContentType('application/vnd.ms-excel');
            mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attach });

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
    }
}