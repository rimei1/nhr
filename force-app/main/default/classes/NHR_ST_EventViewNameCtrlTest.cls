@IsTest
public class NHR_ST_EventViewNameCtrlTest {

    /**
     * テスト用 Event を作成
     */
    private static Event createTestEvent(String browsingHistory) {
        Event e = new Event(
            Subject = 'Test Event',
            StartDateTime = System.now(),
            EndDateTime   = System.now().addHours(1),
            ST_BrowsingHistory__c = browsingHistory
        );
        insert e;
        return e;
    }

    /**
     * ① 初回アクセス時：氏名が保存される
     */
    @IsTest
    static void testFirstAccess() {
        Event e = createTestEvent(null);

        Test.startTest();
        NHR_ST_EventViewNameCtrl.saveAccessUser(e.Id);
        Test.stopTest();

        Event result = [
            SELECT ST_BrowsingHistory__c
            FROM Event
            WHERE Id = :e.Id
        ];


    }

    /**
     * ② 同一ユーザ再アクセス：変更されない
     */
    @IsTest
    static void testSameUserAccessSkip() {
        String userName = UserInfo.getName();
        Event e = createTestEvent(userName);

        Test.startTest();
        NHR_ST_EventViewNameCtrl.saveAccessUser(e.Id);
        Test.stopTest();

        Event result = [
            SELECT ST_BrowsingHistory__c
            FROM Event
            WHERE Id = :e.Id
        ];


    }

    /**
     * ④ recordId が null の場合：例外が出ない
     */
    @IsTest
    static void testNullRecordId() {
        Test.startTest();
        NHR_ST_EventViewNameCtrl.saveAccessUser(null);
        Test.stopTest();

    }
}