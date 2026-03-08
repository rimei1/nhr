global with sharing class NHR_DX_AccOrgUpdOrderByBatch implements Database.Batchable<Contact> {

    global List<Contact> conList{get;set;}
    global String comName{get;set;}
    global NHR_DX_AccOrgUpdOrderByBatch(List<Contact> inParm){
        conList = inParm;
        comName = inParm[0].Account.Name;
    }
    
    
    global Iterable<Contact> start(Database.BatchableContext BC) {
        return conList;
    }

    global void execute(Database.BatchableContext info, List<Contact> scopes) {

        update scopes;
    }

    global void finish(Database.BatchableContext info) {
        mailSend(comName);
    }
    
    /*
    * メール送信
    */
    private void mailSend(String comName){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])
        
        mail.setSubject('「組織情報並び順設定完了のお知らせ」' + comName); // 件名(String)
        mail.setPlainTextBody('「' + comName + '」の組織情報並び順の設定が完了いたしました。'); // 本文(String)

        mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}