({
    execExport: function(component) {
        component.set('v.isLoading',      true);
        component.set('v.isSuccess',      false);
        component.set('v.successMessage', '');
        component.set('v.errorMessage',   '');

        var action = component.get('c.exportOrderPlan');
        // 年度・集計基準日はApex側で自動算出するためパラメータなし
        action.setParams({});

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();

            if (state === 'SUCCESS') {
                component.set('v.isSuccess',      true);
                component.set('v.successMessage', '集計が完了しました。Excelファイルをメールで送信しました。');
            } else if (state === 'ERROR') {
                var errors = response.getError();
                var msg = (errors && errors[0] && errors[0].message)
                    ? errors[0].message
                    : 'エラーが発生しました。管理者に連絡してください。';
                component.set('v.errorMessage', msg);
            }
        });

        $A.enqueueAction(action);
    }
})