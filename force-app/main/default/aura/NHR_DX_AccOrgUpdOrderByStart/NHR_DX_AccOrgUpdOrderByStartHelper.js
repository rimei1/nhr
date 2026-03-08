({
	getNewOrg: function(component, event, helper) {
        var action = component.get("c.getNewOrgList");
        action.setParams({
            "inAccountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state == "SUCCESS"){
                toastEvent.setParams({
                    "title": '',
                    "message": "組織情報更新しました。",
                    "type":"success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else if (state == "ERROR") {
                this.showError(component,"組織情報更新失敗しました。システム管理者を連絡ください。");
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    updOrderBy: function(component, event, helper) {
        var action = component.get("c.setOrgOrderBy");
        action.setParams({
            "inAccountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state == "SUCCESS"){
                toastEvent.setParams({
                    "title": '',
                    "message": "並び順更新を実行しました。完了次第、メールで通知致します。",
                    "type":"success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else if (state == "ERROR") {
                this.showError(component,"並び順更新失敗しました。システム管理者を連絡ください。");
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
})