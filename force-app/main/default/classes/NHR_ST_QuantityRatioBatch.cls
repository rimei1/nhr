/*
*工種別完工高一覧表
*/
global without sharing class NHR_ST_QuantityRatioBatch implements Database.Batchable<sObject>, Database.Stateful{

    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Map<String ,FormCreation__c> excelMap {get;set;}
    global NHR_ST_QuantityRatioBatch(){
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_QuantityRatioBatch');
        setInit();

    	String query = NHR_Dao.get_NHR_ST_QuantityRatioBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        
        for(Opportunity obj : scopes) {
            FormCreation__c tempInfo1 = New FormCreation__c();
            FormCreation__c tempInfo2 = New FormCreation__c();
            FormCreation__c Sum_1 = excelMap.get('ST_SUM1');
            FormCreation__c Sum_2 = excelMap.get('ST_SUM2');
            
            system.debug('obj.ST_CompositionRatio__c:' + obj.ST_CompositionRatio__c);
            if (obj.ST_CompositionRatio__c == NHR_Constant.ST_SUB1) {
                tempInfo1 = excelMap.get('ST_1_1');
                tempInfo2 = excelMap.get('ST_1_2');
            } else if (obj.ST_CompositionRatio__c == NHR_Constant.ST_SUB2) {
                tempInfo1 = excelMap.get('ST_2_1');
                tempInfo2 = excelMap.get('ST_2_2');
            } else if (obj.ST_CompositionRatio__c == NHR_Constant.ST_SUB3) {
                tempInfo1 = excelMap.get('ST_3_1');
                tempInfo2 = excelMap.get('ST_3_2');
            } else if (obj.ST_CompositionRatio__c == NHR_Constant.ST_SUB4) {
                tempInfo1 = excelMap.get('ST_4_1');
                tempInfo2 = excelMap.get('ST_4_2');
            } else if (obj.ST_CompositionRatio__c == NHR_Constant.ST_SUB5) {
                tempInfo1 = excelMap.get('ST_5_1');
                tempInfo2 = excelMap.get('ST_5_2');
            }
            
            if ( String.isNotBlank(obj.Name) ) {
                if (obj.StageName == 'A' || obj.StageName == 'B' || obj.StageName == 'C' || obj.StageName == 'D'
                   || obj.StageName == 'E' || obj.StageName == 'F' || obj.StageName == 'G' || obj.StageName == 'H') {
                       system.debug('tempInfo1:' + tempInfo1);
                       system.debug('obj:' + obj);
                    tempInfo1.I__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    tempInfo2.I__c += 1;
                    Sum_1.I__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    Sum_2.I__c += 1;
                } else if (obj.StageName == '受注ST') {
                    tempInfo1.F__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    tempInfo2.F__c += 1;
                    Sum_1.F__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    Sum_2.F__c += 1;
                } else if (obj.StageName == '仕掛') {
                    tempInfo1.C__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    tempInfo2.C__c += 1;
                    Sum_1.C__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                    Sum_2.C__c += 1;
                }
                
                tempInfo1.L__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                tempInfo2.L__c += 1;
                Sum_1.L__c += obj.ST_suryou__c == null ? 0 : obj.ST_suryou__c;
                Sum_2.L__c += 1;
            }

        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum();
        //完了後の処理があれば
        insert excelMap.values();


        //完了後の処理があれば
        System.Queueable job = new NHR_ST_QuantityRatioExcelCreate();
        System.enqueueJob(job);
    }

    /**
     * 集計
     */
    private void setSum(){
        Decimal quantity1 = 0;
        Decimal num1 = 0;
        Decimal quantity2 = 0;
        Decimal num2 = 0;
        Decimal quantity3 = 0;
        Decimal num3 = 0;
        Decimal quantity4 = 0;
        Decimal num4 = 0;
        FormCreation__c Sum_1 = excelMap.get('ST_SUM1');
        FormCreation__c Sum_2 = excelMap.get('ST_SUM2');
        
        
        for(integer i = 1 ; i <=5 ; i++) {
            FormCreation__c tempInfo_1 = excelMap.get('ST_' +String.valueOf(i) + '_1');
            quantity1 += tempInfo_1.C__c;
            quantity2 += tempInfo_1.F__c;
            quantity3 += tempInfo_1.I__c;
            quantity4 += tempInfo_1.L__c;

            FormCreation__c tempInfo_2 = excelMap.get('ST_' +String.valueOf(i) + '_2');
            num1 += tempInfo_2.C__c;
            num2 += tempInfo_2.F__c;
            num3 += tempInfo_2.I__c;
            num4 += tempInfo_2.L__c;
            
            
            if (Sum_1.C__c != 0 && Sum_1.C__c != null) {
                tempInfo_1.D__c = tempInfo_1.C__c / Sum_1.C__c * 100;
                tempInfo_1.E__c = quantity1/ Sum_1.C__c * 100;
                
                tempInfo_2.D__c = tempInfo_2.C__c / Sum_2.C__c * 100;
                tempInfo_2.E__c = num1/ Sum_2.C__c * 100;
            }
            

            if (Sum_1.F__c != 0 && Sum_1.F__c != null) {
                tempInfo_1.G__c = tempInfo_1.F__c / Sum_1.F__c * 100;
                tempInfo_1.H__c = quantity2/ Sum_1.F__c * 100;
                
                tempInfo_2.G__c = tempInfo_2.F__c / Sum_2.F__c * 100;
                tempInfo_2.H__c = num2/ Sum_2.F__c * 100;
            }
            
            if (Sum_1.I__c != 0 && Sum_1.I__c != null) {
                tempInfo_1.J__c = tempInfo_1.I__c / Sum_1.I__c * 100;
                tempInfo_1.K__c = quantity3/ Sum_1.I__c * 100;
                
                tempInfo_2.J__c = tempInfo_2.I__c / Sum_2.I__c * 100;
                tempInfo_2.K__c = num3/ Sum_2.I__c * 100;
            }
            
            if (Sum_1.L__c != 0 && Sum_1.L__c != null) {
                tempInfo_1.M__c = tempInfo_1.L__c / Sum_1.L__c * 100;
                tempInfo_1.N__c = quantity4/ Sum_1.L__c * 100;
                
                tempInfo_2.M__c = tempInfo_2.L__c / Sum_2.L__c * 100;
                tempInfo_2.N__c = num4/ Sum_2.L__c * 100;
            }
        }
        
        
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

        startDate = NHR_Dao.getFiscalYearStartDate(forGetDay.addYears(-1));
        endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);
        //thisFiscalYear = NHR_Dao.getFiscalYear(forGetDay);
        excelMap = new Map<String ,FormCreation__c>();

        //合計行追加
        excelMap.put('ST_1_1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB1,NHR_Constant.QUANTITY ,1001));
        excelMap.put('ST_1_2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB1,NHR_Constant.NUM ,1002));

        excelMap.put('ST_2_1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB2,NHR_Constant.QUANTITY ,2001));
        excelMap.put('ST_2_2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB2,NHR_Constant.NUM ,2002));

        excelMap.put('ST_3_1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB3,NHR_Constant.QUANTITY ,3001));
        excelMap.put('ST_3_2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB3,NHR_Constant.NUM ,3002));

        excelMap.put('ST_4_1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB4,NHR_Constant.QUANTITY ,4001));
        excelMap.put('ST_4_2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB4,NHR_Constant.NUM ,4002));

        excelMap.put('ST_5_1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB5,NHR_Constant.QUANTITY ,5001));
        excelMap.put('ST_5_2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.ST_SUB5,NHR_Constant.NUM ,5002));

        excelMap.put('ST_SUM1' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.TOTAL,NHR_Constant.QUANTITY ,9001));
        excelMap.put('ST_SUM2' , setFC(NHR_Constant.BATCHNAME_ST_R,NHR_Constant.TOTAL,NHR_Constant.NUM ,9002));

    }

    private FormCreation__c setFC(String Name , String Title1 ,String Title2 ,integer orderBy){
        FormCreation__c rec = new FormCreation__c();
        rec.Name = Name;
        rec.Title1__c = Title1;
        rec.Title2__c = Title2;
        //rec.Title3__c = Title3;
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
        rec.X__c = 0;
        rec.Y__c = 0;
        rec.Z__c = 0;
        rec.AA__c = 0;
        rec.AB__c = 0;
        rec.AC__c = 0;

        return rec;
    }

    /**
   * EXCEL作成
   */
    public class NHR_ST_QuantityRatioExcelCreate implements Queueable, Database.AllowsCallouts {
        public NHR_ST_QuantityRatioExcelCreate()
        {
        }
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                String fileSubName = 'ST_';

                String fileName = fileSubName + String.valueOf(Date.today()).replaceAll('-', '');
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_ST_QuantityRatio;
                conObject.versiondata=pr.getContent();
                insert conObject;

                mailSend(conObject.Id);
            }
        }

        /*
        * メール送信
       */
        private void mailSend(String contentId){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])

            mail.setSubject('【スチール】規模別数量・件数構成比の出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('【スチール】規模別数量・件数構成比の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
}