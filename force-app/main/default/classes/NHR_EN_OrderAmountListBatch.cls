global without sharing class NHR_EN_OrderAmountListBatch implements Database.Batchable<sObject>, Database.Stateful{

    static final String ACTUAL = '実績';
    static final String BUDGET = '予算';
    static final String TITLE2_1 = '受注';
    static final String TITLE2_2 = '追求';
    static final String TITLE3_1 = '年間計画';
    static final String TITLE3_2 = '累計実績';
    static final String TITLE3_3 = '進捗率';
    static final String TITLE3_4 = '不足額';
    static final String TITLE3_5 = '合計';
    static final String TITLE3_6 = 'A';
    static final String TITLE3_7 = 'B';
    static final String TITLE3_8 = 'C';
    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global List<String> kanseiki {get;set;}
    
    global NHR_EN_OrderAmountListBatch(String inDeStr ,String inUnit ,String userId){
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_OrderAmountListBatch');
        setInit();
        Date theDate = Date.today();
        if (theDate.month() == 7) {
            theDate = theDate.addMonths(-1);
        }
        kanseiki = NHR_Dao.getNext10FiscalYear(NHR_Dao.getFiscalYear(theDate));
        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_OrderAmountListBatch(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<en_yojitsu__c> scopes){
        for(en_yojitsu__c obj : scopes) {
            FormCreation__c tempInfo = new FormCreation__c();
            
            if (this.unitStr == NHR_Constant.UNIT1) {
                String tantobusyoStr = obj.en_tantobusyo1__c;
                if (tantobusyoStr == '営業部') {
                    tantobusyoStr = '営業第一チーム';
                }
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo = excelMap1_1.get(tantobusyoStr + TITLE3_1);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    //実績
                    tempInfo = excelMap1_1.get(tantobusyoStr + TITLE3_2);
                } 
            } else if (this.unitStr == NHR_Constant.UNIT2) {
                system.debug('チーム単位');
                system.debug(obj.OwnerId);
                system.debug(obj.Id);
                //チーム単位
                if (!excelMap1_1.containsKey(obj.OwnerId + TITLE3_1)) {
                    integer orderStart = excelMap1_1.size() / 8;
                    excelMap1_1.put(obj.OwnerId + TITLE3_1, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_1 ,Integer.valueOf(orderStart * 10 + 1)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_2, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_2 ,Integer.valueOf(orderStart * 10 + 2)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_3, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_3 ,Integer.valueOf(orderStart * 10 + 3)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_4, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_4 ,Integer.valueOf(orderStart * 10 + 4)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_5, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_5 ,Integer.valueOf(orderStart * 10 + 5)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_6, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_6 ,Integer.valueOf(orderStart * 10 + 6)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_7, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_7 ,Integer.valueOf(orderStart * 10 + 7)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_8, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_8 ,Integer.valueOf(orderStart * 10 + 8)  ));
                }
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo = excelMap1_1.get(obj.OwnerId + TITLE3_1);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    //実績
                    tempInfo = excelMap1_1.get(obj.OwnerId + TITLE3_2);
                } 
                
            } else if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                //個人単位
                if (!excelMap1_1.containsKey(obj.en_tokuisaki_s__c + TITLE3_1)) {
                    integer orderStart = excelMap1_1.size() / 8;
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_1, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_1 , TITLE3_1 ,Integer.valueOf(orderStart * 10 + 1)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_2, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_1 , TITLE3_2 ,Integer.valueOf(orderStart * 10 + 2)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_3, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_1 , TITLE3_3 ,Integer.valueOf(orderStart * 10 + 3)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_4, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_1 , TITLE3_4 ,Integer.valueOf(orderStart * 10 + 4)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_5, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_2 , TITLE3_5 ,Integer.valueOf(orderStart * 10 + 5)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_6, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_2 , TITLE3_6 ,Integer.valueOf(orderStart * 10 + 6)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_7, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_2 , TITLE3_7 ,Integer.valueOf(orderStart * 10 + 7)  ));
                    excelMap1_1.put(obj.en_tokuisaki_s__c + TITLE3_8, setFC('OrderAmountList' + this.userId,obj.en_tokuisaki_s__r.Name, TITLE2_2 , TITLE3_8 ,Integer.valueOf(orderStart * 10 + 8)  ));
                }
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo = excelMap1_1.get(obj.en_tokuisaki_s__c + TITLE3_1);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    //実績
                    tempInfo = excelMap1_1.get(obj.en_tokuisaki_s__c + TITLE3_2);
                } 
            }
            system.debug(tempInfo);

            if (obj.EN_kanseiki__c == kanseiki[0]) {
                //今期
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo.E__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.F__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    if (obj.Yeaemonth__c >= startDate && obj.Yeaemonth__c <= endDate) {
                        //実績
                        tempInfo.E__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.F__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    }
                } 
            } else if (obj.EN_kanseiki__c == kanseiki[1]) {
                //来期
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo.G__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.H__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    if (obj.Yeaemonth__c >= startDate && obj.Yeaemonth__c <= endDate) {
                        //実績
                        tempInfo.G__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.H__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    }
                    
                } 
            } else {
                //来期以降
                if ( obj.en_yojitu2__c == BUDGET ) {
                    //予算
                    tempInfo.I__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo.J__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else if ( obj.en_yojitu2__c == ACTUAL ) {
                    if (obj.Yeaemonth__c >= startDate && obj.Yeaemonth__c <= endDate) {
                        //実績
                        tempInfo.I__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                        tempInfo.J__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                    }
                } 
            }
            
            system.debug(tempInfo.E__c);
        }
    }
    
     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum();
        
        //insert excelMap1_1.values();

        //完了後の処理があれば
        NHR_EN_OrderAmountListBatch2 myBatchObject = new NHR_EN_OrderAmountListBatch2
            (excelMap1_1
             ,reportMap
             ,yearMap
             ,kanseiki
             ,deStr
             ,this.unitStr
             ,this.userId
            ); 
        Database.executeBatch(myBatchObject,2000);

    }
    /** 
     * 集計
     */
    private void setSum(){
        FormCreation__c sum_1 = new FormCreation__c();
        FormCreation__c sum_2 = new FormCreation__c();
        FormCreation__c sum_3 = new FormCreation__c();
        FormCreation__c sum_4 = new FormCreation__c();
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            sum_1 = excelMap1_1.get('Sum' + this.userId + TITLE3_1);
            sum_2 = excelMap1_1.get('Sum' + this.userId + TITLE3_2);
            sum_3 = excelMap1_1.get('Sum' + this.userId + TITLE3_3);
            sum_4 = excelMap1_1.get('Sum' + this.userId + TITLE3_4);
        } else {
            sum_1 = excelMap1_1.get('Sum'  + TITLE3_1);
            sum_2 = excelMap1_1.get('Sum' + TITLE3_2);
            sum_3 = excelMap1_1.get('Sum' + TITLE3_3);
            sum_4 = excelMap1_1.get('Sum' + TITLE3_4);
        }
        
        for (String keyStr : excelMap1_1.KeySet()) {
            FormCreation__c tempObj = excelMap1_1.get(keyStr);
            if ( !keyStr.contains('Sum') && keyStr.contains(TITLE3_1)) {
                String subKey = keyStr.replace(TITLE3_1 , '');
                FormCreation__c tempInfo_1 = excelMap1_1.get(subKey + TITLE3_1);
                FormCreation__c tempInfo_2 = excelMap1_1.get(subKey + TITLE3_2);
                FormCreation__c tempInfo_3 = excelMap1_1.get(subKey + TITLE3_3);
                FormCreation__c tempInfo_4 = excelMap1_1.get(subKey + TITLE3_4);
                
                tempInfo_3.E__c = NHR_Dao.getDivision(tempInfo_1.E__c ,tempInfo_2.E__c);
                tempInfo_3.F__c = NHR_Dao.getDivision(tempInfo_1.F__c ,tempInfo_2.F__c);
                tempInfo_3.G__c = NHR_Dao.getDivision(tempInfo_1.G__c ,tempInfo_2.G__c);
                tempInfo_3.H__c = NHR_Dao.getDivision(tempInfo_1.H__c ,tempInfo_2.H__c);
                tempInfo_3.I__c = NHR_Dao.getDivision(tempInfo_1.I__c ,tempInfo_2.I__c);
                tempInfo_3.J__c = NHR_Dao.getDivision(tempInfo_1.J__c ,tempInfo_2.J__c);
                
                tempInfo_4.E__c = tempInfo_1.E__c  - tempInfo_2.E__c;
                tempInfo_4.F__c = tempInfo_1.F__c  - tempInfo_2.F__c;
                tempInfo_4.G__c = tempInfo_1.G__c  - tempInfo_2.G__c;
                tempInfo_4.H__c = tempInfo_1.H__c  - tempInfo_2.H__c;
                tempInfo_4.I__c = tempInfo_1.I__c  - tempInfo_2.I__c;
                tempInfo_4.J__c = tempInfo_1.J__c  - tempInfo_2.J__c;
                
                tempInfo_1.K__c = tempInfo_1.E__c + tempInfo_1.G__c + tempInfo_1.I__c;
                tempInfo_2.K__c = tempInfo_2.E__c + tempInfo_2.G__c + tempInfo_2.I__c;
                tempInfo_3.K__c = NHR_Dao.getDivision(tempInfo_1.K__c ,tempInfo_2.K__c);
                tempInfo_4.K__c = tempInfo_4.E__c + tempInfo_4.G__c + tempInfo_4.I__c;
                
                tempInfo_1.L__c = tempInfo_1.F__c + tempInfo_1.H__c + tempInfo_1.J__c;
                tempInfo_2.L__c = tempInfo_2.F__c + tempInfo_2.H__c + tempInfo_2.J__c;
                tempInfo_3.L__c = NHR_Dao.getDivision(tempInfo_1.L__c ,tempInfo_2.L__c);
                tempInfo_4.L__c = tempInfo_4.F__c + tempInfo_4.H__c + tempInfo_4.J__c;
                
                sum_1 = setSumRow(sum_1 ,tempInfo_1);
                sum_2 = setSumRow(sum_2 ,tempInfo_2);
                sum_4 = setSumRow(sum_4 ,tempInfo_4);
                
                /*
                excelMap1_1.put(mt.Department__c + TITLE3_1 ,tempInfo_1);
                excelMap1_1.put(mt.Department__c + TITLE3_2 ,tempInfo_2);
                excelMap1_1.put(mt.Department__c + TITLE3_3 ,tempInfo_3);
                excelMap1_1.put(mt.Department__c + TITLE3_4 ,tempInfo_4);
*/
            }
        }

        sum_3.E__c = NHR_Dao.getDivision(sum_1.E__c ,sum_2.E__c);
        sum_3.F__c = NHR_Dao.getDivision(sum_1.F__c ,sum_2.F__c);
        sum_3.G__c = NHR_Dao.getDivision(sum_1.G__c ,sum_2.G__c);
        sum_3.H__c = NHR_Dao.getDivision(sum_1.H__c ,sum_2.H__c);
        sum_3.I__c = NHR_Dao.getDivision(sum_1.I__c ,sum_2.I__c);
        sum_3.J__c = NHR_Dao.getDivision(sum_1.J__c ,sum_2.J__c);
        sum_3.K__c = NHR_Dao.getDivision(sum_1.K__c ,sum_2.K__c);
        sum_3.L__c = NHR_Dao.getDivision(sum_1.L__c ,sum_2.L__c);

        /*
        excelMap1_1.put('Sum' + TITLE3_1 ,sum_1);
        excelMap1_1.put('Sum' + TITLE3_2 ,sum_2);
        excelMap1_1.put('Sum' + TITLE3_3 ,sum_3);
        excelMap1_1.put('Sum' + TITLE3_4 ,sum_4);
        */
    }
    
    private FormCreation__c setSumRow(FormCreation__c sum , FormCreation__c tempInfo){
        sum.E__c += tempInfo.E__c;
        sum.F__c += tempInfo.F__c;
        sum.G__c += tempInfo.G__c;
        sum.H__c += tempInfo.H__c;
        sum.I__c += tempInfo.I__c;
        sum.J__c += tempInfo.J__c;
        sum.K__c += tempInfo.K__c;
        sum.L__c += tempInfo.L__c;
        return sum;
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
        
        //表示内容設定
        yearMap = new Map<String ,String>();
        reportMap = new Map<String ,EN_Report__mdt>();
        excelMap1_1 = new Map<String ,FormCreation__c>();
        
        // 会年度取得
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }
        
        //１．受注計画に対する実績数値の確認
        //２．売上計画に対する実績数値の確認
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        for(EN_Report__mdt mt : md2) {
            if (this.unitStr == NHR_Constant.UNIT1) {
                reportMap.put(mt.Department__c ,mt);
                if (mt.Department__c != '営業部') {
                    excelMap1_1.put(mt.Department__c + TITLE3_1, setFC('OrderAmountList',mt.Department__c, TITLE2_1 , TITLE3_1 ,Integer.valueOf(mt.OrderBy__c * 10 + 1)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_2, setFC('OrderAmountList',mt.Department__c, TITLE2_1 , TITLE3_2 ,Integer.valueOf(mt.OrderBy__c * 10 + 2)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_3, setFC('OrderAmountList',mt.Department__c, TITLE2_1 , TITLE3_3 ,Integer.valueOf(mt.OrderBy__c * 10 + 3)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_4, setFC('OrderAmountList',mt.Department__c, TITLE2_1 , TITLE3_4 ,Integer.valueOf(mt.OrderBy__c * 10 + 4)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_5, setFC('OrderAmountList',mt.Department__c, TITLE2_2 , TITLE3_5 ,Integer.valueOf(mt.OrderBy__c * 10 + 5)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_6, setFC('OrderAmountList',mt.Department__c, TITLE2_2 , TITLE3_6 ,Integer.valueOf(mt.OrderBy__c * 10 + 6)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_7, setFC('OrderAmountList',mt.Department__c, TITLE2_2 , TITLE3_7 ,Integer.valueOf(mt.OrderBy__c * 10 + 7)  ));
                    excelMap1_1.put(mt.Department__c + TITLE3_8, setFC('OrderAmountList',mt.Department__c, TITLE2_2 , TITLE3_8 ,Integer.valueOf(mt.OrderBy__c * 10 + 8)  ));
                }
                
                if (mt.Department__c == '営業第一チーム') {
                    reportMap.put('営業部' ,mt);
                }
            } else {
                if (mt.Department__c == this.deStr ) {
                    reportMap.put(mt.Department__c ,mt);
                    if (this.deStr == '営業第一チーム') {
                        reportMap.put('営業部' ,mt);
                    }
                }
            }
        }
        //合計行追加
        //
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            String userName = NHR_Dao.getUserInfo(userId).Name;
            excelMap1_1.put('Sum' + this.userId   + TITLE3_1, setFC('OrderAmountList' + this.userId,userName, TITLE2_1,TITLE3_1 ,9991));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_2, setFC('OrderAmountList' + this.userId,userName, TITLE2_1,TITLE3_2 ,9992));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_3, setFC('OrderAmountList' + this.userId,userName, TITLE2_1,TITLE3_3 ,9993));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_4, setFC('OrderAmountList' + this.userId,userName, TITLE2_1,TITLE3_4 ,9994));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_5, setFC('OrderAmountList' + this.userId,userName, TITLE2_2,TITLE3_5 ,9995));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_6, setFC('OrderAmountList' + this.userId,userName, TITLE2_2,TITLE3_6 ,9996));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_7, setFC('OrderAmountList' + this.userId,userName, TITLE2_2,TITLE3_7 ,9997));
            excelMap1_1.put('Sum' + this.userId   + TITLE3_8, setFC('OrderAmountList' + this.userId,this.deStr, TITLE2_2,TITLE3_8 ,9998));
        } else {
            excelMap1_1.put('Sum'  + TITLE3_1, setFC('OrderAmountList',this.deStr, TITLE2_1,TITLE3_1 ,9991));
            excelMap1_1.put('Sum'  + TITLE3_2, setFC('OrderAmountList',this.deStr, TITLE2_1,TITLE3_2 ,9992));
            excelMap1_1.put('Sum'  + TITLE3_3, setFC('OrderAmountList',this.deStr, TITLE2_1,TITLE3_3 ,9993));
            excelMap1_1.put('Sum'  + TITLE3_4, setFC('OrderAmountList',this.deStr, TITLE2_1,TITLE3_4 ,9994));
            excelMap1_1.put('Sum'  + TITLE3_5, setFC('OrderAmountList',this.deStr, TITLE2_2,TITLE3_5 ,9995));
            excelMap1_1.put('Sum'  + TITLE3_6, setFC('OrderAmountList',this.deStr, TITLE2_2,TITLE3_6 ,9996));
            excelMap1_1.put('Sum'  + TITLE3_7, setFC('OrderAmountList',this.deStr, TITLE2_2,TITLE3_7 ,9997));
            excelMap1_1.put('Sum'  + TITLE3_8, setFC('OrderAmountList',this.deStr, TITLE2_2,TITLE3_8 ,9998));
        }
        
                
    }
    
    private FormCreation__c setFC(String Name , String Title1 ,String Title2 ,String Title3 ,integer orderBy){
        FormCreation__c rec = new FormCreation__c();
        rec.Name = Name;
        rec.Title1__c = Title1;
        rec.Title2__c = Title2;
        rec.Title3__c = Title3;
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
}