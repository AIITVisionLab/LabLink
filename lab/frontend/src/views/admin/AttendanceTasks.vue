<template>
  <div class="page-shell">
    <section class="toolbar-card">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow">实验室签到管理台</p>
          <h2>60 秒签到会话、实时记录、结果标签和名单导出</h2>
        </div>
        <div class="toolbar-actions">
          <el-select v-if="showLabSelector" v-model="selectedLabId" placeholder="选择实验室" style="width: 220px" @change="loadPageData">
            <el-option v-for="item in labOptions" :key="item.id" :label="item.labName" :value="item.id" />
          </el-select>
          <el-date-picker v-model="selectedDate" type="date" value-format="YYYY-MM-DD" @change="loadManageList" />
          <el-button @click="loadPageData">刷新数据</el-button>
          <el-button type="primary" :loading="creatingSession" :disabled="!labId" @click="handleCreateSession">生成签到码</el-button>
          <el-button :disabled="!isSessionActive" :loading="expiringSession" @click="handleExpireSession">作废会话</el-button>
          <el-button :disabled="!isSessionActive" :loading="expiringSession" @click="handleFinalize">保存结果</el-button>
          <el-button type="success" plain :disabled="!labId" @click="handleExport">导出名单</el-button>
        </div>
      </div>
    </section>

    <div v-if="!labId" class="empty-panel">
      <el-empty description="当前账号没有可管理的实验室" />
    </div>

    <template v-else>
      <section class="metric-grid">
        <MetricCard label="总人数" :value="stats.totalCount" tip="当前实验室在册成员" />
        <MetricCard label="已签到" :value="stats.signedCount" tip="签到成功成员" />
        <MetricCard label="缺勤" :value="stats.absentCount" tip="未签到且未打标签" />
        <MetricCard label="请假" :value="stats.leaveCount" tip="管理员补标签为请假" />
        <MetricCard label="忘记签到" :value="stats.forgotCount" tip="管理员补标签为忘记签到" />
      </section>

      <section class="panel-grid">
        <article class="session-card qr-card">
          <div class="card-head">
            <div>
              <p class="panel-eyebrow">二维码</p>
              <h3>{{ hasSession ? '当前签到入口' : '等待创建签到会话' }}</h3>
            </div>
            <StatusTag :value="sessionStatusLabel" :label-map="sessionStatusLabels" :type-map="sessionStatusTypes" />
          </div>

          <div v-if="isSessionCodeVisible" class="qr-wrap">
            <img v-if="qrCodeDataUrl" class="qr-image" :src="qrCodeDataUrl" alt="签到二维码" />
            <div v-else class="qr-placeholder">QR</div>
            <p class="qr-tip">学生可扫码进入移动端签到页，也可直接输入签到码。</p>
          </div>
          <el-empty v-else description="创建会话后显示二维码" :image-size="88" />
        </article>

        <article class="session-card">
          <div class="card-head">
            <div>
              <p class="panel-eyebrow">当前会话</p>
              <h3>{{ activeSession.sessionNo || '暂无最近会话' }}</h3>
            </div>
            <div class="session-code">{{ visibleSignCode }}</div>
          </div>

          <div class="summary-grid">
            <div class="summary-item">
              <span>状态</span>
              <strong>{{ sessionStatusText }}</strong>
            </div>
            <div class="summary-item">
              <span>剩余时间</span>
              <strong>{{ remainingText }}</strong>
            </div>
            <div class="summary-item">
              <span>过期时间</span>
              <strong>{{ formatDateTime(activeSession.expireTime) }}</strong>
            </div>
            <div class="summary-item">
              <span>说明</span>
              <strong>{{ sessionHint }}</strong>
            </div>
          </div>
        </article>
      </section>

      <TablePageCard title="实时签到记录" subtitle="当前会话">
        <el-table :data="sessionRecords" stripe>
          <el-table-column prop="realName" label="姓名" min-width="140" />
          <el-table-column prop="studentId" label="学号" min-width="120" />
          <el-table-column label="签到时间" min-width="180">
            <template #default="{ row }">{{ formatDateTime(row.signTime) }}</template>
          </el-table-column>
          <el-table-column label="签到方式" min-width="120">
            <template #default="{ row }">{{ signMethodLabel(row.signMethod) }}</template>
          </el-table-column>
          <el-table-column prop="statusLabel" label="状态" min-width="120" />
        </el-table>
      </TablePageCard>

      <TablePageCard title="当日考勤名单" subtitle="最终归档结果" :count-label="`${attendanceRows.length} 条`">
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
          <el-table-column label="操作" min-width="180" fixed="right">
            <template #default="{ row }">
              <template v-if="canTagRow(row)">
                <el-button link type="warning" @click="handleTag(row, 'leave')">标记请假</el-button>
                <el-button link type="primary" @click="handleTag(row, 'forgot')">标记忘记签到</el-button>
              </template>
              <span v-else class="muted-text">已归档</span>
            </template>
          </el-table-column>
        </el-table>
      </TablePageCard>
    </template>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import QRCode from 'qrcode'
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import MetricCard from '@/components/common/MetricCard.vue'
import StatusTag from '@/components/common/StatusTag.vue'
import TablePageCard from '@/components/common/TablePageCard.vue'
import {
  createAttendanceSession,
  exportAttendanceManage,
  expireAttendanceSession,
  finalizeAttendanceSession,
  getActiveAttendanceSession,
  getAttendanceManageList,
  getAttendanceSessionRecords,
  tagAttendanceManage
} from '@/api/attendance'
import { getLabPage } from '@/api/lab'
import { useUserStore } from '@/stores/user'
import { createSessionCountdown } from '@/utils/attendanceSession'
import { buildPublicAppUrl } from '@/utils/public-url'

const userStore = useUserStore()
const labOptions = ref([])
const selectedLabId = ref(null)
const hasBroadLabScope = computed(() => Boolean(userStore.userInfo?.schoolDirector || userStore.userInfo?.collegeManager))
const showLabSelector = computed(() => hasBroadLabScope.value)
const fixedLabId = computed(() => {
  if (userStore.userInfo?.managedLabId) {
    return userStore.userInfo.managedLabId
  }
  return hasBroadLabScope.value ? null : (userStore.userInfo?.labId || null)
})
const labId = computed(() => selectedLabId.value || fixedLabId.value || null)
const selectedDate = ref(dayjs().format('YYYY-MM-DD'))
const creatingSession = ref(false)
const expiringSession = ref(false)
const qrCodeDataUrl = ref('')
const sessionRecords = ref([])
const attendanceRows = ref([])

const activeSession = reactive({
  id: null,
  sessionNo: '',
  signCode: '',
  qrCodeContent: '',
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
const isSessionCodeVisible = computed(() => isSessionActive.value && (activeSession.remainingSeconds || 0) > 0)
const visibleSignCode = computed(() => (isSessionCodeVisible.value ? (activeSession.signCode || '------') : '------'))
const sessionStatusLabels = {
  active: '进行中',
  expired: '已过期',
  cancelled: '已作废',
  idle: '未开始'
}
const sessionStatusTypes = {
  active: 'success',
  expired: 'warning',
  cancelled: 'info',
  idle: 'info'
}
const sessionStatusLabel = computed(() => (hasSession.value ? (activeSession.status || 'idle') : 'idle'))
const sessionStatusText = computed(() => sessionStatusLabels[sessionStatusLabel.value] || sessionStatusLabels.idle)
const remainingText = computed(() => {
  if (!hasSession.value) {
    return '-'
  }
  if (isSessionActive.value) {
    return `${Math.max(activeSession.remainingSeconds || 0, 0)} 秒`
  }
  return '0 秒'
})
const sessionHint = computed(() => {
  if (!hasSession.value) {
    return '点击生成签到码开始一个 60 秒签到会话。'
  }
  if (activeSession.status === 'expired') {
    return '本次会话已自动结束，签到码只在有效签到时段内显示。'
  }
  if (activeSession.status === 'cancelled') {
    return '本次会话已作废，签到码只在有效签到时段内显示。'
  }
  return '会话到期后会自动沉淀当日结果。'
})

watch(
  () => activeSession.qrCodeContent,
  async (value) => {
    if (!value) {
      qrCodeDataUrl.value = ''
      return
    }
    qrCodeDataUrl.value = await QRCode.toDataURL(buildPublicAppUrl(value), {
      width: 220,
      margin: 1
    })
  },
  { immediate: true }
)

const loadActiveSession = async () => {
  const response = await getActiveAttendanceSession({ labId: labId.value })
  Object.assign(activeSession, {
    id: null,
    sessionNo: '',
    signCode: '',
    qrCodeContent: '',
    status: '',
    expireTime: '',
    remainingSeconds: 0,
    ...(response.data || {})
  })
  sessionCountdown.restart()
  if (activeSession.id) {
    await loadSessionRecords(activeSession.id)
    return
  }
  sessionRecords.value = []
}

const loadSessionRecords = async (sessionId = activeSession.id) => {
  if (!sessionId) {
    sessionRecords.value = []
    return
  }
  const response = await getAttendanceSessionRecords({ sessionId })
  sessionRecords.value = response.data?.records || []
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

const loadLabOptions = async () => {
  if (!showLabSelector.value) {
    return
  }
  const response = await getLabPage({
    pageNum: 1,
    pageSize: 500,
    collegeId: userStore.userInfo?.managedCollegeId
  })
  labOptions.value = response.data?.records || []
  if (!selectedLabId.value) {
    const preferredLabId = userStore.userInfo?.labId || userStore.userInfo?.managedLabId || null
    selectedLabId.value = labOptions.value.find((item) => item.id === preferredLabId)?.id || labOptions.value[0]?.id || null
  }
}

const handleCreateSession = async () => {
  creatingSession.value = true
  try {
    const response = await createAttendanceSession({ labId: labId.value })
    Object.assign(activeSession, {
      id: null,
      sessionNo: '',
      signCode: '',
      qrCodeContent: '',
      status: '',
      expireTime: '',
      remainingSeconds: 0,
      ...(response.data || {})
    })
    sessionCountdown.restart()
    await Promise.all([loadSessionRecords(response.data?.id), loadManageList()])
    ElMessage.success('签到会话已创建')
  } finally {
    creatingSession.value = false
  }
}

const closeSession = async (action, message) => {
  if (!activeSession.id) {
    ElMessage.info('当前没有可处理的会话')
    return
  }
  expiringSession.value = true
  try {
    await action({ sessionId: activeSession.id })
    await loadPageData()
    ElMessage.success(message)
  } finally {
    expiringSession.value = false
  }
}

const handleExpireSession = async () => {
  const confirmed = await ElMessageBox.confirm('作废会话会立即结束签到并沉淀当日结果，是否继续？', '作废会话', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).catch(() => false)
  if (!confirmed) {
    return
  }
  await closeSession(expireAttendanceSession, '会话已作废并归档')
}

const handleFinalize = async () => {
  const confirmed = await ElMessageBox.confirm('这会立即结束签到并保存当前结果，是否继续？', '保存结果', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).catch(() => false)
  if (!confirmed) {
    return
  }
  await closeSession(finalizeAttendanceSession, '结果已保存并归档')
}

const handleTag = async (row, tagType) => {
  const title = tagType === 'leave' ? '标记请假' : '标记忘记签到'
  const result = await ElMessageBox.prompt('可填写备注，直接确认则留空。', title, {
    confirmButtonText: '保存',
    cancelButtonText: '取消',
    inputValue: row.reason || ''
  }).catch(() => null)
  if (!result) {
    return
  }
  await tagAttendanceManage({
    attendanceId: row.attendanceId,
    tagType,
    reason: result.value || ''
  })
  ElMessage.success('标签已保存')
  await loadManageList()
}

const canTagRow = (row) => {
  const status = Number(row?.status)
  return status === 3 || status === 4 || row?.tagType === 'leave' || row?.tagType === 'forgot'
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
  loadLabOptions().then(loadPageData)
})

onUnmounted(() => {
  sessionCountdown.stop()
})
</script>

<style scoped>
.panel-grid {
  display: grid;
  grid-template-columns: 320px minmax(0, 1fr);
  gap: 16px;
}

.session-card {
  padding: 20px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.qr-card {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(240, 249, 255, 0.96));
}

.card-head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
}

.panel-eyebrow,
.qr-tip,
.summary-item span,
.muted-text {
  color: #64748b;
}

.panel-eyebrow {
  margin: 0 0 8px;
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.card-head h3 {
  margin: 0;
  font-size: 22px;
  color: #0f172a;
}

.session-code {
  min-width: 140px;
  padding: 10px 14px;
  border-radius: 16px;
  background: rgba(15, 23, 42, 0.08);
  font-size: 28px;
  font-weight: 800;
  letter-spacing: 0.2em;
  text-align: center;
  color: #0f172a;
}

.qr-wrap {
  display: grid;
  place-items: center;
  gap: 14px;
  margin-top: 22px;
}

.qr-image,
.qr-placeholder {
  width: 220px;
  height: 220px;
  border-radius: 24px;
  border: 1px solid rgba(226, 232, 240, 0.9);
  background: #fff;
}

.qr-placeholder {
  display: grid;
  place-items: center;
  font-size: 42px;
  font-weight: 800;
  color: #94a3b8;
}

.summary-grid {
  margin-top: 22px;
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

.summary-item strong {
  color: #0f172a;
}

@media (max-width: 960px) {
  .panel-grid {
    grid-template-columns: 1fr;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
