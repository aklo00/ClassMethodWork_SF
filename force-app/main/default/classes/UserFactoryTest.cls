@IsTest
public class UserFactoryTest {
    /**
     * create()
     * 成功時
     */
    @IsTest static void create_success() {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        User testUser = UserFactory.create(prof.Id, null, 'testUser1');
        insert testUser;

        User resultUser = [SELECT Id, ProfileId FROM User WHERE Id = :testUser.Id LIMIT 1];
        System.assertEquals(prof.Id, resultUser.ProfileId);
    }
}