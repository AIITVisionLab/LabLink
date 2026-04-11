<template>
  <div class="m-page">
    <section class="metric-grid">
      <article v-for="card in summaryCards" :key="card.label" class="metric-card">
        <span>{{ card.label }}</span>
        <strong>{{ card.value }}</strong>
        <small>{{ card.tip }}</small>
      </article>
    </section>

    <section v-if="canManageTasks" class="toolbar-card">
      <el-input v-model="filters.keyword" clearable placeholder="搜索学期或任务名称" @keyup.enter="loadTasks" />
      <el-select v-if="isSchoolDirector" v-model="filters.collegeId" clearable placeholder="学院" style="width: 120px" @change="loadTasks">
        <el-option v-for="item in colleges" :key="item.id" :label="item.collegeName" :value="item.id" />
      </el-select>
      <el-button type="primary" @click="openTaskDialog()">新建任务</el-button>
    </section>

    <section v-if="canManageTasks" class="card-list">
      <article v-for="row in tasks" :key="row.id" class="record-card">
        <div class="card-head">
          <div>
            <strong>{{ row.taskName || '未命名任务' }}</strong>
            <p>{{ row.collegeName || '-' }} · {{ row.semesterName || '-' }}</p>
          </div>
          <span class="status-pill" :class="row.status === 'published' ? 'success' : 'default'">
            {{ row.status === 'published' ? '已发布' : '草稿' }}
          </span>
        </div>
        <div class="meta-grid">
          <div><span>日期范围</span><strong>{{ row.startDate || '-' }} ~ {{ row.endDate || '-' }}</strong></div>
          <div><span>排班数</span><strong>{{ row.scheduleCount || 0 }}</strong></div>
        </div>
        <div class="action-row">
          <el-button text type="primary" @click="openTaskDialog(row)">编辑</el-button>
          <el-button text type="warning" @click="openScheduleDialog(row)">排班</el-button>
          <el-button v-if="row.status !== 'published'" text type="success" @click="publishTaskAction(row)">发布</el-button>
        </div>
      </article>
    </section>

    <section v-if="hasLabScope" class="panel-card">
      <header class="panel-head">
        <h2>当前签到场次</h2>
        <span class="status-pill" :class="sessionStatusClass">{{ sessionStatusLabel }}</span>
      </header>
      <div v-if="!currentSession.id" class="empty-wrap">
        <el-empty description="当前没有进行中的签到场次" :image-size="80" />
      </div>
      <template v-else>
        <div class="meta-grid four">
          <div><span>日期</span><strong>{{ currentSession.sessionDate || '-' }}</strong></div>
          <div><span>签到窗口</span><strong>{{ formatTime(currentSession.signStartTime) }} - {{ formatTime(currentSession.signEndTime) }}</strong></div>
          <div><span>动态码</span><strong>{{ sessionCodeDisplay }}</strong></div>
          <div><span>出勤率</span><strong>{{ currentSession.attendanceRate ?? 0 }}%</strong></div>
        </div>
        <div class="action-row top-gap">
          <el-upload :show-file-list="false" :http-request="handlePhotoUpload">
            <el-button plain :loading="uploadingPhoto">上传现场照片</el-button>
          </el-upload>
        </div>
        <div v-if="currentSession.records?.length" class="record-list top-gap">
          <article v-for="item in currentSession.records" :key="item.userId || item.studentId" class="member-card">
            <div>
              <strong>{{ item.realName || '-' }}</strong>
              <p>{{ item.studentId || '-' }} · {{ item.memberRole || 'member' }}</p>
              <small>{{ attendanceStatusLabel(item.signStatus) }} · {{ formatDateTime(item.signTime) }}</small>
            </div>
            <div class="action-row vertical">
              <el-button v-if="canReviewRecords" text type="primary" @click="openReviewDialog(item)">修正</el-button>
            </div>
          </article>
        </div>
      </template>
    </section>

    <section v-if="hasLabScope" class="panel-card">
      <header class="panel-head">
        <h2>请假审批</h2>
        <span>{{ leaveTotal }} 条</span>
      </header>
      <div class="toolbar-card compact">
        <el-input v-model="leaveFilters.keyword" clearable placeholder="搜索姓名、学号或原因" @keyup.enter="loadLeaves" />
        <el-select v-model="leaveFilters.leaveStatus" clearable placeholder="状态" style="width: 120px" @change="loadLeaves">
          <el-option label="待审批" value="PENDING" />
          <el-option label="已通过" value="APPROVED" />
          <el-option label="已驳回" value="REJECTED" />
        </el-select>
      </div>
      <div v-if="leaveRows.length" class="record-list top-gap">
        <article v-for="row in leaveRows" :key="row.id" class="member-card">
          <div>
            <strong>{{ row.realName || '-' }}</strong>
            <p>{{ row.studentId || '-' }} · {{ row.sessionDate || '-' }}</p>
            <small>{{ row.leaveReason || '未填写请假原因' }}</small>
          </div>
          <div class="action-row vertical">
            <span class="status-pill" :class="leaveStatusClass(row.leaveStatus)">{{ leaveStatusLabel(row.leaveStatus) }}</span>
            <el-button v-if="canReviewRecords && row.leaveStatus === 'PENDING'" text type="success" @click="reviewLeave(row, true)">通过</el-button>
            <el-button v-if="canReviewRecords && row.leaveStatus === 'PENDING'" text type="danger" @click="reviewLeave(row, false)">驳回</el-button>
          </div>
        </article>
      </div>
      <el-empty v-else description="暂无请假申请" :image-size="80" />
    </section>

    <el-drawer v-model="taskDialogVisible" :title="taskForm.id ? '编辑任务' : '新建任务'" size="92%">
      <div class="drawer-body">
        <el-form label-position="top">
          <el-form-item label="学院">
            <el-select v-model="taskForm.collegeId" :disabled="!isSchoolDirector" placeholder="请选择学院" style="width: 100%">
              <el-option v-for="item in colleges" :key="item.id" :label="item.collegeName" :value="item.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="学期">
            <el-input v-model="taskForm.semesterName" />
          </el-form-item>
          <el-form-item label="任务名称">
            <el-input v-model="taskForm.taskName" />
          </el-form-item>
          <el-form-item label="日期范围">
            <el-date-picker v-model="taskDateRange" type="daterange" unlink-panels value-format="YYYY-MM-DD" style="width: 100%" />
          </el-form-item>
          <el-form-item label="说明">
            <el-input v-model="taskForm.description" type="textarea" :rows="4" maxlength="200" show-word-limit />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <div class="drawer-actions">
          <el-button @click="taskDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="savingTask" @click="saveTaskAction">保存</el-button>
        </div>
      </template>
    </el-drawer>

    <el-drawer v-model="scheduleDialogVisible" title="任务排班" size="92%">
      <div class="drawer-body">
        <div class="action-row between">
          <strong>{{ currentTask?.taskName || '-' }}</strong>
          <el-button type="primary" plain @click="addSchedule">新增一条</el-button>
        </div>
        <div class="schedule-list top-gap">
          <article v-for="(row, index) in scheduleRows" :key="index" class="schedule-card">
            <div class="schedule-head">
              <strong>排班 {{ index + 1 }}</strong>
              <el-button text type="danger" @click="removeSchedule(index)">删除</el-button>
            </div>
            <el-form label-position="top">
              <el-form-item label="星期">
                <el-select v-model="row.weekDay" style="width: 100%">
                  <el-option v-for="item in weekOptions" :key="item.value" :label="item.label" :value="item.value" />
                </el-select>
              </el-form-item>
              <el-form-item label="开始时间">
                <el-time-picker v-model="row.signInStart" value-format="HH:mm:ss" style="width: 100%" />
              </el-form-item>
              <el-form-item label="结束时间">
                <el-time-picker v-model="row.signInEnd" value-format="HH:mm:ss" style="width: 100%" />
              </el-form-item>
              <div class="meta-grid">
                <div>
                  <span>迟到阈值(分钟)</span>
                  <el-input-number v-model="row.lateThresholdMinutes" :min="1" :max="120" style="width: 100%" />
                </div>
                <div>
                  <span>签到码长度</span>
                  <el-input-number v-model="row.signCodeLength" :min="4" :max="6" style="width: 100%" />
                </div>
                <div>
                  <span>有效期(分钟)</span>
                  <el-input-number v-model="row.codeTtlMinutes" :min="1" :max="180" style="width: 100%" />
                </div>
              </div>
            </el-form>
          </article>
        </div>
      </div>
      <template #footer>
        <div class="drawer-actions">
          <el-button @click="scheduleDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="savingSchedules" @click="saveSchedulesAction">保存排班</el-button>
        </div>
      </template>
    </el-drawer>

    <el-dialog v-model="reviewDialogVisible" title="修正考勤记录" width="92%">
      <el-form label-position="top">
        <el-form-item label="学生">
          <el-input :model-value="`${reviewForm.realName} / ${reviewForm.studentId}`" disabled />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="reviewForm.signStatus" style="width: 100%">
            <el-option label="正常" value="normal" />
            <el-option label="迟到" value="late" />
            <el-option label="请假" value="leave" />
            <el-option label="缺勤" value="absent" />
            <el-option label="补签" value="supplement" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="reviewForm.remark" type="textarea" :rows="3" maxlength="120" show-word-limit />
        </el-form-item>
        <el-form-item label="修正原因">
          <el-input v-model="reviewForm.changedReason" type="textarea" :rows="3" maxlength="120" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="drawer-actions">
          <el-button @click="reviewDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="savingReview" @click="submitReview">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  approveAttendanceLeave,
  getAttendanceLeavePage,
  getAttendanceTaskPage,
  getAttendanceTaskSchedules,
  getCurrentLabAttendanceSession,
  publishAttendanceTask,
  rejectAttendanceLeave,
  reviewAttendanceRecord,
  saveAttendanceTask,
  saveAttendanceTaskSchedules,
  uploadAttendanceSessionPhoto
} from '@/api/attendanceWorkflow'
import { getCollegeOptions } from '@/api/colleges'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const tasks = ref([])
const colleges = ref([])
const leaveRows = ref([])
const leaveTotal = ref(0)
const taskDialogVisible = ref(false)
const scheduleDialogVisible = ref(false)
const reviewDialogVisible = ref(false)
const savingTask = ref(false)
const savingSchedules = ref(false)
const savingReview = ref(false)
const uploadingPhoto = ref(false)
const currentTask = ref(null)
const scheduleRows = ref([])
const taskDateRange = ref([])
let sessionPollTimer = null

const filters = reactive({
  collegeId: undefined,
  keyword: ''
})

const leaveFilters = reactive({
  leaveStatus: 'PENDING',
  keyword: ''
})

const taskForm = reactive({
  id: null,
  collegeId: undefined,
  semesterName: '',
  taskName: '',
  description: '',
  startDate: '',
  endDate: ''
})

const reviewForm = reactive({
  sessionId: null,
  userId: null,
  realName: '',
  studentId: '',
  signStatus: 'normal',
  remark: '',
  changedReason: ''
})

const currentSession = reactive({
  id: null,
  status: null,
  sessionDate: '',
  signStartTime: '',
  signEndTime: '',
  sessionCode: '',
  codeReady: false,
  codeExpireTime: '',
  attendanceRate: 0,
  records: []
})

const isSchoolDirector = computed(() => Boolean(userStore.userInfo?.schoolDirector))
const canManageTasks = computed(() => userStore.hasPermission('attendance:task:manage'))
const canReviewRecords = computed(() => userStore.hasPermission('attendance:record:manage'))
const hasLabScope = computed(() => Boolean(userStore.userInfo?.managedLabId || userStore.userInfo?.labId))

const summaryCards = computed(() => [
  { label: '任务数', value: tasks.value.length, tip: '当前筛选范围下的任务数量' },
  { label: '已发布', value: tasks.value.filter((item) => item.status === 'published').length, tip: '已进入执行状态的任务' },
  { label: '待批请假', value: leaveRows.value.filter((item) => item.leaveStatus === 'PENDING').length, tip: '当前待审核请假申请' },
  { label: '当前记录', value: currentSession.records?.length || 0, tip: '当前签到场次成员记录数' }
])

const sessionCodeDisplay = computed(() => {
  if (!currentSession.id) return '-'
  if (currentSession.status === 'pending') return '待开始'
  if (currentSession.status === 'closed') return '已关闭'
  if (currentSession.codeReady && currentSession.sessionCode) return currentSession.sessionCode
  return '生成中'
})

const sessionStatusLabel = computed(() => ({ pending: '未开始', active: '进行中', closed: '已结束' }[currentSession.status] || '未知'))
const sessionStatusClass = computed(() => ({ pending: 'pending', active: 'progress', closed: 'default' }[currentSession.status] || 'default'))

const weekOptions = [
  { label: '周一', value: 1 },
  { label: '周二', value: 2 },
  { label: '周三', value: 3 },
  { label: '周四', value: 4 },
  { label: '周五', value: 5 },
  { label: '周六', value: 6 },
  { label: '周日', value: 7 }
]

const resetTaskForm = () => {
  taskForm.id = null
  taskForm.collegeId = userStore.userInfo?.managedCollegeId || undefined
  taskForm.semesterName = ''
  taskForm.taskName = ''
  taskForm.description = ''
  taskForm.startDate = ''
  taskForm.endDate = ''
  taskDateRange.value = []
}

const loadColleges = async () => {
  if (!canManageTasks.value) return
  const response = await getCollegeOptions()
  colleges.value = response.data || []
  if (!isSchoolDirector.value) {
    filters.collegeId = userStore.userInfo?.managedCollegeId
  }
}

const loadTasks = async () => {
  if (!canManageTasks.value) {
    tasks.value = []
    return
  }
  const response = await getAttendanceTaskPage({
    pageNum: 1,
    pageSize: 50,
    collegeId: isSchoolDirector.value ? filters.collegeId : userStore.userInfo?.managedCollegeId,
    keyword: filters.keyword || undefined
  })
  tasks.value = response.data?.records || []
}

const loadCurrentSession = async () => {
  if (!hasLabScope.value) {
    Object.assign(currentSession, {
      id: null,
      status: null,
      sessionDate: '',
      signStartTime: '',
      signEndTime: '',
      sessionCode: '',
      codeReady: false,
      codeExpireTime: '',
      attendanceRate: 0,
      records: []
    })
    return
  }
  const response = await getCurrentLabAttendanceSession()
  Object.assign(currentSession, {
    id: null,
    status: null,
    sessionDate: '',
    signStartTime: '',
    signEndTime: '',
    sessionCode: '',
    codeReady: false,
    codeExpireTime: '',
    attendanceRate: 0,
    records: [],
    ...(response.data || {})
  })
}

const loadLeaves = async () => {
  if (!hasLabScope.value) {
    leaveRows.value = []
    leaveTotal.value = 0
    return
  }
  const response = await getAttendanceLeavePage({
    pageNum: 1,
    pageSize: 20,
    leaveStatus: leaveFilters.leaveStatus || undefined,
    keyword: leaveFilters.keyword || undefined
  })
  leaveRows.value = response.data?.records || []
  leaveTotal.value = Number(response.data?.total || 0)
}

const loadPageData = async () => {
  await Promise.all([loadColleges(), loadTasks(), loadCurrentSession(), loadLeaves()])
}

const openTaskDialog = (row = null) => {
  resetTaskForm()
  if (row) {
    taskForm.id = row.id
    taskForm.collegeId = row.collegeId
    taskForm.semesterName = row.semesterName || ''
    taskForm.taskName = row.taskName || ''
    taskForm.description = row.description || ''
    taskForm.startDate = row.startDate || ''
    taskForm.endDate = row.endDate || ''
    taskDateRange.value = row.startDate && row.endDate ? [row.startDate, row.endDate] : []
  }
  taskDialogVisible.value = true
}

const saveTaskAction = async () => {
  if (!taskForm.collegeId || !taskForm.semesterName.trim() || !taskForm.taskName.trim() || taskDateRange.value.length !== 2) {
    ElMessage.warning('请完整填写任务信息')
    return
  }
  savingTask.value = true
  try {
    taskForm.startDate = taskDateRange.value[0]
    taskForm.endDate = taskDateRange.value[1]
    await saveAttendanceTask({ ...taskForm })
    ElMessage.success('任务已保存')
    taskDialogVisible.value = false
    await loadTasks()
  } finally {
    savingTask.value = false
  }
}

const openScheduleDialog = async (row) => {
  currentTask.value = row
  const response = await getAttendanceTaskSchedules(row.id)
  scheduleRows.value = (response.data || []).map((item) => ({
    id: item.id,
    weekDay: item.weekDay,
    signInStart: item.signInStart,
    signInEnd: item.signInEnd,
    lateThresholdMinutes: item.lateThresholdMinutes || 15,
    signCodeLength: item.signCodeLength || 4,
    codeTtlMinutes: item.codeTtlMinutes || 90,
    remark: item.remark || ''
  }))
  if (!scheduleRows.value.length) {
    addSchedule()
  }
  scheduleDialogVisible.value = true
}

const addSchedule = () => {
  scheduleRows.value.push({
    weekDay: 1,
    signInStart: '18:30:00',
    signInEnd: '21:30:00',
    lateThresholdMinutes: 15,
    signCodeLength: 4,
    codeTtlMinutes: 90,
    remark: ''
  })
}

const removeSchedule = (index) => {
  scheduleRows.value.splice(index, 1)
}

const saveSchedulesAction = async () => {
  if (!currentTask.value?.id || !scheduleRows.value.length) {
    ElMessage.warning('请至少保留一条排班')
    return
  }
  savingSchedules.value = true
  try {
    await saveAttendanceTaskSchedules(currentTask.value.id, scheduleRows.value)
    ElMessage.success('排班已保存')
    scheduleDialogVisible.value = false
    await loadTasks()
  } finally {
    savingSchedules.value = false
  }
}

const publishTaskAction = async (row) => {
  await publishAttendanceTask(row.id)
  ElMessage.success('任务已发布')
  await loadTasks()
}

const handlePhotoUpload = async ({ file }) => {
  const formData = new FormData()
  formData.append('file', file)
  uploadingPhoto.value = true
  try {
    await uploadAttendanceSessionPhoto(formData)
    ElMessage.success('现场照片已上传')
    await loadCurrentSession()
  } finally {
    uploadingPhoto.value = false
  }
}

const openReviewDialog = (row) => {
  reviewForm.sessionId = currentSession.id
  reviewForm.userId = row.userId
  reviewForm.realName = row.realName
  reviewForm.studentId = row.studentId
  reviewForm.signStatus = row.signStatus === 'makeup_approved' ? 'supplement' : row.signStatus || 'normal'
  reviewForm.remark = row.remark || ''
  reviewForm.changedReason = ''
  reviewDialogVisible.value = true
}

const submitReview = async () => {
  if (!reviewForm.changedReason.trim()) {
    ElMessage.warning('请填写修正原因')
    return
  }
  savingReview.value = true
  try {
    await reviewAttendanceRecord({
      sessionId: reviewForm.sessionId,
      userId: reviewForm.userId,
      signStatus: reviewForm.signStatus,
      remark: reviewForm.remark || undefined,
      changedReason: reviewForm.changedReason.trim()
    })
    ElMessage.success('考勤记录已更新')
    reviewDialogVisible.value = false
    await loadCurrentSession()
  } finally {
    savingReview.value = false
  }
}

const reviewLeave = async (row, approved) => {
  const title = approved ? '通过请假申请' : '驳回请假申请'
  const result = await ElMessageBox.prompt(`请输入“${title}”意见`, title, {
    inputPattern: /.+/,
    inputErrorMessage: '审核意见不能为空',
    confirmButtonText: approved ? '通过' : '驳回',
    cancelButtonText: '取消'
  }).catch(() => null)

  if (!result) {
    return
  }

  if (approved) {
    await approveAttendanceLeave(row.id, { reviewComment: result.value })
    ElMessage.success('请假申请已通过')
  } else {
    await rejectAttendanceLeave(row.id, { reviewComment: result.value })
    ElMessage.success('请假申请已驳回')
  }
  await Promise.all([loadLeaves(), loadCurrentSession()])
}

const startPolling = () => {
  stopPolling()
  sessionPollTimer = window.setInterval(() => {
    loadCurrentSession().catch(() => {})
  }, 15000)
}

const stopPolling = () => {
  if (sessionPollTimer) {
    window.clearInterval(sessionPollTimer)
    sessionPollTimer = null
  }
}

const attendanceStatusLabel = (value) => ({
  normal: '正常',
  late: '迟到',
  leave: '请假',
  absent: '缺勤',
  makeup_pending: '补签待审',
  makeup_approved: '补签通过',
  makeup_rejected: '补签驳回'
}[value] || '待处理')

const leaveStatusLabel = (value) => ({ PENDING: '待审批', APPROVED: '已通过', REJECTED: '已驳回' }[value] || value || '-')
const leaveStatusClass = (value) => ({ PENDING: 'pending', APPROVED: 'success', REJECTED: 'danger' }[value] || 'default')
const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-')
const formatTime = (value) => (value ? dayjs(value).format('HH:mm') : '-')

onMounted(() => {
  resetTaskForm()
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

.metric-grid,
.meta-grid,
.card-list,
.record-list,
.schedule-list {
  display: grid;
  gap: 10px;
}

.metric-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.metric-card,
.toolbar-card,
.record-card,
.panel-card,
.member-card,
.schedule-card {
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.metric-card,
.record-card,
.panel-card,
.member-card,
.schedule-card {
  padding: 14px;
}

.metric-card {
  display: grid;
  gap: 6px;
}

.metric-card span,
.metric-card small,
.card-head p,
.meta-grid span,
.member-card p,
.member-card small,
.muted {
  color: #64748b;
}

.metric-card strong,
.card-head strong,
.meta-grid strong,
.panel-head h2,
.schedule-head strong,
.member-card strong {
  color: #0f172a;
}

.metric-card strong {
  font-size: 24px;
}

.toolbar-card {
  padding: 14px;
  display: grid;
  grid-template-columns: minmax(0, 1fr) 120px auto;
  gap: 10px;
}

.toolbar-card.compact {
  padding: 0;
  border: 0;
  background: transparent;
  grid-template-columns: minmax(0, 1fr) 120px;
}

.card-head,
.panel-head,
.schedule-head,
.action-row.between {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: flex-start;
}

.card-head p {
  margin: 6px 0 0;
}

.meta-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.meta-grid.four {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.meta-grid span {
  display: block;
  font-size: 12px;
  margin-bottom: 4px;
}

.panel-head h2 {
  margin: 0;
  font-size: 16px;
}

.action-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-row.vertical {
  flex-direction: column;
  align-items: flex-end;
}

.top-gap {
  margin-top: 12px;
}

.member-card {
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.empty-wrap {
  padding-top: 6px;
}

.status-pill {
  height: fit-content;
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.status-pill.pending {
  color: #b45309;
  background: rgba(254, 243, 199, 0.92);
}

.status-pill.progress {
  color: #1d4ed8;
  background: rgba(219, 234, 254, 0.92);
}

.status-pill.success {
  color: #047857;
  background: rgba(209, 250, 229, 0.92);
}

.status-pill.danger {
  color: #b91c1c;
  background: rgba(254, 226, 226, 0.92);
}

.status-pill.default {
  color: #475569;
  background: rgba(241, 245, 249, 0.92);
}

.drawer-body {
  padding-bottom: 20px;
}

.drawer-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.load-more {
  display: flex;
  justify-content: center;
}

@media (max-width: 560px) {
  .metric-grid,
  .toolbar-card,
  .toolbar-card.compact,
  .meta-grid,
  .meta-grid.four {
    grid-template-columns: 1fr;
  }
}
</style>
