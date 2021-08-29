/**
 * ユーザ無効化処理
 */
global class DisableIrregularUserSchedule implements Schedulable {

    // 無効化対象ユーザID
    private Id userId;

    /**
     * コンストラクタ
     * @param userId 無効化対象のユーザID
     */
    public DisableIrregularUserSchedule(Id userId) {
        this.userId = userId;
    }
    
    global void execute(SchedulableContext ctx) {

        List<User> targetUserList = [SELECT Id, IsActive FROM User WHERE Id = :userId AND IsActive = true];

        // ユーザが見つからなかった場合、処理終了
        if(targetUserList.isEmpty()) {
            return;
        }

        // ユーザを無効化する
        User targetUser = targetUserList.get(0);
        targetUser.IsActive = false;
        update targetUser;
    }
}