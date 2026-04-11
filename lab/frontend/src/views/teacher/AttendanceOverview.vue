<template>
  <div class="page-shell">
    <section class="toolbar-card">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow">考勤查看</p>
          <h2>查看当前实验室考勤场次和请假申请</h2>
        </div>
        <div class="toolbar-actions">
          <el-button @click="loadPageData">刷新</el-button>
        </div>
      </div>
    </section>

    <section class="metric-grid">
      <MetricCard v-for="card in summaryCards" :key="card.label" :label="card.label" :value="card.value" :tip="card.tip" />
    </section>

    <TablePageCard title="当前实验室场次" subtitle="教师查看">
      <template #header-extra>
        <StatusTag :value="session.status" preset="session" />
      </template>
      <div v-if="!session.id" class="empty-panel">
        <el-empty description="当前绑定实验室暂时没有可查看的考勤场次。" />
      </div>

      <template v-else>
        <div class="summary-grid">
          <div class="summary-item">
            <span>日期</span>
            <strong>{{ session.sessionDate || '-' }}</strong>
          </div>
          <div class="summary-item">
            <span>签到时段</span>
            <strong>{{ formatTime(session.signStartTime) }} - {{ formatTime(session.signEndTime) }}</strong>
          </div>
          <div class="summary-item">
            <span>动态签到码</span>
            <strong>{{ sessionCodeDisplay }}</strong>
            <small>{{ sessionCodeHint }}</small>
          </div>
          <div class="summary-item">
            <span>出勤率</span>
            <strong>{{ session.attendanceRate ?? 0 }}%</strong>
          </div>
        </div>

        <el-table :data="session.records || []" stripe>
          <el-table-column prop="realName" label="姓名" min-width="140" />
          <el-table-column prop="studentId" label="学号" min-width="120" />
          <el-table-column prop="memberRole" label="角色" min-width="120" />
          <el-table-column label="状态" min-width="120">
            <template #default="{ row }">
              <StatusTag :value="row.signStatus" preset="attendance" />
            </template>
          </el-table-column>
          <el-table-column label="请假" min-width="140">
            <template #default="{ row }">
              <StatusTag :value="row.leaveRequest?.leaveStatus" preset="leave" fallback-label="无" />
            </template>
          </el-table-column>
          <el-table-column label="签到时间" min-width="170">
            <template #default="{ row }">{{ formatDateTime(row.signTime) }}</template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="220" show-overflow-tooltip />
        </el-table>
      </template>
    </TablePageCard>

    <TablePageCard title="请假申请" subtitle="教师查看" :count-label="`${leaveRows.length} 条`">
      <el-table v-loading="leaveLoading" :data="leaveRows" stripe>
        <el-table-column prop="realName" label="姓名" min-width="140" />
        <el-table-column prop="studentId" label="学号" min-width="120" />
        <el-table-column prop="sessionDate" label="场次日期" min-width="120" />
        <el-table-column prop="leaveReason" label="请假原因" min-width="240" show-overflow-tooltip />
        <el-table-column label="状态" min-width="120">
          <template #default="{ row }">
            <StatusTag :value="row.leaveStatus" preset="leave" fallback-label="无" />
          </template>
        </el-table-column>
        <el-table-column prop="reviewComment" label="审核意见" min-width="220" show-overflow-tooltip />
      </el-table>
    </TablePageCard>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { computed, onMounted, reactive, ref } from 'vue'
import MetricCard from '@/components/common/MetricCard.vue'
import StatusTag from '@/components/common/StatusTag.vue'
import TablePageCard from '@/components/common/TablePageCard.vue'
import { getStatusLabel } from '@/utils/status-presenters'
import { getAttendanceLeavePage, getCurrentLabAttendanceSession } from '@/api/attendanceWorkflow'

const session = reactive({
  id: null,
  status: null,
  sessionDate: '',
  signStartTime: '',
  signEndTime: '',
  sessionCode: '',
  codeReady: false,
  codeRemainingSeconds: 0,
  attendanceRate: 0,
  records: []
})
const leaveRows = ref([])
const leaveLoading = ref(false)

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
    return '暂无可用签到码'
  }
  if (session.status === 'pending') {
    return '到达签到时间后自动生成'
  }
  if (session.status === 'closed') {
    return '场次结束后不再展示'
  }
  if (session.codeRemainingSeconds > 0) {
    return `剩余 ${Math.max(1, Math.ceil(session.codeRemainingSeconds / 60))} 分钟`
  }
  return '动态码即将刷新'
})

const summaryCards = computed(() => [
  {
    label: '场次状态',
    value: getStatusLabel(session.status, 'session', '暂无'),
    tip: '当前实验室考勤阶段'
  },
  {
    label: '动态码',
    value: sessionCodeDisplay.value,
    tip: '进行中的场次会自动生成动态签到码'
  },
  {
    label: '记录数',
    value: session.records?.length || 0,
    tip: '当前场次中的成员签到记录数'
  },
  {
    label: '请假申请',
    value: leaveRows.value.length,
    tip: '当前实验室可见的请假申请数量'
  }
])

const loadCurrentSession = async () => {
  try {
    const response = await getCurrentLabAttendanceSession()
    Object.assign(session, {
      id: null,
      status: null,
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
      status: null,
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
  leaveLoading.value = true
  try {
    const response = await getAttendanceLeavePage({
      pageNum: 1,
      pageSize: 20
    })
    leaveRows.value = response.data?.records || []
  } finally {
    leaveLoading.value = false
  }
}

const loadPageData = async () => {
  await Promise.all([loadCurrentSession(), loadLeaves()])
}

const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-')
const formatTime = (value) => (value ? dayjs(value).format('HH:mm') : '-')

onMounted(() => {
  loadPageData()
})
</script>

<style scoped>
.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 16px;
}

.summary-item {
  padding: 14px 16px;
  border-radius: 16px;
  background: rgba(248, 250, 252, 0.92);
  display: grid;
  gap: 6px;
}

.summary-item span,
.summary-item small {
  color: #64748b;
}

@media (max-width: 768px) {
  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
