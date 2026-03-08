({
    doInit : function(component, event, helper) {
        var action = component.get("c.saveAccessUser");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result:' + result);
                if (result) {
                    window.location.reload();
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})