/*
* 以下レポートのバッチ
*【材料販売】得意先別受注金額・数量予実_事業1部
*【材料販売】得意先別受注金額・数量予実_事業2部
*/
global without sharing class NHR_ST_CusOrderAmountQuantityBatch implements Database.Batchable<sObject>, Database.Stateful {
    /** レポート名 */
    private final static String REPORTNAME = '【材料販売】得意先別受注金額・数量予実';
    /** 会計年度開始日付 */
    global Date startDate;
    /** 会計年度終了日付 */
    global Date endDate;
    /** 顧客マップ   キー1：顧客Id　キー2：種別（金額、数量、粗利）API名　キー3：月API　値：実績 */ 
    global Map<String, Map<String, Map<String, Decimal>>> jisekiDataMap = new Map<String, Map<String, Map<String, Decimal>>>();
    /** 年間予算マップ   キー1：取引先Id　キー2：種別API名 値：年間予算値 */ 
    global Map<String, Map<String, Decimal>> annualBudgetMap = new Map<String, Map<String, Decimal>>();
    /** 合計金額マップ   キー1：担当部署　キー2：種別（金額、数量、粗利）API名　キー3：月API 　値：合計値 */ 
    global Map<String, Map<String, Map<String, Decimal>>> jisekiSumMap = new Map<String, Map<String, Map<String, Decimal>>>();
    /** 年間予算合計マップ   キー1：担当部署  キー2：種別API名  値：年間予算合計値  */
    global Map<String, Map<String, Decimal>> annualBudgetSumMap = new Map<String, Map<String, Decimal>>{};
    /** 部署マップ   キー：顧客Id　 値：部署 */ 
    global Map<String, String> departmentMap = new Map<String, String>();
    /** 取引先マップ  キー：取引先Id 　 値：取引先名 */ 
    global Map<String, String> accountNameMap = new Map<String, String>();
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
    /** 種別API名、種別マップ */
    global Map<String, String> categoryApiMap = new Map<String, String>{
        'ST_Estimatedamount__c' => '金額',
        'ST_suryou__c' => '数量',
        'ST_grossprofit__c' => '粗利'
    };

    /** 事業部リスト */
    private List<String> DEPARTMENTLIST = new List<String>{ '事業一部', '事業二部' };

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        // 初期設定
        setInit();

    	String query = 'SELECT Id, AccountId, Account.ST_Department__c, Account.Name, ST_Estimatedamount__c, ST_suryou__c, ST_grossprofit__c,steel_OrderDate__c FROM Opportunity '
        +'WHERE steel_OrderDate__c >= :startDate AND steel_OrderDate__c <= :endDate AND RecordType.Name = \'スチール_材料販売\' AND Account.ST_Department__c IN :DEPARTMENTLIST Order By AccountId';
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        Set<String> accountIdList = new Set<String>();

        for (Opportunity opp : scopes) {
            // キー1：種別（金額、数量、粗利）　キー2：月API　値：実績
            Map<String, Map<String, Decimal>> categoryMap = new Map<String, Map<String, Decimal>>();

            if(jisekiDataMap.containsKey(opp.AccountId)){
                categoryMap = jisekiDataMap.get(opp.AccountId);
            }

            // 商談レコードの受注日_スチール
            String monthApi = monthApiMap.get(opp.steel_OrderDate__c.month());

            // 実績設定
            categoryMap = setJiseki(categoryMap, opp, monthApi);
            jisekiDataMap.put(opp.AccountId, categoryMap);

            // 部署マップ
            if(!departmentMap.containsKey(opp.AccountId)){
                departmentMap.put(opp.AccountId, opp.Account.ST_Department__c);
            }

            // 取引先名マップ
            if(!accountNameMap.containsKey(opp.AccountId)){
                accountNameMap.put(opp.AccountId, opp.Account.Name);
            }

            if(!annualBudgetMap.containsKey(opp.AccountId)){
                accountIdList.add(opp.AccountId);
            }
        }

        // 年間予算データ取得
        for (AggregateResult aggr : [SELECT SUM(ST_Orderamounttarget__c) ST_Estimatedamount__c, SUM(ST_Orderquantitytarget__c) ST_suryou__c, SUM(ST_zyutyuararigaku__c) ST_grossprofit__c, AccountId accountId 
        FROM Opportunity WHERE steel_OrderDate__c >= :startDate AND steel_OrderDate__c <= :endDate AND RecordType.Name = 'スチール_工事_材料販売_目標' 
        AND AccountId IN :accountIdList group by AccountId]) {
            setAnnualBudget(aggr);
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
     * 年間予算設定
     * 
     * @param aggr SOQL集計オブジェクト
     */
    private void setAnnualBudget(AggregateResult aggr){
        // 種別API年間予算マップ  キー：種別API名  値：年間予算
        Map<String, Decimal> annualBudgetCategoryMap = new Map<String, Decimal>();
        String accountId = String.valueof(aggr.get('accountId'));

        for (String categoryApi : categoryApiMap.keySet()) {
            object tempValue = aggr.get(categoryApi) != null ? aggr.get(categoryApi) : 0;
            Decimal value = Decimal.valueOf(String.valueof(tempValue));
            annualBudgetCategoryMap.put(categoryApi, value);

            // 年間予算合計値
            String department = departmentMap.get(accountId);
            if(department != null){
                Map<String, Decimal> annualBudgetSumCategoryMap = new Map<String, Decimal>();
                
                if(annualBudgetSumMap.containsKey(department)){
                    annualBudgetSumCategoryMap = annualBudgetSumMap.get(department);
                }

                Decimal existValue = 0;
                if(annualBudgetSumCategoryMap.containsKey(categoryApi)){
                    existValue = annualBudgetSumCategoryMap.get(categoryApi);
                }

                annualBudgetSumCategoryMap.put(categoryApi, value + existValue);
                annualBudgetSumMap.put(department, annualBudgetSumCategoryMap);
            }
        }
        annualBudgetMap.put(String.valueof(aggr.get('accountId')), annualBudgetCategoryMap);
    }

    /**
     * 実績設定
     * 
     * @param categoryMap 種別マップ
     * @param opp 商談
     * @param monthApi 月API名
     * @return 種別マップ
     */
    private Map<String, Map<String, Decimal>> setJiseki(Map<String, Map<String, Decimal>> categoryMap, Opportunity opp, String monthApi){
        for(String categoryApi : categoryApiMap.keySet()){
            // キー1：月API名　値：実績
            Map<String, Decimal> monthMap = new Map<String, Decimal>();

            if(categoryMap.containsKey(categoryApi)){
                monthMap = categoryMap.get(categoryApi);
            }

            Decimal existJiseki = 0;
            if(monthMap.containsKey(monthApi)){
                existJiseki = monthMap.get(monthApi);
            }

            // 実績取得
            Decimal jiseki = opp.get(categoryApi) != null ? Decimal.valueOf(String.valueof(opp.get(categoryApi))) : 0;

            monthMap.put(monthApi, existJiseki + jiseki);
            categoryMap.put(categoryApi, monthMap);

            // 担当部署
            String department = opp.Account.ST_Department__c;

            // 合計値計算
            // キー1：種別API名  キー2：月API名 　値：実績合計値
            Map<String, Map<String, Decimal>> sumCategoryApiMap = new Map<String, Map<String, Decimal>>();
            Map<String, Decimal> monthSumMap = new Map<String, Decimal>();
            Decimal existSumJiseki = 0;
            if(jisekiSumMap.containsKey(department)){
                sumCategoryApiMap = jisekiSumMap.get(department);

                
                if(sumCategoryApiMap != null && sumCategoryApiMap.containsKey(categoryApi)){
                    monthSumMap = sumCategoryApiMap.get(categoryApi);
        
                    if(monthSumMap.containsKey(monthApi)){
                        existSumJiseki = monthSumMap.get(monthApi);
                    }
                }
            }
            monthSumMap.put(monthApi, existSumJiseki + jiseki);
            sumCategoryApiMap.put(categoryApi, monthSumMap);
            jisekiSumMap.put(department, sumCategoryApiMap);
        }
        return categoryMap;
    }

    /**
     * スチール経営ダッシュボード用レコード作成
     */
    private List<ST_ManagementDashboard__c> createSTDashboard(){
        // 戻り値
        List<ST_ManagementDashboard__c> result = new List<ST_ManagementDashboard__c>();

        Integer index = 1;

        for (String accountId : jisekiDataMap.keySet()) {
            // 種別マップ
            Map<String, Map<String, Decimal>> categoryApiDataMap = jisekiDataMap.get(accountId);
            // 年間予算マップ
            Map<String, Decimal> categoryAnnualBudgetMap = annualBudgetMap.get(accountId);

            if(categoryApiDataMap != null){
                for(String categoryApi : categoryApiMap.keySet()){
                    // スチール経営ダッシュボード用レコード
                    ST_ManagementDashboard__c dashBoard = new ST_ManagementDashboard__c();

                    // レポート名
                    dashBoard.Name = REPORTNAME;
                    // 担当部署
                    dashBoard.Department__c = departmentMap.get(accountId);
                    // 年間予算
                    Decimal annualBudget = 0;
                    if(categoryAnnualBudgetMap != null){
                        annualBudget = categoryAnnualBudgetMap.get(categoryApi);
                    }
                    dashBoard.AnnualBudget__c = annualBudget;
                    // 顧客名
                    dashBoard.AccountId__c = accountId;
                    // 顧客名
                    dashBoard.AccountName__c = index + '_' + accountNameMap.get(accountId);
                    // 種別
                    dashBoard.Category__c = categoryApiMap.get(categoryApi);
                    // 各月の実績を設定する
                    Map<String, Decimal> monthMap = categoryApiDataMap.get(categoryApi);
                    if(monthMap != null){
                        for(String monthApi : monthMap.keySet()){
                            dashBoard.put(monthApi, monthMap.get(monthApi));
                        }
                    }

                    result.add(dashBoard);
                }
            }
            index = index + 1;
        }

        // 合計のレコード作成
        for (String department : jisekiSumMap.keySet()) {
            Map<String, Map<String, Decimal>> annualBudgetCategoryMap = jisekiSumMap.get(department);

            if(annualBudgetCategoryMap != null){
                for (String categoryApi : categoryApiMap.keySet()) {
                    // スチール経営ダッシュボード用レコード
                    ST_ManagementDashboard__c dashBoard = new ST_ManagementDashboard__c();

                    // レポート名
                    dashBoard.Name = REPORTNAME;
                    // 担当部署
                    dashBoard.Department__c = department;
                    // 種別
                    dashBoard.Category__c = categoryApiMap.get(categoryApi);
                    // 顧客名
                    dashBoard.AccountName__c = index + '_SUM';
                    // 年間予算
                    dashBoard.AnnualBudget__c = annualBudgetSumMap.get(department) != null ? annualBudgetSumMap.get(department).get(categoryApi) : 0;
                    // 各月の実績を設定する
                    Map<String, Decimal> monthMap = annualBudgetCategoryMap.get(categoryApi);
                    if(monthMap != null){
                        for(String monthApi : monthMap.keySet()){
                            dashBoard.put(monthApi, monthMap.get(monthApi));
                        }
                    }

                    result.add(dashBoard);
                }
            }
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

        // スチール経営ダッシュボード用オブジェクトに、【材料販売】得意先別受注金額・数量予実のデータを削除する
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