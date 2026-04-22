<template>
  <div v-loading="loading" class="page-shell statistics-page">
    <div class="page-backdrop" aria-hidden="true"></div>

    <section class="page-hero statistics-hero">
      <div class="hero-copy">
        <p class="eyebrow">统计分析</p>
        <h1>{{ pageTitle }}</h1>
        <p class="hero-subtitle">
          把实验室、成员、考勤、设备和资料数据收拢到同一张看板里，管理端可以像考勤分析页一样快速看清趋势、分布和待处理事项。
        </p>
        <div class="hero-pills">
          <span class="hero-pill">{{ scopeLabel }}</span>
          <span class="hero-pill muted">{{ rangeLabel }}</span>
        </div>
        <div class="hero-highlights">
          <article
            v-for="item in heroHighlights"
            :key="item.label"
            class="hero-highlight-card"
            :class="`hero-highlight-card--${item.tone}`"
          >
            <span>{{ item.label }}</span>
            <strong>{{ item.value }}</strong>
          </article>
        </div>
      </div>

      <div class="hero-side">
        <article class="hero-focus-card">
          <span>当前范围</span>
          <strong>{{ scopeLabel }}</strong>
          <small>{{ scopeTypeLabel }}</small>
        </article>
        <article class="hero-focus-card highlight">
          <span>待处理事项</span>
          <strong>{{ formatCount(pendingTotal) }}</strong>
          <small>{{ pendingSummaryLabel }}</small>
        </article>
      </div>
    </section>

    <section class="toolbar-card statistics-toolbar">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow toolbar-eyebrow">分析条件</p>
          <h2>按时间范围查看管理域数据变化</h2>
        </div>
        <div class="toolbar-actions">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            unlink-panels
            value-format="YYYY-MM-DD"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 320px"
          />
          <el-button type="primary" :loading="loading" @click="loadStatistics">刷新数据</el-button>
          <el-button @click="useLast30Days">最近 30 天</el-button>
        </div>
      </div>

      <div class="toolbar-meta">
        <article v-for="item in toolbarMetrics" :key="item.label" class="toolbar-meta-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <small>{{ item.tip }}</small>
        </article>
      </div>
    </section>

    <section class="section-block">
      <header class="section-header">
        <div class="section-header__copy">
          <p class="section-header__eyebrow">CORE METRICS</p>
          <h2>核心指标</h2>
          <span>用更紧凑的卡片层次把规模、资产、资料和出勤表现放在同一视觉平面里。</span>
        </div>
        <span class="section-header__pill">{{ overviewCards.length }} 项核心指标</span>
      </header>

      <section class="overview-grid">
        <article
          v-for="card in overviewCards"
          :key="card.label"
          class="overview-card"
          :class="`overview-card--${card.tone}`"
        >
          <span class="overview-card__accent" />
          <div class="overview-card__icon">
            <el-icon><component :is="card.icon" /></el-icon>
          </div>
          <div class="overview-card__content">
            <span class="overview-card__label">{{ card.label }}</span>
            <strong class="overview-card__value">{{ card.value }}</strong>
            <small class="overview-card__tip">{{ card.tip }}</small>
            <div class="overview-card__meta">
              <span class="overview-card__badge">{{ card.badge }}</span>
              <span class="overview-card__tail">{{ card.tail }}</span>
            </div>
          </div>
        </article>
      </section>
    </section>

    <section class="section-block">
      <header class="section-header">
        <div class="section-header__copy">
          <p class="section-header__eyebrow">ACTION QUEUE</p>
          <h2>待办协同</h2>
          <span>把需要处理的事项单独提出来，避免重要审批和维修被埋在统计数据里。</span>
        </div>
        <span class="section-header__pill accent">{{ formatCount(pendingTotal) }} 项待处理</span>
      </header>

      <section class="pending-grid">
        <article
          v-for="card in pendingCards"
          :key="card.label"
          class="pending-card"
          :class="`pending-card--${card.tone}`"
        >
          <span class="pending-card__line" />
          <div class="pending-card__icon">
            <el-icon><component :is="card.icon" /></el-icon>
          </div>
          <div class="pending-card__content">
            <div class="pending-card__head">
              <span>{{ card.label }}</span>
              <em>{{ card.badge }}</em>
            </div>
            <strong>{{ card.value }}</strong>
            <small>{{ card.tip }}</small>
          </div>
        </article>
      </section>
    </section>

    <section class="section-block">
      <header class="section-header">
        <div class="section-header__copy">
          <p class="section-header__eyebrow">FOCUS PANELS</p>
          <h2>重点趋势</h2>
          <span>用趋势图和结构图先看全局走势，再决定要深入到哪一块业务分析。</span>
        </div>
        <span class="section-header__pill">{{ rangeLabel }}</span>
      </header>

      <section class="focus-grid">
        <article class="focus-card focus-card--trend">
          <div class="focus-card__head">
            <div>
              <h3>考勤趋势</h3>
              <p>{{ rangeLabel }} 内的月度出勤率变化</p>
            </div>
            <el-tag type="primary" effect="plain">{{ formatPercent(attendance.attendanceRate) }}</el-tag>
          </div>
          <div ref="trendChartRef" class="chart-canvas"></div>
          <div class="trend-metrics">
            <article
              v-for="item in attendanceHighlights"
              :key="item.label"
              class="trend-metric"
              :class="`trend-metric--${item.tone}`"
            >
              <span>{{ item.label }}</span>
              <strong>{{ item.value }}</strong>
            </article>
          </div>
        </article>

        <article class="focus-card focus-card--composition">
          <div class="focus-card__head">
            <div>
              <h3>{{ compositionMeta.title }}</h3>
              <p>{{ compositionMeta.subtitle }}</p>
            </div>
            <el-tag effect="plain">{{ formatCount(compositionTotal) }}</el-tag>
          </div>
          <div ref="compositionChartRef" class="chart-canvas chart-canvas--donut"></div>
          <div v-if="compositionMeta.rows.length" class="legend-list">
            <article
              v-for="(item, index) in compositionMeta.rows"
              :key="`${compositionMeta.title}-${item.name}`"
              class="legend-item"
            >
              <span class="legend-dot" :style="{ background: getPaletteColor(index) }" />
              <strong>{{ item.name }}</strong>
              <span>{{ formatMetric(item.value) }}</span>
            </article>
          </div>
          <el-empty v-else description="暂无数据" :image-size="64" />
        </article>
      </section>
    </section>

    <section class="section-block">
      <header class="section-header">
        <div class="section-header__copy">
          <p class="section-header__eyebrow">BUSINESS INSIGHT</p>
          <h2>业务洞察</h2>
          <span>把实验室、成员、设备和资料拆成四张分析卡，既有整体感，也方便快速定位问题。</span>
        </div>
        <span class="section-header__pill">{{ insightPanels.length }} 个分析视角</span>
      </header>

      <section class="insight-grid">
        <article
          v-for="panel in insightPanels"
          :key="panel.key"
          class="insight-card"
          :class="`insight-card--${panel.tone}`"
        >
          <div class="insight-card__head">
            <div>
              <p class="insight-card__eyebrow">{{ panel.eyebrow }}</p>
              <h3>{{ panel.title }}</h3>
            </div>
            <span class="insight-card__pill">{{ panel.tag }}</span>
          </div>

          <div v-if="panel.sections.length" class="insight-sections">
            <section v-for="section in panel.sections" :key="`${panel.key}-${section.key}`" class="insight-section">
              <div class="insight-section__head">
                <h4>{{ section.title }}</h4>
                <span>TOP {{ section.rows.length }}</span>
              </div>

              <div class="progress-list">
                <article
                  v-for="item in section.rows"
                  :key="`${section.key}-${item.name}`"
                  class="progress-item"
                >
                  <div class="progress-item__head">
                    <strong>{{ item.name }}</strong>
                    <span>{{ formatMetric(item.value) }}</span>
                  </div>
                  <div class="progress-track">
                    <span class="progress-fill" :style="{ width: calcWidth(item.value, section.rows) }" />
                  </div>
                </article>
              </div>
            </section>
          </div>

          <el-empty v-else description="暂无数据" :image-size="72" />
        </article>
      </section>
    </section>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import * as echarts from 'echarts'
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue'
import {
  Calendar,
  Files,
  Monitor,
  OfficeBuilding,
  Tickets,
  Tools,
  TrendCharts,
  UserFilled
} from '@element-plus/icons-vue'
import {
  getStatisticsAttendance,
  getStatisticsDashboard,
  getStatisticsDevices,
  getStatisticsLabs,
  getStatisticsMembers,
  getStatisticsProfiles
} from '@/api/statistics'

const numberFormatter = new Intl.NumberFormat('zh-CN')
const chartPalette = ['#2563eb', '#38bdf8', '#34d399', '#f59e0b', '#f97316', '#a855f7']

const loading = ref(false)
const dateRange = ref([
  dayjs().subtract(29, 'day').format('YYYY-MM-DD'),
  dayjs().format('YYYY-MM-DD')
])
const dashboard = ref({})
const labGroups = ref([])
const memberGroups = ref([])
const attendance = ref({})
const devices = ref({})
const profiles = ref({})

const trendChartRef = ref(null)
const compositionChartRef = ref(null)
let trendChart = null
let compositionChart = null

const summary = computed(() => dashboard.value.summary || {})
const pending = computed(() => dashboard.value.pending || {})
const scopeLabel = computed(() => dashboard.value.scopeName || '当前范围')
const scopeType = computed(() => dashboard.value.scopeType || 'lab')
const scopeTypeLabel = computed(() => {
  const map = {
    school: '全校视角',
    college: '学院视角',
    lab: '实验室视角'
  }
  return map[scopeType.value] || '实验室视角'
})
const pageTitle = computed(() => {
  if (scopeType.value === 'school') return '全校统计分析'
  return `${scopeLabel.value}统计分析`
})
const rangeLabel = computed(() => {
  const [startDate, endDate] = dateRange.value || []
  if (!startDate || !endDate) {
    return '自定义时间范围'
  }
  return `${startDate} 至 ${endDate}`
})
const pendingTotal = computed(
  () =>
    Number(pending.value.pendingLeaves || 0) +
    Number(pending.value.pendingProfiles || 0) +
    Number(pending.value.pendingMaintenance || 0)
)
const pendingSummaryLabel = computed(() => {
  if (!pendingTotal.value) {
    return '当前没有积压事项'
  }
  return `请假 ${formatCount(pending.value.pendingLeaves || 0)} · 资料 ${formatCount(
    pending.value.pendingProfiles || 0
  )} · 维修 ${formatCount(pending.value.pendingMaintenance || 0)}`
})

const heroHighlights = computed(() => [
  { label: '实验室规模', value: formatCount(summary.value.labCount || 0), tone: 'blue' },
  { label: '成员规模', value: formatCount(summary.value.memberCount || 0), tone: 'emerald' },
  { label: '设备资产', value: formatCount(summary.value.deviceCount || 0), tone: 'violet' }
])

const toolbarMetrics = computed(() => [
  {
    label: '出勤率',
    value: formatPercent(attendance.value.attendanceRate),
    tip: '当前时间范围内的有效出勤占比'
  },
  {
    label: '资料通过率',
    value: formatPercent(profiles.value.approvedRate),
    tip: '已通过和已归档资料占比'
  },
  {
    label: '考勤记录',
    value: formatCount(attendance.value.totalRecords || 0),
    tip: '统计周期内累计考勤记录'
  }
])

const overviewCards = computed(() => [
  {
    label: '实验室数',
    value: formatCount(summary.value.labCount || 0),
    tip: '当前管理范围纳入统计的实验室数量',
    icon: OfficeBuilding,
    tone: 'blue',
    badge: '组织规模',
    tail: '基础盘点'
  },
  {
    label: '成员数',
    value: formatCount(summary.value.memberCount || 0),
    tip: '当前范围内处于活跃状态的成员总量',
    icon: UserFilled,
    tone: 'emerald',
    badge: '人员状态',
    tail: '活跃统计'
  },
  {
    label: '设备数',
    value: formatCount(summary.value.deviceCount || 0),
    tip: '已登记在册的设备资产数量',
    icon: Monitor,
    tone: 'violet',
    badge: '资产台账',
    tail: '设备总览'
  },
  {
    label: '文件数',
    value: formatCount(summary.value.fileCount || 0),
    tip: '资料空间中可管理的文件总数',
    icon: Files,
    tone: 'amber',
    badge: '资料空间',
    tail: '内容沉淀'
  },
  {
    label: '出勤率',
    value: formatPercent(summary.value.attendanceRate),
    tip: '正常、迟到与补签通过记录占比',
    icon: Calendar,
    tone: 'cyan',
    badge: '行为信号',
    tail: '考勤表现'
  },
  {
    label: '资料通过率',
    value: formatPercent(summary.value.profileApprovedRate),
    tip: '资料审核整体通过情况',
    icon: TrendCharts,
    tone: 'rose',
    badge: '审核健康',
    tail: '流程效率'
  }
])

const pendingCards = computed(() => [
  {
    label: '待审请假',
    value: formatCount(pending.value.pendingLeaves || 0),
    tip: '建议优先处理临近开始时间的请假记录',
    icon: Tickets,
    tone: 'amber',
    badge: formatPendingShare(pending.value.pendingLeaves || 0)
  },
  {
    label: '待审资料',
    value: formatCount(pending.value.pendingProfiles || 0),
    tip: '尽量缩短成员资料审核等待时间',
    icon: Files,
    tone: 'blue',
    badge: formatPendingShare(pending.value.pendingProfiles || 0)
  },
  {
    label: '待处理维修',
    value: formatCount(pending.value.pendingMaintenance || 0),
    tip: '留意长期未关闭的维修工单',
    icon: Tools,
    tone: 'rose',
    badge: formatPendingShare(pending.value.pendingMaintenance || 0)
  }
])

const getGroup = (groups, key) => (groups || []).find((item) => item?.key === key) || null

const getGroupTitle = (groups, key, fallback) => getGroup(groups, key)?.title || fallback

const normalizeName = (groupKey, value) => {
  const raw = value === undefined || value === null || value === '' ? '-' : String(value).trim()
  const upper = raw.toUpperCase()
  const lower = raw.toLowerCase()

  if (groupKey === 'memberRoles') {
    const roleMap = {
      member: '成员',
      lab_admin: '实验室管理员',
      lab_leader: '实验室负责人',
      advisor_teacher: '指导教师'
    }
    return roleMap[lower] || raw
  }

  if (groupKey === 'deviceStatus') {
    const statusMap = {
      IDLE: '空闲',
      BORROWED: '借出',
      MAINTAINING: '维修中',
      SCRAPPED: '已报废'
    }
    return statusMap[upper] || raw
  }

  if (groupKey === 'profileStatus') {
    const statusMap = {
      PENDING: '待审核',
      APPROVED: '已通过',
      REJECTED: '已驳回',
      ARCHIVED: '已归档',
      UNKNOWN: '未知'
    }
    return statusMap[upper] || raw
  }

  if (groupKey === 'maintenanceDistribution') {
    const statusMap = {
      PENDING: '待处理',
      PROCESSING: '处理中',
      IN_PROGRESS: '处理中',
      COMPLETED: '已完成',
      REJECTED: '已驳回',
      CANCELLED: '已取消'
    }
    return statusMap[upper] || raw
  }

  return raw
}

const toDisplayRows = (rows, groupKey, limit = 6) =>
  (rows || []).slice(0, limit).map((item) => ({
    name: normalizeName(groupKey, item?.name),
    value: Number(item?.value) || 0
  }))

const topLabsTitle = computed(() => getGroupTitle(labGroups.value, 'topLabs', '热门实验室'))
const labDistributionTitle = computed(() => getGroupTitle(labGroups.value, 'orgDistribution', '实验室分布'))
const memberRoleTitle = computed(() => getGroupTitle(memberGroups.value, 'memberRoles', '成员角色分布'))
const memberMajorTitle = computed(() => getGroupTitle(memberGroups.value, 'majorDistribution', '专业分布'))
const memberOrgTitle = computed(() => getGroupTitle(memberGroups.value, 'memberOrgDistribution', '实验室成员分布'))

const topLabRows = computed(() => toDisplayRows(getGroup(labGroups.value, 'topLabs')?.data, 'topLabs'))
const labDistributionRows = computed(() =>
  toDisplayRows(getGroup(labGroups.value, 'orgDistribution')?.data, 'orgDistribution')
)
const memberRoleRows = computed(() =>
  toDisplayRows(getGroup(memberGroups.value, 'memberRoles')?.data, 'memberRoles')
)
const memberMajorRows = computed(() =>
  toDisplayRows(getGroup(memberGroups.value, 'majorDistribution')?.data, 'majorDistribution')
)
const memberOrgRows = computed(() =>
  toDisplayRows(getGroup(memberGroups.value, 'memberOrgDistribution')?.data, 'memberOrgDistribution')
)
const attendanceTrendRows = computed(() =>
  (attendance.value.monthlyTrend || []).map((item) => ({
    name: item?.name || '-',
    value: Number(item?.value) || 0
  }))
)
const deviceStatusRows = computed(() => toDisplayRows(devices.value.statusDistribution, 'deviceStatus'))
const deviceCategoryRows = computed(() => toDisplayRows(devices.value.categoryDistribution, 'deviceCategory'))
const maintenanceRows = computed(() =>
  toDisplayRows(devices.value.maintenanceDistribution, 'maintenanceDistribution')
)
const profileStatusRows = computed(() => toDisplayRows(profiles.value.statusDistribution, 'profileStatus'))
const profileDirectionRows = computed(() =>
  toDisplayRows(profiles.value.directionDistribution, 'profileDirection')
)
const profileOrgRows = computed(() => toDisplayRows(profiles.value.orgDistribution, 'profileOrg'))

const attendanceHighlights = computed(() => {
  const current = attendance.value.summary || {}
  return [
    { label: '正常签到', value: formatCount(current.normal || 0), tone: 'emerald' },
    { label: '迟到', value: formatCount(current.late || 0), tone: 'amber' },
    { label: '请假', value: formatCount(current.leave || 0), tone: 'sky' },
    { label: '缺勤', value: formatCount(current.absent || 0), tone: 'rose' }
  ]
})

const compositionMeta = computed(() => {
  const candidates = [
    {
      title: memberRoleTitle.value,
      subtitle: '当前范围内的角色结构占比',
      rows: memberRoleRows.value
    },
    {
      title: labDistributionTitle.value,
      subtitle: '当前范围内的实验室归属分布',
      rows: labDistributionRows.value
    },
    {
      title: '设备状态分布',
      subtitle: '设备资产当前可用状态占比',
      rows: deviceStatusRows.value
    }
  ]
  return candidates.find((item) => item.rows.length) || candidates[0]
})

const compositionTotal = computed(() =>
  compositionMeta.value.rows.reduce((total, item) => total + Number(item.value || 0), 0)
)

const insightPanels = computed(() => [
  {
    key: 'labs',
    eyebrow: 'LAB OVERVIEW',
    title: '实验室分析',
    tag: formatCount(summary.value.labCount || 0),
    tone: 'blue',
    sections: [
      { key: 'topLabs', title: topLabsTitle.value, rows: topLabRows.value },
      { key: 'orgDistribution', title: labDistributionTitle.value, rows: labDistributionRows.value }
    ].filter((item) => item.rows.length)
  },
  {
    key: 'members',
    eyebrow: 'MEMBER INSIGHT',
    title: '成员分析',
    tag: formatCount(summary.value.memberCount || 0),
    tone: 'emerald',
    sections: [
      { key: 'memberRoles', title: memberRoleTitle.value, rows: memberRoleRows.value },
      { key: 'majorDistribution', title: memberMajorTitle.value, rows: memberMajorRows.value },
      { key: 'memberOrgDistribution', title: memberOrgTitle.value, rows: memberOrgRows.value }
    ].filter((item) => item.rows.length)
  },
  {
    key: 'devices',
    eyebrow: 'DEVICE STATUS',
    title: '设备分析',
    tag: formatCount(devices.value.totalDevices || 0),
    tone: 'violet',
    sections: [
      { key: 'statusDistribution', title: '状态分布', rows: deviceStatusRows.value },
      { key: 'categoryDistribution', title: '分类分布', rows: deviceCategoryRows.value },
      { key: 'maintenanceDistribution', title: '维修分布', rows: maintenanceRows.value }
    ].filter((item) => item.rows.length)
  },
  {
    key: 'profiles',
    eyebrow: 'PROFILE STATUS',
    title: '资料分析',
    tag: formatCount(profiles.value.totalProfiles || 0),
    tone: 'rose',
    sections: [
      { key: 'statusDistribution', title: '状态分布', rows: profileStatusRows.value },
      { key: 'directionDistribution', title: '方向分布', rows: profileDirectionRows.value },
      { key: 'orgDistribution', title: '组织分布', rows: profileOrgRows.value }
    ].filter((item) => item.rows.length)
  }
])

const buildParams = () => {
  const [startDate, endDate] = dateRange.value || []
  return {
    startDate,
    endDate
  }
}

const buildTrendChart = () => {
  if (!trendChartRef.value) return
  if (!trendChart) {
    trendChart = echarts.init(trendChartRef.value)
  }

  const xData = attendanceTrendRows.value.length
    ? attendanceTrendRows.value.map((item) => item.name)
    : [dayjs().format('YYYY-MM')]
  const yData = attendanceTrendRows.value.length ? attendanceTrendRows.value.map((item) => item.value) : [0]

  trendChart.setOption(
    {
      animationDuration: 500,
      tooltip: {
        trigger: 'axis',
        backgroundColor: 'rgba(255,255,255,.96)',
        borderColor: '#dbeafe',
        textStyle: { color: '#334155' },
        valueFormatter: (value) => `${formatMetric(value)}%`
      },
      grid: { top: 18, left: 42, right: 18, bottom: 34 },
      xAxis: {
        type: 'category',
        data: xData,
        boundaryGap: false,
        axisLine: { lineStyle: { color: '#dbeafe' } },
        axisTick: { show: false },
        axisLabel: { color: '#64748b', fontSize: 11 }
      },
      yAxis: {
        type: 'value',
        min: 0,
        max: 100,
        axisLabel: { color: '#94a3b8', formatter: '{value}%' },
        splitLine: { lineStyle: { color: '#e2e8f0' } }
      },
      series: [
        {
          name: '出勤率',
          type: 'line',
          smooth: true,
          data: yData,
          symbol: 'circle',
          symbolSize: 8,
          lineStyle: {
            width: 3,
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#2563eb' },
              { offset: 1, color: '#38bdf8' }
            ])
          },
          itemStyle: {
            color: '#2563eb',
            borderColor: '#ffffff',
            borderWidth: 2
          },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(37, 99, 235, 0.18)' },
              { offset: 1, color: 'rgba(56, 189, 248, 0.02)' }
            ])
          },
          markLine: {
            symbol: 'none',
            lineStyle: { type: 'dashed', color: '#94a3b8' },
            label: {
              color: '#475569',
              formatter: ({ value }) => `均值 ${formatMetric(value)}%`
            },
            data: [{ type: 'average', name: '平均值' }]
          }
        }
      ]
    },
    true
  )
}

const buildCompositionChart = () => {
  if (!compositionChartRef.value) return
  if (!compositionChart) {
    compositionChart = echarts.init(compositionChartRef.value)
  }

  const hasData = compositionMeta.value.rows.length > 0
  const data = hasData
    ? compositionMeta.value.rows.map((item) => ({ name: item.name, value: item.value }))
    : [{ name: '暂无数据', value: 1 }]

  compositionChart.setOption(
    {
      animationDuration: 500,
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(255,255,255,.96)',
        borderColor: '#e2e8f0',
        textStyle: { color: '#334155' },
        formatter: (params) =>
          hasData ? `${params.name}<br/>${formatMetric(params.value)} (${params.percent}%)` : '暂无数据'
      },
      graphic: [
        {
          type: 'text',
          left: 'center',
          top: '39%',
          style: {
            text: hasData ? formatCount(compositionTotal.value) : '0',
            textAlign: 'center',
            fill: '#0f172a',
            fontSize: 28,
            fontWeight: 700
          }
        },
        {
          type: 'text',
          left: 'center',
          top: '52%',
          style: {
            text: hasData ? '总量' : '暂无数据',
            textAlign: 'center',
            fill: '#64748b',
            fontSize: 12
          }
        }
      ],
      series: [
        {
          type: 'pie',
          radius: ['52%', '76%'],
          center: ['50%', '46%'],
          avoidLabelOverlap: true,
          minAngle: hasData ? 6 : 360,
          label: {
            show: hasData,
            formatter: '{b}\n{d}%',
            color: '#334155',
            fontSize: 12,
            lineHeight: 18
          },
          labelLine: {
            show: hasData,
            lineStyle: { color: '#cbd5e1' }
          },
          itemStyle: {
            borderColor: '#ffffff',
            borderWidth: 3,
            borderRadius: 10
          },
          data,
          color: hasData ? chartPalette : ['#e2e8f0']
        }
      ]
    },
    true
  )
}

const renderCharts = () => {
  buildTrendChart()
  buildCompositionChart()
}

const handleResize = () => {
  trendChart?.resize()
  compositionChart?.resize()
}

const loadStatistics = async () => {
  loading.value = true
  try {
    const params = buildParams()
    const [dashboardRes, labsRes, membersRes, attendanceRes, devicesRes, profilesRes] = await Promise.all([
      getStatisticsDashboard(params),
      getStatisticsLabs(params),
      getStatisticsMembers(params),
      getStatisticsAttendance(params),
      getStatisticsDevices(params),
      getStatisticsProfiles(params)
    ])

    dashboard.value = dashboardRes.data || {}
    labGroups.value = labsRes.data || []
    memberGroups.value = membersRes.data || []
    attendance.value = attendanceRes.data || {}
    devices.value = devicesRes.data || {}
    profiles.value = profilesRes.data || {}

    await nextTick()
    renderCharts()
  } finally {
    loading.value = false
  }
}

const useLast30Days = () => {
  dateRange.value = [
    dayjs().subtract(29, 'day').format('YYYY-MM-DD'),
    dayjs().format('YYYY-MM-DD')
  ]
  loadStatistics()
}

const formatCount = (value) => numberFormatter.format(Number(value || 0))

const formatMetric = (value) => {
  const number = Number(value ?? 0)
  if (Number.isNaN(number)) {
    return '0'
  }
  if (Number.isInteger(number)) {
    return numberFormatter.format(number)
  }
  return `${Math.round(number * 100) / 100}`.replace(/\.0+$/, '').replace(/(\.\d*[1-9])0+$/, '$1')
}

const formatPercent = (value) => `${formatMetric(value)}%`

const formatPendingShare = (value) => {
  const total = Number(pendingTotal.value || 0)
  const current = Number(value || 0)
  if (total <= 0 || current <= 0) {
    return '已清零'
  }
  return `${Math.round((current / total) * 100)}%`
}

const calcWidth = (value, rows) => {
  const max = Math.max(...(rows || []).map((item) => Number(item.value) || 0), 0)
  if (max <= 0) {
    return '0%'
  }
  return `${Math.max(10, Math.round(((Number(value) || 0) / max) * 100))}%`
}

const getPaletteColor = (index) => chartPalette[index % chartPalette.length]

onMounted(() => {
  loadStatistics()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  trendChart?.dispose()
  compositionChart?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.statistics-page {
  position: relative;
  isolation: isolate;
  --analytics-blue: #2563eb;
  --analytics-cyan: #38bdf8;
  --analytics-emerald: #10b981;
  --analytics-violet: #8b5cf6;
  --analytics-amber: #f59e0b;
  --analytics-rose: #f43f5e;
  background: #f8fafc;
}

.page-backdrop {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  background:
    radial-gradient(circle at 8% 12%, rgba(37, 99, 235, 0.08), transparent 28%),
    radial-gradient(circle at 92% 26%, rgba(56, 189, 248, 0.08), transparent 24%),
    radial-gradient(circle at 78% 78%, rgba(16, 185, 129, 0.06), transparent 26%);
}

.statistics-page > :not(.page-backdrop) {
  position: relative;
  z-index: 1;
}

.statistics-hero {
  background:
    radial-gradient(circle at top right, rgba(96, 165, 250, 0.2), transparent 28%),
    radial-gradient(circle at bottom left, rgba(56, 189, 248, 0.14), transparent 24%),
    linear-gradient(135deg, rgba(15, 23, 42, 0.96), rgba(30, 64, 175, 0.94));
}

.hero-copy {
  display: grid;
  gap: 12px;
}

.hero-copy h1 {
  margin: 0;
  color: #ffffff;
}

.hero-subtitle {
  max-width: 760px;
  color: rgba(226, 232, 240, 0.92);
}

.hero-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 6px;
}

.hero-highlights {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-top: 10px;
}

.hero-highlight-card {
  display: grid;
  gap: 4px;
  padding: 14px 16px;
  border-radius: 18px;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.hero-highlight-card span {
  color: rgba(219, 234, 254, 0.82);
  font-size: 12px;
}

.hero-highlight-card strong {
  color: #ffffff;
  font-size: 22px;
  line-height: 1.1;
}

.hero-highlight-card--blue {
  background: linear-gradient(180deg, rgba(59, 130, 246, 0.16), rgba(255, 255, 255, 0.08));
  border-color: rgba(147, 197, 253, 0.22);
}

.hero-highlight-card--emerald {
  background: linear-gradient(180deg, rgba(16, 185, 129, 0.16), rgba(255, 255, 255, 0.08));
  border-color: rgba(110, 231, 183, 0.22);
}

.hero-highlight-card--violet {
  background: linear-gradient(180deg, rgba(139, 92, 246, 0.16), rgba(255, 255, 255, 0.08));
  border-color: rgba(196, 181, 253, 0.22);
}

.hero-pill {
  display: inline-flex;
  align-items: center;
  min-height: 34px;
  padding: 8px 14px;
  border-radius: 999px;
  color: #dbeafe;
  background: rgba(255, 255, 255, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.16);
}

.hero-pill.muted {
  color: rgba(226, 232, 240, 0.9);
}

.hero-side {
  display: grid;
  gap: 14px;
  min-width: 280px;
}

.hero-focus-card {
  display: grid;
  gap: 6px;
  padding: 18px 20px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.12);
  border: 1px solid rgba(255, 255, 255, 0.16);
  color: #e0f2fe;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.04);
}

.hero-focus-card span,
.hero-focus-card small {
  color: rgba(219, 234, 254, 0.84);
}

.hero-focus-card strong {
  font-size: 24px;
  line-height: 1.2;
}

.hero-focus-card.highlight {
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.26), rgba(14, 165, 233, 0.2));
}

.statistics-toolbar {
  padding-bottom: 20px;
}

.section-block {
  display: grid;
  gap: 16px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-end;
}

.section-header__copy {
  display: grid;
  gap: 6px;
}

.section-header__eyebrow {
  margin: 0;
  color: #94a3b8;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.14em;
}

.section-header__copy h2 {
  margin: 0;
  color: #0f172a;
  font-size: 24px;
  line-height: 1.15;
}

.section-header__copy span {
  color: #64748b;
  line-height: 1.6;
}

.section-header__pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 38px;
  padding: 9px 14px;
  border-radius: 999px;
  background: rgba(37, 99, 235, 0.08);
  border: 1px solid rgba(37, 99, 235, 0.12);
  color: #1d4ed8;
  font-weight: 600;
  white-space: nowrap;
}

.section-header__pill.accent {
  background: rgba(245, 158, 11, 0.1);
  border-color: rgba(245, 158, 11, 0.14);
  color: #b45309;
}

.toolbar-eyebrow {
  color: #64748b;
}

.toolbar-main {
  margin-bottom: 0;
}

.toolbar-main h2 {
  margin-top: 6px;
  font-size: 22px;
}

.toolbar-meta {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 18px;
}

.toolbar-meta-card {
  display: grid;
  gap: 6px;
  padding: 16px 18px;
  border-radius: 18px;
  background: linear-gradient(180deg, rgba(248, 250, 252, 0.98), rgba(239, 246, 255, 0.9));
  border: 1px solid rgba(191, 219, 254, 0.64);
}

.toolbar-meta-card span,
.toolbar-meta-card small {
  color: #64748b;
}

.toolbar-meta-card strong {
  color: #0f172a;
  font-size: 24px;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}

.overview-card,
.pending-card,
.focus-card,
.insight-card {
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid rgba(226, 232, 240, 0.94);
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.06);
}

.overview-card {
  position: relative;
  overflow: hidden;
  display: flex;
  gap: 16px;
  align-items: flex-start;
  padding: 20px;
  border-radius: 22px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.overview-card::before,
.focus-card::before,
.insight-card::before,
.pending-card::before {
  content: '';
  position: absolute;
  width: 120px;
  height: 120px;
  top: -56px;
  right: -40px;
  border-radius: 999px;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.85), rgba(255, 255, 255, 0));
  pointer-events: none;
}

.overview-card:hover,
.pending-card:hover,
.insight-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 24px 48px rgba(15, 23, 42, 0.08);
}

.overview-card__accent {
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 4px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.12), rgba(255, 255, 255, 0.5));
}

.overview-card__icon,
.pending-card__icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 16px;
  flex-shrink: 0;
}

.overview-card__icon :deep(svg),
.pending-card__icon :deep(svg) {
  width: 22px;
  height: 22px;
}

.overview-card__content,
.pending-card__content {
  display: grid;
  gap: 6px;
  min-width: 0;
}

.overview-card__label,
.overview-card__tip,
.pending-card__content span,
.pending-card__content small {
  color: #64748b;
}

.overview-card__value,
.pending-card__content strong {
  color: #0f172a;
  font-size: 28px;
  line-height: 1.15;
}

.overview-card__meta {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
  margin-top: 6px;
}

.overview-card__badge,
.overview-card__tail {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
}

.overview-card__tail {
  padding-left: 0;
  padding-right: 0;
  background: transparent;
  color: #64748b;
  font-weight: 500;
}

.overview-card--blue .overview-card__icon,
.pending-card--blue .pending-card__icon {
  color: var(--analytics-blue);
  background: rgba(37, 99, 235, 0.12);
}

.overview-card--blue {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(239, 246, 255, 0.96));
  border-color: rgba(191, 219, 254, 0.72);
}

.overview-card--blue .overview-card__accent,
.overview-card--blue .overview-card__badge {
  background: linear-gradient(90deg, #2563eb, #38bdf8);
  color: #ffffff;
}

.overview-card--emerald .overview-card__icon {
  color: var(--analytics-emerald);
  background: rgba(16, 185, 129, 0.12);
}

.overview-card--emerald {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(236, 253, 245, 0.96));
  border-color: rgba(167, 243, 208, 0.72);
}

.overview-card--emerald .overview-card__accent,
.overview-card--emerald .overview-card__badge {
  background: linear-gradient(90deg, #059669, #34d399);
  color: #ffffff;
}

.overview-card--violet .overview-card__icon {
  color: var(--analytics-violet);
  background: rgba(139, 92, 246, 0.12);
}

.overview-card--violet {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(245, 243, 255, 0.96));
  border-color: rgba(221, 214, 254, 0.72);
}

.overview-card--violet .overview-card__accent,
.overview-card--violet .overview-card__badge {
  background: linear-gradient(90deg, #7c3aed, #a855f7);
  color: #ffffff;
}

.overview-card--amber .overview-card__icon,
.pending-card--amber .pending-card__icon {
  color: var(--analytics-amber);
  background: rgba(245, 158, 11, 0.14);
}

.overview-card--amber {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(255, 251, 235, 0.96));
  border-color: rgba(253, 230, 138, 0.72);
}

.overview-card--amber .overview-card__accent,
.overview-card--amber .overview-card__badge {
  background: linear-gradient(90deg, #d97706, #f59e0b);
  color: #ffffff;
}

.overview-card--cyan .overview-card__icon {
  color: var(--analytics-cyan);
  background: rgba(56, 189, 248, 0.12);
}

.overview-card--cyan {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(240, 249, 255, 0.96));
  border-color: rgba(186, 230, 253, 0.72);
}

.overview-card--cyan .overview-card__accent,
.overview-card--cyan .overview-card__badge {
  background: linear-gradient(90deg, #0284c7, #38bdf8);
  color: #ffffff;
}

.overview-card--rose .overview-card__icon,
.pending-card--rose .pending-card__icon {
  color: var(--analytics-rose);
  background: rgba(244, 63, 94, 0.12);
}

.overview-card--rose {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(255, 241, 242, 0.96));
  border-color: rgba(254, 205, 211, 0.72);
}

.overview-card--rose .overview-card__accent,
.overview-card--rose .overview-card__badge {
  background: linear-gradient(90deg, #e11d48, #fb7185);
  color: #ffffff;
}

.pending-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}

.pending-card {
  position: relative;
  overflow: hidden;
  display: flex;
  gap: 14px;
  align-items: center;
  padding: 18px 20px;
  border-radius: 20px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(248, 250, 252, 0.96));
}

.pending-card__line {
  position: absolute;
  left: 0;
  top: 16px;
  bottom: 16px;
  width: 4px;
  border-radius: 999px;
}

.focus-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.45fr) minmax(320px, 1fr);
  gap: 18px;
}

.focus-card {
  position: relative;
  overflow: hidden;
  padding: 22px;
  border-radius: 24px;
}

.focus-card--trend {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.99), rgba(239, 246, 255, 0.95));
  border-color: rgba(191, 219, 254, 0.76);
}

.focus-card--composition {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.99), rgba(240, 253, 250, 0.95));
  border-color: rgba(167, 243, 208, 0.76);
}

.focus-card__head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
  margin-bottom: 16px;
}

.focus-card__head h3 {
  margin: 0 0 4px;
  color: #0f172a;
  font-size: 18px;
}

.focus-card__head p {
  margin: 0;
  color: #64748b;
}

.chart-canvas {
  width: 100%;
  height: 300px;
  border-radius: 20px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.8), rgba(241, 245, 249, 0.28));
}

.chart-canvas--donut {
  height: 270px;
}

.trend-metrics {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-top: 16px;
}

.trend-metric {
  display: grid;
  gap: 6px;
  padding: 14px 16px;
  border-radius: 18px;
  border: 1px solid transparent;
}

.trend-metric span {
  color: #64748b;
}

.trend-metric strong {
  color: #0f172a;
  font-size: 22px;
}

.trend-metric--emerald {
  background: rgba(16, 185, 129, 0.08);
  border-color: rgba(16, 185, 129, 0.12);
}

.trend-metric--amber {
  background: rgba(245, 158, 11, 0.08);
  border-color: rgba(245, 158, 11, 0.12);
}

.trend-metric--sky {
  background: rgba(56, 189, 248, 0.08);
  border-color: rgba(56, 189, 248, 0.12);
}

.trend-metric--rose {
  background: rgba(244, 63, 94, 0.08);
  border-color: rgba(244, 63, 94, 0.12);
}

.legend-list {
  display: grid;
  gap: 10px;
  margin-top: 4px;
}

.legend-item {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  border-radius: 14px;
  background: #f8fafc;
  border: 1px solid rgba(226, 232, 240, 0.92);
  transition: transform 0.2s ease, border-color 0.2s ease, background 0.2s ease;
}

.legend-item strong {
  color: #1e293b;
  font-size: 14px;
}

.legend-item:hover {
  transform: translateX(2px);
  border-color: rgba(147, 197, 253, 0.9);
  background: linear-gradient(180deg, #ffffff, #eff6ff);
}

.legend-item span:last-child {
  color: #64748b;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 999px;
}

.insight-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.insight-card {
  position: relative;
  overflow: hidden;
  padding: 22px;
  border-radius: 24px;
}

.insight-card__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: flex-start;
  margin-bottom: 18px;
}

.insight-card__eyebrow {
  margin: 0 0 8px;
  color: #94a3b8;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.12em;
}

.insight-card__head h3 {
  margin: 0;
  color: #0f172a;
  font-size: 18px;
}

.insight-card__pill {
  display: inline-flex;
  align-items: center;
  min-height: 32px;
  padding: 6px 12px;
  border-radius: 999px;
  font-weight: 600;
  color: #334155;
  background: #eff6ff;
}

.insight-sections {
  display: grid;
  gap: 18px;
}

.insight-section {
  display: grid;
  gap: 14px;
  padding: 16px 18px;
  border-radius: 18px;
  background: linear-gradient(180deg, rgba(248, 250, 252, 0.98), rgba(241, 245, 249, 0.96));
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.insight-section__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.insight-section__head h4 {
  margin: 0;
  color: #1e293b;
  font-size: 15px;
}

.insight-section__head span {
  color: #94a3b8;
  font-size: 12px;
}

.progress-list {
  display: grid;
  gap: 12px;
}

.progress-item {
  display: grid;
  gap: 8px;
}

.progress-item__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.progress-item__head strong {
  color: #334155;
  font-size: 14px;
  font-weight: 600;
}

.progress-item__head span {
  color: #64748b;
  font-size: 13px;
}

.progress-track {
  height: 10px;
  overflow: hidden;
  border-radius: 999px;
  background: #e2e8f0;
}

.progress-fill {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, #2563eb, #38bdf8);
}

.pending-card--amber .pending-card__line {
  background: linear-gradient(180deg, #f59e0b, #fbbf24);
}

.pending-card--blue .pending-card__line {
  background: linear-gradient(180deg, #2563eb, #38bdf8);
}

.pending-card--rose .pending-card__line {
  background: linear-gradient(180deg, #e11d48, #fb7185);
}

.pending-card__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.pending-card__head em {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 4px 10px;
  border-radius: 999px;
  font-style: normal;
  font-size: 12px;
  font-weight: 700;
  color: #334155;
  background: rgba(148, 163, 184, 0.14);
}

.pending-card--amber .pending-card__head em {
  color: #b45309;
  background: rgba(245, 158, 11, 0.14);
}

.pending-card--blue .pending-card__head em {
  color: #1d4ed8;
  background: rgba(37, 99, 235, 0.12);
}

.pending-card--rose .pending-card__head em {
  color: #be123c;
  background: rgba(244, 63, 94, 0.12);
}

.insight-card--blue .progress-fill {
  background: linear-gradient(90deg, #2563eb, #38bdf8);
}

.insight-card--blue .insight-card__pill {
  color: #1d4ed8;
  background: rgba(37, 99, 235, 0.1);
}

.insight-card--emerald .progress-fill {
  background: linear-gradient(90deg, #059669, #34d399);
}

.insight-card--emerald .insight-card__pill {
  color: #047857;
  background: rgba(16, 185, 129, 0.1);
}

.insight-card--violet .progress-fill {
  background: linear-gradient(90deg, #7c3aed, #a855f7);
}

.insight-card--violet .insight-card__pill {
  color: #7c3aed;
  background: rgba(139, 92, 246, 0.1);
}

.insight-card--rose .progress-fill {
  background: linear-gradient(90deg, #e11d48, #fb7185);
}

.insight-card--rose .insight-card__pill {
  color: #e11d48;
  background: rgba(244, 63, 94, 0.1);
}

@media (max-width: 1280px) {
  .overview-grid,
  .focus-grid,
  .insight-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .focus-card--trend {
    grid-column: 1 / -1;
  }
}

@media (max-width: 960px) {
  .page-hero,
  .section-header,
  .toolbar-main,
  .focus-card__head,
  .insight-card__head {
    flex-direction: column;
    align-items: flex-start;
  }

  .hero-side,
  .hero-highlights,
  .toolbar-meta,
  .overview-grid,
  .pending-grid,
  .focus-grid,
  .insight-grid,
  .trend-metrics {
    grid-template-columns: 1fr;
  }

  .hero-side {
    min-width: 0;
    width: 100%;
  }
}

@media (max-width: 768px) {
  .statistics-toolbar :deep(.el-date-editor) {
    width: 100% !important;
  }

  .section-header__copy h2 {
    font-size: 22px;
  }

  .overview-card,
  .pending-card,
  .focus-card,
  .insight-card {
    padding: 18px;
    border-radius: 20px;
  }

  .chart-canvas {
    height: 260px;
  }

  .chart-canvas--donut {
    height: 240px;
  }

  .legend-item,
  .insight-section {
    padding: 14px;
  }
}
</style>
