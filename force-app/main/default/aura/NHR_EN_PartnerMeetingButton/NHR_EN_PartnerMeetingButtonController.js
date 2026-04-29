({
    // 初期化: 対象月ラベルを表示するだけ（Apex呼び出しなし）
    doInit: function(component, event, helper) {
        var today = new Date();
        var label = today.getFullYear() + '年' + (today.getMonth() + 1) + '月';
        component.set('v.targetMonth', label);
    },

    // Excel出力・メール送信
    sendExcel: function(component, event, helper) {
        component.set('v.isLoading',  true);
        component.set('v.errorMsg',   '');
        component.set('v.successMsg', '');

        var action = component.get('c.enqueueExcelMail');
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            if (response.getState() === 'SUCCESS') {
                component.set('v.successMsg',
                    component.get('v.targetMonth') +
                    ' のパートナー会議資料をメールに送信しました。');
            } else {
                var errors = response.getError();
                component.set('v.errorMsg',
                    (errors && errors[0] && errors[0].message)
                        ? errors[0].message
                        : 'エラーが発生しました。管理者にお問い合わせください。');
            }
        });
        $A.enqueueAction(action);
    }
})