@IsTest
public class UserTriggerHandlerTest {

    /**
     * afterUpdate()
     * 「非定期ログインユーザの有効時間」更新時、
     * スケジューラが起動することを確認する
     */
    @IsTest static void afterUpdate_schedule() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        insert testUser;

        Test.startTest();
        //「 非定期ログインユーザの有効時間」更新
        testUser.ValidTimeForIrregularUser__c = '2';
        update testUser;
        Test.stopTest();

        String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        
        // スケジューラが起動していることを確認
        System.assertEquals(1, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * 「非定期ログインユーザの有効時間」更新のユーザが無効の場合、
     * スケジューラが動かないことを確認する
     */
    @IsTest static void afterUpdate_notschedule_user_is_notActive() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        // 無効のユーザを作成
        testUser.IsActive = false;
        insert testUser;

        Test.startTest();
        //「 非定期ログインユーザの有効時間」更新
        testUser.ValidTimeForIrregularUser__c = '2';
        update testUser;
        Test.stopTest();

        String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        
        // スケジューラが起動していないことを確認
        System.assertEquals(0, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * 「非定期ログインユーザの有効時間」をnullに更新した場合、
     * スケジューラが動かないことを確認する
     */
    @IsTest static void afterUpdate_notschedule_update_null() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        testUser.ValidTimeForIrregularUser__c = '2';
        insert testUser;

        Test.startTest();
        //「 非定期ログインユーザの有効時間」をnullに更新
        testUser.ValidTimeForIrregularUser__c = null;
        update testUser;
        Test.stopTest();

        String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        
        // スケジューラが起動していないことを確認
        System.assertEquals(0, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * 「非定期ログインユーザの有効時間」を同じ値に更新した場合、
     * スケジューラが動かないことを確認する
     */
    @IsTest static void afterUpdate_notschedule_update_sameValue() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        testUser.ValidTimeForIrregularUser__c = '2';
        insert testUser;

        Test.startTest();
        //「 非定期ログインユーザの有効時間」を同じ値に更新
        testUser.ValidTimeForIrregularUser__c = '2';
        update testUser;
        Test.stopTest();

        String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        
        // スケジューラが起動していないことを確認
        System.assertEquals(0, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * 99ユーザを同時に更新した場合
     * スケジューラが動くことを確認する
     */
    @IsTest static void afterUpdate_schedule_update_99User() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];

        List<User> testUserList = new List<User>();

        // 99回繰り返す
        for (Integer i = 0; i < 99; i++) {
            User testUser = UserFactory.create(prof.Id, null, 'testUser' + i);
            testUser.IsActive = true;
            testUserList.add(testUser);
        }
        insert testUserList;

        // 99ユーザ登録したことを確認
        System.assertEquals(99, testUserList.size());

        Test.startTest();

        for (User testUser : testUserList) {
            testUser.ValidTimeForIrregularUser__c = '2';
        }
        // 99ユーザ同時更新
        update testUserList;
        Test.stopTest();

        List<String> jobNameList = new List<String>();
        for (User testUser : testUserList) {
            String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
            jobNameList.add(jobName);
        }
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :jobNameList];
        
        // スケジューラが起動していることを確認
        System.assertEquals(99, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * 100ユーザを同時に更新した場合
     * スケジューラが動かないことを確認する
     */
    @IsTest static void afterUpdate_notschedule_update_100User() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];

        List<User> testUserList = new List<User>();

        // 100回繰り返す
        for (Integer i = 0; i < 100; i++) {
            User testUser = UserFactory.create(prof.Id, null, 'testUser' + i);
            testUser.IsActive = true;
            testUserList.add(testUser);
        }
        insert testUserList;

        // 100ユーザ登録したことを確認
        System.assertEquals(100, testUserList.size());

        Test.startTest();

        for (User testUser : testUserList) {
            testUser.ValidTimeForIrregularUser__c = '2';
        }
        // 100ユーザ同時更新
        update testUserList;
        Test.stopTest();

        List<String> jobNameList = new List<String>();
        for (User testUser : testUserList) {
            String jobName = 'DisableIrregularUserSchedule_' + testUser.Id;
            jobNameList.add(jobName);
        }
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :jobNameList];
        
        // スケジューラが起動していないことを確認
        System.assertEquals(0, scheduledJobList.size());
    }

    /**
     * afterUpdate()
     * スケジューラの実行完了前に「非定期ログインユーザの有効時間」項目を更新した場合
     * エラーが発生しないことを確認する
     */
    @IsTest static void afterUpdate_notschedule_update_twice() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        insert testUser;

        Test.startTest();
        testUser.ValidTimeForIrregularUser__c = '10';
        update testUser;

        try {
            //「 非定期ログインユーザの有効時間」をもう一度更新
            testUser.ValidTimeForIrregularUser__c = '4';
            update testUser;
            // エラー発生しなければテスト成功
            System.assert(true);
        } catch(Exception ex) {
            System.assert(false);
        }
        Test.stopTest();
    }

    /**
     * afterUpdate()
     * 「 非定期ログインユーザの有効時間」を文字列に更新した場合、
     * エラーが発生することを確認する
     */
    @IsTest static void afterUpdate_notschedule_field_notNumber() {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        testUser.IsActive = true;
        insert testUser;

        Test.startTest();
        //「 非定期ログインユーザの有効時間」を文字列で更新
        testUser.ValidTimeForIrregularUser__c = 'aa';
        try {
            update testUser;
            // エラー発生しなければテスト失敗
            System.assert(false);
        } catch(DmlException ex) {
            System.debug(ex.getMessage());
            System.assertEquals(true, ex.getMessage().contains('「非定期ログインユーザの有効時間」項目には数字のみ入力してください。'));
        }
        Test.stopTest();
    }
}