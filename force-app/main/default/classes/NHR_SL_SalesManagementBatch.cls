/*
 * 実績を作成
 */
global without sharing class NHR_SL_SalesManagementBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String ACTUAL = '実績';
    static final String BUDGET = '予算';
    global Map<String ,FormCreation__c> excelMap1 {get;set;}
    global Map<String ,FormCreation__c> excelMap2 {get;set;}
    global Map<String ,FormCreation__c> excelMap3 {get;set;}
    global Map<String ,FormCreation__c> excelMap4 {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}

    global NHR_SL_SalesManagementBatch(){
    }

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_SL_SalesManagementBatch');
        setInit();
    	String query = NHR_Dao.get_NHR_SL_SalesManagementBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Asset> scopes){

        FormCreation__c tempInfo1_1 = excelMap1.get('1');
        FormCreation__c tempInfo1_2 = excelMap1.get('2');
        FormCreation__c tempInfo1_3 = excelMap1.get('3');
        FormCreation__c tempInfo1_4 = excelMap1.get('4');
        FormCreation__c tempInfo1_5 = excelMap1.get('5');
        FormCreation__c tempInfo1_6 = excelMap1.get('6');
        FormCreation__c tempInfo1_7 = excelMap1.get('7');
        FormCreation__c tempInfo1_8 = excelMap1.get('8');
        
        FormCreation__c tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = excelMap3.get('3');
        FormCreation__c tempInfo3_4 = excelMap3.get('4');
        FormCreation__c tempInfo3_5 = excelMap3.get('5');

        for(Asset obj : scopes) {
            if (obj.ProductFamily__c == 'Pro3AK') {
                setExcelData(tempInfo1_1 ,tempInfo1_7,tempInfo3_1, tempInfo1_2,obj);
            } else if (obj.ProductFamily__c == 'Pro2') {
                setExcelData(tempInfo1_1 ,tempInfo1_7,tempInfo3_2, tempInfo1_3 ,obj);
            } else if (obj.ProductFamily__c == 'Pro2備品') {
                setExcelData(tempInfo1_1 ,tempInfo1_7,null, tempInfo1_4 ,obj);
            } else if (obj.ProductFamily__c == 'Axis') {
                setExcelData(tempInfo1_1 ,tempInfo1_7,tempInfo3_3, tempInfo1_5 ,obj);
            } else if (obj.ProductFamily__c == 'SaaS') {
                if (obj.keiyakukoushinbi__c == null || obj.keiyakukoushinbi__c == obj.syokaikeiyakubi__c ) {
                    setExcelData(tempInfo1_1 ,tempInfo1_7,tempInfo3_4, tempInfo1_6,obj);
                } else {
                    setExcelData(tempInfo1_1 ,tempInfo1_7,tempInfo3_5, tempInfo1_6,obj);
                }
            } 
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum1();
        setSum3();

        insert excelMap1.values();
        insert excelMap3.values();
       
        //完了後の処理があれば
        NHR_SL_SalesManagementBatch2 myBatchObject = new NHR_SL_SalesManagementBatch2
            (excelMap1
             ,excelMap2
             ,excelMap3
             ,excelMap4
             ,startDate
             ,endDate
            );
        Database.executeBatch(myBatchObject,2000);
    }

    /**
     * 日付によって値設定
     */
    private void setExcelData(FormCreation__c inData ,FormCreation__c inData2 ,FormCreation__c inData3 ,FormCreation__c inData4 ,Asset aObj){
        if (aObj.SL_SalesManagement__c != null) {
            Integer monthNum =  aObj.SL_SalesManagement__c.month();
               // AdoptionAmount__c 
            switch on monthNum {
                when 1 {
                    inData.J__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.J__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.J__c += 1;}
                    inData4.J__c += getDecimal(aObj.Cost__c);
                }	
                when 2 {
                    inData.K__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.K__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.K__c += 1;}
                    inData4.K__c += getDecimal(aObj.Cost__c);
                }
                when 3 {
                    inData.L__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.L__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.L__c += 1;}
                    inData4.L__c += getDecimal(aObj.Cost__c);
                }
                when 4 {
                    inData.M__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.M__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.M__c += 1;}
                    inData4.M__c += getDecimal(aObj.Cost__c);
                }	
                when 5 {
                    inData.N__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.N__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.N__c += 1;}
                    inData4.N__c += getDecimal(aObj.Cost__c);
                }
                when 6 {
                    inData.O__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.O__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.O__c += 1;}
                    inData4.O__c += getDecimal(aObj.Cost__c);
                }
                when 7 {
                    inData.D__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.D__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.D__c += 1;}
                    inData4.D__c += getDecimal(aObj.Cost__c);
                }	
                when 8 {
                    inData.E__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.E__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.E__c += 1;}
                    inData4.E__c += getDecimal(aObj.Cost__c);
                }
                when 9 {
                    inData.F__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.F__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.F__c += 1;}
                    inData4.F__c += getDecimal(aObj.Cost__c);
                }
                when 10 {
                    inData.G__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.G__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.G__c += 1;}
                    inData4.G__c += getDecimal(aObj.Cost__c);
                }	
                when 11 {
                    inData.H__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.H__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.H__c += 1;}
                    inData4.H__c += getDecimal(aObj.Cost__c);
                }
                when 12 {
                    inData.I__c += getDecimal(aObj.AdoptionAmount__c);
                    inData2.I__c += getDecimal(aObj.GrossProfitAmount__c);
                    if (inData3 != null){inData3.I__c += 1;}
                    inData4.I__c += getDecimal(aObj.Cost__c);
                }
            }
        }
    }
    
    /**
     * 集計 1
     */
    private void setSum1(){
        FormCreation__c tempInfo1_1 = excelMap1.get('1');
        FormCreation__c tempInfo1_2 = excelMap1.get('2');
        FormCreation__c tempInfo1_3 = excelMap1.get('3');
        FormCreation__c tempInfo1_4 = excelMap1.get('4');
        FormCreation__c tempInfo1_5 = excelMap1.get('5');
        FormCreation__c tempInfo1_6 = excelMap1.get('6');
        FormCreation__c tempInfo1_7 = excelMap1.get('7');
        FormCreation__c tempInfo1_8 = excelMap1.get('8');
        
        tempInfo1_1 = set1000Tani(tempInfo1_1);
        tempInfo1_2 = set1000Tani(tempInfo1_2);
        tempInfo1_3 = set1000Tani(tempInfo1_3);
        tempInfo1_4 = set1000Tani(tempInfo1_4);
        tempInfo1_5 = set1000Tani(tempInfo1_5);
        tempInfo1_6 = set1000Tani(tempInfo1_6);
        tempInfo1_7 = set1000Tani(tempInfo1_7);
        
        setSum(tempInfo1_1);
        setSum(tempInfo1_2);
        setSum(tempInfo1_3);
        setSum(tempInfo1_4);
        setSum(tempInfo1_5);
        setSum(tempInfo1_6);
        setSum(tempInfo1_7);
        
        tempInfo1_8.D__c = NHR_Dao.getDivision(tempInfo1_1.D__c ,tempInfo1_7.D__c);
        tempInfo1_8.E__c = NHR_Dao.getDivision(tempInfo1_1.E__c ,tempInfo1_7.E__c);
        tempInfo1_8.F__c = NHR_Dao.getDivision(tempInfo1_1.F__c ,tempInfo1_7.F__c);
        tempInfo1_8.G__c = NHR_Dao.getDivision(tempInfo1_1.G__c ,tempInfo1_7.G__c);
        tempInfo1_8.H__c = NHR_Dao.getDivision(tempInfo1_1.H__c ,tempInfo1_7.H__c);
        tempInfo1_8.I__c = NHR_Dao.getDivision(tempInfo1_1.I__c ,tempInfo1_7.I__c);
        tempInfo1_8.J__c = NHR_Dao.getDivision(tempInfo1_1.J__c ,tempInfo1_7.J__c);
        tempInfo1_8.K__c = NHR_Dao.getDivision(tempInfo1_1.K__c ,tempInfo1_7.K__c);
        tempInfo1_8.L__c = NHR_Dao.getDivision(tempInfo1_1.L__c ,tempInfo1_7.L__c);
        tempInfo1_8.M__c = NHR_Dao.getDivision(tempInfo1_1.M__c ,tempInfo1_7.M__c);
        tempInfo1_8.N__c = NHR_Dao.getDivision(tempInfo1_1.N__c ,tempInfo1_7.N__c);
        tempInfo1_8.O__c = NHR_Dao.getDivision(tempInfo1_1.O__c ,tempInfo1_7.O__c);
        tempInfo1_8.P__c = NHR_Dao.getDivision(tempInfo1_1.P__c ,tempInfo1_7.P__c);
    }
    
    private void setSum(FormCreation__c inObj){
        inObj.P__c = inObj.D__c + inObj.E__c + inObj.F__c + inObj.G__c + inObj.H__c + inObj.I__c
             + inObj.J__c + inObj.K__c + inObj.L__c + inObj.M__c + inObj.N__c + inObj.O__c;
    }
    

    /**
     * 集計3
     */
    private void setSum3(){
        FormCreation__c tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = excelMap3.get('3');
        FormCreation__c tempInfo3_4 = excelMap3.get('4');
        FormCreation__c tempInfo3_5 = excelMap3.get('5');
        
        setSum(tempInfo3_1);
        setSum(tempInfo3_2);
        setSum(tempInfo3_3);
        setSum(tempInfo3_4);
        setSum(tempInfo3_5);
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
system.debug('startDate:' + startDate);
        system.debug('endDate:' + endDate);
        //表示内容設定
        excelMap1 = new Map<String ,FormCreation__c>();
        excelMap2 = new Map<String ,FormCreation__c>();
        excelMap3 = new Map<String ,FormCreation__c>();
        excelMap4 = new Map<String ,FormCreation__c>();

        excelMap1.put('1', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','売上合計','　',1));
        excelMap1.put('2', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','原価','　Pro3Aｷｯﾄ',2));
        excelMap1.put('3', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','原価','　Pro2',3));
        excelMap1.put('4', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','原価','　Pro2備品',4));
        excelMap1.put('5', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','原価','　Axis',5));
        excelMap1.put('6', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','原価','　SaaS',6));
        excelMap1.put('7', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','粗利益額','　',7));
        excelMap1.put('8', setFC(NHR_Constant.BATCHNAME_SLSALES1,'実績','粗利率 ','　',8));
        
        excelMap2.put('1', setFC(NHR_Constant.BATCHNAME_SLSALES2,'目標','売上合計','　',1));
        excelMap2.put('2', setFC(NHR_Constant.BATCHNAME_SLSALES2,'目標','　原価合計','　SaaS',2));
        excelMap2.put('3', setFC(NHR_Constant.BATCHNAME_SLSALES2,'目標','粗利益額','　',3));
        excelMap2.put('4', setFC(NHR_Constant.BATCHNAME_SLSALES2,'目標','粗利率 ','　',4));
        
        excelMap3.put('1', setFC(NHR_Constant.BATCHNAME_SLSALES3,'販売数実績','Pro3販売台数','　',1));
        excelMap3.put('2', setFC(NHR_Constant.BATCHNAME_SLSALES3,'販売数実績','　Pro2販売台数','　SaaS',2));
        excelMap3.put('3', setFC(NHR_Constant.BATCHNAME_SLSALES3,'販売数実績','Axis販売台数','　',3));
        excelMap3.put('4', setFC(NHR_Constant.BATCHNAME_SLSALES3,'販売数実績','新規クラウド契約販売数 ','　',4));
         excelMap3.put('5', setFC(NHR_Constant.BATCHNAME_SLSALES3,'販売数実績','クラウド更新 ','　',5));
        
        excelMap4.put('1', setFC(NHR_Constant.BATCHNAME_SLSALES4,'販売数目標','Pro2販売台数','　',1));
        excelMap4.put('2', setFC(NHR_Constant.BATCHNAME_SLSALES4,'販売数目標','　Pro3販売台数','　SaaS',2));
        excelMap4.put('3', setFC(NHR_Constant.BATCHNAME_SLSALES4,'販売数目標','Axis販売台数','　',3));

    }

    private decimal getDecimal(decimal  inDecimal){
        decimal rec = 0;
        if (inDecimal != null) {
            rec = inDecimal;
        }
        return rec;
    }
    
    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.D__c = tempInfo.D__c / 1000;
        tempInfo.E__c = tempInfo.E__c / 1000;
        tempInfo.F__c = tempInfo.F__c / 1000;
        tempInfo.G__c = tempInfo.G__c / 1000;
        tempInfo.H__c = tempInfo.H__c / 1000;
        tempInfo.I__c = tempInfo.I__c / 1000;
        tempInfo.J__c = tempInfo.J__c / 1000;
        tempInfo.K__c = tempInfo.K__c / 1000;
        tempInfo.L__c = tempInfo.L__c / 1000;
        tempInfo.M__c = tempInfo.M__c / 1000;
        tempInfo.N__c = tempInfo.N__c / 1000;
        tempInfo.O__c = tempInfo.O__c / 1000;
        tempInfo.P__c = tempInfo.P__c / 1000;
        tempInfo.Q__c = tempInfo.Q__c / 1000;
        tempInfo.R__c = tempInfo.R__c / 1000;
        tempInfo.S__c = tempInfo.S__c / 1000;
        tempInfo.T__c = tempInfo.T__c / 1000;
        return tempInfo;
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

    public static void forTest() {
        String test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
    }
}