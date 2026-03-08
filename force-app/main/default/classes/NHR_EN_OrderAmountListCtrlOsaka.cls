public class NHR_EN_OrderAmountListCtrlOsaka {
    public List<FormCreation__c> FormCreation{get;set;}
    public List<List<FormCreation__c>> FormCreationList{get;set;}
    public String fileName {get;set;}
    
    public String thisYear {get;set;}
    public String thisFiscalYear {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public String colNum {get;set;}
    
    public NHR_EN_OrderAmountListCtrlOsaka() {
        thisDay = Date.today();
        if (thisDay.month() == 7) {
            thisDay = thisDay.addMonths(-1);
        }
        thisDayStr = thisDay.format();
        thisYear = NHR_Dao.getYear(thisDay);
        thisFiscalYear = NHR_Dao.getFiscalYearStr(thisDay);
        
        FormCreation = new List<FormCreation__c>();
        FormCreationList = new List<List<FormCreation__c>>();
        //ファイル名
        fileName = '受注追求金額一覧表_大阪' + String.valueOf(Date.today()).replaceAll('-', '') ;
        
        FormCreation = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_OAL);
        system.debug('FormCreation:' + FormCreation);
        integer i = 0;
        List<FormCreation__c> tempList = new List<FormCreation__c>();
        for (FormCreation__c obj : FormCreation) {
            if (math.mod(i, 8) == 0) {
                if (i != 0) {
                    FormCreationList.add(tempList);
                }
                tempList = new List<FormCreation__c>();
                tempList.add(obj);
            } else {
                tempList.add(obj);
            }
            i += 1;
        }
        FormCreationList.add(tempList);
        system.debug('i:' + i);
        colNum = String.valueOf(FormCreationList.size() * 3);
        system.debug('FormCreationList:' + FormCreationList);
        system.debug('colNum:' + colNum);
        //FormCreationList = Osmo_Dao.getAccountForFWHForExcel(System.Label.Osmo_CHWSumUser);
    }
}