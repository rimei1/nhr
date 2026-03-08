public class NHR_EN_CreateExcelCtrl {

    //営業報告書作成
    @AuraEnabled
    public static void Call_EN_SalesReportStart(String targetStr ,String inUnit){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where (Name like 'Sales3%'
                   OR Name like 'Sales4%'
                   OR Name like 'Sales1_1%'
                   OR Name like 'Sales1_2%'
                   OR Name like 'Sales2%'
                   )
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }

        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        if (inUnit == NHR_Constant.UNIT4) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            NHR_EN_SalesReportBatch1 myBatchObject = new NHR_EN_SalesReportBatch1(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_SalesReportBatch1 myBatchObject = new NHR_EN_SalesReportBatch1(targetStr ,inUnit , obj.id);
                Database.executeBatch(myBatchObject,2000);
            }
        } else {
            NHR_EN_SalesReportBatch1 myBatchObject = new NHR_EN_SalesReportBatch1(targetStr ,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }


    }

    //受注追求金額一覧表作成
    @AuraEnabled
    public static void Call_EN_OrderAmountList(String targetStr ,String inUnit){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name like 'OrderAmountList%'
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_OrderAmountListBatch myBatchObject = new NHR_EN_OrderAmountListBatch(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_OrderAmountListBatch myBatchObject = new NHR_EN_OrderAmountListBatch(targetStr ,inUnit , obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_OrderAmountListBatch myBatchObject = new NHR_EN_OrderAmountListBatch(targetStr ,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }
        
    }

    //受注追求金額一覧表(大阪)作成
    @AuraEnabled
    public static void Call_EN_OrderAmountListOsaka(){
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name In ('OrderAmountListOsaka')
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        NHR_EN_OrderAmountListOsakaBatch myBatchObject = new NHR_EN_OrderAmountListOsakaBatch();
        Database.executeBatch(myBatchObject,2000);
    }

    //得意先別受注目標作成
    @AuraEnabled
    public static void Call_AccountOrderTargetBatch(String targetStr ,String inUnit){
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name like :(NHR_Constant.BATCHNAME_AOT + '%')
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        List<String> targetList = new List<String>();
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_AccountOrderTargetBatch myBatchObject = new NHR_EN_AccountOrderTargetBatch(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else 
        if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_AccountOrderTargetBatch myBatchObject = new NHR_EN_AccountOrderTargetBatch(targetStr,inUnit ,obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_AccountOrderTargetBatch myBatchObject = new NHR_EN_AccountOrderTargetBatch(targetStr,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }

    }

    //得意先別売上目標作成
    @AuraEnabled
    public static void Call_AccountSalesTargetBatch(String targetStr ,String inUnit){
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name like :(NHR_Constant.BATCHNAME_AST + '%')
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        List<String> targetList = new List<String>();
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_AccountSalesTargetBatch myBatchObject = new NHR_EN_AccountSalesTargetBatch(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_AccountSalesTargetBatch myBatchObject = new NHR_EN_AccountSalesTargetBatch(targetStr,inUnit ,obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_AccountSalesTargetBatch myBatchObject = new NHR_EN_AccountSalesTargetBatch(targetStr,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }
        
    }

    //工種別完工高一覧表作成
    @AuraEnabled
    public static void Call_ConOppOrderBatch(String targetStr ,String inUnit){
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name like :(NHR_Constant.BATCHNAME_COO + '%')
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        List<String> targetList = new List<String>();
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_ConOppOrderBatch myBatchObject = new NHR_EN_ConOppOrderBatch(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_ConOppOrderBatch myBatchObject = new NHR_EN_ConOppOrderBatch(targetStr,inUnit ,obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_ConOppOrderBatch myBatchObject = new NHR_EN_ConOppOrderBatch(targetStr,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }
        
    }

    //工種別受注高一覧表作成
    @AuraEnabled
    public static void Call_ConOrderBatch(String targetStr ,String inUnit){
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name like :(NHR_Constant.BATCHNAME_CO + '%')
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        List<String> targetList = new List<String>();
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_ConOrderBatch myBatchObject = new NHR_EN_ConOrderBatch(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_ConOrderBatch myBatchObject = new NHR_EN_ConOrderBatch(targetStr,inUnit , obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_ConOrderBatch myBatchObject = new NHR_EN_ConOrderBatch(targetStr,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }
        
    }

    //営業検討会添付資料作成
    @AuraEnabled
    public static void Call_SalesReviewMeetingBatch(String targetStr,String inUnit){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where (Name like :(NHR_Constant.BATCHNAME_SRM1 + '%')
                   OR Name like :(NHR_Constant.BATCHNAME_SRM2 + '%')
                   OR Name like :(NHR_Constant.BATCHNAME_SRM3 + '%')
                   )
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        
        if (targetStr == '東京') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '東京') {
                    targetList.add(mt.Department__c);
                }
            }
        } else if (targetStr == '大阪') {
            for(EN_Report__mdt mt : md2) {
                if ( mt.MasterLabel == '大阪') {
                    targetList.add(mt.Department__c);
                }
            }
        }
        if (inUnit == NHR_Constant.UNIT4) {
            NHR_EN_SalesReviewMeetingBatch1 myBatchObject = new NHR_EN_SalesReviewMeetingBatch1(targetStr ,inUnit , UserInfo.getUserID());
            Database.executeBatch(myBatchObject,2000);
        }
        else if (inUnit == NHR_Constant.UNIT3) {
            List<User> userList = new List<User>();
            userList = [Select Id From User Where Department in :targetList];
            for (User obj : userList) {
                NHR_EN_SalesReviewMeetingBatch1 myBatchObject = new NHR_EN_SalesReviewMeetingBatch1(targetStr ,inUnit , obj.id);
                Database.executeBatch(myBatchObject,2000);
            }

        } else {
            NHR_EN_SalesReviewMeetingBatch1 myBatchObject = new NHR_EN_SalesReviewMeetingBatch1(targetStr ,inUnit ,'');
            Database.executeBatch(myBatchObject,2000);
        }
        
        //NHR_EN_SalesReviewMeetingBatch1 myBatchObject = new NHR_EN_SalesReviewMeetingBatch1(targetStr);
        //Database.executeBatch(myBatchObject,2000);
    }
    
    //売上管理表_②
    @AuraEnabled
    public static void Call_SalesManagementBatch(){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where (Name like :(NHR_Constant.BATCHNAME_SLSALES1 + '%')
                          OR Name like :(NHR_Constant.BATCHNAME_SLSALES2 + '%')
                          OR Name like :(NHR_Constant.BATCHNAME_SLSALES3 + '%')
                          OR Name like :(NHR_Constant.BATCHNAME_SLSALES4 + '%')
                   )
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        
        NHR_SL_SalesManagementBatch myBatchObject = new NHR_SL_SalesManagementBatch();
        Database.executeBatch(myBatchObject,2000);

    }
    
    //住環境_BPOKPIレポート
    @AuraEnabled
    public static void Call_JU_BPOKPIKGIReportBatch(){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name = :NHR_Constant.BATCHNAME_JU_KPI
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        
        NHR_JU_BPOKPIKGIReportBatch myBatchObject = new NHR_JU_BPOKPIKGIReportBatch();
        Database.executeBatch(myBatchObject,2000);

    }
    
    //【スチール】規模別数量・件数構成比
    @AuraEnabled
    public static void Call_NHR_ST_QuantityRatioBatch(){
        List<String> targetList = new List<String>();
        List<FormCreation__c> delList= New List<FormCreation__c>();
        delList = [Select Id From FormCreation__c
                   Where Name = :NHR_Constant.BATCHNAME_ST_R
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList.size() > 0) {
            delete delList;
        }
        
        
        NHR_ST_QuantityRatioBatch myBatchObject = new NHR_ST_QuantityRatioBatch();
        Database.executeBatch(myBatchObject,2000);

    }

}