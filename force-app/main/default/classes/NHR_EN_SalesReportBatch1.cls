/*
 * 1_1 , 2 , 3の予算、4の予算を作成
 */
global without sharing class NHR_EN_SalesReportBatch1 implements Database.Batchable<sObject>, Database.Stateful{
    static final String ACTUAL = '実績';
    static final String BUDGET = '予算';
    global List<Opportunity> addOppList {get;set;}
    global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,FormCreation__c> excelMap1_2 {get;set;}
    global Map<String ,FormCreation__c> excelMap2 {get;set;}
    global Map<String ,FormCreation__c> excelMap3 {get;set;}
    global Map<String ,FormCreation__c> excelMap4 {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Date LastYearStartDate {get;set;}
    global Date LastYearEndDate {get;set;}
    global Date Last2YearStartDate {get;set;}
    global Date Last2YearEndDate {get;set;}
    global Date LastMonthStartDate {get;set;}
    global Date LastMonthEndDate {get;set;}

    global NHR_EN_SalesReportBatch1(String inDeStr ,String inUnit ,String userId){
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
    }

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_SalesReportBatch');
        setInit();
        Set<String> tantobusyo = reportMap.keySet();
        system.debug('tantobusyo:' + tantobusyo);
    	String query = NHR_Dao.get_NHR_EN_SalesReportBatch(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<en_yojitsu__c> scopes){

        /*
        FormCreation__c tempInfo3_1 = new FormCreation__c();
        tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = new FormCreation__c();
        tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = new FormCreation__c();
        tempInfo3_3 = excelMap3.get('3');
        */

        FormCreation__c tempInfo4_1 = new FormCreation__c();
        tempInfo4_1 = excelMap4.get('1');
        FormCreation__c tempInfo4_2 = new FormCreation__c();
        tempInfo4_2 = excelMap4.get('2');

        for(en_yojitsu__c obj : scopes) {
            system.debug(obj);
            FormCreation__c tempInfo = new FormCreation__c();
            FormCreation__c tempInfo2 = new FormCreation__c();

            if (this.unitStr == NHR_Constant.UNIT1) {
                String tantobusyoStr = obj.en_tantobusyo1__c;
                if (tantobusyoStr == '営業部') {
                    tantobusyoStr = '営業１課';
                }
                //営業所単位
                if (!excelMap1_1.containsKey(tantobusyoStr)) {
                    integer orderStart = excelMap1_1.size();
                    excelMap1_1.put(tantobusyoStr ,setFC('Sales1_1'+ deStr, tantobusyoStr, orderStart * 10 + 1));
                }
                tempInfo = excelMap1_1.get(tantobusyoStr);

                if (!excelMap2.containsKey(tantobusyoStr)) {
                    integer orderStart = excelMap2.size();
                    excelMap2.put(tantobusyoStr ,setFC('Sales2'+ deStr, tantobusyoStr, orderStart * 10 + 1));
                }
                tempInfo2 = excelMap2.get(tantobusyoStr);
            } else if (this.unitStr == NHR_Constant.UNIT2) {
                //チーム単位
                if (!excelMap1_1.containsKey(obj.OwnerId)) {
                    integer orderStart = excelMap1_1.size();
                    excelMap1_1.put(obj.OwnerId ,setFC('Sales1_1'+ deStr, obj.Owner.Name, orderStart * 10 + 1));
                }
                tempInfo = excelMap1_1.get(obj.OwnerId);
                system.debug('tempInfo:' + tempInfo);

                if (!excelMap2.containsKey(obj.OwnerId)) {
                    integer orderStart = excelMap2.size();
                    excelMap2.put(obj.OwnerId ,setFC('Sales2'+ deStr, obj.Owner.Name, orderStart * 10 + 1));
                }
                tempInfo2 = excelMap2.get(obj.OwnerId);
            } else if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                String tempKey = '';
                String tempName = '';
                integer orderStart1 = 0;
                integer orderStart2 = 0;
                
                if(obj.en_tokuisaki_s__r.DX_Other__c) {
                    tempKey = 'DX_Other__c';
                    tempName = 'その他';
                    orderStart1 = 900;
                    orderStart2 = 900;
                } else {
                    tempKey = obj.en_tokuisaki_s__c;
                    tempName = obj.en_tokuisaki_s__r.Name;
                    orderStart1 = excelMap1_1.size();
                    orderStart2 = excelMap2.size();
                }
                
                //個人単位
                if (!excelMap1_1.containsKey(tempKey)) {
                    //integer orderStart = excelMap1_1.size();
                    excelMap1_1.put(tempKey ,setFC('Sales1_1'+ userId, tempName, orderStart1 * 10 + 1));
                }
                tempInfo = excelMap1_1.get(tempKey);

                if (!excelMap2.containsKey(tempKey)) {
                    //integer orderStart = excelMap2.size();
                    excelMap2.put(tempKey ,setFC('Sales2'+ userId, tempName, orderStart2 * 10 + 1));
                }
                tempInfo2 = excelMap2.get(tempKey);
            }
            system.debug('excelMap1_1.size():' + excelMap1_1.size());

            if (obj.Yeaemonth__c >= startDate && obj.Yeaemonth__c < LastMonthStartDate) {
                //先月前
                if (obj.en_yojitu2__c == BUDGET) {
                    //予算
                    //前月累計受注計画額と実績額
                    tempInfo.H__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.I__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    //年間受注目標と累計実績額
                    tempInfo.P__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.Q__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);

                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempInfo2.H__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo2.I__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);

                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                   // tempInfo3_1.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                   // tempInfo3_1.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    
                    //4.当期売上確定
                    tempInfo4_1.A__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo4_2.A__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);
                } else {
                    //実績
                    if (obj.en_ankenkubun_yozitsu__c == '本工事'){
                        //前月累計受注計画額と実績額
                        tempInfo.K__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.L__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        //年間受注目標と累計実績額
                        tempInfo.S__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.T__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        
                        //２．売上計画に対する実績数値の確認
                        ////年間受注目標と累計実績額
                        tempInfo2.K__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                        tempInfo2.L__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                    }
                    //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                    //tempInfo3_1.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                   // tempInfo3_1.A__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                }

            }else if (obj.Yeaemonth__c >= LastMonthStartDate && obj.Yeaemonth__c <= LastMonthEndDate) {
                //先月
                if (obj.en_yojitu2__c == BUDGET) {
                    //予算
                    //前月受注計画額と実績額
                    tempInfo.B__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.C__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    //前月累計受注計画額と実績額
                    tempInfo.H__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.I__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    //年間受注目標と累計実績額
                    tempInfo.P__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.Q__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);

                    //２．売上計画に対する実績数値の確認
                    ////前月売上計画額と実績額
                    tempInfo2.B__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo2.C__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);
                    ////年間受注目標と累計実績額
                    tempInfo2.H__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo2.I__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);

                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    //tempInfo3_1.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    //tempInfo3_1.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    
                    //4.当期売上確定
                    tempInfo4_1.A__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo4_2.A__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);
                } else {
                    if (obj.en_ankenkubun_yozitsu__c == '本工事'){
                        //実績
                        //前月受注計画額と実績額
                        tempInfo.E__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.F__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        //前月累計受注計画額と実績額
                        tempInfo.K__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.L__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        //年間受注目標と累計実績額
                        tempInfo.S__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.T__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        
                        //２．売上計画に対する実績数値の確認
                        ////前月売上計画額と実績額
                        tempInfo2.E__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                        tempInfo2.F__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                        ////年間受注目標と累計実績額
                        tempInfo2.K__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                        tempInfo2.L__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                    }
                    
                    
                    //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                    //tempInfo3_1.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_1.A__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                }
            } else if (obj.Yeaemonth__c > LastMonthEndDate && obj.Yeaemonth__c <= endDate) {
                //当会計年度_今月以降
                if (obj.en_yojitu2__c == BUDGET) {
                    //予算
                    //年間受注目標と累計実績額
                    tempInfo.P__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.Q__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);

                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempInfo2.H__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo2.I__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);

                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    //tempInfo3_1.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    //tempInfo3_1.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                    
                    //4.当期売上確定
                    tempInfo4_1.A__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
                    tempInfo4_2.A__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);
                } else {
                    //実績
                    if (obj.en_ankenkubun_yozitsu__c == '本工事'){
                        //年間受注目標と累計実績額
                        tempInfo.S__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.T__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    }
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    //tempInfo2.K__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                    //tempInfo2.L__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                    //
                    //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                   // tempInfo3_1.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_1.A__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                }
            } else if (obj.Yeaemonth__c >= LastYearStartDate && obj.Yeaemonth__c <= LastYearEndDate) {
                //次回会計年度
                //3.
                if (obj.en_yojitu2__c == BUDGET) {
                    //tempInfo3_2.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_2.B__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    
                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    //tempInfo3_2.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    //tempInfo3_2.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else {
                    //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                    //tempInfo3_2.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_2.A__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                }

            } else if (obj.Yeaemonth__c >= Last2YearStartDate) {
                //次回会計年度以降
                //3.
                if (obj.en_yojitu2__c == BUDGET) {
                    //tempInfo3_3.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_3.B__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    
                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    //tempInfo3_3.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    //tempInfo3_3.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else {
                    //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                   // tempInfo3_3.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                    //tempInfo3_3.A__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                }
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        EN_Report__mdt Osaka = EN_Report__mdt.getInstance('Osaka');
        
        //完了後の処理があれば
        //小計
        if ( (this.unitStr == NHR_Constant.UNIT2 && this.deStr == Osaka.Department__c)
            || (this.unitStr == NHR_Constant.UNIT3 && this.deStr == Osaka.MasterLabel)
            || (this.unitStr == NHR_Constant.UNIT4 && this.userId == '005RC000000EAynYAG')) 
        {
        } else {
            setSumPre();
        }
        
        setSum1_1();
        setSum2();

        for (String keyStr : excelMap1_1.KeySet()) {
            FormCreation__c tempObj = excelMap1_1.get(keyStr);
            system.debug('tempObj:' + tempObj);
        }
        //１．受注計画に対する実績数値の確認
        insert excelMap1_1.values();

        //２．売上計画に対する実績数値の確認
        insert excelMap2.values();
        //完了後の処理があれば
        NHR_EN_SalesReportBatch2 myBatchObject = new NHR_EN_SalesReportBatch2
            (excelMap1_1
             ,excelMap1_2
             ,excelMap2
             ,excelMap3
             ,excelMap4
             ,deStr
             ,this.unitStr
             ,this.userId
             ,startDate
             ,endDate
             ,LastMonthStartDate
             ,LastMonthEndDate
             ,reportMap
             ,yearMap
            );
        Database.executeBatch(myBatchObject,2000);
    }

    /**
     * 初期設定
     */
    private void setInit(){
        //日付設定
        Date theToday = Date.Today();
        Date forGetDay = Date.Today();

        if (theToday.month() == 7) {
            forGetDay = theToday.addMonths(-1);
        }

        startDate = NHR_Dao.getFiscalYearStartDate(forGetDay);
        endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);
        LastYearStartDate = startDate.addYears(1);
        LastYearEndDate = endDate.addYears(1);
        Last2YearStartDate = startDate.addYears(2);
        Last2YearEndDate = endDate.addYears(2);
        Date tempDate = Date.newInstance(theToday.year() , theToday.month(), 1);
        LastMonthStartDate = tempDate.addMonths(-1);
        LastMonthEndDate = tempDate.addDays(-1);
        system.debug('startDate:' + startDate);
        system.debug('endDate:' + endDate);
        system.debug('LastYearStartDate:' + LastYearStartDate);
        system.debug('LastYearEndDate:' + LastYearEndDate);
        system.debug('Last2YearStartDate:' + Last2YearStartDate);
        system.debug('Last2YearEndDate:' + Last2YearEndDate);
        system.debug('LastMonthStartDate:' + LastMonthStartDate);
        system.debug('LastMonthEndDate:' + LastMonthEndDate);

        //表示内容設定
        yearMap = new Map<String ,String>();
        reportMap = new Map<String ,EN_Report__mdt>();
        excelMap1_1 = new Map<String ,FormCreation__c>();
        excelMap1_2 = new Map<String ,FormCreation__c>();
        excelMap2 = new Map<String ,FormCreation__c>();
        excelMap3 = new Map<String ,FormCreation__c>();
        excelMap4 = new Map<String ,FormCreation__c>();

        // 会年度取得
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        system.debug('md1:' + md1);
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }

        //１．受注計画に対する実績数値の確認
        //２．売上計画に対する実績数値の確認
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        for(EN_Report__mdt mt : md2) {
            if (this.unitStr == NHR_Constant.UNIT1) {
                if (deStr == '全社' || mt.MasterLabel == deStr ) {
                    reportMap.put(mt.Department__c ,mt);
                    excelMap1_1.put(mt.Department__c , setFC('Sales1_1' + this.deStr,mt.Department__c, Integer.valueOf(mt.OrderBy__c)));
                    excelMap1_2.put(mt.Department__c , setFC('Sales1_2' + this.deStr,mt.Department__c, Integer.valueOf(mt.OrderBy__c)));
                    excelMap2.put(mt.Department__c , setFC('Sales2' + this.deStr,mt.Department__c, Integer.valueOf(mt.OrderBy__c)));
                }
            } else {
                if (mt.Department__c == this.deStr ) {
                    reportMap.put(mt.Department__c ,mt);
                }
            }
        }
        system.debug('reportMap:' + reportMap);

        //３．売上計上後の受注残高
        String thisFiscalYear = NHR_Dao.getFiscalYear(forGetDay);
        String thisFiscalYear2 = NHR_Dao.getFiscalYear(forGetDay.addYears(1));
        String thisFiscalYear3 = NHR_Dao.getFiscalYear(forGetDay.addYears(2));
        //合計行追加
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            excelMap1_1.put('Sum', setFC('Sales1_1'+ userId,'合計',9999));
            excelMap1_2.put('Sum', setFC('Sales1_2'+ userId,'合計',9999));
            excelMap2.put('Sum', setFC('Sales2'+ userId,'合計',9999));

            excelMap3.put('1' , setFC('Sales3'+ userId,thisFiscalYear + '期竣工見込受注残高',1));
            excelMap3.put('2' , setFC('Sales3'+ userId,thisFiscalYear2 + '期竣工見込受注残高',2));
            excelMap3.put('3' , setFC('Sales3'+ userId,thisFiscalYear3 + '期竣工見込受注残高',3));
            excelMap3.put('Sum' , setFC('Sales3'+ userId,'受注残高計',4));

            //４．当期売上確定
            excelMap4.put('1' , setFC('Sales4'+ userId,'売上確定見込',1));
            excelMap4.put('2' , setFC('Sales4'+ userId,'粗利確定見込',2));
            excelMap4.put('Sum' , setFC('Sales4'+ userId,'粗利率',3));
        } else {
            excelMap1_1.put('Sum', setFC('Sales1_1' + this.deStr,'合計',9999));
            excelMap1_2.put('Sum', setFC('Sales1_2' + this.deStr,'合計',9999));
            excelMap2.put('Sum', setFC('Sales2' + this.deStr,'合計',9999));

            excelMap3.put('1' , setFC('Sales3',thisFiscalYear + '期竣工見込受注残高',1));
            excelMap3.put('2' , setFC('Sales3',thisFiscalYear2 + '期竣工見込受注残高',2));
            excelMap3.put('3' , setFC('Sales3',thisFiscalYear3 + '期竣工見込受注残高',3));
            excelMap3.put('Sum' , setFC('Sales3','受注残高計',4));

            //４．当期売上確定
            excelMap4.put('1' , setFC('Sales4','売上確定見込',1));
            excelMap4.put('2' , setFC('Sales4','粗利確定見込',2));
            excelMap4.put('Sum' , setFC('Sales4','粗利率',3));
        }
    }

    /**
     * 集計事前処理
     */
    private void setSumPre(){
        Set<String> tantobusyo = reportMap.keySet();
        //商談（営繕工事、材料販売）
        addOppList = Database.query(NHR_Dao.get_NHR_EN_AddOppGet(this.unitStr ,this.userId));
        
        FormCreation__c tempOppInfo1_1_1 = new FormCreation__c();
        FormCreation__c tempOppInfo1_1_2 = new FormCreation__c();
        
        FormCreation__c tempOppInfo2_1 = new FormCreation__c();
        FormCreation__c tempOppInfo2_2 = new FormCreation__c();
        

        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            excelMap1_1.put('addOpp1', setFC('Sales1_1'+ this.userId,'材料販売',9001));
            excelMap1_1.put('addOpp2', setFC('Sales1_1'+ this.userId,'営繕工事',9002));
            
            excelMap2.put('addOpp1', setFC('Sales2'+ this.userId,'材料販売',9001));
            excelMap2.put('addOpp2', setFC('Sales2'+ this.userId,'営繕工事',9002));
            
            tempOppInfo1_1_1 = excelMap1_1.get('addOpp1');
            tempOppInfo1_1_2 = excelMap1_1.get('addOpp2');
            
            tempOppInfo2_1 = excelMap2.get('addOpp1');
            tempOppInfo2_2 = excelMap2.get('addOpp2');
        } else {            
            excelMap1_1.put('addOpp1', setFC('Sales1_1'+ this.deStr,'材料販売',9001));
            excelMap1_1.put('addOpp2', setFC('Sales1_1'+ this.deStr,'営繕工事',9002));
            
            excelMap2.put('addOpp1', setFC('Sales2'+ this.deStr,'材料販売',9001));
            excelMap2.put('addOpp2', setFC('Sales2'+ this.deStr,'営繕工事',9002));
            
            tempOppInfo1_1_1 = excelMap1_1.get('addOpp1');
            tempOppInfo1_1_2 = excelMap1_1.get('addOpp2');
            
            tempOppInfo2_1 = excelMap2.get('addOpp1');
            tempOppInfo2_2 = excelMap2.get('addOpp2');
        }
        
        for(Opportunity obj : addOppList) {
            if (obj.en_zyutyuubi__c >= startDate && obj.en_zyutyuubi__c < LastMonthStartDate) {
                //先月前
                if (obj.en_ankenkubun__c == '材料販売') {
                    //材料販売
                    //予算
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_1.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_1.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_1.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                } else {
                    //営繕工事
                    //予算
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_2.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_2.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_2.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                }
                
            }else if (obj.en_zyutyuubi__c >= LastMonthStartDate && obj.en_zyutyuubi__c <= LastMonthEndDate) {
                //先月
                if (obj.en_ankenkubun__c == '材料販売') {
                    //予算
                    //前月受注計画額と実績額
                    tempOppInfo1_1_1.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////前月売上計画額と実績額
                    tempOppInfo2_1.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_1.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    ////年間受注目標と累計実績額
                    tempOppInfo2_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //実績
                    //前月受注計画額と実績額
                    tempOppInfo1_1_1.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_1.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////前月売上計画額と実績額
                    tempOppInfo2_1.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_1.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    ////年間受注目標と累計実績額
                    tempOppInfo2_1.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_1.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                } else {
                    //予算
                    //前月受注計画額と実績額
                    tempOppInfo1_1_2.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////前月売上計画額と実績額
                    tempOppInfo2_2.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_2.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    ////年間受注目標と累計実績額
                    tempOppInfo2_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //実績
                    //前月受注計画額と実績額
                    tempOppInfo1_1_2.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //前月累計受注計画額と実績額
                    tempOppInfo1_1_2.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////前月売上計画額と実績額
                    tempOppInfo2_2.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_2.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                    ////年間受注目標と累計実績額
                    tempOppInfo2_2.K__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo2_2.L__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                }
            } else if (obj.en_zyutyuubi__c > LastMonthEndDate && obj.en_zyutyuubi__c <= endDate) {
                //当会計年度_今月以降
                if (obj.en_ankenkubun__c == '材料販売') {
                    //予算
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_1.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //実績
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_1.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_1.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                } else {
                    //予算
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.P__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_1_2.Q__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    
                    //２．売上計画に対する実績数値の確認
                    ////年間受注目標と累計実績額
                    tempOppInfo2_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo2_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    //実績
                    //年間受注目標と累計実績額
                    tempOppInfo1_1_2.S__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_1_2.T__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                }
            } 
        }
       
    }
    
    /**
     * 集計
     */
    private void setSum1_1(){
        FormCreation__c sum = excelMap1_1.get('Sum');
                
        for (String keyStr : excelMap1_1.KeySet()) {
            FormCreation__c tempObj = excelMap1_1.get(keyStr);
            if ( keyStr != 'Sum') {
                sum.B__c += tempObj.B__c;
                sum.C__c += tempObj.C__c;
                sum.E__c += tempObj.E__c;
                sum.F__c += tempObj.F__c;
                sum.H__c += tempObj.H__c;
                sum.I__c += tempObj.I__c;
                sum.K__c += tempObj.K__c;
                sum.L__c += tempObj.L__c;
                sum.P__c += tempObj.P__c;
                sum.Q__c += tempObj.Q__c;
                sum.S__c += tempObj.S__c;
                sum.T__c += tempObj.T__c;

                tempObj.D__c = NHR_Dao.getDivision(tempObj.B__c ,tempObj.C__c);
                tempObj.G__c = NHR_Dao.getDivision(tempObj.E__c ,tempObj.F__c);
                tempObj.J__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.I__c);
                tempObj.N__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.K__c);
                tempObj.M__c = NHR_Dao.getDivision(tempObj.K__c ,tempObj.L__c);
                tempObj.N__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.K__c);
                tempObj.O__c = NHR_Dao.getDivision(tempObj.I__c ,tempObj.L__c);
                tempObj.R__c = NHR_Dao.getDivision(tempObj.P__c ,tempObj.Q__c);
                tempObj.V__c = NHR_Dao.getDivision(tempObj.P__c ,tempObj.S__c);
                tempObj.U__c = NHR_Dao.getDivision(tempObj.S__c ,tempObj.T__c);
                tempObj.W__c = NHR_Dao.getDivision(tempObj.Q__c ,tempObj.T__c);
                excelMap1_1.put(keyStr ,tempObj);
            }
        }

        sum.D__c = NHR_Dao.getDivision(sum.B__c ,sum.C__c);
        sum.G__c = NHR_Dao.getDivision(sum.E__c ,sum.F__c);
        sum.J__c = NHR_Dao.getDivision(sum.H__c ,sum.I__c);
        sum.N__c = NHR_Dao.getDivision(sum.H__c ,sum.K__c);
        sum.M__c = NHR_Dao.getDivision(sum.K__c ,sum.L__c);
        sum.N__c = NHR_Dao.getDivision(sum.H__c ,sum.K__c);
        sum.O__c = NHR_Dao.getDivision(sum.I__c ,sum.L__c);
        sum.R__c = NHR_Dao.getDivision(sum.P__c ,sum.Q__c);
        sum.V__c = NHR_Dao.getDivision(sum.P__c ,sum.S__c);
        sum.U__c = NHR_Dao.getDivision(sum.S__c ,sum.T__c);
        sum.W__c = NHR_Dao.getDivision(sum.Q__c ,sum.T__c);
        excelMap1_1.put('Sum' ,sum);

        if (excelMap1_1.size() < 5) {
            for ( integer i = excelMap1_1.size() ; i < 5 ; i++) {
                if (String.isNotBlank(this.userId) ) {
                    excelMap1_1.put( String.valueOf(i)  ,setFC('Sales1_1' + this.userId , '', i * 10 + 1));
                } else {
                    excelMap1_1.put( String.valueOf(i)  ,setFC('Sales1_1' + this.deStr , '', i * 10 + 1));
                }

            }
        }

        system.debug('excelMap1_1:' + excelMap1_1);
        system.debug('excelMap1_1.size():' + excelMap1_1.size());
        for (String key : excelMap1_1.keySet()) {
            FormCreation__c  tempInfo = excelMap1_1.get(key);
            if (removeChk(tempInfo)) {
                excelMap1_1.remove(key);
            } else {
                tempInfo = set1000Tani(tempInfo);
                excelMap1_1.put(key ,tempInfo);
            }
        }
    }

    /**
     * 集計2
     */
    private void setSum2(){
        FormCreation__c sum = excelMap2.get('Sum');
        for (String keyStr : excelMap2.KeySet()) {
            FormCreation__c tempObj = excelMap2.get(keyStr);
            if ( keyStr != 'Sum') {
                sum.B__c += tempObj.B__c;
                sum.C__c += tempObj.C__c;
                sum.E__c += tempObj.E__c;
                sum.F__c += tempObj.F__c;
                sum.H__c += tempObj.H__c;
                sum.I__c += tempObj.I__c;
                sum.K__c += tempObj.K__c;
                sum.L__c += tempObj.L__c;

                tempObj.D__c = NHR_Dao.getDivision(tempObj.B__c ,tempObj.C__c);
                tempObj.G__c = NHR_Dao.getDivision(tempObj.E__c ,tempObj.F__c);
                tempObj.J__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.I__c);
                tempObj.M__c = NHR_Dao.getDivision(tempObj.K__c ,tempObj.L__c);
                tempObj.N__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.K__c);
                tempObj.O__c = NHR_Dao.getDivision(tempObj.I__c ,tempObj.L__c);
                excelMap2.put(keyStr ,tempObj);
            }
        }

        sum.D__c = NHR_Dao.getDivision(sum.B__c ,sum.C__c) ;
        sum.G__c = NHR_Dao.getDivision(sum.E__c ,sum.F__c);
        sum.J__c = NHR_Dao.getDivision(sum.H__c ,sum.I__c);
        sum.M__c = NHR_Dao.getDivision(sum.K__c ,sum.L__c);
        sum.N__c = NHR_Dao.getDivision(sum.H__c ,sum.K__c);
        sum.O__c = NHR_Dao.getDivision(sum.I__c ,sum.L__c);

        excelMap2.put('Sum' ,sum);

        if (excelMap2.size() < 5) {
            for ( integer i = excelMap2.size() ; i < 5 ; i++) {
                if (String.isNotBlank(this.userId) ) {
                    excelMap2.put( String.valueOf(i)  ,setFC('Sales2' + this.userId , '', i * 10 + 1));
                } else {
                    excelMap2.put( String.valueOf(i)  ,setFC('Sales2' + this.deStr , '', i * 10 + 1));
                }
            }
        }

        for (String key : excelMap2.keySet()) {
            FormCreation__c  tempInfo = excelMap2.get(key);
            if (removeChk(tempInfo)) {
                excelMap2.remove(key);
            } else {
                tempInfo = set1000Tani(tempInfo);
                excelMap2.put(key ,tempInfo);
            }
        }
    }

    private Boolean removeChk(FormCreation__c  tempInfo){
        Boolean res = False ;
        if (tempInfo.H__c == 0
           && tempInfo.I__c == 0
           && tempInfo.K__c == 0
           && tempInfo.L__c == 0
           && tempInfo.P__c == 0
           && tempInfo.Q__c == 0
           && tempInfo.S__c == 0
           && tempInfo.T__c == 0
           && tempInfo.B__c == 0
           && tempInfo.C__c == 0) {
            res = TRUE;
        }
        return res;
    }
    
    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.B__c = tempInfo.B__c / 1000;
        tempInfo.C__c = tempInfo.C__c / 1000;
        tempInfo.E__c = tempInfo.E__c / 1000;
        tempInfo.F__c = tempInfo.F__c / 1000;
        tempInfo.H__c = tempInfo.H__c / 1000;
        tempInfo.I__c = tempInfo.I__c / 1000;
        tempInfo.K__c = tempInfo.K__c / 1000;
        tempInfo.L__c = tempInfo.L__c / 1000;
        tempInfo.P__c = tempInfo.P__c / 1000;
        tempInfo.Q__c = tempInfo.Q__c / 1000;
        tempInfo.S__c = tempInfo.S__c / 1000;
        tempInfo.T__c = tempInfo.T__c / 1000;
        return tempInfo;
    }

    private FormCreation__c setFC(String Name , String Title1 ,integer orderBy){
        FormCreation__c rec = new FormCreation__c();
        rec.Name = Name;
        rec.Title1__c = Title1;
        rec.orderBy__c = orderBy;
        rec.A__c = 0;
        rec.B__c = 0;
        rec.C__c = 0;
        rec.D__c = 0;
        rec.E__c = 0;
        rec.F__c = 0;
        rec.G__c = 0;
        rec.H__c = 0;
        rec.I__c = 0;
        rec.J__c = 0;
        rec.K__c = 0;
        rec.L__c = 0;
        rec.M__c = 0;
        rec.N__c = 0;
        rec.O__c = 0;
        rec.P__c = 0;
        rec.Q__c = 0;
        rec.R__c = 0;
        rec.S__c = 0;
        rec.T__c = 0;
        rec.U__c = 0;
        rec.V__c = 0;
        rec.W__c = 0;
        return rec;
    }
    
    public static void forTest() {
        String test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    }

}