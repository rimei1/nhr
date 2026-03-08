global class NHR_CS_PerceptualMappingBatchSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      NHR_CS_PerceptualMappingBatch myBatchObject = new NHR_CS_PerceptualMappingBatch();
        Database.executeBatch(myBatchObject,200);
   }
}