public without sharing class UserTriggerHandler extends TriggerHandler {

    /**
     * ユーザ更新後処理
     * 
     * @param oldMap 更新前ユーザMap
     * @param newMap 更新後ユーザMap
     */
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {

        // ユーザ無効化スケジューラをスケジュール
        scheduleDisableUserSchedule(oldMap, newMap);
    }

    /**
     * 「非定期ログインユーザの有効時間」項目更新時、
     * ユーザを無効化するスケジューラを実行する
     * 
     * @param oldMap 更新前ユーザMap
     * @param newMap 更新後ユーザMap
     */
    private void scheduleDisableUserSchedule(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        
        Map<String, User> targetMap = new Map<String, User>();
        for(Id key : newMap.keySet()) {
            User oldUser = (User)oldMap.get(key);
            User newUser = (User)newMap.get(key);

            // 無効化されているユーザの場合、無効化処理の対象外とする
            if(!newUser.IsActive) {
                continue;
            }
            
            // 非定期ログインユーザの有効時間更新時
            if (newUser.ValidTimeForIrregularUser__c != null &&
                oldUser.ValidTimeForIrregularUser__c != newUser.ValidTimeForIrregularUser__c) {

                String jobName = 'DisableIrregularUserSchedule_' + newUser.Id;

                targetMap.put(jobName, newUser);
            }
        }

        // 無効化対象が100件以上の場合、ガバナ制限回避のため処理スキップ
        if (targetMap.size() >=100) {
            System.debug(targetMap);
            return;
        }

        // ジョブが実行中に期限を更新した場合に対応するため
        // 既に実行中・実行済みのジョブがある場合、削除する
        List<CronTrigger> scheduledJobList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :targetMap.keySet()];
        for (CronTrigger scheduledJob : scheduledJobList) {
            System.abortJob(scheduledJob.Id);
        }

        for (String jobName : targetMap.keySet()) {
            User targetUser = (User)targetMap.get(jobName);

            // 非定期ユーザの有効時間
            Integer availableTime;
            try {
                availableTime = Integer.valueOf(targetUser.ValidTimeForIrregularUser__c);
            } catch(System.TypeException ex) {
                // 数字以外で更新した場合、処理終了
                System.debug(ex.getMessage());
                targetUser.addError('「非定期ログインユーザの有効時間」項目には数字のみ入力してください。');
                return;
            }
            
            // ユーザを無効化する時間を設定
            Datetime disableDateTime = datetime.now().addMinutes(availableTime);
            String sch = disableDateTime.format('s m H d M ? yyyy');

            // ユーザ無効化処理を有効期限後に実施するようスケジュール
            String jobID = system.schedule(jobName, sch, new DisableIrregularUserSchedule(targetUser.Id));
        }
    }
}