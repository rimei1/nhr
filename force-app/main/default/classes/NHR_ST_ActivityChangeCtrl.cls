public class NHR_ST_ActivityChangeCtrl{
    @InvocableMethod(label='スチール_今週の活動・先週の活動・先々週の活動は週毎に自動変更')
    public static void NHR_ST_Start(){
        Database.executeBatch(new NHR_ST_ActivityChangeBatch(),20);
    }
}