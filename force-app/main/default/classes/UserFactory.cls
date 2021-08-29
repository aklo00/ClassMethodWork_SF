/**
 * テストユーザ生成用クラス
 */
public class UserFactory {
    /**
     * ユーザ新規作成処理
     * 
     * @param profileId 作成するユーザのプロファイルID
     * @param roleId 作成するユーザのロールID
     * @param userName ユーザ名
     * @return ユーザオブジェクト
     */
    public static User create(Id profileId, ID roleId, String userName) {

        String nowDateTime = Datetime.now().format('yyyyMMddHHmmss');

        return new User(
            UserName = userName + '-' + nowDateTime + '@exapmle.com.dev',
            Email = userName + '-' + nowDateTime + '@exapmle.com.dev',
            LastName = 'test',
            Alias = 'test',
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja',
            ProfileId = profileId,
            UserRoleId = roleId
        );
    }
}