({
	Sales: function(component, event, helper ,inTargetStr  , inUnit) {
        var action = component.get("c.Call_EN_SalesReportStart");
        action.setParams({
            "targetStr": inTargetStr,
            "inUnit" : inUnit
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state == "SUCCESS"){
                toastEvent.setParams({
                    "title": '',
                    "message": "Excel作成しています。完了したらメールで通知します。",
                    "type":"success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else if (state == "ERROR") {
                this.showError(component,"Excel作成失敗。システム管理者を連絡ください。");
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
})