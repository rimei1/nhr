/**
 * NHR_EN_OrderPlanExportCtrl
 *
 * 処理フロー:
 *   1. LWCのボタンから呼び出し
 *   2. Opportunity（計画/実績）を取得
 *   3. VFページ(NHR_EN_OrderPlanExcel.page)をExcel形式で生成
 *   4. 実行ユーザーにメールで添付送信
 *
 * ※FormCreation__c は使用しない（件数が少ないため直接出力）
 */
public with sharing class NHR_EN_OrderPlanExportCtrl {

    // -------------------------------------------------------
    // 定数
    // -------------------------------------------------------
    public static final String OSAKA_PROFILE_ID = '00eBV000000LqpMYAS';

    public static final List<String> MONTH_LIST = new List<String>{
        '７月','８月','９月','１０月','１１月','１２月',
        '１月','２月','３月','４月','５月','６月'
    };

    // 月番号 → 月ラベル
    public static final Map<Integer, String> NUM_TO_MONTH = new Map<Integer, String>{
        7=>'７月', 8=>'８月', 9=>'９月', 10=>'１０月', 11=>'１１月', 12=>'１２月',
        1=>'１月', 2=>'２月', 3=>'３月', 4=>'４月', 5=>'５月', 6=>'６月'
    };

    public static final String TYPE_PLAN   = '受注計画';
    public static final String TYPE_ACTUAL = '実績';

    /** 計画レコードタイプ DeveloperName */
    public static final String RT_PLAN   = 'RecordType_EngGoal';
    /** 実績レコードタイプ DeveloperName */
    public static final String RT_ACTUAL = 'en_zenekonsh';

    /** 受注確度の変換マップ */
    public static final Map<String, String> RANK_MAP = new Map<String, String>{
        'Aランク'  => 'A',
        'Bランク'  => 'B',
        'Cランク'  => 'C',
        '受注'     => '受注',
        '受注確定' => '受確'
    };

    // -------------------------------------------------------
    // レコードタイプID取得（キャッシュ）
    // -------------------------------------------------------
    public static Map<String, Id> rtIdCache {
        get {
            if (rtIdCache == null) {
                rtIdCache = new Map<String, Id>();
                for (RecordType rt : [
                    SELECT Id, DeveloperName
                    FROM   RecordType
                    WHERE  SObjectType   = 'Opportunity'
                    AND    DeveloperName IN (:RT_PLAN, :RT_ACTUAL)
                ]) {
                    rtIdCache.put(rt.DeveloperName, rt.Id);
                }
            }
            return rtIdCache;
        }
        set;
    }

    // -------------------------------------------------------
    // Aura エントリーポイント
    // 年度・集計基準日はApex側で自動算出（パラメータ不要）
    // @AuraEnabled → Queueable（直接エンキュー）
    // -------------------------------------------------------
    @AuraEnabled
    public static void exportOrderPlan() {
        try {
            String fiscalYear = calcFiscalYear(Date.today());
            String targetDate = String.valueOf(Date.today());
            System.enqueueJob(new OrderPlanExcelMailJob(fiscalYear, targetDate, UserInfo.getUserId()));
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('処理エラー: ' + e.getMessage());
        }
    }

    // 年度コード自動算出（暫定値）
    // ※ExcelCtrl.buildBlocks() で祝日取得後に正確な年度に補正される
    // 暫定: 7月以降は当年度開始とみなす
    @TestVisible
    private static String calcFiscalYear(Date d) {
        Integer year = d.month() >= 7 ? d.year() : d.year() - 1;
        return String.valueOf(year) + '06';
    }

    // -------------------------------------------------------
    // ユーザー取得
    // -------------------------------------------------------
    public static List<User> getOsakaSalesUsers() {
        String profileId = OSAKA_PROFILE_ID;
        return [
            SELECT Id, Name, Orderby__c
            FROM   User
            WHERE  Department = '大阪営業部'
            AND    ProfileId  = :profileId
            AND    IsActive   = true
            ORDER BY Orderby__c ASC NULLS LAST
        ];
    }

    // -------------------------------------------------------
    // Opportunity 取得（計画）
    // 月判定: en_zyutyuubi__c（受注日）を使用、営業日考慮なし
    // -------------------------------------------------------
    public static List<Opportunity> fetchPlanOpps(
            Set<Id> userIds, Date periodStart, Date periodEnd) {

        Id rtId = rtIdCache.get(RT_PLAN);
        return [
            SELECT Id,
                   OwnerId,
                   Name,
                   en_zyutyuubi__c,
                   en_zyutyukingaku__c,
                   en_zyutyuararigaku__c,
                   AccountNameAbb__c
            FROM   Opportunity
            WHERE  OwnerId         IN :userIds
            AND    en_zyutyuubi__c >= :periodStart
            AND    en_zyutyuubi__c <= :periodEnd
            AND    RecordTypeId    =  :rtId
            ORDER BY OwnerId, en_zyutyuubi__c ASC
        ];
    }

    // -------------------------------------------------------
    // Opportunity 取得（実績①：確定済み）
    //
    // 対象: en_zyutyuukakudo__c = '受注確定'
    // 月判定: en_zyutyuubi__c（受注日）の属するカウント月
    // -------------------------------------------------------
    public static List<Opportunity> fetchActualConfirmedOpps(
            Set<Id> userIds, Date periodStart, Date periodEnd) {

        Id rtId = rtIdCache.get(RT_ACTUAL);
        return [
            SELECT Id,
                   OwnerId,
                   Name,
                   en_zyutyuubi__c,
                   en_zyutyukingaku__c,
                   en_zyutyuararigaku__c,
                   AccountNameAbb__c,
                   en_zyutyuukakudo__c
            FROM   Opportunity
            WHERE  OwnerId             IN :userIds
            AND    RecordTypeId        =  :rtId
            AND    en_zyutyuukakudo__c =  '受注確定'
            AND    en_zyutyuubi__c     >= :periodStart
            AND    en_zyutyuubi__c     <= :periodEnd
            ORDER BY OwnerId, en_zyutyuubi__c ASC
        ];
    }

    // -------------------------------------------------------
    // Opportunity 取得（実績②：見込み）
    //
    // 対象: 受注確度条件なし
    // 月判定: EN_zyutyumikomiduki__c（受注見込み月）の属するカウント月
    // -------------------------------------------------------
    public static List<Opportunity> fetchActualProspectOpps(
            Set<Id> userIds, Date periodStart, Date periodEnd) {

        Id rtId = rtIdCache.get(RT_ACTUAL);
        return [
            SELECT Id,
                   OwnerId,
                   Name,
                   EN_zyutyumikomiduki__c,
                   en_zyutyuumokuhyougaku__c,
                   en_mokuhyouriekigaku__c,
                   AccountNameAbb__c,
                   en_zyutyuukakudo__c
            FROM   Opportunity
            WHERE  OwnerId                IN :userIds
            AND    RecordTypeId           =  :rtId
            AND    EN_zyutyumikomiduki__c >= :periodStart
            AND    EN_zyutyumikomiduki__c <= :periodEnd
            AND    en_zyutyuukakudo__c    != '辞退'
            ORDER BY OwnerId, EN_zyutyumikomiduki__c ASC
        ];
    }

    // -------------------------------------------------------
    // 受注確度変換
    // -------------------------------------------------------
    public static String convertRank(String rawRank) {
        if (String.isBlank(rawRank)) return '';
        String trimmed = rawRank.trim();
        return RANK_MAP.containsKey(trimmed) ? RANK_MAP.get(trimmed) : trimmed;
    }

    // -------------------------------------------------------
    // 非同期：Queueable エンキュー（テスト・外部からの直接呼び出し用）
    // -------------------------------------------------------
    public static void sendExcelMailAsync(
            String fiscalYear, String targetDate, Id recipientUserId) {
        System.enqueueJob(new OrderPlanExcelMailJob(fiscalYear, targetDate, recipientUserId));
    }

    // -------------------------------------------------------
    // Queueable クラス
    // -------------------------------------------------------
    public class OrderPlanExcelMailJob implements Queueable, Database.AllowsCallouts {

        private String fiscalYear;
        private String targetDate;
        private Id     recipientUserId;

        public OrderPlanExcelMailJob(String fiscalYear, String targetDate, Id recipientUserId) {
            this.fiscalYear      = fiscalYear;
            this.targetDate      = targetDate;
            this.recipientUserId = recipientUserId;
        }

        public void execute(QueueableContext ctx) {
            // try-catchを外し、例外をそのままスローする
            // → Queueable失敗時にSalesforceがエラーメールで通知してくれる
            // → デバッグログの「Automated Process」ユーザーのログにスタックトレースが残る
            PageReference pr = Page.NHR_EN_OrderPlanExcel;
            pr.getParameters().put('fy',         fiscalYear);
            pr.getParameters().put('targetDate', targetDate);

            Blob excelBlob = Test.isRunningTest()
                ? Blob.valueOf('TEST_EXCEL_CONTENT')
                : pr.getContent();

            // VFページのレンダリングエラーは空Blobとして返ってくるため明示的にチェック
            if (excelBlob == null || excelBlob.size() == 0) {
                throw new CalloutException(
                    'Excelファイルの生成に失敗しました。VFページのエラーを確認してください。' +
                    '（fy=' + fiscalYear + ', targetDate=' + targetDate + '）'
                );
            }

            User recipient = [SELECT Email, Name FROM User WHERE Id = :recipientUserId LIMIT 1];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ recipient.Email });
            mail.setSubject('【大阪受注計画・実績】Excelファイルを送付します（' + targetDate + '）');
            mail.setPlainTextBody(
                recipient.Name + ' 様\n\n' +
                '大阪受注計画・実績の集計が完了しました。\n' +
                '添付のExcelファイルをご確認ください。\n\n' +
                '年度: ' + fiscalYear + '\n' +
                '集計基準日: ' + targetDate + '\n\n' +
                '※このメールは自動送信です。'
            );

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName('大阪受注計画_' + fiscalYear + '_' + targetDate + '.xls');
            attach.setBody(excelBlob);
            attach.setContentType('application/vnd.ms-excel');
            mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attach });

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
    }
}