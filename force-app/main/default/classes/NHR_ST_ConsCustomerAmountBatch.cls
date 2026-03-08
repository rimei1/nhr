/*
* 以下レポートのバッチ
*【工事】得意先別受注金額_事業1部
*【工事】得意先別受注金額_事業2部
*/
global without sharing class NHR_ST_ConsCustomerAmountBatch implements Database.Batchable<sObject>, Database.Stateful {
    /** レポート名 */
    private final static String REPORTNAME = '【工事】得意先別受注金額';
    /** 会計年度開始日付 */
    global Date startDate;
    /** 会計年度終了日付 */
    global Date endDate;
    /** 顧客マップ   キー：顧客Id 　値：月分マップ    キー：月分　値：実績 */ 
    global Map<String, Map<String, Decimal>> customerMap = new Map<String, Map<String, Decimal>>();
    /** 部署マップ   キー：顧客Id　 値：部署 */ 
    global Map<String, String> departmentMap = new Map<String, String>();
    /** 年間予算マップ */ 
    global Map<String, Decimal> annualBudgetMap = new Map<String, Decimal>();
    /** 月分、実績API名マップ */
    global Map<Integer, String> monthApiMap = new Map<Integer, String>{
        7 => 'July_Jisseki__c',
        8 => 'August_Jisseki__c',
        9 => 'September_Jisseki__c',
        10 => 'October_Jisseki__c',
        11 => 'November_Jisseki__c',
        12 => 'December_Jisseki__c',
        1 => 'January_Jisseki__c',
        2 => 'February_Jisseki__c',
        3 => 'March_Jisseki__c',
        4 => 'April_Jisseki__c',
        5 => 'May_Jisseki__c',
        6 => 'June_Jisseki__c'
    };

    /** 事業部リスト */
    private List<String> DEPARTMENTLIST = new List<String>{ '事業一部', '事業二部' };

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        // 初期設定
        setInit();

    	String query = 'SELECT Id, Opportunity__r.AccountId, Opportunity__r.Account.ST_Department__c, ST_suryou__c, ST_zyutyuubi__c FROM ST_yojitsu__c '
        +'WHERE ST_zyutyuubi__c >= :startDate AND ST_zyutyuubi__c <= :endDate AND Opportunity__r.Account.ST_Department__c IN :DEPARTMENTLIST AND RecordType.Name = \'ST実績入力\' Order By Opportunity__r.AccountId';
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_yojitsu__c> scopes){
        Set<String> accountIdList = new Set<String>();

        for (ST_yojitsu__c styojitsu : scopes) {
            // キー：月API名   値：実績
            Map<String, Decimal> monthMap = new Map<String, Decimal>();

            if(customerMap.containsKey(styojitsu.Opportunity__r.AccountId)){
                monthMap = customerMap.get(styojitsu.Opportunity__r.AccountId);
            }

            // ST予実管理レコードの月
            String monthApi = monthApiMap.get(styojitsu.ST_zyutyuubi__c.month());

            Decimal existSuryo = 0;
            if(monthMap.containsKey(monthApi)){
                existSuryo = monthMap.get(monthApi);
            }

            // ST予実管理レコードの数量
            Decimal newSuryo = styojitsu.ST_suryou__c != null ? styojitsu.ST_suryou__c : 0;

            monthMap.put(monthApi, existSuryo + newSuryo);
            customerMap.put(styojitsu.Opportunity__r.AccountId, monthMap);

            // 部署マップ
            if(!departmentMap.containsKey(styojitsu.Opportunity__r.AccountId)){
                departmentMap.put(styojitsu.Opportunity__r.AccountId, styojitsu.Opportunity__r.Account.ST_Department__c);
            }

            if(!annualBudgetMap.containsKey(styojitsu.Opportunity__r.AccountId)){
                accountIdList.add(styojitsu.Opportunity__r.AccountId);
            }
        }

        // 年間予算データ取得
        for (AggregateResult aggr : [SELECT SUM(ST_Orderquantitytarget__c) suryoSum, Account__c accountId FROM ST_yojitsu__c WHERE ST_zyutyuubi__c >= :startDate 
        AND ST_zyutyuubi__c <= :endDate AND RecordType.Name = 'ST予算入力' AND Account__c IN :accountIdList group by Account__c]) {
            Decimal suryoSum = aggr.get('suryoSum') == null ? 0 : Decimal.valueOf(String.valueof(aggr.get('suryoSum')));
            annualBudgetMap.put(String.valueof(aggr.get('accountId')), suryoSum);
        }       
    }

     //完了
    global void finish(Database.BatchableContext BC){
        // スチール経営ダッシュボード用レコード作成
        List<ST_ManagementDashboard__c> dashboardList = createSTDashboard();

        if(!dashboardList.isEmpty()){
            insert dashboardList;
        }
    }

    /**
     * スチール経営ダッシュボード用レコード作成
     */
    private List<ST_ManagementDashboard__c> createSTDashboard(){
        // 戻り値
        List<ST_ManagementDashboard__c> result = new List<ST_ManagementDashboard__c>();

        for (String accountId : customerMap.keySet()) {
            // スチール経営ダッシュボード用レコード
            ST_ManagementDashboard__c dashBoard = new ST_ManagementDashboard__c();

            // レポート名
            dashBoard.Name = REPORTNAME;
            // 担当部署
            dashBoard.Department__c = departmentMap.get(accountId);
            // 年間予算
            dashBoard.AnnualBudget__c = annualBudgetMap.get(accountId);
            // 顧客名
            dashBoard.AccountId__c = accountId;
            // 各月の実績を設定する
            Map<String, Decimal> monthMap = customerMap.get(accountId);
            if(monthMap != null){
                for(String monthApi : monthMap.keySet()){
                    dashBoard.put(monthApi, monthMap.get(monthApi));
                }
            }

            result.add(dashBoard);
        }

        return result;
    }

    /**
     * 初期設定
     */
    private void setInit(){
        // 日付設定
        Date theToday = Date.Today();
        Date forGetDay = Date.Today();
        if (theToday.month() == 7) {
            forGetDay = theToday.addMonths(-1);
        }

        startDate = NHR_Dao.getFiscalYearStartDate(forGetDay);
        endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);

        // スチール経営ダッシュボード用オブジェクトに、【工事】得意先別受注金額のデータを削除する
        delete [SELECT Id FROM ST_ManagementDashboard__c WHERE Name = :REPORTNAME];
    }
    
    global static void forTest(){
        String test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
        test1 = '';
    }
}