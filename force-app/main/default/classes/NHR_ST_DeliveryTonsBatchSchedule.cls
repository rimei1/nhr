global class NHR_ST_DeliveryTonsBatchSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      NHR_ST_DeliveryTonsBatch myBatchObject = new NHR_ST_DeliveryTonsBatch();
        Database.executeBatch(myBatchObject,200);
   }
}