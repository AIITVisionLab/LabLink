<template>
  <div class="m-page">
    <section class="hero-card">
      <div>
        <p class="eyebrow">Teacher Attendance</p>
        <h1>{{ session.id ? '今日考勤场次' : '今日暂无场次' }}</h1>
        <p>{{ sessionHint }}</p>
      </div>
      <button class="refresh-btn" type="button" :disabled="loading" @click="loadPageData">刷新</button>
    </section>

    <section class="metric-grid">
      <article v-for="card in summaryCards" :key="card.label" class="metric-card">
        <span>{{ card.label }}</span>
        <strong>{{ card.value }}</strong>
        <small>{{ card.tip }}</small>
      </article>
    </section>

    <section class="panel-card">
      <header class="panel-head">
        <h2>当前场次</h2>
        <span class="status-chip" :class="sessionStatusClass">{{ sessionStatusLabel(session.status) }}</span>
      </header>

      <el-empty v-if="!session.id" description="当前实验室今天没有可查看的考勤场次" :image-size="84" />

      <template v-else>
        <div class="meta-grid">
          <article class="info-card">
            <span>日期</span>
            <strong>{{ session.sessionDate || '-' }}</strong>
          </article>
          <article class="info-card">
            <span>签到窗口</span>
            <strong>{{ formatTime(session.signStartTime) }} - {{ formatTime(session.signEndTime) }}</strong>
          </article>
          <article class="info-card">
            <span>动态码</span>
            <strong>{{ sessionCodeDisplay }}</strong>
          </article>
          <article class="info-card">
            <span>出勤率</span>
            <strong>{{ `${session.attendanceRate ?? 0}%` }}</strong>
          </article>
        </div>
        <p class="panel-tip">{{ sessionCodeHint }}</p>

        <div v-if="session.records?.length" class="record-list">
          <article v-for="item in session.records" :key="item.userId || item.studentId" class="record-card">
            <div>
              <strong>{{ item.realName || '-' }}</strong>
              <p>{{ item.studentId || '-' }} · {{ item.memberRole || 'member' }}</p>
              <small>{{ attendanceStatusLabel(item.signStatus) }} · {{ formatDateTime(item.signTime) }}</small>
            </div>
            <div class="record-side">
              <span class="status-chip light">{{ attendanceStatusLabel(item.signStatus) }}</span>
              <small>{{ leaveStatusLabel(item.leaveRequest?.leaveStatus) }}</small>
            </div>
          </article>
        </div>
        <el-empty v-else description="暂无成员签到记录" :image-size="72" />
      </template>
    </section>

    <section class="panel-card">
      <header class="panel-head">
        <h2>请假申请</h2>
        <span>{{ leaveRows.length }} 条</span>
      </header>

      <div v-if="leaveRows.length" class="record-list">
        <article v-for="row in leaveRows" :key="row.id" class="record-card">
          <div>
            <strong>{{ row.realName || '-' }}</strong>
            <p>{{ row.studentId || '-' }} · {{ row.sessionDate || '-' }}</p>
            <small>{{ row.leaveReason || '未填写请假原因' }}</small>
          </div>
          <div class="record-side">
            <span class="status-chip light">{{ leaveStatusLabel(row.leaveStatus) }}</span>
            <small>{{ row.reviewComment || '待处理' }}</small>
          </div>
        </article>
      </div>
      <el-empty v-else description="暂无请假申请" :image-size="72" />
    </section>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { getAttendanceLeavePage, getCurrentLabAttendanceSession } from '@/api/attendanceWorkflow'

const loading = ref(false)
const leaveRows = ref([])
const session = reactive({
  id: null,
  status: '',
  sessionDate: '',
  signStartTime: '',
  signEndTime: '',
  sessionCode: '',
  codeReady: false,
  codeRemainingSeconds: 0,
  attendanceRate: 0,
  records: []
})

let pollTimer = null

const summaryCards = computed(() => [
  {
    label: '场次状态',
    value: sessionStatusLabel(session.status),
    tip: '当前实验室考勤阶段'
  },
  {
    label: '签到码',
    value: sessionCodeDisplay.value,
    tip: '动态签到码只在进行中场次显示'
  },
  {
    label: '签到记录',
    value: session.records?.length || 0,
    tip: '当前场次成员签到记录数'
  },
  {
    label: '请假申请',
    value: leaveRows.value.length,
    tip: '可查看的请假申请数量'
  }
])

const sessionCodeDisplay = computed(() => {
  if (!session.id) {
    return '-'
  }
  if (session.status === 'pending') {
    return '待开始'
  }
  if (session.status === 'closed') {
    return '已结束'
  }
  return session.sessionCode || '生成中'
})

const sessionCodeHint = computed(() => {
  if (!session.id) {
    return '发布考勤任务并到达排班时间后，系统会自动生成签到动态码。'
  }
  if (session.status === 'pending') {
    return '签到窗口尚未开始。'
  }
  if (session.status === 'closed') {
    return '本场签到已经结束。'
  }
  if (!session.codeReady) {
    return '动态签到码生成中，请稍后刷新。'
  }
  if (session.codeRemainingSeconds > 0) {
    return `动态码剩余 ${Math.max(1, Math.ceil(session.codeRemainingSeconds / 60))} 分钟有效。`
  }
  return '动态签到码即将刷新。'
})

const sessionHint = computed(() => {
  if (!session.id) {
    return '老师可以在手机上直接查看当前签到场次、动态码和学生签到状态。'
  }
  return `${sessionStatusLabel(session.status)}，签到时间 ${formatTime(session.signStartTime)} - ${formatTime(session.signEndTime)}。`
})

const sessionStatusClass = computed(() => {
  if (session.status === 'active') {
    return 'success'
  }
  if (session.status === 'closed') {
    return 'muted'
  }
  return 'progress'
})

const loadCurrentSession = async () => {
  try {
    const response = await getCurrentLabAttendanceSession()
    Object.assign(session, {
      id: null,
      status: '',
      sessionDate: '',
      signStartTime: '',
      signEndTime: '',
      sessionCode: '',
      codeReady: false,
      codeRemainingSeconds: 0,
      attendanceRate: 0,
      records: [],
      ...(response.data || {})
    })
  } catch (error) {
    Object.assign(session, {
      id: null,
      status: '',
      sessionDate: '',
      signStartTime: '',
      signEndTime: '',
      sessionCode: '',
      codeReady: false,
      codeRemainingSeconds: 0,
      attendanceRate: 0,
      records: []
    })
  }
}

const loadLeaves = async () => {
  try {
    const response = await getAttendanceLeavePage({ pageNum: 1, pageSize: 20 })
    leaveRows.value = response.data?.records || []
  } catch (error) {
    leaveRows.value = []
  }
}

const loadPageData = async () => {
  loading.value = true
  try {
    await Promise.all([loadCurrentSession(), loadLeaves()])
  } finally {
    loading.value = false
  }
}

const startPolling = () => {
  stopPolling()
  pollTimer = window.setInterval(() => {
    loadCurrentSession().catch(() => {})
  }, 15000)
}

const stopPolling = () => {
  if (pollTimer) {
    window.clearInterval(pollTimer)
    pollTimer = null
  }
}

const sessionStatusLabel = (value) => ({
  pending: '未开始',
  active: '进行中',
  closed: '已结束'
}[value] || '暂无')

const attendanceStatusLabel = (value) => ({
  normal: '正常',
  late: '迟到',
  leave: '请假',
  absent: '缺勤',
  makeup_pending: '补签待审',
  makeup_approved: '补签通过',
  makeup_rejected: '补签驳回'
}[value] || '待处理')

const leaveStatusLabel = (value) => ({
  PENDING: '待审批',
  APPROVED: '已通过',
  REJECTED: '已驳回'
}[value] || '无请假')

const formatTime = (value) => (value ? dayjs(value).format('HH:mm') : '-')
const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-')

onMounted(() => {
  loadPageData()
  startPolling()
})

onUnmounted(() => {
  stopPolling()
})
</script>

<style scoped>
.m-page {
  display: grid;
  gap: 14px;
}

.hero-card,
.metric-card,
.panel-card,
.info-card,
.record-card {
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.hero-card {
  padding: 18px;
  background: linear-gradient(145deg, rgba(15, 23, 42, 0.94), rgba(180, 83, 9, 0.88));
  color: #f8fafc;
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.eyebrow {
  margin: 0 0 8px;
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  opacity: 0.82;
}

.hero-card h1 {
  margin: 0 0 8px;
  font-size: 24px;
}

.hero-card p {
  margin: 0;
  line-height: 1.6;
  color: rgba(226, 232, 240, 0.9);
}

.refresh-btn {
  height: fit-content;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.12);
  color: #f8fafc;
  border-radius: 14px;
  padding: 10px 14px;
}

.metric-grid,
.meta-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.metric-card,
.info-card {
  padding: 14px;
  display: grid;
  gap: 6px;
}

.metric-card span,
.metric-card small,
.info-card span,
.record-card p,
.record-card small,
.panel-tip {
  color: #64748b;
}

.metric-card strong,
.info-card strong,
.record-card strong,
.panel-head h2 {
  color: #0f172a;
}

.metric-card strong {
  font-size: 20px;
}

.panel-card {
  padding: 14px;
}

.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.panel-head h2 {
  margin: 0;
  font-size: 16px;
}

.panel-tip {
  margin: 12px 0 0;
  line-height: 1.6;
}

.record-list {
  display: grid;
  gap: 10px;
  margin-top: 12px;
}

.record-card {
  padding: 14px;
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.record-card p,
.record-card small {
  margin: 6px 0 0;
}

.record-side {
  min-width: 94px;
  display: grid;
  justify-items: end;
  align-content: start;
  gap: 6px;
  text-align: right;
}

.status-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 28px;
  padding: 0 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  background: rgba(217, 119, 6, 0.14);
  color: #b45309;
}

.status-chip.success {
  background: rgba(34, 197, 94, 0.14);
  color: #15803d;
}

.status-chip.progress {
  background: rgba(245, 158, 11, 0.16);
  color: #b45309;
}

.status-chip.muted {
  background: rgba(148, 163, 184, 0.16);
  color: #475569;
}

.status-chip.light {
  background: rgba(15, 23, 42, 0.06);
  color: #334155;
}

@media (max-width: 480px) {
  .metric-grid,
  .meta-grid {
    grid-template-columns: 1fr;
  }

  .record-card {
    grid-template-columns: 1fr;
    display: grid;
  }

  .record-side {
    justify-items: start;
    text-align: left;
  }
}
</style>
