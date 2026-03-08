public class NHR_Dao {

    //**営業報告書データ作成用**
    public static String get_NHR_EN_SalesReportBatch(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' en_tokuisaki_s__r.Name  ,';
        soql += ' en_tokuisaki_s__r.DX_Other__c  ,';
        soql += ' Owner.Name  ,';
        soql += ' en_shodans__r.EN_zyutyuumikomi__c  ,';
        soql += ' en_shodans__r.EN_LastMonthzyutyuumikomi__c  ,';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\',\'予算\')';
        soql += '  AND Yeaemonth__c  >= :startDate';
        //soql += '  AND en_ankenkubun_yozitsu__c  = \'本工事\'';
        
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**営業報告書データ作成用**
    public static String get_NHR_EN_SalesReportBatch2(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.Name  ,';
        soql += ' Account.Name  ,';
        soql += ' Account.DX_Other__c  ,';
        soql +=  createSelect('Opportunity');
        soql += ' , ( SELECT ';
        soql += '  Id , en_juchu12__c , en_jutyuarari__c';
        soql += ' FROM en_shodansan__r  ';
        //soql += ' WHERE en_yojitu2__c in (\'実績\')  AND en_tantobusyo1__c  in :tantobusyo)';
        soql += ' WHERE en_yojitu2__c in (\'実績\')  ';
        soql += '  AND en_ankenkubun_yozitsu__c  = \'本工事\')';
        soql += ' FROM Opportunity ';
        soql += ' WHERE ';
        soql += '  (EN_zyutyuumikomi__c = \'受注\'';
        soql += '  OR EN_LastMonthzyutyuumikomi__c = \'受注\')';
        soql += '  AND RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND en_ankenkubun__c  = \'本工事\'';
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }


        system.debug('soql:' + soql);
        return soql;
    }

    //**営業報告書データ作成用**
    /*
    public static String get_NHR_EN_SalesReportBatch3_old(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' en_shodans__r.en_genbastatus__c, ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\')';
        soql += '  AND EN_kanseiki__c in :kanseiki';
        //soql += '  AND en_shodans__r.en_genbastatus__c  not in (\'完成\')';
        //soql += '  AND en_shodans__r.en_genbastatus__c  != null';
        soql += '  AND en_shodans__r.en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }
        system.debug('soql:' + soql);
        return soql;
    }*/
    
    //**営業報告書データ作成用**
    public static String get_NHR_EN_SalesReportBatch3(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND EN_kanseiki__c in :kanseiki';
        //soql += '  AND en_genbastatus__c  not in (\'完成\')';
        //soql += '  AND en_genbastatus__c  != null';
        soql += '  AND en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        soql += '  AND en_ankenkubun__c  = \'本工事\'';
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }
        system.debug('soql:' + soql);
        return soql;
    }

    //**営業報告書データ作成用**
    public static String get_NHR_EN_AddOppGet(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND en_zyutyuubi__c >= :startDate';
        soql += '  AND en_zyutyuubi__c <= :endDate';
        soql += '  AND en_ankenkubun__c in  (\'営繕工事\' , \'材料販売\')';
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }
        system.debug('soql:' + soql);
        return soql;
    }
    
    //**営業報告書データ作成用**
    public static String get_NHR_EN_SalesReportBatch4(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.Name  ,';
        soql += ' Account.Name  ,';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity ';
        soql += ' WHERE ';
        soql += '  en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        soql += '  AND EN_kanseiki__c = :kanseiki';
        soql += '  AND RecordType.DeveloperName = \'en_zenekonsh\' ';
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }


        system.debug('soql:' + soql);
        return soql;
    }
    
    //**営業報告書データ作成用_3**
    public static String get_NHR_EN_SalesReportBatch5(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\',\'予算\')';
        soql += '  AND EN_kanseiki__c in :kanseiki';
        //soql += '  AND en_ankenkubun_yozitsu__c  = \'本工事\'';
        if (unitStr == NHR_Constant.UNIT3 || unitStr == NHR_Constant.UNIT4) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**営業報告書帳票作成用**
    public static List<FormCreation__c> get_NHR_EN_SalesReportCtrl(String Name) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('FormCreation__c');
        soql += ' FROM FormCreation__c  ';
        soql += ' WHERE Name  = :Name';
        if(!Test.isRunningTest()){
            soql += '  AND OwnerId = \'' + UserInfo.getUserId() +'\' ';
        }
        soql += '  Order by orderBy__c';

        return Database.query(soql);
    }

    //**受注追求金額一覧表作成用**
    public static String get_NHR_EN_OrderAmountListBatch(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' en_tokuisaki_s__r.Name  ,';
        soql += ' Owner.Name  ,';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\',\'予算\')';
        soql += '  AND EN_kanseiki__c in :kanseiki';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**受注追求金額一覧表作成用**
    public static String get_NHR_EN_OrderAmountListBatch2(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.Name  ,';
        soql += ' Account.Name  ,';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity ';
        soql += ' WHERE ';
        soql += '  EN_kanseiki__c in :kanseiki';
        soql += '  AND RecordType.DeveloperName = \'en_zenekonsh\' ';
        if(!Test.isRunningTest()){
            if (unitStr == NHR_Constant.UNIT3) {
                soql += '  AND OwnerId  = \'' + userId + '\'';
            } else {
                soql += '  AND Department__c  in :tantobusyo ';
            }
        }
        

        soql += '  AND en_zyutyuukakudo__c  in (\'Aランク\',\'Bランク\',\'Cランク\')';


        system.debug('soql:' + soql);
        return soql;
    }

    //**受注追求金額一覧表作成用_大阪**
    public static String get_NHR_EN_OrderAmountListOsakaBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\',\'予算\')';
        soql += '  AND EN_kanseiki__c = :kanseiki';
        soql += '  AND en_tantobusyo1__c  in :tantobusyo';

        system.debug('soql:' + soql);
        return soql;
    }

    //**受注追求金額一覧表作成用_大阪**
    public static String get_NHR_EN_OrderAmountListOsakaBatch2() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity ';
        soql += ' WHERE ';
        soql += '  EN_kanseiki__c = :kanseiki';
        soql += '  AND RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND Department__c  in :tantobusyo ';
        soql += '  AND en_zyutyuukakudo__c  in (\'Aランク\',\'Bランク\',\'Cランク\')';


        system.debug('soql:' + soql);
        return soql;
    }

    //**得意先別受注目標表作成用**
    public static String get_NHR_EN_AccountOrderTargetBatch(String unitStr, String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' en_tokuisaki_s__r.Name , ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'予算\')';
        soql += '  AND Yeaemonth__c  >= :startDate';
        soql += '  AND Yeaemonth__c  <= :endDate';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**得意先別売上目標表作成用**
    public static String get_NHR_EN_AccountSalesTargetBatch(String unitStr, String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' en_tokuisaki_s__r.Name , ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'予算\')';
        soql += '  AND Yeaemonth__c  >= :startDate';
        soql += '  AND Yeaemonth__c  <= :endDate';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**営業検討会添付資料表(EN予実管理)作成用**
    public static String get_NHR_EN_SalesReviewMeetingEY(String unitStr, String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' en_tokuisaki_s__r.Name , ';
        soql += ' en_shodans__r.en_zyutyuukakudo__c , ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'予算\' ,\'実績\')';
        soql += '  AND Yeaemonth__c  >= :startDate';
        soql += '  AND Yeaemonth__c  <= :endDate';
        //soql += '  AND en_shodans__r.en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**営業検討会添付資料表(商談)作成用**
    public static String get_NHR_EN_SalesReviewMeetingOpp(String unitStr , String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' Account.Name , ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND en_ukeoisyunkouyoteibi__c  >= :startDate';
        soql += '  AND en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**工種別完工高一覧表作成用**
    public static String get_NHR_EN_ConOppOrderBatch(String unitStr, String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' Account.Name , ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'en_zenekonsh\' ';
        soql += '  AND en_ankenkubun__c = \'本工事\'';
        soql += '  AND en_zyutyuukakudo__c  in (\'受注\' ,\'受注確定\')';
        soql += '  AND en_ukeoisyunkouyoteibi__c  >= :startDate';
        if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND Department__c  in :tantobusyo ';
        }

        system.debug('soql:' + soql);
        return soql;
    }

    //**工種別受注高一覧表作成用**
    public static String get_NHR_EN_ConOrderBatch(String unitStr, String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Owner.LastName , ';
        soql += ' en_tokuisaki_s__r.Name , ';
        soql +=  createSelect('en_yojitsu__c');
        soql += ' FROM en_yojitsu__c  ';
        soql += ' WHERE ';
        soql += '  en_yojitu2__c  in (\'実績\')';
        soql += '  AND Yeaemonth__c  >= :startDate';
        soql += '  AND Yeaemonth__c  <= :endDate';
       if (unitStr == NHR_Constant.UNIT3) {
            soql += '  AND OwnerId  = \'' + userId + '\'';
        } else {
            soql += '  AND en_tantobusyo1__c  in :tantobusyo';
        }

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**ソリューション営業部_売上管理表_②作成用**
    public static String get_NHR_SL_SalesManagementBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Asset');
        soql += ' FROM Asset   ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'Achievements\' ';
        soql += '  AND SL_SalesManagement__c   >= :startDate';
        soql += '  AND SL_SalesManagement__c   <= :endDate';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**ソリューション営業部_売上管理表_②作成用**
    public static String get_NHR_SL_SalesManagementBatch2() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Asset');
        soql += ' FROM Asset   ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'Target\' ';
        soql += '  AND SL_SalesManagement__c   >= :startDate';
        soql += '  AND SL_SalesManagement__c   <= :endDate';

        system.debug('soql:' + soql);
        return soql;
    }
    

    //**ソリューション営業部_売上管理表_②作成用**
    public static String get_NHR_JU_BPOKPIKGIReport() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Account.JU_sakuzusekisanbpo_yusendo__c , ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity   ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'JU_sakzusekisanbpotaisyou\' ';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】規模別数量・件数構成比_作成用**
    public static String get_NHR_ST_QuantityRatioBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity   ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'RecordType_SteelCons\' ';
        soql += '  AND StageName NOT IN (\'失注\' ,\'完成\' ,\'辞退\' )';
        //soql += '  AND SL_SalesManagement__c   >= :startDate';
        //soql += '  AND SL_SalesManagement__c   <= :endDate';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】納品トン数objの当月以降（当月含む）のトン数を商談objの項目に積み上げ_作成用**
    public static String get_NHR_ST_DeliveryTonsBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Steel_delivery__c');
        soql += ' FROM Steel_delivery__c    ';
        soql += ' WHERE ';
        soql += '  Opp__r.RecordType.DeveloperName = \'RecordType_SteelCons\' ';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】加工数量実績および予定_作成用**
    public static String get_NHR_ST_QuantityActualPlansBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Opp__r.ST_processing__c, '; 
        soql += ' Opp__r.StageName, '; 
        soql +=  createSelect('Steel_delivery__c');
        soql += ' FROM Steel_delivery__c    ';
        soql += ' WHERE ';
        soql += '  Opp__r.RecordType.DeveloperName = \'RecordType_SteelCons\' ';         

        system.debug('soql:' + soql);
        return soql;
    }
     
    //**【スチール】加工数量実績および予定_作成用**
    public static String get_NHR_ST_QuantityActualPlansBatch2() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Opp__r.ST_processing__c, '; 
        soql += ' Opp__r.StageName, '; 
        soql +=  createSelect('Steel_delivery__c');
        soql += ' FROM Steel_delivery__c    ';
        soql += ' WHERE ';
        soql += '  Opp__r.RecordType.DeveloperName = \'RecordType_Steel_kakou\' ';     
        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】加工数量実績および予定_作成用**
    public static List<ST_ManagementDashboard__c> get_NHR_ST_QuantityActualPlansCtrl(String Name) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('ST_ManagementDashboard__c');
        soql += ' FROM ST_ManagementDashboard__c';
        soql += ' WHERE Name  = :Name';
        if(!Test.isRunningTest()){
            soql += '  AND OwnerId = \'' + UserInfo.getUserId() +'\' ';
        }
        soql += '  Order by orderBy__c';
        return Database.query(soql);
    }
    
    
    //**【スチール】経営ダッシュボード_作成用**
    public static String get_NHR_ST_OppSnapshotDashboardPreBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('ST_ManagementDashboard__c');
        soql += ' FROM ST_ManagementDashboard__c ';
        soql += ' WHERE ';
        soql += '  CreatedDate = THIS_FISCAL_YEAR  ';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】経営ダッシュボード_作成用**
    public static String get_NHR_ST_OppSnapshotDashboardBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Account.ST_focustype_kouji_im__c, ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity';
        soql += ' WHERE ';
        soql += '  transtionDateToPhaseJuchuST__c = THIS_FISCAL_YEAR  ';
        soql += '  AND RecordType.DeveloperName = \'RecordType_SteelCons\' ';
        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】経営ダッシュボード_作成用**
    public static String get_NHR_ST_OppSnapshotDashboardBatch2() {
        
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('ST_Opportunity_Snapshot__c');
        soql += ' FROM ST_Opportunity_Snapshot__c ';
        soql += ' WHERE ';
        soql += '  CreatedDate = THIS_FISCAL_YEAR  ';
        soql += '  AND ST_focustype_kouji_imInput__c = true ';

        system.debug('soql:' + soql);

        return soql;
    }
    
    //**【スチール】経営ダッシュボード_作成用**
    public static String get_NHR_ST_OppSnapshotDashboardBatch3() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('ST_Opportunity_Snapshot__c');
        soql += ' FROM ST_Opportunity_Snapshot__c ';
        soql += ' WHERE OppCreatedDate__c = THIS_FISCAL_YEAR  ';
        soql += ' OR ST_yosankumikomi__c = :ST_yosankumikomi  ';
         
        system.debug('soql:' + soql);

        return soql;
    }
    
    //**【スチール】経営ダッシュボード_作成用**
    public static String get_NHR_ST_OppSnapshotDashboardBatch4() {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('ST_Opportunity_Snapshot__c');
        soql += ' FROM ST_Opportunity_Snapshot__c ';
        soql += ' WHERE ';
        soql += '  CreatedDate = THIS_FISCAL_YEAR  ';
        //soql += '  AND ST_focustype_kouji__c not in (\'積極拡大\' ,\'重要な維持①\' ,\'重要な維持②\')  ';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【スチール】「月数分」計算用**
    public static String get_NHR_ST_SuryouSet(String OppId) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('Steel_delivery__c');
        soql += ' FROM Steel_delivery__c';
        soql += ' WHERE ';
        soql += '  Opp__c  = :OppId ';
        soql += '  AND RecordType.DeveloperName = \'Actual\' Limit 1';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**【CS】パーセプションマップ_作成用**
    public static String get_NHR_CS_PerceptualMappingBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' (Select id From EventRelations where Event.CS__c in (\'訪問\',\'WEB面談\') AND Event.RecordTypeId = \'0125h000000YEnMAAW\' Limit 3), ';
        soql += ' (Select id From genbatantousya__r Limit 2), ';//得意先担当者
        soql += ' (Select id From zyutyusakigenbatantousya__r Limit 2), ';//元請現場担当者
        soql += ' (Select id From zyouhouteikyousya__r Where zyutyusakigenbatantousya__c != NULL Limit 2), ';//情報提供者
        soql += ' (Select  '; 
        soql +=  createSelect('contact_schedule__c');
        soql += '  From coCS__r Where OrderBy__c > 0 Order by OrderBy__c), '; 
        soql += ' Account.CS_zyoutyukaryu__c,  ';
        soql +=  createSelect('Contact');
        soql += ' FROM Contact ';
        soql += ' WHERE ';
        soql += '  Account.CW_ManagementTarget__c = TRUE ';
        //soql += '  AND (CS_RBD_LastUpdDate__c < THIS_MONTH OR CS_RBD_LastUpdDate__c = NULL) ';
        soql += '  AND Account.CS_zyoutyukaryu__c in  (\'川上\',\'中流\',\'川下\')';

        system.debug('soql:' + soql);
        return soql;
    }
    
    //**住環境_カテゴリ別レポートの作成**
    public static String get_NHR_JU_CategoryReportBatch() {
        String soql = '';
        soql += ' SELECT ';
        soql += ' Account.ParentId , ';
        soql += ' (Select Id ,Category__c From OppotunityProposedProduct__r ) , ';
        soql +=  createSelect('Opportunity');
        soql += ' FROM Opportunity   ';
        soql += ' WHERE ';
        soql += '  RecordType.DeveloperName = \'Jukankyo\' ';
        
        system.debug('soql:' + soql);
        return soql;
    }

    //オブジェクトの全項目を取得するSELECT句を作成
    public static String createSelect(String objectName) {
        Schema.SObjectType sType = (Schema.SObjectType)Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult sObjectResult = sType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();

        String selectFields = '';
        for (Schema.SObjectField field : fieldMap.values()) {
            if (selectFields.length() > 0) {
                selectFields = selectFields + ', ';
            }
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            selectFields = selectFields + fieldResult.getName();
        }
        return selectFields + ' ';
    }

    //会計年度開始日
    public static Date getFiscalYearStartDate(Date inDate) {
        Date rec = Date.Today();
        if (inDate.month() > 6) {
            rec = Date.newInstance(inDate.year(), 7, 1);
        } else {
            rec = Date.newInstance(inDate.year() - 1, 7, 1);
        }

        return rec;
    }

    //会計年度開始日
    public static Date getFiscalYearEndDate(Date inDate) {
        Date rec = Date.Today();
        if (inDate.month() > 6) {
            rec = Date.newInstance(inDate.year() + 1, 6, 30);
        } else {
            rec = Date.newInstance(inDate.year() , 6, 30);
        }

        return rec;
    }
    
    //null check
    public static decimal getDecimal(decimal  inDecimal){
        decimal rec = 0;
        if (inDecimal != null) {
            rec = inDecimal;
        }
        return rec;
    }

    //割り算
    public static Decimal  getDivision(Decimal d1 ,Decimal d2) {
        Decimal rec = 0;
        if (d1 > 0) {
            rec = (d2 / d1) * 100;
        }
        return rec;
    }

    //会計年度(例：2023)
    public static String getYear(Date inDate) {
        String rec;
        if (inDate.month() > 6) {
            rec = String.valueOf(inDate.year());
        } else {
            rec = String.valueOf(inDate.year() - 1);
        }

        return rec;
    }

    //会計年度(例：12)
    public static String getFiscalYear(Date inDate) {
        String rec;
        // 会年度取得
        Map<String ,String> yearMap = new Map<String ,String>();
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }

        if (inDate.month() > 6) {
            rec = yearMap.get(String.valueOf(inDate.year()) );
        } else {
            rec = yearMap.get(String.valueOf(inDate.year() - 1) );
        }

        return rec;
    }

    //会計年度(例：2024年6月期)
    public static String getFiscalYearStr(Date inDate) {
        String rec;
        // 会年度取得
        Map<String ,String> yearMap = new Map<String ,String>();
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }

        if (inDate.month() > 6) {
            rec = String.valueOf(inDate.year() + 1) + '年6月期';
        } else {
            rec = String.valueOf(inDate.year() ) + '年6月期';
        }

        return rec;
    }

    //次の10会計年度
    public static List<String> getNext10FiscalYear(String thisFiscalYear) {
        List<String> rec = new List<String>();
        Integer thisFiscalYearNum = Integer.valueOf(thisFiscalYear);
        rec.add(thisFiscalYear);
        for(integer i = 1 ; i < 10 ; i++) {
            rec.add(String.valueOf(thisFiscalYearNum + i));
        }

        return rec;
    }

    //次の10会計年度
    public static User getUserInfo(String userId) {
        String soql = '';
        soql += ' SELECT ';
        soql +=  createSelect('User');
        soql += ' FROM User  ';
        soql += ' WHERE ';
        soql += '  ID in :userId';
        system.debug('userId:' + userId);
        //List<User> UserList = New List<User>();
        //UserList = Database.query(soql);

        return [Select ID ,Name,Username From User Where ID = :userId Limit 1];
    }
}