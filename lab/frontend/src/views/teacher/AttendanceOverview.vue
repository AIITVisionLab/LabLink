<template>
  <div class="page-shell">
    <section class="toolbar-card">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow">教师考勤查看</p>
          <h2>查看当前签到会话和当日归档结果</h2>
        </div>
        <div class="toolbar-actions">
          <el-date-picker v-model="selectedDate" type="date" value-format="YYYY-MM-DD" @change="loadManageList" />
          <el-button @click="loadPageData">刷新</el-button>
          <el-button type="success" plain @click="handleExport">导出名单</el-button>
        </div>
      </div>
    </section>

    <div v-if="!labId" class="empty-panel">
      <el-empty description="当前账号没有绑定实验室" />
    </div>

    <template v-else>
      <section class="metric-grid">
        <MetricCard label="总人数" :value="stats.totalCount" tip="当前实验室成员" />
        <MetricCard label="已签到" :value="stats.signedCount" tip="今日已签到成员" />
        <MetricCard label="请假" :value="stats.leaveCount" tip="今日请假成员" />
        <MetricCard label="忘记签到" :value="stats.forgotCount" tip="今日忘记签到成员" />
        <MetricCard label="缺勤" :value="stats.absentCount" tip="今日缺勤成员" />
      </section>

      <section class="content-grid two-column">
        <article class="overview-card">
          <div class="card-head">
            <div>
              <p class="panel-eyebrow">当前会话</p>
              <h3>{{ activeSession.sessionNo || '暂无最近会话' }}</h3>
            </div>
            <span class="status-pill">{{ sessionStatusText }}</span>
          </div>
          <div class="summary-grid">
            <div class="summary-item">
              <span>剩余时间</span>
              <strong>{{ remainingText }}</strong>
            </div>
            <div class="summary-item">
              <span>结束时间</span>
              <strong>{{ formatDateTime(activeSession.expireTime) }}</strong>
            </div>
            <div class="summary-item">
              <span>签到码</span>
              <strong>{{ visibleSignCode }}</strong>
            </div>
            <div class="summary-item">
              <span>说明</span>
              <strong>{{ sessionHint }}</strong>
            </div>
          </div>
        </article>

        <article class="overview-card">
          <div class="card-head">
            <div>
              <p class="panel-eyebrow">实时签到记录</p>
              <h3>{{ sessionRecords.length }} 条</h3>
            </div>
          </div>
          <div v-if="sessionRecords.length" class="record-list">
            <article v-for="item in sessionRecords" :key="item.id || item.userId" class="record-card">
              <div>
                <strong>{{ item.realName || '-' }}</strong>
                <p>{{ item.studentId || '-' }}</p>
                <small>{{ formatDateTime(item.signTime) }}</small>
              </div>
              <span class="status-pill light">{{ signMethodLabel(item.signMethod) }}</span>
            </article>
          </div>
          <el-empty v-else description="暂无实时签到记录" :image-size="72" />
        </article>
      </section>

      <TablePageCard title="当日考勤名单" subtitle="最终结果" :count-label="`${attendanceRows.length} 条`">
        <el-table :data="attendanceRows" stripe>
          <el-table-column prop="realName" label="姓名" min-width="140" />
          <el-table-column prop="studentId" label="学号" min-width="120" />
          <el-table-column prop="college" label="学院" min-width="160" />
          <el-table-column prop="statusLabel" label="状态" min-width="120" />
          <el-table-column label="签到时间" min-width="180">
            <template #default="{ row }">{{ formatDateTime(row.checkinTime) }}</template>
          </el-table-column>
          <el-table-column prop="tagLabel" label="标签" min-width="120" />
          <el-table-column prop="reason" label="备注" min-width="220" show-overflow-tooltip />
        </el-table>
      </TablePageCard>
    </template>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import MetricCard from '@/components/common/MetricCard.vue'
import TablePageCard from '@/components/common/TablePageCard.vue'
import {
  exportAttendanceManage,
  getActiveAttendanceSession,
  getAttendanceManageList,
  getAttendanceSessionRecords
} from '@/api/attendance'
import { useUserStore } from '@/stores/user'
import { createSessionCountdown } from '@/utils/attendanceSession'

const userStore = useUserStore()
const labId = computed(() => userStore.userInfo?.managedLabId || userStore.userInfo?.labId || null)
const selectedDate = ref(dayjs().format('YYYY-MM-DD'))
const sessionRecords = ref([])
const attendanceRows = ref([])

const activeSession = reactive({
  id: null,
  sessionNo: '',
  signCode: '',
  status: '',
  expireTime: '',
  remainingSeconds: 0
})
const sessionCountdown = createSessionCountdown(activeSession)

const stats = reactive({
  totalCount: 0,
  signedCount: 0,
  leaveCount: 0,
  forgotCount: 0,
  absentCount: 0
})
const hasSession = computed(() => Boolean(activeSession.id))
const isSessionActive = computed(() => activeSession.status === 'active')
const visibleSignCode = computed(() => (isSessionActive.value && (activeSession.remainingSeconds || 0) > 0 ? (activeSession.signCode || '------') : '------'))
const sessionStatusText = computed(() => ({
  active: '进行中',
  expired: '已过期',
  cancelled: '已作废'
}[activeSession.status] || '未开始'))
const remainingText = computed(() => {
  if (!hasSession.value) {
    return '-'
  }
  if (isSessionActive.value) {
    return `${activeSession.remainingSeconds || 0} 秒`
  }
  return '0 秒'
})
const sessionHint = computed(() => {
  if (!hasSession.value) {
    return '等待管理员创建新会话'
  }
  if (isSessionActive.value) {
    return '学生可通过二维码或签到码签到'
  }
  return '会话已结束，签到码保留展示供核对'
})

const loadActiveSession = async () => {
  const response = await getActiveAttendanceSession({ labId: labId.value })
  Object.assign(activeSession, {
    id: null,
    sessionNo: '',
    signCode: '',
    status: '',
    expireTime: '',
    remainingSeconds: 0,
    ...(response.data || {})
  })
  sessionCountdown.restart()
  if (!activeSession.id) {
    sessionRecords.value = []
    return
  }
  const recordsResponse = await getAttendanceSessionRecords({ sessionId: activeSession.id })
  sessionRecords.value = recordsResponse.data?.records || []
}

const loadManageList = async () => {
  const response = await getAttendanceManageList({ labId: labId.value, date: selectedDate.value })
  attendanceRows.value = response.data?.rows || []
  Object.assign(stats, response.data?.stat || {
    totalCount: 0,
    signedCount: 0,
    leaveCount: 0,
    forgotCount: 0,
    absentCount: 0
  })
}

const loadPageData = async () => {
  if (!labId.value) {
    return
  }
  await Promise.all([loadActiveSession(), loadManageList()])
}

const handleExport = async () => {
  const response = await exportAttendanceManage({
    labId: labId.value,
    startDate: selectedDate.value,
    endDate: selectedDate.value
  })
  const blob = new Blob([response.data], { type: response.headers['content-type'] || 'application/octet-stream' })
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `attendance-${selectedDate.value}.xlsx`
  link.click()
  window.URL.revokeObjectURL(url)
}

const signMethodLabel = (value) => ({ code: '签到码', qr: '二维码' }[value] || '-')
const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm:ss') : '-')

onMounted(() => {
  loadPageData()
})

onUnmounted(() => {
  sessionCountdown.stop()
})
</script>

<style scoped>
.overview-card {
  padding: 20px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.card-head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
}

.panel-eyebrow,
.summary-item span,
.record-card p,
.record-card small {
  color: #64748b;
}

.panel-eyebrow {
  margin: 0 0 8px;
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.card-head h3,
.summary-item strong,
.record-card strong {
  color: #0f172a;
}

.summary-grid {
  margin-top: 18px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.summary-item {
  padding: 14px 16px;
  border-radius: 18px;
  background: rgba(248, 250, 252, 0.92);
  display: grid;
  gap: 8px;
}

.record-list {
  display: grid;
  gap: 10px;
  margin-top: 18px;
}

.record-card {
  padding: 14px;
  border-radius: 18px;
  background: rgba(248, 250, 252, 0.92);
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.status-pill {
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(219, 234, 254, 0.9);
  color: #2563eb;
  font-size: 12px;
  font-weight: 700;
}

.status-pill.light {
  background: rgba(15, 23, 42, 0.06);
  color: #334155;
}

@media (max-width: 768px) {
  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
