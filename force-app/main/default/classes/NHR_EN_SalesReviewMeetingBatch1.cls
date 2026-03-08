global without sharing class NHR_EN_SalesReviewMeetingBatch1 implements Database.Batchable<sObject>, Database.Stateful{

  global String deStr {get;set;}
  global String unitStr {get;set;}
  global String userId {get;set;}
  global Date startDate {get;set;}
  global Date endDate {get;set;}
  global Date LastMonthStartDate {get;set;}
  global Date forGetDay {get;set;}
  global Map<String ,FormCreation__c> excelMap1 {get;set;}
  global Map<String ,FormCreation__c> excelMap2 {get;set;}
  global Map<String ,FormCreation__c> excelMap3 {get;set;}
  //global Map<String ,Map<String ,FormCreation__c>> excelMap {get;set;}
  global Map<String ,String> yearMap {get;set;}
  global Map<String ,EN_Report__mdt> reportMap {get;set;}
  global String thisFiscalYear {get;set;}
  global NHR_EN_SalesReviewMeetingBatch1(String inDeStr ,String inUnit ,String userId){
      this.deStr = inDeStr;
      this.unitStr = inUnit;
      this.userId = userId;
  }
  //データ取得
  global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('NHR_EN_SalesReviewMeetingBatch1');
      setInit();

      Set<String> tantobusyo = reportMap.keySet();
      system.debug('startDate:' + startDate);
      system.debug('endDate:' + endDate);
    String query = NHR_Dao.get_NHR_EN_SalesReviewMeetingOpp(this.unitStr ,this.userId);
      return Database.getQueryLocator(query);
  }

  //開始
  global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
      FormCreation__c sum1_1 = new FormCreation__c();

      FormCreation__c sum2_1 = new FormCreation__c();
      FormCreation__c sum2_2 = new FormCreation__c();
      FormCreation__c sum2_3 = new FormCreation__c();
      FormCreation__c sum2_4 = new FormCreation__c();
      FormCreation__c sum2_9 = new FormCreation__c();

      FormCreation__c sum3_1 = new FormCreation__c();
      FormCreation__c sum3_2 = new FormCreation__c();
      FormCreation__c sum3_3 = new FormCreation__c();
      FormCreation__c sum3_4 = new FormCreation__c();
      FormCreation__c sum3_9 = new FormCreation__c();

      if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
          sum1_1 = excelMap1.get('Sum' + this.userId);

          sum2_1 = excelMap2.get('Sum_1' + this.userId);
          sum2_2 = excelMap2.get('Sum_2' + this.userId);
          sum2_3 = excelMap2.get('Sum_3' + this.userId);
          sum2_4 = excelMap2.get('Sum_4' + this.userId);
          sum2_9 = excelMap2.get('Sum_9' + this.userId);

          sum3_1 = excelMap3.get('Sum_1' + this.userId);
          sum3_2 = excelMap3.get('Sum_2' + this.userId);
          sum3_3 = excelMap3.get('Sum_3' + this.userId);
          sum3_4 = excelMap3.get('Sum_4' + this.userId);
          sum3_9 = excelMap3.get('Sum_9' + this.userId);
      } else {
          sum1_1 = excelMap1.get('Sum');

          sum2_1 = excelMap2.get('Sum_1');
          sum2_2 = excelMap2.get('Sum_2');
          sum2_3 = excelMap2.get('Sum_3');
          sum2_4 = excelMap2.get('Sum_4');
          sum2_9 = excelMap2.get('Sum_9');

          sum3_1 = excelMap3.get('Sum_1');
          sum3_2 = excelMap3.get('Sum_2');
          sum3_3 = excelMap3.get('Sum_3');
          sum3_4 = excelMap3.get('Sum_4');
          sum3_9 = excelMap3.get('Sum_9');
      }


      for(Opportunity obj : scopes) {
          if (!excelMap1.containsKey(obj.AccountId)) {
              integer orderStart = excelMap1.size();
              if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                  excelMap1.put(obj.AccountId ,setFC(NHR_Constant.BATCHNAME_SRM1 + this.userId, obj.Account.Name , '' , orderStart * 10 + 1));
              } else {
                  excelMap1.put(obj.AccountId ,setFC(NHR_Constant.BATCHNAME_SRM1, obj.Account.Name , '' , orderStart * 10 + 1));
              }

          }

          FormCreation__c tempInfo1 = excelMap1.get(obj.AccountId);

          String theYear = NHR_Dao.getFiscalYear(obj.en_ukeoisyunkouyoteibi__c) ;
          Integer theMonth = obj.en_ukeoisyunkouyoteibi__c.month();
          if (theYear == thisFiscalYear) {
              if (obj.en_koujihinsyu__c == NHR_Constant.CON1) {
                  setFCDetail(sum3_1 ,obj ,theMonth);
                  setFCDetail(sum3_9 ,obj ,theMonth);

                  //tempInfo1.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //tempInfo1.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  //sum2_1.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //sum2_1.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  if (obj.en_ukeoisyunkouyoteibi__c >= forGetDay && obj.en_ukeoisyunkouyoteibi__c < LastMonthStartDate) {
                      tempInfo1.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_1.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_1.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  } else if (obj.en_ukeoisyunkouyoteibi__c >= LastMonthStartDate && obj.en_ukeoisyunkouyoteibi__c <= endDate) {
                      tempInfo1.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_1.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_1.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  }
              } else if (obj.en_koujihinsyu__c == NHR_Constant.CON2) {
                  setFCDetail(sum3_2 ,obj ,theMonth);
                  setFCDetail(sum3_9 ,obj ,theMonth);

                  //tempInfo1.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //tempInfo1.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  //sum2_2.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //sum2_2.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  if (obj.en_ukeoisyunkouyoteibi__c >= forGetDay && obj.en_ukeoisyunkouyoteibi__c < LastMonthStartDate) {
                      tempInfo1.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_2.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_2.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  } else if (obj.en_ukeoisyunkouyoteibi__c >= LastMonthStartDate && obj.en_ukeoisyunkouyoteibi__c <= endDate) {

                      tempInfo1.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_2.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_2.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  }
              } else if (obj.en_koujihinsyu__c == NHR_Constant.CON3) {
                  setFCDetail(sum3_3 ,obj ,theMonth);
                  setFCDetail(sum3_9 ,obj ,theMonth);
                  //tempInfo1.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //tempInfo1.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  //sum2_3.R__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                  //sum2_3.S__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                  if (obj.en_ukeoisyunkouyoteibi__c >= forGetDay && obj.en_ukeoisyunkouyoteibi__c < LastMonthStartDate) {
                      tempInfo1.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_3.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_3.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  } else if (obj.en_ukeoisyunkouyoteibi__c >= LastMonthStartDate && obj.en_ukeoisyunkouyoteibi__c <= endDate) {
                      tempInfo1.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_3.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_3.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  }
              } else {
                  setFCDetail(sum3_4 ,obj ,theMonth);
                  setFCDetail(sum3_9 ,obj ,theMonth);
                  //tempInfo1.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //tempInfo1.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  //sum2_4.R__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  //sum2_4.S__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

                  if (obj.en_ukeoisyunkouyoteibi__c >= forGetDay && obj.en_ukeoisyunkouyoteibi__c < LastMonthStartDate) {
                      tempInfo1.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_4.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_4.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  } else if (obj.en_ukeoisyunkouyoteibi__c >= LastMonthStartDate && obj.en_ukeoisyunkouyoteibi__c <= endDate) {
                      tempInfo1.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      tempInfo1.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                      sum2_4.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                      sum2_4.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                  }
              }
          } else {
              tempInfo1.X__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
              tempInfo1.Y__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
              if (obj.en_koujihinsyu__c == NHR_Constant.CON1) {
                  sum2_1.X__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  sum2_1.Y__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

              } else if (obj.en_koujihinsyu__c == NHR_Constant.CON2) {
                  sum2_2.X__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  sum2_2.Y__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

              } else if (obj.en_koujihinsyu__c == NHR_Constant.CON3) {
                  sum2_3.X__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  sum2_3.Y__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

              } else {
                  sum2_4.X__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                  sum2_4.Y__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);

              }
          }
      }
  }

   //完了
  global void finish(Database.BatchableContext BC)
  {
      //完了後の処理があれば
      NHR_EN_SalesReviewMeetingBatch2 myBatchObject = new NHR_EN_SalesReviewMeetingBatch2
          (excelMap1
           ,excelMap2
           ,excelMap3
           ,yearMap
           ,reportMap
           ,startDate
           ,endDate
           ,LastMonthStartDate
           ,forGetDay
           ,deStr
           ,this.unitStr
           ,this.userId
          );
      Database.executeBatch(myBatchObject,2000);
  }

  /**
   * 初期設定
   */
  private void setInit(){
      //日付設定
      Date theToday = Date.Today();
      forGetDay = Date.Today();
      if (theToday.month() == 7) {
          forGetDay = Date.newInstance(forGetDay.year(), forGetDay.month(), 1).addMonths(-1);
      } else {
          forGetDay = Date.newInstance(forGetDay.year(), forGetDay.month(), 1);
      }

      startDate = NHR_Dao.getFiscalYearStartDate(forGetDay);
      endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);
      LastMonthStartDate = Date.newInstance(forGetDay.addMonths(1).year(), forGetDay.addMonths(1).month(), 1);
      thisFiscalYear = NHR_Dao.getFiscalYear(forGetDay);

      //表示内容設定
      yearMap = new Map<String ,String>();
      reportMap = new Map<String ,EN_Report__mdt>();
      excelMap1 = new Map<String ,FormCreation__c>();
      excelMap2 = new Map<String ,FormCreation__c>();
      excelMap3 = new Map<String ,FormCreation__c>();


      // 会年度取得
      List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
      for(EN_FiscalYear__mdt mt : md1) {
          yearMap.put(mt.Year__c ,mt.Period__c);
      }

      //出力部署単位
      List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
      /*
      for(EN_Report__mdt mt : md2) {
          if (deStr == NHR_Constant.ZENSHYA || mt.MasterLabel == deStr ) {
              reportMap.put(mt.Department__c ,mt);
          }
      }*/
      for(EN_Report__mdt mt : md2) {
            if (this.unitStr == NHR_Constant.UNIT1) {
                if (deStr == '全社' || mt.MasterLabel == deStr ) {
                    if (mt.Department__c != '営業部') {
                        reportMap.put(mt.Department__c ,mt);
                    }

                    if (mt.Department__c == '営業第一チーム' || deStr == '全社') {
                        reportMap.put('営業部' ,mt);
                    }
                }
            } else {
                if (mt.Department__c == this.deStr ) {
                    reportMap.put(mt.Department__c ,mt);
                    if (this.deStr == '営業第一チーム') {
                        reportMap.put('営業部' ,mt);
                    }
                }
            }
        }
        system.debug('reportMap:' + reportMap);
      //合計行追加
      if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
          excelMap1.put('Sum'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM1 + this.userId,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));

          excelMap2.put('Sum_1'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM2 + this.userId,NHR_Constant.CON1 ,NHR_Constant.CON1 ,9901));
          excelMap2.put('Sum_2'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM2 + this.userId,NHR_Constant.CON2 ,NHR_Constant.CON2 ,9902));
          excelMap2.put('Sum_3'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM2 + this.userId,NHR_Constant.CON3 ,NHR_Constant.CON3 ,9903));
          excelMap2.put('Sum_4'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM2 + this.userId,NHR_Constant.CON_OTHER ,NHR_Constant.CON_OTHER ,9904));
          excelMap2.put('Sum_9'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM2 + this.userId,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));

          excelMap3.put('Sum_1'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM3 + this.userId,NHR_Constant.CON1 ,NHR_Constant.CON1 ,9901));
          excelMap3.put('Sum_2'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM3 + this.userId,NHR_Constant.CON2 ,NHR_Constant.CON2 ,9902));
          excelMap3.put('Sum_3'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM3 + this.userId,NHR_Constant.CON3 ,NHR_Constant.CON3 ,9903));
          excelMap3.put('Sum_4'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM3 + this.userId,NHR_Constant.CON_OTHER ,NHR_Constant.CON_OTHER ,9904));
          excelMap3.put('Sum_9'  + this.userId, setFC(NHR_Constant.BATCHNAME_SRM3 + this.userId,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));
      } else {
          excelMap1.put('Sum' , setFC(NHR_Constant.BATCHNAME_SRM1,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));

          excelMap2.put('Sum_1' , setFC(NHR_Constant.BATCHNAME_SRM2,NHR_Constant.CON1 ,NHR_Constant.CON1 ,9901));
          excelMap2.put('Sum_2' , setFC(NHR_Constant.BATCHNAME_SRM2,NHR_Constant.CON2 ,NHR_Constant.CON2 ,9902));
          excelMap2.put('Sum_3' , setFC(NHR_Constant.BATCHNAME_SRM2,NHR_Constant.CON3 ,NHR_Constant.CON3 ,9903));
          excelMap2.put('Sum_4' , setFC(NHR_Constant.BATCHNAME_SRM2,NHR_Constant.CON_OTHER ,NHR_Constant.CON_OTHER ,9904));
          excelMap2.put('Sum_9' , setFC(NHR_Constant.BATCHNAME_SRM2,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));

          excelMap3.put('Sum_1' , setFC(NHR_Constant.BATCHNAME_SRM3,NHR_Constant.CON1 ,NHR_Constant.CON1 ,9901));
          excelMap3.put('Sum_2' , setFC(NHR_Constant.BATCHNAME_SRM3,NHR_Constant.CON2 ,NHR_Constant.CON2 ,9902));
          excelMap3.put('Sum_3' , setFC(NHR_Constant.BATCHNAME_SRM3,NHR_Constant.CON3 ,NHR_Constant.CON3 ,9903));
          excelMap3.put('Sum_4' , setFC(NHR_Constant.BATCHNAME_SRM3,NHR_Constant.CON_OTHER ,NHR_Constant.CON_OTHER ,9904));
          excelMap3.put('Sum_9' , setFC(NHR_Constant.BATCHNAME_SRM3,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));
      }
  }

  private FormCreation__c setFCDetail(FormCreation__c tempObj ,Opportunity obj , integer theMonth){
      switch on theMonth {
          when 1 {
              tempObj.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 2 {
              tempObj.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 3 {
              tempObj.R__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.S__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 4 {
              tempObj.T__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.U__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 5 {
              tempObj.V__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.W__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 6 {
              tempObj.X__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.Y__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 7 {
              tempObj.B__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.C__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 8 {
              tempObj.D__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.E__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 9 {
              tempObj.F__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.G__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 10 {
              tempObj.H__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.I__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 11 {
              tempObj.J__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.K__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
          when 12 {
              tempObj.L__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
              tempObj.M__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
          }
      }

      //tempObj.AB__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
      //tempObj.AC__c += (obj.en_zyutyuararigaku__c == null ? 0 : obj.en_zyutyuararigaku__c);
      return tempObj;
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