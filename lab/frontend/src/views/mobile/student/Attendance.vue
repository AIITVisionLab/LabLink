<template>
  <div class="m-page">
    <section v-if="!userStore.userInfo?.labId" class="empty-card">
      <el-empty description="加入实验室后才能使用考勤功能" :image-size="88" />
    </section>

    <template v-else>
      <section class="hero-card">
        <div>
          <p class="eyebrow">Attendance</p>
          <h1>{{ currentSession.available ? '今日签到' : '今日暂无签到' }}</h1>
          <p>{{ signNotice }}</p>
        </div>
        <button class="refresh-btn" type="button" :disabled="loading" @click="loadPageData">刷新</button>
      </section>

      <section v-if="currentSession.available" class="grid-card">
        <article class="info-card">
          <span>签到日期</span>
          <strong>{{ currentSession.sessionDate || '-' }}</strong>
        </article>
        <article class="info-card">
          <span>签到时间</span>
          <strong>{{ formatTime(currentSession.signStartTime) }} - {{ formatTime(currentSession.signEndTime) }}</strong>
        </article>
        <article class="info-card">
          <span>迟到阈值</span>
          <strong>{{ formatTime(currentSession.lateTime) }}</strong>
        </article>
        <article class="info-card">
          <span>当前状态</span>
          <strong>{{ sessionStatusLabel(currentSession.status) }}</strong>
        </article>
      </section>

      <section v-if="currentSession.available" class="panel-card">
        <header class="panel-head">
          <h2>签到操作</h2>
          <span class="status-tag">{{ attendanceStatusLabel(currentSession.myRecord?.signStatus) }}</span>
        </header>
        <el-form label-position="top">
          <el-form-item label="签到码">
            <el-input v-model="signForm.signCode" maxlength="12" placeholder="输入管理员现场展示的签到码" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="signForm.remark" type="textarea" :rows="3" maxlength="120" show-word-limit />
          </el-form-item>
          <el-button type="primary" :disabled="!currentSession.canSignIn" :loading="signing" @click="submitSignIn">
            立即签到
          </el-button>
        </el-form>
      </section>

      <section v-if="currentSession.available" class="panel-card">
        <header class="panel-head">
          <h2>请假 / 补签</h2>
          <span class="muted">{{ leaveStatusLabel(currentSession.myLeaveRequest?.leaveStatus) }}</span>
        </header>
        <el-form label-position="top">
          <el-form-item label="请假原因">
            <el-input v-model="leaveForm.leaveReason" type="textarea" :rows="3" maxlength="255" show-word-limit />
          </el-form-item>
          <div class="button-row">
            <el-button type="warning" plain :disabled="!currentSession.canApplyLeave" :loading="submittingLeave" @click="submitLeave">
              提交请假
            </el-button>
            <el-button type="info" plain :disabled="currentSession.status !== 'closed'" :loading="submittingMakeup" @click="submitMakeup">
              申请补签
            </el-button>
          </div>
        </el-form>
      </section>

      <section class="panel-card">
        <header class="panel-head">
          <h2>历史记录</h2>
          <span>{{ total }} 条</span>
        </header>
        <div v-if="history.length" class="history-list">
          <article v-for="item in history" :key="item.id || `${item.sessionDate}-${item.signTime}`" class="history-card">
            <div class="history-head">
              <strong>{{ item.sessionDate || '-' }}</strong>
              <span class="status-chip">{{ attendanceStatusLabel(item.signStatus) }}</span>
            </div>
            <p>签到时间：{{ formatDateTime(item.signTime) }}</p>
            <p>审核时间：{{ formatDateTime(item.reviewTime) }}</p>
            <p>备注：{{ item.remark || '无' }}</p>
          </article>
        </div>
        <el-empty v-else description="暂无考勤记录" :image-size="80" />
      </section>

      <div class="load-more">
        <el-button v-if="hasMore" plain :loading="historyLoadingMore" @click="fetchMoreHistory">加载更多</el-button>
      </div>
    </template>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import {
  applyAttendanceLeave,
  getCurrentStudentAttendanceSession,
  getStudentAttendanceHistory,
  requestAttendanceMakeup,
  signInStudentAttendance
} from '@/api/attendanceWorkflow'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const loading = ref(false)
const signing = ref(false)
const submittingLeave = ref(false)
const submittingMakeup = ref(false)
const historyLoadingMore = ref(false)
const currentSession = reactive({})
const history = ref([])
const pageNum = ref(1)
const pageSize = 10
const total = ref(0)
let timer = null

const signForm = reactive({
  signCode: '',
  remark: ''
})

const leaveForm = reactive({
  leaveReason: ''
})

const hasMore = computed(() => history.value.length < total.value)
const signNotice = computed(() => {
  if (!currentSession.available) {
    return '到达签到时间后，管理员端会自动生成动态签到码。'
  }
  if (currentSession.status === 'pending') {
    return '签到窗口尚未开始，请等待实验室管理员现场公布动态签到码。'
  }
  if (currentSession.status === 'closed') {
    return '本场签到已经结束，如有需要可申请补签。'
  }
  return '请向实验室管理员获取当前动态签到码后完成签到。'
})

const loadCurrentSession = async () => {
  const response = await getCurrentStudentAttendanceSession()
  Object.assign(currentSession, response.data || { available: false })
}

const fetchHistoryPage = async (page) => {
  const response = await getStudentAttendanceHistory({ pageNum: page, pageSize })
  total.value = Number(response.data?.total || 0)
  return response.data?.records || []
}

const loadHistory = async () => {
  pageNum.value = 1
  history.value = await fetchHistoryPage(1)
}

const fetchMoreHistory = async () => {
  if (historyLoadingMore.value || !hasMore.value) {
    return
  }
  historyLoadingMore.value = true
  try {
    const nextPage = pageNum.value + 1
    const list = await fetchHistoryPage(nextPage)
    pageNum.value = nextPage
    history.value = history.value.concat(list)
  } finally {
    historyLoadingMore.value = false
  }
}

const loadPageData = async () => {
  loading.value = true
  try {
    await Promise.all([loadCurrentSession(), loadHistory()])
  } finally {
    loading.value = false
  }
}

const submitSignIn = async () => {
  if (!signForm.signCode.trim()) {
    ElMessage.warning('请输入签到码')
    return
  }
  signing.value = true
  try {
    await signInStudentAttendance({ signCode: signForm.signCode.trim(), remark: signForm.remark || undefined })
    signForm.signCode = ''
    signForm.remark = ''
    ElMessage.success('签到成功')
    await loadPageData()
  } finally {
    signing.value = false
  }
}

const submitLeave = async () => {
  if (!leaveForm.leaveReason.trim()) {
    ElMessage.warning('请填写请假原因')
    return
  }
  submittingLeave.value = true
  try {
    await applyAttendanceLeave({ sessionId: currentSession.id, leaveReason: leaveForm.leaveReason.trim() })
    leaveForm.leaveReason = ''
    ElMessage.success('请假申请已提交')
    await loadCurrentSession()
  } finally {
    submittingLeave.value = false
  }
}

const submitMakeup = async () => {
  submittingMakeup.value = true
  try {
    await requestAttendanceMakeup({ remark: signForm.remark || undefined })
    ElMessage.success('补签申请已提交')
    await loadPageData()
  } finally {
    submittingMakeup.value = false
  }
}

const startPolling = () => {
  stopPolling()
  timer = window.setInterval(() => {
    loadCurrentSession().catch(() => {})
  }, 15000)
}

const stopPolling = () => {
  if (timer) {
    window.clearInterval(timer)
    timer = null
  }
}

const sessionStatusLabel = (status) => ({ pending: '未开始', active: '进行中', closed: '已结束' }[status] || '未知')
const attendanceStatusLabel = (status) => ({
  normal: '正常',
  late: '迟到',
  leave: '请假',
  absent: '缺勤',
  makeup_pending: '补签待审',
  makeup_approved: '补签通过',
  makeup_rejected: '补签驳回'
}[status] || '待处理')
const leaveStatusLabel = (status) => ({ pending: '请假待审', approved: '请假通过', rejected: '请假驳回' }[status] || '暂无请假')
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
.grid-card,
.panel-card,
.empty-card {
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.hero-card {
  padding: 18px;
  background: linear-gradient(145deg, rgba(15, 23, 42, 0.94), rgba(37, 99, 235, 0.88));
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
  opacity: 0.8;
}

.hero-card h1 {
  margin: 0 0 8px;
  font-size: 22px;
}

.hero-card p {
  margin: 0;
  color: rgba(226, 232, 240, 0.9);
  line-height: 1.6;
}

.refresh-btn {
  height: fit-content;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.12);
  color: #f8fafc;
  border-radius: 14px;
  padding: 10px 14px;
}

.grid-card {
  padding: 14px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.info-card {
  border-radius: 14px;
  padding: 12px;
  background: #ffffff;
  border: 1px solid rgba(226, 232, 240, 0.86);
  display: grid;
  gap: 4px;
}

.info-card span,
.info-card small,
.history-card p,
.muted {
  color: #64748b;
}

.info-card strong,
.panel-head h2,
.history-card strong {
  color: #0f172a;
}

.panel-card {
  padding: 14px;
}

.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.panel-head h2 {
  margin: 0;
  font-size: 16px;
}

.status-tag,
.status-chip {
  color: #2563eb;
  background: rgba(219, 234, 254, 0.9);
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.button-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.history-list {
  display: grid;
  gap: 10px;
}

.history-card {
  border-radius: 16px;
  padding: 12px;
  background: #ffffff;
  border: 1px solid rgba(226, 232, 240, 0.86);
}

.history-head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 8px;
}

.history-card p {
  margin: 6px 0 0;
}

.load-more {
  display: flex;
  justify-content: center;
}

@media (max-width: 480px) {
  .grid-card {
    grid-template-columns: 1fr;
  }
}
</style>
