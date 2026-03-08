global without sharing class NHR_EN_OrderAmountListOsakaBatch implements Database.Batchable<sObject>, Database.Stateful{

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
    //global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,Map<String ,FormCreation__c>> excelMap {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String kanseiki {get;set;}
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_OrderAmountListOsakaBatch');
        setInit();
        kanseiki = NHR_Dao.getFiscalYear(Date.today());
        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_OrderAmountListOsakaBatch();
        return Database.getQueryLocator(query);
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<en_yojitsu__c> scopes){
        for(en_yojitsu__c obj : scopes) {
            if (!excelMap.containsKey(obj.OwnerId)) {
                Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
                integer orderStart = excelMap.size();
                excelMap1_1.put(obj.OwnerId + TITLE3_1, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_1 , orderStart * 10 + 1));
                excelMap1_1.put(obj.OwnerId  + TITLE3_2, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_2 ,orderStart * 10 + 2));
                excelMap1_1.put(obj.OwnerId  + TITLE3_3, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_3 ,orderStart * 10 + 3));
                excelMap1_1.put(obj.OwnerId  + TITLE3_4, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_4 ,orderStart * 10 + 4));
                excelMap1_1.put(obj.OwnerId  + TITLE3_5, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_5 ,orderStart * 10 + 5));
                excelMap1_1.put(obj.OwnerId  + TITLE3_6, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_6 ,orderStart * 10 + 6));
                excelMap1_1.put(obj.OwnerId  + TITLE3_7, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_7 ,orderStart * 10 + 7));
                excelMap1_1.put(obj.OwnerId  + TITLE3_8, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_8 ,orderStart * 10 + 8));
                excelMap.put(obj.OwnerId ,excelMap1_1);
            }
            
            FormCreation__c tempInfo = new FormCreation__c();
            
            if ( obj.en_yojitu2__c == BUDGET ) {
                //予算
                tempInfo = excelMap.get(obj.OwnerId).get(obj.OwnerId + TITLE3_1);
            } else if ( obj.en_yojitu2__c == ACTUAL ) {
                //実績
                tempInfo = excelMap.get(obj.OwnerId).get(obj.OwnerId + TITLE3_2);
            } 
            
            //今期
            if ( obj.en_yojitu2__c == BUDGET ) {
                //予算
                tempInfo.E__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                tempInfo.F__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
            } else if ( obj.en_yojitu2__c == ACTUAL ) {
                //実績
                tempInfo.E__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                tempInfo.F__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
            } 
            
            system.debug('tempInfo:' + tempInfo);
        }
    }
    
     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        
        NHR_EN_OrderAmountListOsakaBatch2 myBatchObject = new NHR_EN_OrderAmountListOsakaBatch2
            (excelMap
             ,reportMap
             ,yearMap
             ,kanseiki
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
        
        //表示内容設定
        yearMap = new Map<String ,String>();
        reportMap = new Map<String ,EN_Report__mdt>();
        Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
        excelMap = new Map<String ,Map<String ,FormCreation__c>>();
        
        // 会年度取得
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }
        
        //１．受注計画に対する実績数値の確認
        //２．売上計画に対する実績数値の確認
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        for(EN_Report__mdt mt : md2) {
            if (mt.MasterLabel == '大阪') {
                reportMap.put(mt.Department__c ,mt);
            }
        }
        //合計行追加
        excelMap1_1.put('Sum'  + TITLE3_1, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_1,TITLE3_1 ,1));
        excelMap1_1.put('Sum'  + TITLE3_2, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_1,TITLE3_2 ,2));
        excelMap1_1.put('Sum'  + TITLE3_3, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_1,TITLE3_3 ,3));
        excelMap1_1.put('Sum'  + TITLE3_4, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_1,TITLE3_4 ,4));
        excelMap1_1.put('Sum'  + TITLE3_5, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_2,TITLE3_5 ,5));
        excelMap1_1.put('Sum'  + TITLE3_6, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_2,TITLE3_6 ,6));
        excelMap1_1.put('Sum'  + TITLE3_7, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_2,TITLE3_7 ,7));
        excelMap1_1.put('Sum'  + TITLE3_8, setFC(NHR_Constant.BATCHNAME_OAL,'大阪支店', TITLE2_2,TITLE3_8 ,8));
        excelMap.put('Sum' ,excelMap1_1);
                
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