/**
 * NHR_EN_OrderPlanExcelCtrl
 * Excel出力VFページ（NHR_EN_OrderPlanExcel.page）のコントローラ
 * Opportunity を直接参照して担当者×月のマトリックスを構築する
 *
 * 実績の月振り分けルール（第5営業日カウント）:
 *   カウントルール: 前月第5営業日〜当月第4営業日 = その月
 *   confirmedCutoff = 実行日が属するカウント月の第4営業日
 *     例) 実行日1/10（1月第5営業日以降）→ confirmedCutoff = 1月第4営業日
 *     例) 実行日1/3 （1月第5営業日より前）→ confirmedCutoff = 12月第4営業日
 *
 *   ① 確定済み: 商談日のカウント月締切 ≦ confirmedCutoff
 *      → en_zyutyuubi__c で月判定、受注金額・粗利、確度空白
 *   ② 見込み  : 商談日のカウント月締切 >  confirmedCutoff
 *      → EN_zyutyumikomiduki__c で月判定、目標額・目標利益・確度あり
 */
public with sharing class NHR_EN_OrderPlanExcelCtrl {

    private static final List<String> MONTH_LIST          = NHR_EN_OrderPlanExportCtrl.MONTH_LIST;
    private static final Map<Integer, String> NUM_TO_MONTH = NHR_EN_OrderPlanExportCtrl.NUM_TO_MONTH;
    private static final Set<String> CUMULATIVE_MONTHS = new Set<String>{
        '７月','８月','９月','１０月','１１月','１２月'
    };

    // -------------------------------------------------------
    // プロパティ
    // -------------------------------------------------------
    public String       fiscalYear   { get; set; }
    public Date         targetDate   { get; set; }
    public List<String> months       { get; set; }
    public List<PersonBlockWrapper> personBlocks { get; set; }
    public TotalSummaryWrapper      totalSummary { get; set; }

    /** エラーメッセージ（VFページでのデバッグ用） */
    public String errorMessage { get; set; }

    // -------------------------------------------------------
    // コンストラクタ
    // -------------------------------------------------------
    public NHR_EN_OrderPlanExcelCtrl() {
        months       = MONTH_LIST;
        errorMessage = '';

        String fyParam = ApexPages.currentPage().getParameters().get('fy');
        fiscalYear = String.isNotBlank(fyParam) ? fyParam : '202506';

        String dtParam = ApexPages.currentPage().getParameters().get('targetDate');
        targetDate = String.isNotBlank(dtParam)
            ? Date.valueOf(dtParam)
            : Date.newInstance(Integer.valueOf(fiscalYear.left(4)), 12, 31);

        try {
            buildBlocks();
        } catch (Exception e) {
            // エラーをページに出力することでgetContent()が空Blobを返す前に
            // Queueableのexecute()でBlobサイズチェックにより検知できる
            errorMessage = 'ExcelCtrl エラー: ' + e.getMessage()
                         + ' / ' + e.getStackTraceString();
            // personBlocks / totalSummary を空で初期化してVFレンダリングエラーを防ぐ
            personBlocks = new List<PersonBlockWrapper>();
            totalSummary = new TotalSummaryWrapper();
            initEmptyTotalSummary(totalSummary);
        }
    }

    private void initEmptyTotalSummary(TotalSummaryWrapper ts) {
        ts.planAmountByMonth   = new Map<String, Decimal>();
        ts.planProfitByMonth   = new Map<String, Decimal>();
        ts.actualAmountByMonth = new Map<String, Decimal>();
        ts.actualProfitByMonth = new Map<String, Decimal>();
        ts.diffAmountByMonth   = new Map<String, Decimal>();
        ts.diffProfitByMonth   = new Map<String, Decimal>();
        ts.confirmedCumulativeAmount = 0; ts.confirmedCumulativeProfit = 0;
        ts.annualTotalAmount         = 0; ts.annualTotalProfit         = 0;
        ts.planCumulativeAmount = 0; ts.planCumulativeProfit = 0;
        ts.planAnnualAmount     = 0; ts.planAnnualProfit     = 0;
        ts.diffCumulativeAmount = 0; ts.diffCumulativeProfit = 0;
        ts.diffAnnualAmount     = 0; ts.diffAnnualProfit     = 0;
        ts.rankAAmount = 0; ts.rankAProfit = 0;
        ts.rankBAmount = 0; ts.rankBProfit = 0;
        ts.rankCAmount = 0; ts.rankCProfit = 0;
        for (String m : MONTH_LIST) {
            ts.planAmountByMonth.put(m, 0);   ts.planProfitByMonth.put(m, 0);
            ts.actualAmountByMonth.put(m, 0); ts.actualProfitByMonth.put(m, 0);
            ts.diffAmountByMonth.put(m, 0);   ts.diffProfitByMonth.put(m, 0);
        }
    }

    // -------------------------------------------------------
    // データ構築
    // -------------------------------------------------------
    private void buildBlocks() {
        List<User> users = NHR_EN_OrderPlanExportCtrl.getOsakaSalesUsers();
        Set<Id> userIds  = new Map<Id, User>(users).keySet();

        Integer startYear  = Integer.valueOf(fiscalYear.left(4));

        // -------------------------------------------------------
        // 年度補正：7月カウント月（7月第5営業日〜8月第4営業日）中に出力した場合
        //           前年度（前年7月〜当年6月）のデータを対象とする
        // 手順: 暫定祝日で実行日のカウント月を判定し、7月なら前年度に補正
        // -------------------------------------------------------
        // -------------------------------------------------------
        // 年度の正確な判定
        // 実行日が属するカウント月から正しい年度を決定する
        //
        // カウント月と年度の対応:
        //   ７月カウント月（7月第5営業日〜8月第4営業日） → 前年度（前年7月〜当年6月）
        //   ６月カウント月（6月第5営業日〜7月第4営業日） → 前年度（前年7月〜当年6月）
        //   ８月カウント月以降                           → 当年度
        //   ５月カウント月以前                           → 前年度
        //
        // 実装: 実行日の前後の祝日を取得してカウント月を特定し、
        //       そこから「7月カウント月が含まれる年度」を判定する
        // -------------------------------------------------------
        Set<Date> tempHolidays = getHolidays(
            Date.newInstance(targetDate.year(), 1, 1),
            Date.newInstance(targetDate.year() + 1, 3, 31)
        );
        String runCountMonth = getCountMonthLabel(targetDate, tempHolidays);

        // 実行日のカウント月が属する年度の startYear を直接決定
        Integer correctedStartYear;
        if (runCountMonth == '７月' || runCountMonth == '８月' || runCountMonth == '９月'
            || runCountMonth == '１０月' || runCountMonth == '１１月' || runCountMonth == '１２月') {
            // 7〜12月カウント月 → 当年度の7月始まり
            correctedStartYear = targetDate.year();
            // ただし7月カウント月は前年度（前年7月〜当年6月）
            if (runCountMonth == '７月') {
                correctedStartYear = targetDate.year() - 1;
            }
        } else {
            // 1〜6月カウント月 → 前年度の7月始まり
            correctedStartYear = targetDate.year() - 1;
        }

        if (correctedStartYear != startYear) {
            startYear  = correctedStartYear;
            fiscalYear = String.valueOf(startYear) + '06';
        }

        // periodStart: 当年度の7月1日
        Date periodStart   = Date.newInstance(startYear,     7, 1);
        // periodEnd: 翌年7月の第4営業日（6月カウント月＝6/5〜7/4を全て取得するため）
        Date periodEndBase = Date.newInstance(startYear + 1, 7, 31);

        // 祝日取得：カウント月境界（前後1ヶ月）まで含めて正確に取得
        Set<Date> holidays = getHolidays(
            periodStart.addMonths(-1),
            periodEndBase
        );

        // confirmedCutoff（受注確定とみなす締切日）を算出
        Date confirmedCutoff = calcConfirmedCutoff(targetDate, holidays);

        // periodEnd: 翌年7月の第4営業日（6月カウント月の末尾）
        Date periodEnd = getNthBizDay(startYear + 1, 7, 4, holidays);

        // 確定実績の取得開始日 = 当年度7月第5営業日
        // 7月第4営業日以前は前年度6月カウント月に属するため除外
        Date actualConfirmedStart = getNthBizDay(startYear, 7, 5, holidays);

        // Opportunity 取得
        List<Opportunity> planOpps            = NHR_EN_OrderPlanExportCtrl.fetchPlanOpps(userIds, periodStart, periodEnd);
        List<Opportunity> actualConfirmedOpps = NHR_EN_OrderPlanExportCtrl.fetchActualConfirmedOpps(userIds, actualConfirmedStart, periodEnd);
        List<Opportunity> actualProspectOpps  = NHR_EN_OrderPlanExportCtrl.fetchActualProspectOpps(userIds, periodStart, periodEnd);

        // Map化
        Map<Id, Map<String, List<RowWrapper>>> planMap   = buildPlanRowMap(planOpps);
        Map<Id, Map<String, List<RowWrapper>>> actualMap = buildActualRowMap(
            actualConfirmedOpps, actualProspectOpps, confirmedCutoff, holidays);

        personBlocks = new List<PersonBlockWrapper>();
        for (User u : users) {
            Map<String, List<RowWrapper>> pRows = planMap.containsKey(u.Id)
                ? planMap.get(u.Id)   : new Map<String, List<RowWrapper>>();
            Map<String, List<RowWrapper>> aRows = actualMap.containsKey(u.Id)
                ? actualMap.get(u.Id) : new Map<String, List<RowWrapper>>();
            personBlocks.add(buildPersonBlock(u, pRows, aRows, confirmedCutoff, holidays));
        }

        totalSummary = buildTotalSummary();
    }

    // -------------------------------------------------------
    // confirmedCutoff 算出
    //
    // カウント月定義:「当月第5営業日〜翌月第4営業日 = 当月カウント月」
    // confirmedCutoff = 実行日が属するカウント月の「1つ前のカウント月の締切」
    //
    // 例: 実行日3/22（3月第5営業日以降）
    //   → 実行日は3月カウント月（3月第5営業日〜4月第4営業日）の期間中
    //   → 確定済みは3月カウント月の1つ前=2月カウント月まで
    //   → confirmedCutoff = 3月第4営業日（2月カウント月の締切）
    //
    // 例: 実行日3/3（3月第5営業日より前）
    //   → 実行日は2月カウント月（2月第5営業日〜3月第4営業日）の期間中
    //   → 確定済みは2月カウント月の1つ前=1月カウント月まで
    //   → confirmedCutoff = 2月第4営業日（1月カウント月の締切）
    // -------------------------------------------------------
    @TestVisible
    private static Date calcConfirmedCutoff(Date runDate, Set<Date> holidays) {
        Date bizDay5 = getNthBizDay(runDate.year(), runDate.month(), 5, holidays);
        // 実行日が属するカウント月を特定
        Date countMonthDate = (runDate < bizDay5) ? runDate.addMonths(-1) : runDate;
        // そのカウント月の締切日（翌月第4営業日）が confirmedCutoff
        // = 1つ前のカウント月の締切なので、countMonthDate.month() の第4営業日
        return getNthBizDay(countMonthDate.year(), countMonthDate.month(), 4, holidays);
    }

    // -------------------------------------------------------
    // 指定年月の第N営業日（土日祝除く）を返す
    // -------------------------------------------------------
    @TestVisible
    private static Date getNthBizDay(Integer year, Integer month, Integer n, Set<Date> holidays) {
        Date d     = Date.newInstance(year, month, 1);
        Integer count = 0;
        for (Integer i = 0; i < 50; i++) {
            // 曜日判定: Date.toStartOfWeek() は日曜始まりのためdayOfWeekを計算
            // Apex に dayOfWeek() はないので基準日からの差分 mod 7 で算出
            // 基準日: 2000-01-01 = 土曜日(6)
            Integer dow = Math.mod(Date.newInstance(2000, 1, 1).daysBetween(d) + 6, 7);
            // dow: 0=月,1=火,2=水,3=木,4=金,5=土,6=日
            Boolean isWeekend = (dow == 5 || dow == 6);
            Boolean isHoliday = holidays.contains(d);
            if (!isWeekend && !isHoliday) {
                count++;
                if (count == n) return d;
            }
            d = d.addDays(1);
        }
        return d;
    }

    // -------------------------------------------------------
    // 祝日取得（Holiday__c.HolidayDate__c）
    // -------------------------------------------------------
    private Set<Date> getHolidays(Date periodStart, Date periodEnd) {
        Set<Date> result = new Set<Date>();
        for (Holiday__c h : [
            SELECT HolidayDate__c
            FROM   Holiday__c
            WHERE  HolidayDate__c >= :periodStart
            AND    HolidayDate__c <= :periodEnd
        ]) {
            if (h.HolidayDate__c != null) result.add(h.HolidayDate__c);
        }
        return result;
    }

    // -------------------------------------------------------
    // 計画 Opportunity → Map<userId, Map<month, List<RowWrapper>>>
    // -------------------------------------------------------
    private Map<Id, Map<String, List<RowWrapper>>> buildPlanRowMap(List<Opportunity> opps) {
        Map<Id, Map<String, List<RowWrapper>>> result =
            new Map<Id, Map<String, List<RowWrapper>>>();

        for (Opportunity opp : opps) {
            // 月判定: en_zyutyuubi__c（受注日）の月をそのまま使用、営業日考慮なし
            if (opp.en_zyutyuubi__c == null) continue;
            String monthLabel = NUM_TO_MONTH.get(opp.en_zyutyuubi__c.month());
            if (monthLabel == null) continue;

            if (!result.containsKey(opp.OwnerId))
                result.put(opp.OwnerId, new Map<String, List<RowWrapper>>());
            Map<String, List<RowWrapper>> monthMap = result.get(opp.OwnerId);
            if (!monthMap.containsKey(monthLabel))
                monthMap.put(monthLabel, new List<RowWrapper>());
            List<RowWrapper> rows = monthMap.get(monthLabel);

            RowWrapper rw        = new RowWrapper();
            rw.rowNumber         = rows.size() + 1;
            rw.orderAmount       = toThousands(opp.en_zyutyukingaku__c);      // 受注金額（千円単位）
            rw.grossProfit       = toThousands(opp.en_zyutyuararigaku__c);    // 受注粗利額（千円単位）
            rw.generalContractor = opp.AccountNameAbb__c;
            rw.projectRank       = '';    // 確度：空白
            rw.projectName       = opp.Name;
            rows.add(rw);
        }
        return result;
    }

    // -------------------------------------------------------
    // 実績 Opportunity → Map<userId, Map<month, List<RowWrapper>>>
    //
    // 【①確定済み】en_zyutyuukakudo__c = '受注確定'
    //   月判定: en_zyutyuubi__c の属するカウント月
    //          （前月第5営業日〜当月第4営業日 = その月）
    //   対象範囲: confirmedCutoff（当月第4営業日）以前のカウント月
    //   金額: 受注金額・粗利、確度: 空白
    //
    // 【②見込み】確度条件なし
    //   月判定: EN_zyutyumikomiduki__c の属するカウント月
    //          （前月第5営業日〜当月第4営業日 = その月）
    //   対象範囲: confirmedCutoff より後のカウント月
    //   金額: 受注目標額・目標利益額、確度: あり
    // -------------------------------------------------------
    private Map<Id, Map<String, List<RowWrapper>>> buildActualRowMap(
            List<Opportunity> confirmedOpps,
            List<Opportunity> prospectOpps,
            Date confirmedCutoff,
            Set<Date> holidays) {

        Map<Id, Map<String, List<RowWrapper>>> result =
            new Map<Id, Map<String, List<RowWrapper>>>();

        // ① 確定済み：en_zyutyuubi__c のカウント月で表示月を決定
        //   月判定: 受注日が属するカウント月（営業日考慮あり）
        //   確定判定: カウント月締切 ≦ confirmedCutoff の場合のみ表示
        //   例: 3/22実行, confirmedCutoff=3月第4営業日
        //       受注日7/1 → 6月カウント月, 締切=7月第4営業日 ≦ 3月第4営業日? NO → 除外
        //       受注日2/5 → 2月カウント月, 締切=3月第4営業日 ≦ 3月第4営業日? YES → 確定
        Set<String> monthListSet = new Set<String>(MONTH_LIST);
        for (Opportunity opp : confirmedOpps) {
            if (opp.en_zyutyuubi__c == null) continue;

            // 受注日が属するカウント月のラベルを取得
            String monthLabel = getCountMonthLabel(opp.en_zyutyuubi__c, holidays);
            // 年度範囲外は除外
            if (monthLabel == null || !monthListSet.contains(monthLabel)) continue;

            // カウント月締切（翌月第4営業日）が confirmedCutoff 以内か確認
            Date monthCutoff = getMonthCutoff(opp.en_zyutyuubi__c, holidays);
            if (monthCutoff > confirmedCutoff) continue;

            addToMap(result, opp.OwnerId, monthLabel,
                opp.en_zyutyukingaku__c,
                opp.en_zyutyuararigaku__c,
                opp.AccountNameAbb__c,
                '',
                opp.Name,
                true);
        }

        // ② 見込み：EN_zyutyumikomiduki__c でカウント月を計算し、
        //   confirmedCutoff より後のカウント月のみ計上
        //   かつ MONTH_LIST に含まれる月のみ（年度範囲外を除外）
        for (Opportunity opp : prospectOpps) {
            if (opp.EN_zyutyumikomiduki__c == null) continue;

            String monthLabel = getCountMonthLabel(opp.EN_zyutyumikomiduki__c, holidays);
            // 年度範囲外（MONTH_LIST にない月）は除外
            if (monthLabel == null || !new Set<String>(MONTH_LIST).contains(monthLabel)) continue;

            Date monthCutoff = getMonthCutoff(opp.EN_zyutyumikomiduki__c, holidays);
            // confirmedCutoff より後のカウント月のみ対象
            if (monthCutoff <= confirmedCutoff) continue;

            addToMap(result, opp.OwnerId, monthLabel,
                opp.en_zyutyuumokuhyougaku__c,
                opp.en_mokuhyouriekigaku__c,
                opp.AccountNameAbb__c,
                NHR_EN_OrderPlanExportCtrl.convertRank(opp.en_zyutyuukakudo__c),
                opp.Name,
                false);
        }

        return result;
    }

    /**
     * 指定日が属するカウント月のラベルを返す
     *
     * カウント月の定義:「当月第5営業日〜翌月第4営業日 = 当月のカウント月」
     *
     * 例: 受注日6/10（6月第5営業日以降）→ カウント月='６月'
     *     受注日7/1（7月第5営業日より前）→ 7月第5営業日未満 → 前月=6月カウント月='６月'
     *     受注日7/8（7月第5営業日以降）→ カウント月='７月'
     *
     * ロジック:
     *   受注日 < 当月第5営業日 → 前月のカウント月（前月第5営業日〜当月第4営業日の範囲）
     *   受注日 ≧ 当月第5営業日 → 当月のカウント月（当月第5営業日〜翌月第4営業日の範囲）
     */
    private String getCountMonthLabel(Date d, Set<Date> holidays) {
        Date bizDay5 = getNthBizDay(d.year(), d.month(), 5, holidays);
        // 当月第5営業日より前 → 前月カウント月、以降 → 当月カウント月
        Date countDate = (d < bizDay5) ? d.addMonths(-1) : d;
        return NHR_EN_OrderPlanExportCtrl.NUM_TO_MONTH.get(countDate.month());
    }

    /**
     * 指定日が属するカウント月の締切日（翌月第4営業日）を返す
     * 例: 6月カウント月の締切 = 2026/7/4営業日
     */
    private Date getMonthCutoff(Date d, Set<Date> holidays) {
        Date bizDay5   = getNthBizDay(d.year(), d.month(), 5, holidays);
        Date countDate = (d < bizDay5) ? d.addMonths(-1) : d;
        // カウント月の締切 = 翌月の第4営業日
        Date nextMonth = countDate.addMonths(1);
        return getNthBizDay(nextMonth.year(), nextMonth.month(), 4, holidays);
    }

    /** Map への追加ヘルパー */
    private void addToMap(
            Map<Id, Map<String, List<RowWrapper>>> result,
            Id ownerId, String monthLabel,
            Decimal orderAmount, Decimal grossProfit,
            String generalContractor, String projectRank, String projectName,
            Boolean isConfirmed) {

        if (!result.containsKey(ownerId))
            result.put(ownerId, new Map<String, List<RowWrapper>>());
        Map<String, List<RowWrapper>> monthMap = result.get(ownerId);
        if (!monthMap.containsKey(monthLabel))
            monthMap.put(monthLabel, new List<RowWrapper>());
        List<RowWrapper> rows = monthMap.get(monthLabel);

        RowWrapper rw        = new RowWrapper();
        rw.rowNumber         = rows.size() + 1;
        rw.orderAmount       = toThousands(orderAmount);
        rw.grossProfit       = toThousands(grossProfit);
        rw.generalContractor = generalContractor;
        rw.projectRank       = projectRank;
        rw.projectName       = projectName;
        rw.isConfirmed       = isConfirmed;
        rows.add(rw);
    }

    // -------------------------------------------------------
    // PersonBlockWrapper 組み立て
    // -------------------------------------------------------
    private PersonBlockWrapper buildPersonBlock(
            User u,
            Map<String, List<RowWrapper>> planMap,
            Map<String, List<RowWrapper>> actualMap,
            Date confirmedCutoff,
            Set<Date> holidays) {

        PersonBlockWrapper pb = new PersonBlockWrapper();
        pb.personName          = u.Name;
        pb.planRowsByMonth     = new Map<String, List<RowWrapper>>();
        pb.actualRowsByMonth   = new Map<String, List<RowWrapper>>();
        pb.diffAmountByMonth   = new Map<String, Decimal>();
        pb.diffProfitByMonth   = new Map<String, Decimal>();
        pb.confirmedCumulativeAmount = 0;
        pb.confirmedCumulativeProfit = 0;
        pb.annualTotalAmount         = 0;
        pb.annualTotalProfit         = 0;
        pb.planCumulativeAmount      = 0;
        pb.planCumulativeProfit      = 0;
        pb.planAnnualAmount          = 0;
        pb.planAnnualProfit          = 0;
        pb.diffCumulativeAmount      = 0;
        pb.diffCumulativeProfit      = 0;
        pb.diffAnnualAmount          = 0;
        pb.diffAnnualProfit          = 0;
        pb.rankAAmount = 0; pb.rankAProfit = 0;
        pb.rankBAmount = 0; pb.rankBProfit = 0;
        pb.rankCAmount = 0; pb.rankCProfit = 0;

        for (String month : MONTH_LIST) {
            List<RowWrapper> planRows   = planMap.containsKey(month)
                ? planMap.get(month)   : new List<RowWrapper>{ emptyRow() };
            List<RowWrapper> actualRows = actualMap.containsKey(month)
                ? actualMap.get(month) : new List<RowWrapper>{ emptyRow() };

            pb.planRowsByMonth.put(month,   planRows);
            pb.actualRowsByMonth.put(month, actualRows);

            // 差分用（月別）
            Decimal planAmt = sumAmount(planRows);
            Decimal planGp  = sumProfit(planRows);
            Decimal actAmt  = sumAmount(actualRows);
            Decimal actGp   = sumProfit(actualRows);
            pb.diffAmountByMonth.put(month, actAmt - planAmt);
            pb.diffProfitByMonth.put(month, actGp  - planGp);

            // -------------------------------------------------------
            // 当月（月ラベル）の締切日を算出
            // 締切 = 翌月第4営業日（確定済み判定と同じ基準）
            // 例: 7月の締切 = 8月第4営業日
            // -------------------------------------------------------
            Integer monthNum  = getMonthNumber(month);
            Integer monthYear = Integer.valueOf(fiscalYear.left(4))
                + (monthNum >= 7 ? 0 : 1);
            Integer nextM = monthNum == 12 ? 1 : monthNum + 1;
            Integer nextY = monthNum == 12 ? monthYear + 1 : monthYear;
            Date thisMonthCutoff = getNthBizDay(nextY, nextM, 4, holidays);

            // -------------------------------------------------------
            // 計画集計
            // BK/BL: 計画累計 = confirmedCutoff 以前のカウント月の計画合計
            //        例: 3/22 → confirmedCutoff=3月第4営業日
            //            3月カウント月締切(4月第4営業日) > confirmedCutoff → 3月は含まない
            //            2月カウント月締切(3月第4営業日) <= confirmedCutoff → 2月は含む
            // BM/BN: 計画年間 = 全月合計
            // -------------------------------------------------------
            pb.planAnnualAmount += planAmt;
            pb.planAnnualProfit += planGp;
            if (thisMonthCutoff <= confirmedCutoff) {
                pb.planCumulativeAmount += planAmt;
                pb.planCumulativeProfit += planGp;
            }

            // -------------------------------------------------------
            // 実績集計
            // BK/BL: 実績累計 = confirmedCutoff 以前のカウント月の確定実績合計
            // BM/BN: 実績年間 = 全実績行の合計
            // BO〜BT: 見込み確度別合計
            // -------------------------------------------------------
            for (RowWrapper rw : actualRows) {
                Decimal amt = rw.orderAmount != null ? rw.orderAmount : 0;
                Decimal gp  = rw.grossProfit != null ? rw.grossProfit : 0;

                // BM〜BN: 年間（確定＋見込み）
                pb.annualTotalAmount += amt;
                pb.annualTotalProfit += gp;

                if (rw.isConfirmed == true) {
                    // BK〜BL: 確定累計（カウント月締切 ≦ confirmedCutoff の月のみ）
                    if (thisMonthCutoff <= confirmedCutoff) {
                        pb.confirmedCumulativeAmount += amt;
                        pb.confirmedCumulativeProfit += gp;
                    }
                } else {
                    // BO〜BT: 見込み確度別
                    if      (rw.projectRank == 'A') { pb.rankAAmount += amt; pb.rankAProfit += gp; }
                    else if (rw.projectRank == 'B') { pb.rankBAmount += amt; pb.rankBProfit += gp; }
                    else if (rw.projectRank == 'C') { pb.rankCAmount += amt; pb.rankCProfit += gp; }
                }
            }
        }

        // VF用：月ごとの行数Map と 全月最大行数のインデックスリスト
        pb.planRowCountByMonth   = new Map<String, Integer>();
        pb.actualRowCountByMonth = new Map<String, Integer>();
        Integer maxPlanRows   = 0;
        Integer maxActualRows = 0;
        for (String month : MONTH_LIST) {
            Integer pc = pb.planRowsByMonth.get(month).size();
            Integer ac = pb.actualRowsByMonth.get(month).size();
            pb.planRowCountByMonth.put(month,   pc);
            pb.actualRowCountByMonth.put(month, ac);
            if (pc > maxPlanRows)   maxPlanRows   = pc;
            if (ac > maxActualRows) maxActualRows = ac;
        }
        pb.planRowIndexes   = makeIndexList(maxPlanRows);
        pb.actualRowIndexes = makeIndexList(maxActualRows);

        // 集計列の差分（実績-計画）
        pb.diffCumulativeAmount = pb.confirmedCumulativeAmount - pb.planCumulativeAmount;
        pb.diffCumulativeProfit = pb.confirmedCumulativeProfit - pb.planCumulativeProfit;
        pb.diffAnnualAmount     = pb.annualTotalAmount         - pb.planAnnualAmount;
        pb.diffAnnualProfit     = pb.annualTotalProfit         - pb.planAnnualProfit;

        return pb;
    }

    /** 月ラベル（全角）→ 月番号 */
    private static Integer getMonthNumber(String monthLabel) {
        Map<String, Integer> m = new Map<String, Integer>{
            '７月'=>7,'８月'=>8,'９月'=>9,'１０月'=>10,'１１月'=>11,'１２月'=>12,
            '１月'=>1,'２月'=>2,'３月'=>3,'４月'=>4,'５月'=>5,'６月'=>6
        };
        return m.containsKey(monthLabel) ? m.get(monthLabel) : 1;
    }

    /** 千円単位に変換（nullは0扱い、端数切り捨て） */
    private static Decimal toThousands(Decimal val) {
        if (val == null) return null;
        return (val / 1000).setScale(0, System.RoundingMode.DOWN);
    }

    private List<Integer> makeIndexList(Integer size) {
        List<Integer> result = new List<Integer>();
        for (Integer i = 0; i < size; i++) result.add(i);
        return result;
    }

    private RowWrapper emptyRow() {
        RowWrapper rw        = new RowWrapper();
        rw.rowNumber         = 1;
        rw.orderAmount       = null;
        rw.grossProfit       = null;
        rw.generalContractor = '';
        rw.projectRank       = '';
        rw.projectName       = '';
        return rw;
    }

    private Decimal sumAmount(List<RowWrapper> rows) {
        Decimal t = 0;
        for (RowWrapper rw : rows) t += rw.orderAmount != null ? rw.orderAmount : 0;
        return t;
    }

    private Decimal sumProfit(List<RowWrapper> rows) {
        Decimal t = 0;
        for (RowWrapper rw : rows) t += rw.grossProfit != null ? rw.grossProfit : 0;
        return t;
    }

    // -------------------------------------------------------
    // 全体合計
    // -------------------------------------------------------
    private TotalSummaryWrapper buildTotalSummary() {
        TotalSummaryWrapper ts = new TotalSummaryWrapper();
        ts.planAmountByMonth   = new Map<String, Decimal>();
        ts.planProfitByMonth   = new Map<String, Decimal>();
        ts.actualAmountByMonth = new Map<String, Decimal>();
        ts.actualProfitByMonth = new Map<String, Decimal>();
        ts.diffAmountByMonth   = new Map<String, Decimal>();
        ts.diffProfitByMonth   = new Map<String, Decimal>();
        ts.confirmedCumulativeAmount = 0;
        ts.confirmedCumulativeProfit = 0;
        ts.annualTotalAmount         = 0;
        ts.annualTotalProfit         = 0;
        ts.planCumulativeAmount      = 0;
        ts.planCumulativeProfit      = 0;
        ts.planAnnualAmount          = 0;
        ts.planAnnualProfit          = 0;
        ts.diffCumulativeAmount      = 0;
        ts.diffCumulativeProfit      = 0;
        ts.diffAnnualAmount          = 0;
        ts.diffAnnualProfit          = 0;
        ts.rankAAmount = 0; ts.rankAProfit = 0;
        ts.rankBAmount = 0; ts.rankBProfit = 0;
        ts.rankCAmount = 0; ts.rankCProfit = 0;

        for (String month : MONTH_LIST) {
            ts.planAmountByMonth.put(month,   0);
            ts.planProfitByMonth.put(month,   0);
            ts.actualAmountByMonth.put(month, 0);
            ts.actualProfitByMonth.put(month, 0);
        }

        for (PersonBlockWrapper pb : personBlocks) {
            // BK〜BL: 累計（受注確定）
            ts.confirmedCumulativeAmount += pb.confirmedCumulativeAmount;
            ts.confirmedCumulativeProfit += pb.confirmedCumulativeProfit;
            // BM〜BN: 年間（受注確定＋見込み）
            ts.annualTotalAmount         += pb.annualTotalAmount;
            ts.annualTotalProfit         += pb.annualTotalProfit;
            // 計画累計・年間
            ts.planCumulativeAmount += pb.planCumulativeAmount;
            ts.planCumulativeProfit += pb.planCumulativeProfit;
            ts.planAnnualAmount     += pb.planAnnualAmount;
            ts.planAnnualProfit     += pb.planAnnualProfit;
            // BO〜BT
            ts.rankAAmount += pb.rankAAmount; ts.rankAProfit += pb.rankAProfit;
            ts.rankBAmount += pb.rankBAmount; ts.rankBProfit += pb.rankBProfit;
            ts.rankCAmount += pb.rankCAmount; ts.rankCProfit += pb.rankCProfit;

            for (String month : MONTH_LIST) {
                for (RowWrapper rw : pb.planRowsByMonth.get(month)) {
                    ts.planAmountByMonth.put(month,
                        ts.planAmountByMonth.get(month) + (rw.orderAmount != null ? rw.orderAmount : 0));
                    ts.planProfitByMonth.put(month,
                        ts.planProfitByMonth.get(month) + (rw.grossProfit != null ? rw.grossProfit : 0));
                }
                for (RowWrapper rw : pb.actualRowsByMonth.get(month)) {
                    ts.actualAmountByMonth.put(month,
                        ts.actualAmountByMonth.get(month) + (rw.orderAmount != null ? rw.orderAmount : 0));
                    ts.actualProfitByMonth.put(month,
                        ts.actualProfitByMonth.get(month) + (rw.grossProfit != null ? rw.grossProfit : 0));
                }
            }
        }

        for (String month : MONTH_LIST) {
            ts.diffAmountByMonth.put(month,
                ts.actualAmountByMonth.get(month) - ts.planAmountByMonth.get(month));
            ts.diffProfitByMonth.put(month,
                ts.actualProfitByMonth.get(month) - ts.planProfitByMonth.get(month));
        }
        // 集計列の差分（実績-計画）
        ts.diffCumulativeAmount = ts.confirmedCumulativeAmount - ts.planCumulativeAmount;
        ts.diffCumulativeProfit = ts.confirmedCumulativeProfit - ts.planCumulativeProfit;
        ts.diffAnnualAmount     = ts.annualTotalAmount         - ts.planAnnualAmount;
        ts.diffAnnualProfit     = ts.annualTotalProfit         - ts.planAnnualProfit;
        return ts;
    }

    // -------------------------------------------------------
    // Wrapper クラス
    // -------------------------------------------------------
    public class RowWrapper {
        public Integer rowNumber         { get; set; }
        public Decimal orderAmount       { get; set; }
        public Decimal grossProfit       { get; set; }
        public String  generalContractor { get; set; }
        public String  projectRank       { get; set; }
        public String  projectName       { get; set; }
        public Boolean isConfirmed       { get; set; } // 確定済み（受注確定）かどうか
    }

    public class PersonBlockWrapper {
        public String  personName { get; set; }
        public Map<String, List<RowWrapper>> planRowsByMonth   { get; set; }
        public Map<String, List<RowWrapper>> actualRowsByMonth { get; set; }
        /** 月 → 計画行数（VFのhasRow判定用） */
        public Map<String, Integer> planRowCountByMonth   { get; set; }
        /** 月 → 実績行数（VFのhasRow判定用） */
        public Map<String, Integer> actualRowCountByMonth { get; set; }
        /** 計画行のインデックスリスト（VFのapex:repeat用: 0,1,2,...） */
        public List<Integer> planRowIndexes   { get; set; }
        /** 実績行のインデックスリスト（VFのapex:repeat用: 0,1,2,...） */
        public List<Integer> actualRowIndexes { get; set; }
        public Map<String, Decimal> diffAmountByMonth { get; set; }
        public Map<String, Decimal> diffProfitByMonth { get; set; }

        // === 実績集計 ===
        // BK: 累計（受注確定・7〜12月）受注金額
        public Decimal confirmedCumulativeAmount { get; set; }
        // BL: 累計（受注確定・7〜12月）粗利
        public Decimal confirmedCumulativeProfit { get; set; }
        // BM: 年間（受注確定＋見込み）受注金額
        public Decimal annualTotalAmount         { get; set; }
        // BN: 年間（受注確定＋見込み）粗利
        public Decimal annualTotalProfit         { get; set; }

        // === 計画集計 ===
        // 計画BK: confirmedCutoff以前の月の計画受注金額合計
        public Decimal planCumulativeAmount { get; set; }
        // 計画BL: confirmedCutoff以前の月の計画粗利合計
        public Decimal planCumulativeProfit { get; set; }
        // 計画BM: 年間（全月）計画受注金額合計
        public Decimal planAnnualAmount     { get; set; }
        // 計画BN: 年間（全月）計画粗利合計
        public Decimal planAnnualProfit     { get; set; }

        // === 集計列差分（実績-計画） ===
        public Decimal diffCumulativeAmount { get; set; }
        public Decimal diffCumulativeProfit { get; set; }
        public Decimal diffAnnualAmount     { get; set; }
        public Decimal diffAnnualProfit     { get; set; }

        // BO: 確度A 受注目標額合計
        public Decimal rankAAmount { get; set; }
        // BP: 確度A 目標利益額合計
        public Decimal rankAProfit { get; set; }
        // BQ: 確度B 受注目標額合計
        public Decimal rankBAmount { get; set; }
        // BR: 確度B 目標利益額合計
        public Decimal rankBProfit { get; set; }
        // BS: 確度C 受注目標額合計
        public Decimal rankCAmount { get; set; }
        // BT: 確度C 目標利益額合計
        public Decimal rankCProfit { get; set; }
    }

    public class TotalSummaryWrapper {
        public Map<String, Decimal> planAmountByMonth   { get; set; }
        public Map<String, Decimal> planProfitByMonth   { get; set; }
        public Map<String, Decimal> actualAmountByMonth { get; set; }
        public Map<String, Decimal> actualProfitByMonth { get; set; }
        public Map<String, Decimal> diffAmountByMonth   { get; set; }
        public Map<String, Decimal> diffProfitByMonth   { get; set; }

        // BK〜BL: 累計（受注確定）
        public Decimal confirmedCumulativeAmount { get; set; }
        public Decimal confirmedCumulativeProfit { get; set; }
        // BM〜BN: 年間（受注確定＋見込み）
        public Decimal annualTotalAmount         { get; set; }
        public Decimal annualTotalProfit         { get; set; }
        // 計画BK〜BL: 確定月までの計画合計
        public Decimal planCumulativeAmount { get; set; }
        public Decimal planCumulativeProfit { get; set; }
        // 計画BM〜BN: 年間計画合計
        public Decimal planAnnualAmount     { get; set; }
        public Decimal planAnnualProfit     { get; set; }
        // 集計列差分
        public Decimal diffCumulativeAmount { get; set; }
        public Decimal diffCumulativeProfit { get; set; }
        public Decimal diffAnnualAmount     { get; set; }
        public Decimal diffAnnualProfit     { get; set; }

        // BO〜BT: 確度別合計
        public Decimal rankAAmount { get; set; }
        public Decimal rankAProfit { get; set; }
        public Decimal rankBAmount { get; set; }
        public Decimal rankBProfit { get; set; }
        public Decimal rankCAmount { get; set; }
        public Decimal rankCProfit { get; set; }
    }
}