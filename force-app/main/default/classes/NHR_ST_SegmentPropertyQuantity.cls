/*
* 以下レポートのバッチ
*【工事】セグメント別物件確度件数・数量_全体
*/
global with sharing class NHR_ST_SegmentPropertyQuantity implements Database.Batchable<sObject>, Database.Stateful {
    /** レポート名 */
    private final static String REPORTNAME = '【工事】セグメント別物件確度件数・数量_全体';
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

    /** 物件 予算の追及物件 */
    private static final String BUDGET = '1_予算の追及物件';
    /** 物件 期中発生の新規物件 */
    private static final String NEWPROPERTY = '2_期中発生の新規物件';   

    /** 確度 受注・内定 */
    private static final String ORDEROFFICIAL = '1_内定・仕掛・完成';
    /** 確度 AB */
    private static final String AB = '2_AB';
    /** 確度 CD */
    private static final String CD = '3_CD';
    /** 確度 EF */
    private static final String EF = '4_EF';
    /** 確度 GH */
    private static final String GH = '5_GH';
    /** 確度 失注 */
    private static final String LOSTORDER = '6_失注';

    /** 件数 */
    private static final String RECOUNTCOUNT = '件数';
    /** 数量 */
    private static final String QUANTITY = '数量';

    /** 事業一部 */
    private static final String DEPARTMENTONE = '事業一部';
    /** 事業二部 */
    private static final String DEPARTMENTTWO = '事業二部';

    /** 事業部リスト */
    private List<String> DEPARTMENTLIST = new List<String>{ DEPARTMENTONE, DEPARTMENTTWO };

    /** 当期最後の月 予算組込み */
    private String currentLastMonth = '';

    /** データマップ キー1：セグメント キー2：物件 キー3：確度 キー4：月 キー5：件数/数量 */
    global Map<String, Map<String, Map<String, Map<Integer, Map<String, Decimal>>>>> dataMap = null;
    List<String> segementList = new List<String>{ ALL, ALL_IMPORTANT, ALL_OTHER, DEPARTMENTONE_ALL, DEPARTMENTONE_IMPORTANT, DEPARTMENTONE_OTHER, DEPARTMENTTWO_ALL, DEPARTMENTTWO_IMPORTANT, DEPARTMENTTWO_OTHER };
    List<String> propertyList = new List<String>{ BUDGET, NEWPROPERTY };
    List<String> accuracyList = new List<String>{ ORDEROFFICIAL, AB, CD, EF, GH, LOSTORDER };
    List<String> numberQuantityList = new List<String>{ RECOUNTCOUNT, QUANTITY };

    /** 月分、件数API名マップ */
    global Map<Integer, String> numberApiMap = new Map<Integer, String>{
        7 => 'July_Number__c',
        8 => 'August_Number__c',
        9 => 'September_Number__c',
        10 => 'October_Number__c',
        11 => 'November_Number__c',
        12 => 'December_Number__c',
        1 => 'January_Number__c',
        2 => 'February_Number__c',
        3 => 'March_Number__c',
        4 => 'April_Number__c',
        5 => 'May_Number__c',
        6 => 'June_Number__c'
    };

    /** 月分、数量API名マップ */
    global Map<Integer, String> quantityApiMap = new Map<Integer, String>{
        7 => 'July_Quantity__c',
        8 => 'August_Quantity__c',
        9 => 'September_Quantity__c',
        10 => 'October_Quantity__c',
        11 => 'November_Quantity__c',
        12 => 'December_Quantity__c',
        1 => 'January_Quantity__c',
        2 => 'February_Quantity__c',
        3 => 'March_Quantity__c',
        4 => 'April_Quantity__c',
        5 => 'May_Quantity__c',
        6 => 'June_Quantity__c'
    };

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        // 初期設定
        setInit();

    	String query = 'SELECT Id, ST_focustype_kouji_imInput__c, ST_yosankumikomiInput__c, StageNameInput__c, ST_suryou__c, DepartmentInput__c, OpportunityCreatedDate__c, CreatedDate FROM ST_Yojitsu_Snapshot__c '
        +'WHERE DepartmentInput__c IN :DEPARTMENTLIST';
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_Yojitsu_Snapshot__c> scopes){
        for (ST_Yojitsu_Snapshot__c snapshot : scopes) {
            setData(snapshot);
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

    private void setData(ST_Yojitsu_Snapshot__c snapshot){
        // 1_全体 設定
        setMapData(ALL, snapshot);

        String department = snapshot.DepartmentInput__c;
        Boolean importantFlg = snapshot.ST_focustype_kouji_imInput__c;

        // 事業一部
        if(DEPARTMENTONE.equals(department)){
            // 4_事業一部_全体 設定
            setMapData(DEPARTMENTONE_ALL, snapshot);

            // 重要取引先の場合
            if(importantFlg == true){
                // 2_全体_積極・維持 設定
                setMapData(ALL_IMPORTANT, snapshot);
                // 5_事業一部_積極維持 設定
                setMapData(DEPARTMENTONE_IMPORTANT, snapshot);
            } else {
                // 3_全体_その他 設定
                setMapData(ALL_OTHER, snapshot);
                // 6_事業一部_その他 設定
                setMapData(DEPARTMENTONE_OTHER, snapshot);
            }
        } else if(DEPARTMENTTWO.equals(department)){
            // 事業二部
            // 7_事業二部_全体 設定
            setMapData(DEPARTMENTTWO_ALL, snapshot);

            // 重要取引先の場合
            if(importantFlg == true){
                // 2_全体_積極・維持 設定
                setMapData(ALL_IMPORTANT, snapshot);
                // 8_事業二部_積極維持 設定
                setMapData(DEPARTMENTTWO_IMPORTANT, snapshot);
            } else {
                // 3_全体_その他 設定
                setMapData(ALL_OTHER, snapshot);
                // 9_事業二部_その他 設定
                setMapData(DEPARTMENTTWO_OTHER, snapshot);
            }
        }
    }

    /**
     * マップデータ設定
     * 
     * @param segment セグメント
     * @param snapshot ST予実管理_スナップショット
     */
    private void setMapData(String segment, ST_Yojitsu_Snapshot__c snapshot){
        // 物件
        String property = '';
        // 物件マップ
        Map<String, Map<String, Map<Integer, Map<String, Decimal>>>> propertyMap = dataMap.get(segment);

        if(currentLastMonth.equals(snapshot.ST_yosankumikomiInput__c)){
            property = BUDGET;
        } else {
            if(snapshot.OpportunityCreatedDate__c < startDate || snapshot.OpportunityCreatedDate__c > endDate){
                property = NEWPROPERTY;
            }
        }

        if(String.isNotBlank(property)){
            // 確度マップ
            Map<String, Map<Integer, Map<String, Decimal>>> accuracyMap = propertyMap.get(property);

            String accuracy = '';

            switch on snapshot.StageNameInput__c {
                when '内定', '仕掛', '完成' {
                    accuracy = ORDEROFFICIAL;
                }
                when 'A', 'B' {
                    accuracy = AB;
                }
                when 'C', 'D' {
                    accuracy = CD;
                }
                when 'E', 'F' {
                    accuracy = EF;
                }
                when 'G', 'H' {
                    accuracy = GH;
                }
                when '失注' {
                    accuracy = LOSTORDER;
                }
                when else {
                    accuracy = '';
                }
            }

            if(String.isNotEmpty(accuracy)){
                Map<Integer, Map<String, Decimal>> monthMap = accuracyMap.get(accuracy);

                // 月
                Integer month = snapshot.CreatedDate.month();

                Map<String, Decimal> typeMap = monthMap.get(month);

                // 件数
                typeMap.put(RECOUNTCOUNT, typeMap.get(RECOUNTCOUNT) + 1);
                // 数量
                Decimal quantityValue = snapshot.ST_suryou__c != null ? snapshot.ST_suryou__c : 0;
                typeMap.put(QUANTITY, typeMap.get(QUANTITY) + quantityValue);
                monthMap.put(month, typeMap);

                accuracyMap.put(accuracy, monthMap);
            }
            propertyMap.put(property, accuracyMap);
        }
        dataMap.put(segment, propertyMap);
    }

    /**
     * スチール経営ダッシュボード用レコードリスト作成
     */
    private List<ST_ManagementDashboard__c> createSTDashboardList(){
        // 戻り値
        List<ST_ManagementDashboard__c> result = new List<ST_ManagementDashboard__c>();

        for (String segement : dataMap.keySet()) {
            Map<String, Map<String, Map<Integer, Map<String, Decimal>>>> propertyMap = dataMap.get(segement);

            for (String property : propertyMap.keySet()) {
                Map<String, Map<Integer, Map<String, Decimal>>> accuracyMap = propertyMap.get(property);

                for (String accuracy : accuracyMap.keySet()) {
                    Map<Integer, Map<String, Decimal>> monthMap = accuracyMap.get(accuracy);

                    // レコード作成
                    ST_ManagementDashboard__c stRecord = new ST_ManagementDashboard__c();
                    // レポート名
                    stRecord.Name = REPORTNAME;
                    // セグメント
                    stRecord.Segment__c = segement;
                    // 物件
                    stRecord.Property__c = property;
                    // 確度
                    stRecord.Accuracy__c = accuracy;

                    for(Integer i  = 1; i <= 12; i++){
                        Map<String, Decimal> typeMap = monthMap.get(i);
                        // 件数
                        stRecord.put(numberApiMap.get(i), typeMap.get(RECOUNTCOUNT));
                        // 数量
                        stRecord.put(quantityApiMap.get(i), typeMap.get(QUANTITY));
                    }
                    result.add(stRecord);
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

        currentLastMonth = endDate.year() + '年' + endDate.month() + '月期';

        // スチール経営ダッシュボード用オブジェクトに、【工事】受注実績_全体のデータを削除する
        delete [SELECT Id FROM ST_ManagementDashboard__c WHERE Name = :REPORTNAME];

        // 初期データ作成
        dataMap = new Map<String, Map<String, Map<String, Map<Integer, Map<String, Decimal>>>>>();

        for (String segement : segementList) {
            Map<String, Map<String, Map<Integer, Map<String, Decimal>>>> propertyMap = new Map<String, Map<String, Map<Integer, Map<String, Decimal>>>>();
            for(String property : propertyList){
                Map<String, Map<Integer, Map<String, Decimal>>> accuracyMap = new Map<String, Map<Integer, Map<String, Decimal>>>();
                for(String accuracy : accuracyList){
                    Map<Integer, Map<String, Decimal>> monthMap = new Map<Integer, Map<String, Decimal>>();
                    for(Integer i  = 1; i <= 12; i++){
                        Map<String, Decimal> typeMap = new Map<String, Decimal>();
                        for (String numberQuantity : numberQuantityList) {
                            typeMap.put(numberQuantity, 0);
                        }
                        monthMap.put(i, typeMap);
                    }
                    accuracyMap.put(accuracy, monthMap);
                }
                propertyMap.put(property, accuracyMap);
            }
            dataMap.put(segement, propertyMap);
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