@IsTest
public class DisableIrregularUserScheduleTest {

    /**
     * execute()
     * 成功時
     */
    @IsTest static void execute_success() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        insert testUser;

        Test.startTest();
        String jobID = system.schedule('DisableIrregularUserSchedule_Test', '0 0 * * * ?', new DisableIrregularUserSchedule(testUser.Id));
        Test.stopTest();
        
        User resultUser = [SELECT Id, IsActive FROM User WHERE Id = :testUser.Id LIMIT 1];
        System.assertEquals(false, resultUser.IsActive);
    }

    /**
     * execute()
     * 対象ユーザが見つからない場合
     */
    @IsTest static void execute_noUser() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        insert testUser;

        Test.startTest();
        String jobID = system.schedule('DisableIrregularUserSchedule_Test', '0 0 * * * ?', new DisableIrregularUserSchedule(null));
        Test.stopTest();
        
        User resultUser = [SELECT Id, IsActive FROM User WHERE Id = :testUser.Id LIMIT 1];
        System.assertEquals(true, resultUser.IsActive);
    }
}