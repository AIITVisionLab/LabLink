<template>
  <div class="page-shell">
    <section class="toolbar-card">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow">考勤中心</p>
          <h2>签到、请假申请与历史记录</h2>
        </div>
        <div class="toolbar-actions">
          <el-button @click="loadPageData">刷新</el-button>
        </div>
      </div>
    </section>

    <div v-if="!userStore.userInfo?.labId" class="empty-panel">
      <el-empty description="请先加入实验室后再使用考勤功能。" />
    </div>

    <template v-else>
      <section class="metric-grid">
        <MetricCard v-for="card in metricCards" :key="card.label" :label="card.label" :value="card.value" :tip="card.tip" />
      </section>

      <section class="content-grid two-column">
        <TablePageCard class="panel-card" title="当前考勤场次" subtitle="今日签到窗口">
          <template #header-extra>
            <StatusTag :value="currentSession.status" preset="session" />
          </template>

          <div v-if="!currentSession.available" class="empty-panel">
            <el-empty description="今天暂无可用考勤场次。" />
          </div>

          <template v-else>
            <div class="session-meta">
              <div class="meta-item">
                <span>日期</span>
                <strong>{{ currentSession.sessionDate || '-' }}</strong>
              </div>
              <div class="meta-item">
                <span>签到时间</span>
                <strong>{{ formatTime(currentSession.signStartTime) }} - {{ formatTime(currentSession.signEndTime) }}</strong>
              </div>
              <div class="meta-item">
                <span>迟到阈值</span>
                <strong>{{ formatTime(currentSession.lateTime) }}</strong>
              </div>
            </div>

            <div class="status-box-grid">
              <article class="status-box">
                <span>我的签到</span>
                <StatusTag :value="currentSession.myRecord?.signStatus" preset="attendance" />
                <small>{{ formatDateTime(currentSession.myRecord?.signTime) }}</small>
              </article>
              <article class="status-box">
                <span>请假申请</span>
                <StatusTag :value="currentSession.myLeaveRequest?.leaveStatus" preset="leave" fallback-label="无" />
                <small>{{ currentSession.myLeaveRequest?.reviewComment || currentSession.myLeaveRequest?.leaveReason || '暂无请假申请' }}</small>
              </article>
            </div>

            <el-alert
              class="session-alert"
              :closable="false"
              :type="currentSession.canSignIn ? 'success' : 'info'"
              :title="signCodeNotice"
            />

            <el-form label-width="92px" class="action-form">
              <el-form-item label="签到码">
                <el-input v-model="signForm.signCode" maxlength="12" placeholder="请输入管理员现场展示的签到码" />
              </el-form-item>
              <el-form-item label="备注">
                <el-input v-model="signForm.remark" type="textarea" :rows="3" maxlength="120" show-word-limit />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" :disabled="!currentSession.canSignIn" :loading="signing" @click="submitSignIn">
                  立即签到
                </el-button>
              </el-form-item>
            </el-form>

            <el-divider />

            <el-form label-width="92px" class="action-form">
              <el-form-item label="请假原因">
                <el-input v-model="leaveForm.leaveReason" type="textarea" :rows="3" maxlength="255" show-word-limit />
              </el-form-item>
              <el-form-item>
                <el-button
                  type="warning"
                  plain
                  :disabled="!currentSession.canApplyLeave"
                  :loading="submittingLeave"
                  @click="submitLeave"
                >
                  提交请假
                </el-button>
                <el-button
                  type="info"
                  plain
                  :disabled="currentSession.status !== 'closed'"
                  :loading="submittingMakeup"
                  @click="submitMakeup"
                >
                  申请补签
                </el-button>
              </el-form-item>
            </el-form>
          </template>
        </TablePageCard>

        <TablePageCard class="panel-card" title="近期概览" subtitle="历史统计" :count-label="`历史 ${pagination.total} 条`" count-tag-type="success">

          <div class="summary-grid">
            <MetricCard label="正常" :value="historyStats.normal" compact />
            <MetricCard label="迟到" :value="historyStats.late" compact />
            <MetricCard label="请假" :value="historyStats.leave" compact />
            <MetricCard label="补签" :value="historyStats.supplement" compact />
            <MetricCard label="缺勤" :value="historyStats.absent" compact />
            <MetricCard label="待处理" :value="historyStats.pending" compact />
          </div>
        </TablePageCard>
      </section>

      <TablePageCard title="考勤记录" subtitle="历史场次" :count-label="`${pagination.total} 条`">

        <el-table v-loading="historyLoading" :data="history" stripe>
          <el-table-column prop="sessionDate" label="日期" min-width="120" />
          <el-table-column prop="labName" label="实验室" min-width="160" />
          <el-table-column label="状态" min-width="120">
            <template #default="{ row }">
              <StatusTag :value="row.signStatus" preset="attendance" />
            </template>
          </el-table-column>
          <el-table-column label="签到时间" min-width="180">
            <template #default="{ row }">{{ formatDateTime(row.signTime) }}</template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="220" show-overflow-tooltip />
          <el-table-column label="审核时间" min-width="180">
            <template #default="{ row }">{{ formatDateTime(row.reviewTime) }}</template>
          </el-table-column>
        </el-table>

        <template #pagination>
          <el-pagination
            background
            layout="prev, pager, next, total"
            :current-page="pagination.pageNum"
            :page-size="pagination.pageSize"
            :total="pagination.total"
            @current-change="handlePageChange"
          />
        </template>
      </TablePageCard>
    </template>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import MetricCard from '@/components/common/MetricCard.vue'
import StatusTag from '@/components/common/StatusTag.vue'
import TablePageCard from '@/components/common/TablePageCard.vue'
import { getStatusLabel } from '@/utils/status-presenters'
import {
  applyAttendanceLeave,
  getCurrentStudentAttendanceSession,
  getStudentAttendanceHistory,
  requestAttendanceMakeup,
  signInStudentAttendance
} from '@/api/attendanceWorkflow'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const signing = ref(false)
const submittingLeave = ref(false)
const submittingMakeup = ref(false)
const historyLoading = ref(false)
const currentSession = reactive({
  available: false,
  status: null,
  sessionDate: '',
  signStartTime: '',
  signEndTime: '',
  lateTime: '',
  codeReady: false,
  codeExpireTime: '',
  codeRemainingSeconds: 0,
  canSignIn: false,
  canApplyLeave: false,
  myRecord: null,
  myLeaveRequest: null
})
const history = ref([])

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const signForm = reactive({
  signCode: '',
  remark: ''
})

const leaveForm = reactive({
  leaveReason: ''
})
const SESSION_POLL_INTERVAL_MS = 15000
let sessionPollTimer = null

const metricCards = computed(() => [
  {
    label: '当前状态',
    value: getStatusLabel(currentSession.myRecord?.signStatus, 'attendance'),
    tip: '今日考勤结果'
  },
  {
    label: '请假状态',
    value: getStatusLabel(currentSession.myLeaveRequest?.leaveStatus, 'leave', '无'),
    tip: '当前场次请假审批结果'
  },
  {
    label: '历史记录',
    value: pagination.total,
    tip: '累计考勤记录数'
  },
  {
    label: '当前可签到',
    value: currentSession.canSignIn ? '可以' : '不可以',
    tip: '根据签到时间与签到码校验结果'
  }
])

const signCodeNotice = computed(() => {
  if (!currentSession.available) {
    return '今天暂无可用考勤场次。'
  }
  if (currentSession.status === 'pending') {
    return '到达签到开始时间后，实验室管理员端会自动生成动态签到码并现场公布。'
  }
  if (currentSession.status === 'closed') {
    return '本场签到窗口已结束，如未签到可按需申请补签。'
  }
  if (currentSession.codeReady && currentSession.codeExpireTime) {
    return `当前使用动态签到码签到，有效至 ${formatTime(currentSession.codeExpireTime)}。`
  }
  return '签到窗口已开启，等待实验室管理员获取并公布当前动态签到码。'
})

const historyStats = computed(() => {
  const counter = {
    normal: 0,
    late: 0,
    leave: 0,
    supplement: 0,
    absent: 0,
    pending: 0
  }

  history.value.forEach((item) => {
    switch (item.signStatus) {
      case 'normal':
        counter.normal += 1
        break
      case 'late':
        counter.late += 1
        break
      case 'leave':
        counter.leave += 1
        break
      case 'makeup_pending':
      case 'makeup_rejected':
        counter.pending += 1
        break
      case 'makeup_approved':
        counter.supplement += 1
        break
      case 'absent':
        counter.absent += 1
        break
      default:
        break
    }
  })

  return counter
})

const loadCurrentSession = async () => {
  const response = await getCurrentStudentAttendanceSession()
  Object.assign(currentSession, {
    available: false,
    status: null,
    sessionDate: '',
    signStartTime: '',
    signEndTime: '',
    lateTime: '',
    codeReady: false,
    codeExpireTime: '',
    codeRemainingSeconds: 0,
    canSignIn: false,
    canApplyLeave: false,
    myRecord: null,
    myLeaveRequest: null,
    ...(response.data || {})
  })
}

const loadHistory = async () => {
  historyLoading.value = true
  try {
    const response = await getStudentAttendanceHistory({
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize
    })
    history.value = response.data?.records || []
    pagination.total = response.data?.total || 0
  } finally {
    historyLoading.value = false
  }
}

const loadPageData = async () => {
  await Promise.all([loadCurrentSession(), loadHistory()])
}

const startSessionPolling = () => {
  stopSessionPolling()
  sessionPollTimer = window.setInterval(() => {
    loadCurrentSession().catch(() => {})
  }, SESSION_POLL_INTERVAL_MS)
}

const stopSessionPolling = () => {
  if (sessionPollTimer) {
    window.clearInterval(sessionPollTimer)
    sessionPollTimer = null
  }
}

const submitSignIn = async () => {
  if (!currentSession.available) {
    return
  }
  if (!signForm.signCode.trim()) {
    ElMessage.warning('请先输入签到码')
    return
  }

  signing.value = true
  try {
    await signInStudentAttendance({
      signCode: signForm.signCode.trim(),
      remark: signForm.remark || undefined
    })
    ElMessage.success('签到已提交')
    signForm.signCode = ''
    signForm.remark = ''
    await loadPageData()
  } finally {
    signing.value = false
  }
}

const submitLeave = async () => {
  if (!currentSession.available) {
    return
  }
  if (!leaveForm.leaveReason.trim()) {
    ElMessage.warning('请先填写请假原因')
    return
  }

  submittingLeave.value = true
  try {
    await applyAttendanceLeave({
      sessionId: currentSession.id,
      leaveReason: leaveForm.leaveReason.trim()
    })
    ElMessage.success('请假申请已提交')
    leaveForm.leaveReason = ''
    await loadCurrentSession()
  } finally {
    submittingLeave.value = false
  }
}

const submitMakeup = async () => {
  submittingMakeup.value = true
  try {
    await requestAttendanceMakeup({
      remark: signForm.remark || undefined
    })
    ElMessage.success('补签申请已提交')
    await loadPageData()
  } finally {
    submittingMakeup.value = false
  }
}

const handlePageChange = (page) => {
  pagination.pageNum = page
  loadHistory()
}

const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-')
const formatTime = (value) => (value ? dayjs(value).format('HH:mm') : '-')

onMounted(() => {
  loadPageData()
  startSessionPolling()
})

onUnmounted(() => {
  stopSessionPolling()
})
</script>

<style scoped>
.session-meta {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 18px;
}

.meta-item,
.status-box {
  padding: 14px 16px;
  border-radius: 16px;
  background: rgba(248, 250, 252, 0.92);
  display: grid;
  gap: 6px;
}

.meta-item span,
.status-box span,
.status-box small {
  color: #64748b;
}

.status-box-grid,
.summary-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.action-form {
  margin-top: 12px;
}

.session-alert {
  margin-top: 14px;
}

.summary-grid :deep(.metric-card) {
  min-height: 0;
}

@media (max-width: 768px) {
  .session-meta,
  .status-box-grid,
  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
