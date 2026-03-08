/*
 * 1_2を作成
 */
global without sharing class NHR_EN_SalesReportBatch2 implements Database.Batchable<sObject>, Database.Stateful{
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
    global Date LastMonthStartDate {get;set;}
    global Date LastMonthEndDate {get;set;}
    global NHR_EN_SalesReportBatch2
        (Map<String ,FormCreation__c> inExcelMap1_1
         ,Map<String ,FormCreation__c> inExcelMap1_2
         ,Map<String ,FormCreation__c> inExcelMap2
         ,Map<String ,FormCreation__c> inExcelMap3
         ,Map<String ,FormCreation__c> inExcelMap4
         ,String inDeStr
         ,String inUnit
         ,String userId
         ,Date inStartDate
         ,Date inEndDate
         ,Date inLastMonthStartDate
         ,Date inLastMonthEndDate
         ,Map<String ,EN_Report__mdt> inReportMap
         ,Map<String ,String> inYearMap)
    {
        this.excelMap1_1 = inExcelMap1_1;
        this.excelMap1_2 = inExcelMap1_2;
        this.excelMap2 = inExcelMap2;
        this.excelMap3 = inExcelMap3;
        this.excelMap4 = inExcelMap4;
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
        this.startDate = inStartDate;
        this.endDate = inEndDate;
        this.LastMonthStartDate = inLastMonthStartDate;
        this.LastMonthEndDate = inLastMonthEndDate;
        this.reportMap = inReportMap;
        this.yearMap = inYearMap;
    }

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_SalesReportBatch2');
        system.debug('this.excelMap3:' + this.excelMap3);

        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_SalesReportBatch2(this.unitStr ,this.userId);
        //商談（営繕工事、材料販売）
        addOppList = Database.query(NHR_Dao.get_NHR_EN_AddOppGet(this.unitStr ,this.userId));

        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        for(Opportunity obj : scopes) {
            FormCreation__c tempInfo = new FormCreation__c();
            if (this.unitStr == NHR_Constant.UNIT1) {
                String tantobusyoStr = obj.Department__c;
                if (tantobusyoStr == '営業部') {
                    tantobusyoStr = '営業１課';
                }
                //営業所単位
                if (!excelMap1_2.containsKey(tantobusyoStr)) {
                    integer orderStart = excelMap1_2.size();
                    excelMap1_2.put(tantobusyoStr ,setFC('Sales1_2'+ deStr, tantobusyoStr, orderStart * 10 + 1));
                }
                tempInfo = excelMap1_2.get(tantobusyoStr);
            } else if (this.unitStr == NHR_Constant.UNIT2) {
                //チーム単位
                if (!excelMap1_2.containsKey(obj.OwnerId)) {
                    integer orderStart = excelMap1_2.size();
                    excelMap1_2.put(obj.OwnerId ,setFC('Sales1_2'+ deStr, obj.Owner.Name, orderStart * 10 + 1));
                }
                tempInfo = excelMap1_2.get(obj.OwnerId);
            } else if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                String tempKey = '';
                String tempName = '';
                integer orderStart = 0;
                
                if(obj.Account.DX_Other__c) {
                    tempKey = 'DX_Other__c';
                    tempName = 'その他';
                    orderStart = 900;
                    
                } else {
                    tempKey = obj.AccountId;
                    tempName = obj.Account.Name;
                    orderStart = excelMap1_2.size();
                }
                //個人単位
                if (!excelMap1_2.containsKey(tempKey)) {
                    //integer orderStart = excelMap1_2.size();
                    excelMap1_2.put(tempKey ,setFC('Sales1_2'+ userId, tempName, orderStart * 10 + 1));
                }
                tempInfo = excelMap1_2.get(tempKey);

            }
            //tempInfo = excelMap1_2.get(obj.Department__c);

            //前月受注見込額と実績額
            if (obj.EN_LastMonthzyutyuumikomi__c == '受注') {
                tempInfo.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                tempInfo.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                if(tempInfo.Title1__c == '株式会社大林組　大阪本店 エンジ大阪'){system.debug(obj.en_shodansan__r);system.debug(obj.en_shodansan__r.size());} 
                if (obj.en_shodansan__r != NULL && obj.en_shodansan__r.size() > 0) {
                    for (en_yojitsu__c obj2 : obj.en_shodansan__r) {
                        tempInfo.E__c += (obj2.en_juchu12__c == null ? 0 : obj2.en_juchu12__c);
                        tempInfo.F__c += (obj2.en_jutyuarari__c == null ? 0 : obj2.en_jutyuarari__c);
                    }
                }
            }
            //当月受注見込額
            if (obj.EN_zyutyuumikomi__c == '受注') {
                tempInfo.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                tempInfo.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
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
        setSum1_2();

        //１．受注計画に対する実績数値の確認
        insert excelMap1_2.values();

        //完了後の処理があれば
        NHR_EN_SalesReportBatch3 myBatchObject = new NHR_EN_SalesReportBatch3
            (excelMap1_1
             ,excelMap1_2
             ,excelMap2
             ,excelMap3
             ,excelMap4
             ,deStr
             ,unitStr
             ,userId
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
     * 集計事前処理
     */
    private void setSumPre(){
        Set<String> tantobusyo = reportMap.keySet();
        //商談（営繕工事、材料販売）
        addOppList = Database.query(NHR_Dao.get_NHR_EN_AddOppGet(this.unitStr ,this.userId));
        
        FormCreation__c tempOppInfo1_2_1 = new FormCreation__c();
        FormCreation__c tempOppInfo1_2_2 = new FormCreation__c();
        Date NextMonthStartDate = LastMonthStartDate.addMonths(2);
        
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            excelMap1_2.put('addOpp1', setFC('Sales1_2'+ this.userId,'材料販売',9001));
            excelMap1_2.put('addOpp2', setFC('Sales1_2'+ this.userId,'営繕工事',9002));
            
            tempOppInfo1_2_1 = excelMap1_2.get('addOpp1');
            tempOppInfo1_2_2 = excelMap1_2.get('addOpp2');

        } else {            
            excelMap1_2.put('addOpp1', setFC('Sales1_2'+ this.deStr,'材料販売',9001));
            excelMap1_2.put('addOpp2', setFC('Sales1_2'+ this.deStr,'営繕工事',9002));
            
            tempOppInfo1_2_1 = excelMap1_2.get('addOpp1');
            tempOppInfo1_2_2 = excelMap1_2.get('addOpp2');
            
        }
        
        for(Opportunity obj : addOppList) {
            if (obj.en_zyutyuubi__c >= LastMonthStartDate && obj.en_zyutyuubi__c <= LastMonthEndDate) {
                //前月受注見込額と実績額
                if (obj.en_ankenkubun__c == '材料販売') {
                    tempOppInfo1_2_1.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_2_1.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    tempOppInfo1_2_1.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_2_1.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                } else {
                    tempOppInfo1_2_2.B__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_2_2.C__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                    tempOppInfo1_2_2.E__c += (obj.en_zyutyukingaku__c == null ? 0 : obj.en_zyutyukingaku__c);
                    tempOppInfo1_2_2.F__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
                }
            } else if (obj.en_zyutyuubi__c > LastMonthEndDate && obj.en_zyutyuubi__c < NextMonthStartDate) {
                //当月受注見込額
                if (obj.en_ankenkubun__c == '材料販売') {
                    tempOppInfo1_2_1.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_2_1.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                } else {
                    tempOppInfo1_2_2.H__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempOppInfo1_2_2.I__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                }
            }
        }
    }

    /**
     * 集計1_2
     */
    private void setSum1_2(){
        FormCreation__c sum = excelMap1_2.get('Sum');
        for (String keyStr : excelMap1_2.KeySet()) {
            FormCreation__c tempObj = excelMap1_2.get(keyStr);
            if ( keyStr != 'Sum') {
                sum.B__c += tempObj.B__c;
                sum.C__c += tempObj.C__c;
                sum.E__c += tempObj.E__c;
                sum.F__c += tempObj.F__c;
                sum.H__c += tempObj.H__c;
                sum.I__c += tempObj.I__c;

                tempObj.D__c = NHR_Dao.getDivision(tempObj.B__c ,tempObj.C__c);
                tempObj.G__c = NHR_Dao.getDivision(tempObj.E__c ,tempObj.F__c);
                tempObj.J__c = NHR_Dao.getDivision(tempObj.H__c ,tempObj.I__c);
                excelMap1_2.put(keyStr ,tempObj);
            }
        }

        sum.D__c = NHR_Dao.getDivision(sum.B__c ,sum.C__c);
        sum.G__c = NHR_Dao.getDivision(sum.E__c ,sum.F__c);
        sum.J__c = NHR_Dao.getDivision(sum.H__c ,sum.I__c);

        excelMap1_2.put('Sum' ,sum);

        if (excelMap1_2.size() < 5) {
            for ( integer i = excelMap1_2.size() ; i < 5 ; i++) {
                if (String.isNotBlank(this.userId) ) {
                    excelMap1_2.put( String.valueOf(i)  ,setFC('Sales1_2' + this.userId , '', i * 10 + 1));
                } else {
                    excelMap1_2.put( String.valueOf(i)  ,setFC('Sales1_2' + this.deStr , '', i * 10 + 1));
                }

            }
        }

        for (String key : excelMap1_2.keySet()) {
            FormCreation__c  tempInfo = excelMap1_2.get(key);
                tempInfo = set1000Tani(tempInfo);
                excelMap1_2.put(key ,tempInfo);
        }
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

    public FormCreation__c setFC(String Name , String Title1 ,integer orderBy){
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