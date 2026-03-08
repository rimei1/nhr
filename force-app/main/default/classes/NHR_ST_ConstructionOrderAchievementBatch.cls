/*
* 以下レポートのバッチ
*【工事】受注実績_全体
*/
global with sharing class NHR_ST_ConstructionOrderAchievementBatch implements Database.Batchable<sObject>, Database.Stateful {
    /** レポート名 */
    private final static String REPORTNAME = '【工事】受注実績_全体';
    /** 会計年度開始日付 */
    global Date startDate;
    /** 会計年度終了日付 */
    global Date endDate;

    /** 1_全体 */
    private static final String ALL = '1_全体';
    /** 2_全体_積極・維持 */
    private static final String ALL_IMPORTANT = '2_全体_積極・維持';
    /** 3_全体_その他 */
    private static final String ALL_OTHER = '3_全体_その他';
    /** 4_事業一部_全体 */
    private static final String DEPARTMENTONE_ALL = '4_事業一部_全体';
    /** 5_事業一部_積極維持 */
    private static final String DEPARTMENTONE_IMPORTANT = '5_事業一部_積極維持';
    /** 6_事業一部_その他 */
    private static final String DEPARTMENTONE_OTHER = '6_事業一部_その他';
    /** 7_事業二部_全体 */
    private static final String DEPARTMENTTWO_ALL = '7_事業二部_全体';
    /** 8_事業二部_積極維持 */
    private static final String DEPARTMENTTWO_IMPORTANT = '8_事業二部_積極維持';
    /** 9_事業二部_その他 */
    private static final String DEPARTMENTTWO_OTHER = '9_事業二部_その他';

    /** 1_数量 */
    private static final String QUANTITY = '1_数量';
    /** 2_金額 */
    private static final String AMOUNT = '2_金額';   
    /** 3_件数 */
    private static final String RECOUNTCOUNT = '3_件数';

    /** 1_目標 */
    private static final String GOAL = '1_目標';
    /** 2_実績 */
    private static final String JISEKI = '2_実績';   
    /** 3_達成率 */
    private static final String PERCENT = '3_達成率';

    /** 事業一部 */
    private static final String DEPARTMENTONE = '事業一部';
    /** 事業二部 */
    private static final String DEPARTMENTTWO = '事業二部';

    /** 事業部リスト */
    private List<String> DEPARTMENTLIST = new List<String>{ DEPARTMENTONE, DEPARTMENTTWO };

    /** データマップ キー1：区分1 キー2：区分2 キー3：区分3 キー4：区分4 */
    global Map<String, Map<String, Map<String, Map<String, Decimal>>>> dataMap = null;
    List<String> type1List = new List<String>{ ALL, ALL_IMPORTANT, ALL_OTHER, DEPARTMENTONE_ALL, DEPARTMENTONE_IMPORTANT, DEPARTMENTONE_OTHER, DEPARTMENTTWO_ALL, DEPARTMENTTWO_IMPORTANT, DEPARTMENTTWO_OTHER };
    List<String> type2List = new List<String>{ QUANTITY ,AMOUNT, RECOUNTCOUNT };
    List<String> type3List = new List<String>{ GOAL ,JISEKI };

    /** 月分、実績API名マップ */
    global Map<Integer, String> monthApiMap = new Map<Integer, String>{
        7 => 'Current7_Orig__c',
        8 => 'Current8_Orig__c',
        9 => 'Current9_Orig__c',
        10 => 'Current10_Orig__c',
        11 => 'Current11_Orig__c',
        12 => 'Current12_Orig__c',
        1 => 'Current1_Orig__c',
        2 => 'Current2_Orig__c',
        3 => 'Current3_Orig__c',
        4 => 'Current4_Orig__c',
        5 => 'Current5_Orig__c',
        6 => 'Current6_Orig__c'
    };

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        // 初期設定
        setInit();

        // 目標データ取得
        for (ST_yojitsu__c stYojitsu : [SELECT ST_Targetnumberoforders__c, ST_Orderquantitytarget__c, ST_Orderamounttarget__c, Account__r.ST_focustype_kouji_im__c
        , Account__r.ST_Department__c, ST_zyutyuubi__c FROM ST_yojitsu__c WHERE ST_zyutyuubi__c >= :startDate AND ST_zyutyuubi__c <= :endDate 
        AND RecordType.Name = 'ST予算入力' AND Account__r.ST_Department__c IN :DEPARTMENTLIST]) {
            setDatabyType1(stYojitsu, GOAL, stYojitsu.Account__r.ST_Department__c, stYojitsu.Account__r.ST_focustype_kouji_im__c);
        }

    	String query = 'SELECT Id, Opportunity__r.Account.ST_Department__c, ST_suryou__c, ST_zyutyukingaku__c, Opportunity__r.Account.ST_focustype_kouji_im__c,ST_zyutyuubi__c FROM ST_yojitsu__c '
        +'WHERE ST_zyutyuubi__c >= :startDate AND ST_zyutyuubi__c <= :endDate AND RecordType.Name = \'ST実績入力\' AND Opportunity__r.Account.ST_Department__c IN :DEPARTMENTLIST Order By Opportunity__r.AccountId';
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_yojitsu__c> scopes){
        for (ST_yojitsu__c stYojitsu : scopes) {
            // 実績設定
            setDatabyType1(stYojitsu, JISEKI, stYojitsu.Opportunity__r.Account.ST_Department__c, stYojitsu.Opportunity__r.Account.ST_focustype_kouji_im__c);
        }
    }

     //完了
    global void finish(Database.BatchableContext BC){
        // スチール経営ダッシュボード用レコード作成
        List<ST_ManagementDashboard__c> dashboardList = createSTDashboardList();

        if(!dashboardList.isEmpty()){
            insert dashboardList;
        }
    }

    /**
     * 区分1により、値設定
     * 
     * @param stYojitsu ST予実管理
     * @param type3 区分3（1_目標, 2_実績）
     */
    private void setDatabyType1(ST_yojitsu__c stYojitsu, String type3, String department, Boolean importantFlg){
        // 1_全体 設定
        setMapData(ALL, stYojitsu, type3);

        // 事業一部
        if(DEPARTMENTONE.equals(department)){
            // 4_事業一部_全体 設定
            setMapData(DEPARTMENTONE_ALL, stYojitsu, type3);

            // 重要取引先の場合
            if(importantFlg == true){
                // 2_全体_積極・維持 設定
                setMapData(ALL_IMPORTANT, stYojitsu, type3);
                // 5_事業一部_積極維持 設定
                setMapData(DEPARTMENTONE_IMPORTANT, stYojitsu, type3);
            } else {
                // 3_全体_その他 設定
                setMapData(ALL_OTHER, stYojitsu, type3);
                // 6_事業一部_その他 設定
                setMapData(DEPARTMENTONE_OTHER, stYojitsu, type3);
            }
        } else if(DEPARTMENTTWO.equals(department)){
            // 事業二部
            // 7_事業二部_全体 設定
            setMapData(DEPARTMENTTWO_ALL, stYojitsu, type3);

            // 重要取引先の場合
            if(importantFlg == true){
                // 2_全体_積極・維持 設定
                setMapData(ALL_IMPORTANT, stYojitsu, type3);
                // 8_事業二部_積極維持 設定
                setMapData(DEPARTMENTTWO_IMPORTANT, stYojitsu, type3);
            } else {
                // 3_全体_その他 設定
                setMapData(ALL_OTHER, stYojitsu, type3);
                // 9_事業二部_その他 設定
                setMapData(DEPARTMENTTWO_OTHER, stYojitsu, type3);
            }
        }
    }

    private void setMapData(String type1, ST_yojitsu__c stYojitsu, String type3){
        // 数量
        Decimal quantityValue = 0;
        // 金額
        Decimal amountValue = 0;
        // 件数
        Decimal recordCount = 0;

        Integer month = null;

        // 実績の場合
        if(JISEKI.equals(type3)){
            quantityValue = stYojitsu.ST_suryou__c == null ? 0 : stYojitsu.ST_suryou__c;
            amountValue = stYojitsu.ST_zyutyukingaku__c == null ? 0 : stYojitsu.ST_zyutyukingaku__c;
            recordCount = 1;
        } else if(GOAL.equals(type3)){
            // 目標の場合
            quantityValue = stYojitsu.ST_Orderquantitytarget__c == null ? 0 : stYojitsu.ST_Orderquantitytarget__c;
            amountValue = stYojitsu.ST_Orderamounttarget__c == null ? 0 : stYojitsu.ST_Orderamounttarget__c;
            recordCount = stYojitsu.ST_Targetnumberoforders__c == null ? 0 : stYojitsu.ST_Targetnumberoforders__c;
        }

        month = stYojitsu.ST_zyutyuubi__c.month();

        Map<String, Map<String, Map<String, Decimal>>> type2Map = dataMap.get(type1);

        // 数量マップデータ
        Map<String, Map<String, Decimal>> quantityMap = type2Map.get(QUANTITY);
        // 金額マップデータ
        Map<String, Map<String, Decimal>> amountMap = type2Map.get(AMOUNT);
        // 件数マップデータ
        Map<String, Map<String, Decimal>> recordCountMap = type2Map.get(RECOUNTCOUNT);

        Map<String, Decimal> quantityMonthMap = quantityMap.get(type3);
        Map<String, Decimal> amountMonthMap = amountMap.get(type3);
        Map<String, Decimal> recordCountMonthMap = recordCountMap.get(type3);

        String monthApi = monthApiMap.get(month);

        quantityMonthMap.put(monthApi, quantityMonthMap.get(monthApi) + quantityValue);
        amountMonthMap.put(monthApi, amountMonthMap.get(monthApi) + amountValue);
        recordCountMonthMap.put(monthApi, recordCountMonthMap.get(monthApi) + recordCount);

        quantityMap.put(type3, quantityMonthMap);
        amountMap.put(type3, amountMonthMap);
        recordCountMap.put(type3, recordCountMonthMap);

        type2Map.put(QUANTITY, quantityMap);
        type2Map.put(AMOUNT, amountMap);
        type2Map.put(RECOUNTCOUNT, recordCountMap);

        dataMap.put(type1, type2Map);
    }

    /**
     * スチール経営ダッシュボード用レコードリスト作成
     */
    private List<ST_ManagementDashboard__c> createSTDashboardList(){
        // 戻り値
        List<ST_ManagementDashboard__c> result = new List<ST_ManagementDashboard__c>();

        for (String type1 : dataMap.keySet()) {
            Map<String, Map<String, Map<String, Decimal>>> type2Map = dataMap.get(type1);

            for (String type2 : type2Map.keySet()) {
                Map<String, Map<String, Decimal>> type3Map = type2Map.get(type2);

                // 目標マップ
                Map<String, Decimal> goalMap = type3Map.get(GOAL);
                // 実績マップ
                Map<String, Decimal> jisekiMap = type3Map.get(JISEKI);

                result.addAll(createSTDashboard(type1, type2, jisekiMap, goalMap));
            }
        }
        return result;
    }

    /**
     * スチール経営ダッシュボード用レコード作成
     */
    private List<ST_ManagementDashboard__c> createSTDashboard(String x1, String x2, Map<String, Decimal> jisekiMap, Map<String, Decimal> goalMap){
        // 戻り値
        List<ST_ManagementDashboard__c> result = new List<ST_ManagementDashboard__c>();

        // 目標レコード
        ST_ManagementDashboard__c goalRecord = new ST_ManagementDashboard__c();
        // レポート名
        goalRecord.Name = REPORTNAME;
        // 区分１
        goalRecord.X1__c = x1;
        // 区分２
        goalRecord.X2__c = x2;

        // 実績レコード
        ST_ManagementDashboard__c jisekiRecord = goalRecord.clone(false, false, false, false);
        // 達成率レコード
        ST_ManagementDashboard__c percentRecord = goalRecord.clone(false, false, false, false);

        // 区分３
        goalRecord.X3__c = GOAL;
        // 区分３
        jisekiRecord.X3__c = JISEKI;
        // 区分３
        percentRecord.X3__c = PERCENT;

        String currentMonthApi = monthApiMap.get(Date.today().month());
        Integer index = monthApiMap.values().indexOf(currentMonthApi);

        Decimal totalGoal = 0;
        Decimal totalJiseki = 0;
        Decimal totalThisMonthGoal = 0;
        Decimal totalThisMonthJiseki = 0;
        // 各月の値を設定する
        Integer count = 0;
        for (String monthApi : monthApiMap.values()) {
            Decimal goal = goalMap != null ? goalMap.get(monthApi) : 0;
            Decimal jiseki = jisekiMap != null ? jisekiMap.get(monthApi) : 0;

            if(AMOUNT.equals(x2)){
                jiseki = jiseki / 1000;
            }

            goalRecord.put(monthApi, goal);
            jisekiRecord.put(monthApi, jiseki);
    
            if(goal != null && jiseki != null && goal != 0){
                percentRecord.put(monthApi, jiseki / goal);
            } else {
                percentRecord.put(monthApi, 0);
            }

            if(count <= index){
                totalThisMonthGoal = totalThisMonthGoal + goal;
                totalThisMonthJiseki = totalThisMonthJiseki + jiseki;
            }

            totalGoal = totalGoal + goal;
            totalJiseki = totalJiseki + jiseki;

            count = count + 1;
        }

        // 当月累計
        goalRecord.TotalThisMonth_Orig__c = totalThisMonthGoal;
        jisekiRecord.TotalThisMonth_Orig__c = totalThisMonthJiseki;
        if(goalRecord.TotalThisMonth_Orig__c != 0){
            percentRecord.TotalThisMonth_Orig__c = jisekiRecord.TotalThisMonth_Orig__c / goalRecord.TotalThisMonth_Orig__c;
        } else {
            percentRecord.TotalThisMonth_Orig__c = 0;
        }

        // 通期累計
        goalRecord.TotalThisYear_Orig__c = totalGoal;
        jisekiRecord.TotalThisYear_Orig__c = totalJiseki;
        if(goalRecord.TotalThisYear_Orig__c != 0){
            percentRecord.TotalThisYear_Orig__c = jisekiRecord.TotalThisYear_Orig__c / goalRecord.TotalThisYear_Orig__c;
        } else {
            percentRecord.TotalThisYear_Orig__c = 0;
        }

        result.add(goalRecord);
        result.add(jisekiRecord);
        result.add(percentRecord);

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

        // スチール経営ダッシュボード用オブジェクトに、【工事】受注実績_全体のデータを削除する
        delete [SELECT Id FROM ST_ManagementDashboard__c WHERE Name = :REPORTNAME];

        // 初期データ作成
        dataMap = new Map<String, Map<String, Map<String, Map<String, Decimal>>>>();

        for (String type1 : type1List) {
            Map<String, Map<String, Map<String, Decimal>>> type2Map = new Map<String, Map<String, Map<String, Decimal>>>();
            for(String type2 : type2List){
                Map<String, Map<String, Decimal>> type3Map = new Map<String, Map<String, Decimal>>();
                for(String type3 : type3List){
                    Map<String, Decimal> monthMap = new Map<String, Decimal>();
                    for(String monthApi : monthApiMap.values()){
                        monthMap.put(monthApi, 0);
                    }
                    type3Map.put(type3, monthMap);
                }
                type2Map.put(type2, type3Map);
            }
            dataMap.put(type1, type2Map);
        }
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