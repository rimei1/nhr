public class NHR_ST_EventSummaryCtrl{
    //入力変数用のクラスを作り、変数を入れる
    public class InputInfo{
        //単一変数&必須
        @InvocableVariable(required=true)
        public Date StartDate;

        //コレクション変数&任意
        @InvocableVariable(required=true)
        public Date EndDate;
    }
    
    @InvocableMethod(label='指定された範囲の商談Objに紐づく行動が、「前回からの活動」項目に紐づく')
    public static void NHR_ST_EventSummary(List<InputInfo> infos){
       Database.executeBatch(new NHR_ST_EventSummaryBatch(infos.get(0).StartDate , infos.get(0).EndDate));
    }
}