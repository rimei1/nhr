public class NHR_CS_PerceptualMappingCtrl{
    @InvocableMethod(label='CS_関係構築度自動UpDown')
    public static void NHR_CS_PerceptualMapping(){
        NHR_CS_PerceptualMappingBatch myBatchObject = new NHR_CS_PerceptualMappingBatch();
        Database.executeBatch(myBatchObject,200);
    }
}