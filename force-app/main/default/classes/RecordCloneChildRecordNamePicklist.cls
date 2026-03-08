global class RecordCloneChildRecordNamePicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('[Child record name]', '1');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(new VisualEditor.DataRow('[Child record name]', '1'));
        picklistValues.addRow(new VisualEditor.DataRow('Cloned - [Child record name]', '2'));
        picklistValues.addRow(new VisualEditor.DataRow('Cloned - [Child record name] - [YYYY/mm/dd HH:ii]', '3'));
        return picklistValues;
    }
}