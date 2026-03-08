({
	Sales_All: function(component, event, helper) {
        helper.Sales(component, event, helper , '全社', '営業部');
    },
    Sales_Tokyo: function(component, event, helper) {
        helper.Sales(component, event, helper , '東京', '営業部');
    },
    Sales_Osaka: function(component, event, helper) {
        helper.Sales(component, event, helper , '大阪', '営業部');
    },
    
    Sales_Tokyo1_2: function(component, event, helper) {
        helper.Sales(component, event, helper , '営業第一チーム' , 'チーム');
    },
    Sales_Tokyo2_2: function(component, event, helper) {
        helper.Sales(component, event, helper , '営業第二チーム' , 'チーム');
    },
    Sales_Osaka_2: function(component, event, helper) {
        helper.Sales(component, event, helper, '大阪営業部' , 'チーム');
    },
    
    Sales_Tokyo3: function(component, event, helper) {
        helper.Sales(component, event, helper , '東京' , '個人');
    },
    Sales_Osaka3: function(component, event, helper) {
        helper.Sales(component, event, helper, '大阪' , '個人');
    },
    Sales4: function(component, event, helper) {
        helper.Sales(component, event, helper, '' , '自分');
    },
})