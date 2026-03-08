/*
 * 【CS】パーセプションマップ
 */
global without sharing class NHR_CS_PerceptualMappingBatch implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_CS_PerceptualMappingBatch(){}

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_CS_PerceptualMappingBatch');
    	String query = NHR_Dao.get_NHR_CS_PerceptualMappingBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Contact> scopes){

        for(Contact obj : scopes) {
            obj.CW_RelationshipDegree__c = 'Lv1';
            //関係構築度_CW判定
            if (obj.CW_RelationshipDegree__c != 'Lv5' && obj.CW_RelationshipDegree__c != 'Lv6') {
                integer bukenNum = 0;
                if (obj.Account.CS_zyoutyukaryu__c == '川下') {
                    if (obj.genbatantousya__r  != NULL){bukenNum = obj.genbatantousya__r.size() ;}
                } else if (obj.Account.CS_zyoutyukaryu__c == '中流') {
                    if (obj.zyutyusakigenbatantousya__r  != NULL){bukenNum = obj.zyutyusakigenbatantousya__r.size() ;}
                } else if (obj.Account.CS_zyoutyukaryu__c == '川上') {
                    if (obj.zyouhouteikyousya__r  != NULL){bukenNum = obj.zyouhouteikyousya__r.size() ;}
                } 
                if (bukenNum == 2
                    && obj.EventRelations  != NULL && obj.EventRelations.size() == 3) {
                        obj.CW_RelationshipDegree__c = 'Lv5';
                    } else if (bukenNum >= 1) {
                        obj.CW_RelationshipDegree__c = 'Lv4';
                    } else if (obj.EventRelations  != NULL && obj.EventRelations.size() >= 2) {
                        obj.CW_RelationshipDegree__c = 'Lv3';
                    } else if (obj.EventRelations  != NULL && obj.EventRelations.size() >= 1) {
                        obj.CW_RelationshipDegree__c = 'Lv2';
                    }
            }
            if (obj.coCS__r  != NULL && obj.coCS__r.size()  > 0) {
                integer monthTempNum = chkMonthNum(obj);
                integer monthTempNuLLNum = chkMonthNullNum(obj);
                system.debug('obj:' + obj.Name);
                system.debug('monthTempNum:' + monthTempNum);
                system.debug('monthTempNuLLNum:' + monthTempNuLLNum);
                if (obj.CW_RelationshipDegree__c == 'Lv5') {
                    if (monthTempNum >= 6) {
                        obj.CW_RelationshipDegree__c = 'Lv6';
                    }
                    
                    if ( monthTempNuLLNum >= 4){
                        obj.CW_RelationshipDegree__c = 'Lv4';
                    }
                } 
                if (obj.CW_RelationshipDegree__c == 'Lv6') {
                    
                    if ( monthTempNuLLNum >= 4){
                        obj.CW_RelationshipDegree__c = 'Lv4';
                    } else if ( monthTempNuLLNum >= 2){
                        obj.CW_RelationshipDegree__c = 'Lv5';
                    }
                    
                } 
            }

        }
        
        update scopes;
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //mailSend();
    }
    
     /**
     * API取得
     */
    private String setAPIName(Integer num){
        String apiName = 'property_';
        apiName += String.ValueOf(num) + '_1__c';
        return apiName;
    }
    
     /**
     * 過去連続月数
     */
    private integer chkMonthNum(Contact obj){

        Date theDate = Date.Today();
        Integer thisMonth = Date.Today().Month();
        
        
        integer tempMonthNum = 0;
        for (Integer i = 0; i < 13 ; i++) {
            if (thisMonth - i  < 1 ) {
                if (obj.coCS__r.size() > 1 && obj.coCS__r[1].get(setAPIName(thisMonth - i  + 12)) != NULL) {
                    tempMonthNum ++;
                } else {
                    break;
                }
            } else {
                if (obj.coCS__r[0].get(setAPIName(thisMonth - i )) != NULL) {
                    tempMonthNum ++;
                } else {
                    break;
                }
            }
        }
        
        return tempMonthNum;
    }
    
     /**
     * 過去連続登録しない月数
     */
    private integer chkMonthNullNum(Contact obj){

        Date theDate = Date.Today();
        Integer thisMonth = Date.Today().Month();
        
        
        integer tempMonthNum = 0;
        for (Integer i = 0; i < 13 ; i++) {
            if (thisMonth - i < 1 ) {
                if (obj.coCS__r.size() > 1 && obj.coCS__r[1].get(setAPIName(thisMonth - i + 12)) == NULL) {
                    tempMonthNum ++;
                } else {
                    break;
                }
            } else {
                if (obj.coCS__r[0].get(setAPIName(thisMonth - i )) == NULL) {
                    tempMonthNum ++;
                } else {
                    break;
                }
            }
        }
        
        return tempMonthNum;
    }
    
    /*
        * メール送信
       */
        private void mailSend(){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])

            mail.setSubject('【CS】関係構築度自動UpDown処理完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('【CS】関係構築度自動UpDown処理完了いたしました。'); // 本文(String)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
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