/**
 * NHR_EN_PartnerMeetingExcelCtrl
 * パートナー会議資料 VFページ（Excel出力）用コントローラ
 *
 * URLパラメータ:
 *   targetMonth: Date.toString() 形式 例 "2026-02-01"
 */
public with sharing class NHR_EN_PartnerMeetingExcelCtrl {

    public String  errorMessage { get; private set; }
    public String  reporterName { get; private set; }
    public String  sheetName    { get; private set; }
    public String  col1Label    { get; private set; }
    public String  col2Label    { get; private set; }
    public String  col3Label    { get; private set; }
    public String  col4Label    { get; private set; }
    public Decimal totalCol1    { get; private set; }
    public Decimal totalCol2    { get; private set; }
    public Decimal totalCol3    { get; private set; }
    public Decimal totalCol4    { get; private set; }

    public List<NHR_EN_PartnerMeetingCtrl.PartnerRowData> meetingRows { get; private set; }
    public List<Integer> emptyRows { get; private set; }

    public NHR_EN_PartnerMeetingExcelCtrl() {
        errorMessage = '';
        meetingRows  = new List<NHR_EN_PartnerMeetingCtrl.PartnerRowData>();
        emptyRows    = new List<Integer>();
        totalCol1 = 0; totalCol2 = 0; totalCol3 = 0; totalCol4 = 0;
        sheetName = '資料';

        try {
            String targetMonthParam = ApexPages.currentPage().getParameters().get('targetMonth');

            NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
                NHR_EN_PartnerMeetingCtrl.getMeetingDataForVF(targetMonthParam);

            reporterName = wrapper.reporterName;
            sheetName    = wrapper.targetMonth + '資料';
            col1Label    = wrapper.col1Label;
            col2Label    = wrapper.col2Label;
            col3Label    = wrapper.col3Label;
            col4Label    = wrapper.col4Label;
            meetingRows  = wrapper.rows;

            // 空行パディング（21行になるまで埋める）
            Integer padCount = NHR_EN_PartnerMeetingCtrl.MAX_DATA_ROWS - meetingRows.size();
            for (Integer i = 0; i < padCount; i++) {
                emptyRows.add(i);
            }

            // 列合計
            for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : meetingRows) {
                totalCol1 += r.col1Amount != null ? r.col1Amount : 0;
                totalCol2 += r.col2Amount != null ? r.col2Amount : 0;
                totalCol3 += r.col3Amount != null ? r.col3Amount : 0;
                totalCol4 += r.col4Amount != null ? r.col4Amount : 0;
            }

        } catch (Exception e) {
            // VFページ内でエラーを可視化（getContent()でBlobが空にならないよう出力する）
            errorMessage = 'エラーが発生しました: ' + e.getMessage()
                         + ' [' + e.getTypeName() + ']'
                         + ' StackTrace: ' + e.getStackTraceString();
        }
    }
}