@isTest
public without sharing class NHR_TestDataFactory {
    //取引先
    static List<Account> accs;
    public static List<Account> getAccount(){
        return accs;
    }

    //取引先担当者
    static List<Contact> cons;
    public static List<Contact> getContact(){
        return cons;
    }

     //商談
    static List<Opportunity> opps;
    public static List<Opportunity> getOpportunity(){
        return opps;
    }

    //EN予実管理
    static List<en_yojitsu__c > eys;
    public static List<en_yojitsu__c > getEn_yojitsu(){
        return eys;
    }

    //Excel出力用
    static List<FormCreation__c > cfcs;
    public static List<FormCreation__c > getFormCreation(){
        return cfcs;
    }
    
    //納入商品
    static List<Asset > asss;
    public static List<Asset> getAsset(){
        return asss;
    }
    
    //納品トン数
    static List<Steel_delivery__c> sds;
    public static List<Steel_delivery__c> getsds(){
        return sds;
    }
    
    //商談_スナップショット_ST 
    static List<ST_Opportunity_Snapshot__c> sos;
    public static List<ST_Opportunity_Snapshot__c> getsos(){
        return sos;
    }
    
    //組織管理
    static List<OrgManagement__c> org;
    public static List<OrgManagement__c> getOrg(){
        return org;
    }


    public static void createAllMstData() {
        // テスト用のユーザを作成
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name='システム管理者'
        ];
        User u = new User(
            Alias = 'standt',
            Email='testing_ri_nhr@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing_ri_nhr',
            LanguageLocaleKey='ja',
            LocaleSidKey='ja_JP',
            ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo',
            Department = '大阪営業部',
            UserName='testing_ri_nhr@testorg.com'
        );

        System.runAs(u) {
            //取引先
            accs = createAccount();

            //取引先担当者
            cons = createContact(accs);

            opps = createOpportunity(accs);

            eys = createEn_yojitsu(accs ,opps);

            cfcs = createFormCreation();
            
            asss = createAsset(accs[0],cons[0]);
            
            org = createOrg(accs[0]);
            
            sds = createSd();
            
            sos = createSos(accs);
        }
    }

    //取引先
    public static List<Account> createAccount() {
        // 共通取引先のレコードタイプを取得
        String recordtype_Com = 'CommonRecordType';
        String ComAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordtype_Com).getRecordTypeId();

        List<Account> insList = new List<Account>();
        insList.add(new Account(Name = '共通テスト' , RecordTypeId = ComAccRecTypeId ,ST_focustype_kouji__c = '積極拡大', CW_ManagementTarget__c=true));
        insList.add(new Account(Name = '共通テスト2' , RecordTypeId = ComAccRecTypeId ,ST_focustype_kouji__c = '積極'));
        insList.add(new Account(Name = '営繕工事_テスト' , RecordTypeId = ComAccRecTypeId ,ST_focustype_kouji__c = '積極'));
        insList.add(new Account(Name = '材料販売_テスト' , RecordTypeId = ComAccRecTypeId ,ST_focustype_kouji__c = '積極拡大'));

        insert insList;
        return insList;
    }

    //取引先責任者
    public static List<Contact> createContact(List<Account> accounts) {
        List<Contact> insList = new List<Contact>();
        insList.add(new Contact(LastName = '担当者1' , AccountId = accounts[0].Id,Department  = '部署1' , CW_ManagementTarget__c=true));
        insList.add(new Contact(LastName = '担当者2' , AccountId = accounts[0].Id,Department  = '部署1'));

        
        insert insList;
        
        contact_schedule__c csObj = new contact_schedule__c(contactCS__c =insList[0].Id , targetYear__c = Date.Today());
        insert csObj;
        return insList;
        
        
    }

    //商談
    public static List<Opportunity> createOpportunity(List<Account> accounts) {
        // 共通取引先のレコードタイプを取得
        String recordtype_Com = 'en_zenekonsh';
        String ComAccRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordtype_Com).getRecordTypeId();
        String JURecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('JU_sakzusekisanbpotaisyou').getRecordTypeId();
        String StId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_SteelCons').getRecordTypeId();
        String StGoalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steelzairyou_goal').getRecordTypeId();
        String StId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steel_kakou').getRecordTypeId();


        List<Opportunity> insList = new List<Opportunity>();
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today() ,AccountId = accounts[2].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today() ,AccountId = accounts[3].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today().addMonths(-1) ,AccountId = accounts[2].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today().addMonths(-1) ,AccountId = accounts[3].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today().addMonths(-2) ,AccountId = accounts[2].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1 ,en_zyutyuubi__c = Date.Today().addMonths(-2) ,AccountId = accounts[3].Id
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(-1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(-1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today(),EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today()));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON2
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(2)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON3
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(3)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(4)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON2
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(5)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON3
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(6)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(7)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(8)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(9)));

        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON1
                                    ,en_zyutyuukakudo__c = 'Aランク',en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(2)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON2
                                    ,en_zyutyuukakudo__c = 'Bランク',en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(2)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '13',Department__c='大阪営業部'
                                    ,en_koujihinsyu__c = NHR_Constant.CON3
                                    ,en_zyutyuukakudo__c = 'Cランク',en_ukeoisyunkouyoteibi__c = Date.Today().addMonths(2)));

                insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '14',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = '受注' ,en_ukeoisyunkouyoteibi__c = Date.Today().addYears(1)));

        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '14',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = 'Aランク',en_ukeoisyunkouyoteibi__c = Date.Today().addYears(1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '14',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = 'Bランク',en_ukeoisyunkouyoteibi__c = Date.Today().addYears(1)));
        insList.add(new Opportunity(Name = '共通商談' , RecordTypeId = ComAccRecTypeId,StageName = '受注' ,en_ankenkubun__c = '本工事'
                                    ,CloseDate =  Date.Today().addMonths(1) ,EN_kanseiki__c = '14',Department__c='大阪営業部'
                                    ,en_zyutyuukakudo__c = 'Cランク',en_ukeoisyunkouyoteibi__c = Date.Today().addYears(1)));
        
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '未着手' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '活動開始' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '初回訪問' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = 'KMプレゼン完了' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = 'Phase1導入' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '最終提案完了' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '検討保留' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '提案停止' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '採用（受注）' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '在阪切替' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(1)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(2)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 60 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(3)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 300 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(4)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 800 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(5)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 1700 ));
        
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '受注ST' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(6)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '受注ST' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(7)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 60 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '受注ST' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(8)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 300 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '受注ST' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(9)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 800 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '受注ST' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(10)
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 1700 ));
        
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '仕掛' 
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '仕掛' 
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 60 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '仕掛' 
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 300 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '仕掛' 
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 800 ));
        insList.add(new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = '仕掛' 
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 1700 ));
        
        insList.add(new Opportunity(Name = 'ST商談2' , RecordTypeId = StId2,StageName = '仕掛' ,ST_DeliveryMonth__c = Date.Today()
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 1700 ));
        
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[0].Id
                                    ,CloseDate =  Date.Today().addMonths(-1) , ST_Orderquantitytarget__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[0].Id
                                    ,CloseDate =  Date.Today() , ST_Orderquantitytarget__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[0].Id
                                    ,CloseDate =  Date.Today().addMonths(1) , ST_Orderquantitytarget__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[0].Id
                                    ,CloseDate =  Date.Today().addMonths(2) , ST_Orderquantitytarget__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[1].Id
                                    ,CloseDate =  Date.Today().addMonths(3) , ST_Orderquantitytarget__c = 10 ));
        insList.add(new Opportunity(Name = 'ST商談目標' , RecordTypeId = StGoalId,StageName = '受注' ,AccountId = accounts[1].Id
                                    ,CloseDate =  Date.Today().addMonths(4) , ST_Orderquantitytarget__c = 10 ));
        insert insList;
        return insList;
    }

    //EN予実管理
    public static List<en_yojitsu__c> createEn_yojitsu(List<Account> accounts ,List<Opportunity> opps) {
        // 共通取引先のレコードタイプを取得
        String recordtype_Com1 = 'en_yosan1';
        String recordtype_Com2 = 'en_jissekin';
        String ComAccRecTypeId1 = Schema.SObjectType.en_yojitsu__c.getRecordTypeInfosByDeveloperName().get(recordtype_Com1).getRecordTypeId();
        String ComAccRecTypeId2 = Schema.SObjectType.en_yojitsu__c.getRecordTypeInfosByDeveloperName().get(recordtype_Com2).getRecordTypeId();

        List<en_yojitsu__c> insList = new List<en_yojitsu__c>();
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addMonths(-1) ,' 予算',accounts ,opps) );
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today() ,' 予算',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addMonths(1) ,' 予算',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(-1) ,' 予算',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(1) ,' 予算',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(2) ,' 予算',accounts ,opps));

        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addMonths(-1) ,' 実績',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today() ,' 実績',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addMonths(1)  ,' 実績',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(-1)  ,' 実績',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(1)  ,' 実績',accounts ,opps));
        insList.add(setEn_yojitsu(ComAccRecTypeId1 ,Date.Today().addYears(2)  ,' 実績',accounts ,opps));

        insert insList;
        return insList;
    }

     //EN予実管理
    public static en_yojitsu__c setEn_yojitsu(String recordTypeId , Date inDate , String yojitu ,List<Account> accounts ,List<Opportunity> opps) {
        en_yojitsu__c obj = new en_yojitsu__c();
        obj.en_uriagekingaku__c = 0;
        obj.En_uriara__c =  0;
        obj.en_juchu12__c =  0;
        obj.en_jutyuarari__c =  0;
        obj.EN_mokuhyouuriagekingaku__c =  0;
        obj.EN_mokuhyouuriageararikingaku__c =  0;
        obj.en_kousyuy12__c =  0;
        obj.EN_yosan_arari__c =  0;
        obj.Yeaemonth__c = inDate;
        obj.en_yojitu2__c = yojitu ;
        obj.recordTypeId = recordTypeId;
         obj.en_shodans__c = opps[0].id;
         obj.en_tokuisaki_s__c = accounts[0].id;
        obj.en_tantobusyo1__c = '大阪営業部';
        obj.en_ankenkubun_yozitsu__c = '本工事';
        if (Date.Today().month() < 7) {
             obj.EN_kanseiki__c = String.valueOf(Date.Today().Year() -2024 + 12);
        } else {
            obj.EN_kanseiki__c = String.valueOf(Date.Today().Year() -2024 + 12 + 1);
        }
       
        return obj;
    }

    //EN予実管理
    public static List<FormCreation__c> createFormCreation() {
        List<FormCreation__c> insList = new List<FormCreation__c>();
        insList.add(new FormCreation__c(Name = 'Sales1_1' , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = 'Sales1_2' , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = 'Sales2' , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = 'Sales3' , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = 'Sales4' , OrderBy__c = 1));

        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_AOT , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_AST , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_CO , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_COO , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_SRM1 , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_SRM2 , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_SRM3 , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_OAL , OrderBy__c = 1));
        insList.add(new FormCreation__c(Name = NHR_Constant.BATCHNAME_OAL , OrderBy__c = 2));

        insert insList;
        return insList;
    }


    //納入商品
    public static List<Asset> createAsset(Account acc ,contact con) {
        // レコードタイプを取得
        String Ach = 'Achievements';
        String AchRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Ach).getRecordTypeId();
        String Tar = 'Target';
        String TarRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Tar).getRecordTypeId();

        List<Asset> insList = new List<Asset>();
        insList.add(new Asset(Name = '納入商品1' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Pro3AK',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(1), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Pro2',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(2), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品3' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Pro2備品',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(3), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品4' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(4), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品5' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'SaaS',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(5), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品6' , RecordTypeId = AchRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'SaaS',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(6) ,keiyakukoushinbi__c = Date.today().addYears(1), AccountId= acc.id ,ContactId =con.id));

        insList.add(new Asset(Name = '納入商品2_1' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Pro3AK',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(1), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_2' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                             ProductFamily__c = 'Pro2',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(2), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_3' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(3), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_4' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(4), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_5' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(5), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_6' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(6), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_7' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(7), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_8' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(8), AccountId= acc.id ,ContactId =con.id));
        insList.add(new Asset(Name = '納入商品2_9' , RecordTypeId = TarRecTypeId , AdoptionAmount__c = 10000,Cost__c=6000,Price  = 10000,
                              ProductFamily__c = 'Axis',syokaikeiyakubi__c = Date.today(), syukkabi__c = Date.today().addMonths(9), AccountId= acc.id ,ContactId =con.id));
        insert insList;
        return insList;
    }
    
    //取引先
    public static List<OrgManagement__c > createOrg(Account acc) {
        List<OrgManagement__c> insList = new List<OrgManagement__c>();
        insList.add(new OrgManagement__c(Account__c = acc.id, Department__c  = '部署1',OrderBy__c =1));

        insert insList;
        return insList;
    }
    
    //納品トン数
    public static List<Steel_delivery__c > createSd() {
        List<Steel_delivery__c> insList = new List<Steel_delivery__c>();
        List<Opportunity> oppObj = [ Select Id From Opportunity
        WHERE RecordType.DeveloperName = 'RecordType_SteelCons' Limit 1];
        
        List<Opportunity> oppObj2 = [ Select Id From Opportunity
        WHERE RecordType.DeveloperName = 'RecordType_Steel_kakou' Limit 1];
        
        insList.add(New Steel_delivery__c(Opp__c = oppObj[0].Id));
        insList.add(New Steel_delivery__c(Opp__c = oppObj2[0].Id));
        
        
        insert insList;
        return insList;
    }


    //商談_スナップショット_ST
    public static List<ST_Opportunity_Snapshot__c> createSos(List<Account> accounts ) {

        List<ST_Opportunity_Snapshot__c> insList = new List<ST_Opportunity_Snapshot__c>();
        insList.add(new ST_Opportunity_Snapshot__c(AccountId__c = accounts[0].id, Department__c  = '事業1部' ,StageName__c = 'A',ST_focustype_kouji__c = '積極拡大' , ST_yosankumikomi__c = '2025年6月期'));
        insList.add(new ST_Opportunity_Snapshot__c(AccountId__c = accounts[0].id, Department__c  = '事業2部',StageName__c = 'C',ST_focustype_kouji__c = '積極拡大' , ST_yosankumikomi__c = '2025年6月期'));
        insList.add(new ST_Opportunity_Snapshot__c(AccountId__c = accounts[1].id, Department__c  = '事業1部',StageName__c = 'E',ST_focustype_kouji__c = '積極' , ST_yosankumikomi__c = '2025年6月期'));
        insList.add(new ST_Opportunity_Snapshot__c(AccountId__c = accounts[1].id, Department__c  = '事業2部',StageName__c = 'G',ST_focustype_kouji__c = '積極' , ST_yosankumikomi__c = '2025年6月期'));

        insert insList;
        return insList;
    }

}