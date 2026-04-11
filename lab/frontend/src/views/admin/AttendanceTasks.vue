<template>
  <div class="page-shell">
    <section class="toolbar-card">
      <div class="toolbar-main">
        <div>
          <p class="eyebrow">考勤管理</p>
          <h2>任务设置、当前场次、请假审批与记录修正</h2>
        </div>
        <div class="toolbar-actions">
          <el-button @click="loadPageData">刷新</el-button>
          <el-button v-if="canManageTasks" type="primary" @click="openTaskDialog()">新建任务</el-button>
        </div>
      </div>
    </section>

    <section class="metric-grid">
      <MetricCard v-for="card in summaryCards" :key="card.label" :label="card.label" :value="card.value" :tip="card.tip" />
    </section>

    <TablePageCard v-if="canManageTasks" title="考勤任务" subtitle="考勤管理" :count-label="`${pagination.total} 项`">
      <template #filters>
        <SearchToolbar v-model="filters.keyword" class="toolbar-form" placeholder="学期或任务名称" :show-reset="false" @search="handleSearch">
          <el-form-item v-if="isSchoolDirector" label="学院">
            <el-select v-model="filters.collegeId" clearable placeholder="全部学院" style="width: 220px">
              <el-option v-for="item in colleges" :key="item.id" :label="item.collegeName" :value="item.id" />
            </el-select>
          </el-form-item>
        </SearchToolbar>
      </template>

      <el-table v-loading="taskLoading" :data="tasks" stripe>
        <el-table-column prop="collegeName" label="学院" min-width="160" />
        <el-table-column prop="semesterName" label="学期" min-width="160" />
        <el-table-column prop="taskName" label="任务名称" min-width="200" />
        <el-table-column label="日期范围" min-width="220">
          <template #default="{ row }">
            {{ row.startDate || '-' }} 至 {{ row.endDate || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="scheduleCount" label="排班数" width="100" />
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <StatusTag :value="row.status" :label-map="taskStatusLabels" :type-map="taskStatusTypes" />
          </template>
        </el-table-column>
        <el-table-column label="创建时间" min-width="170">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" min-width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openTaskDialog(row)">编辑</el-button>
            <el-button link type="warning" @click="openScheduleDialog(row)">排班</el-button>
            <el-button v-if="row.status !== 'published'" link type="success" @click="publishTaskAction(row)">发布</el-button>
          </template>
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

    <TablePageCard v-if="hasLabScope" title="当前实验室场次" subtitle="考勤管理">
      <template #header-extra>
        <StatusTag :value="currentSession.status" preset="session" />
      </template>
      <div v-if="!currentSession.id" class="empty-panel">
        <el-empty description="当前实验室暂无进行中的考勤场次。" />
      </div>

      <template v-else>
        <div class="session-meta">
          <div class="summary-item">
            <span>日期</span>
            <strong>{{ currentSession.sessionDate || '-' }}</strong>
          </div>
          <div class="summary-item">
            <span>签到窗口</span>
            <strong>{{ formatTime(currentSession.signStartTime) }} - {{ formatTime(currentSession.signEndTime) }}</strong>
          </div>
          <div class="summary-item">
            <span>动态签到码</span>
            <strong>{{ sessionCodeDisplay }}</strong>
            <small>{{ sessionCodeHint }}</small>
          </div>
          <div class="summary-item">
            <span>出勤率</span>
            <strong>{{ currentSession.attendanceRate ?? 0 }}%</strong>
          </div>
        </div>

        <el-upload
          class="photo-upload"
          :show-file-list="false"
          :http-request="handlePhotoUpload"
        >
          <el-button type="primary" plain :loading="uploadingPhoto">上传现场照片</el-button>
        </el-upload>

        <el-table :data="currentSession.records || []" stripe class="mt-16">
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
          <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip />
          <el-table-column label="变更次数" width="90">
            <template #default="{ row }">{{ row.changeCount || 0 }}</template>
          </el-table-column>
          <el-table-column v-if="canReviewRecords" label="操作" min-width="140" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openReviewDialog(row)">修正</el-button>
            </template>
          </el-table-column>
        </el-table>
      </template>
    </TablePageCard>

    <TablePageCard v-if="hasLabScope" title="请假审批" subtitle="考勤管理" :count-label="`${leavePagination.total} 条申请`">
      <template #filters>
        <SearchToolbar
          v-model="leaveFilters.keyword"
          class="toolbar-form"
          placeholder="姓名、学号或请假原因"
          :show-reset="false"
          @search="handleLeaveSearch"
        >
          <el-form-item label="状态">
            <el-select v-model="leaveFilters.leaveStatus" clearable placeholder="全部">
              <el-option label="待审批" value="PENDING" />
              <el-option label="已通过" value="APPROVED" />
              <el-option label="已驳回" value="REJECTED" />
            </el-select>
          </el-form-item>
        </SearchToolbar>
      </template>

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
        <el-table-column label="审核意见" min-width="220" show-overflow-tooltip>
          <template #default="{ row }">{{ row.reviewComment || '-' }}</template>
        </el-table-column>
        <el-table-column v-if="canReviewRecords" label="操作" min-width="180" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.leaveStatus === 'PENDING'" link type="success" @click="reviewLeave(row, true)">通过</el-button>
            <el-button v-if="row.leaveStatus === 'PENDING'" link type="danger" @click="reviewLeave(row, false)">驳回</el-button>
          </template>
        </el-table-column>
      </el-table>

      <template #pagination>
        <el-pagination
          background
          layout="prev, pager, next, total"
          :current-page="leavePagination.pageNum"
          :page-size="leavePagination.pageSize"
          :total="leavePagination.total"
          @current-change="handleLeavePageChange"
        />
      </template>
    </TablePageCard>

    <el-dialog v-model="taskDialogVisible" :title="taskForm.id ? '编辑任务' : '新建任务'" width="720px">
      <el-form label-width="96px">
        <div class="two-column-form">
          <el-form-item label="学院">
            <el-select v-model="taskForm.collegeId" :disabled="!isSchoolDirector" placeholder="请选择学院">
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
            <el-date-picker
              v-model="taskDateRange"
              type="daterange"
              unlink-panels
              value-format="YYYY-MM-DD"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            />
          </el-form-item>
        </div>
        <el-form-item label="说明">
          <el-input v-model="taskForm.description" type="textarea" :rows="4" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="taskDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingTask" @click="saveTaskAction">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="scheduleDialogVisible" title="任务排班" width="860px">
      <div class="schedule-toolbar">
        <div class="schedule-title">{{ currentTask?.taskName || '-' }}</div>
        <el-button type="primary" plain @click="addSchedule">添加一行</el-button>
      </div>

      <el-table :data="scheduleRows" stripe>
        <el-table-column label="星期" width="120">
          <template #default="{ row }">
            <el-select v-model="row.weekDay">
              <el-option v-for="item in weekOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="开始时间" min-width="150">
          <template #default="{ row }">
            <el-time-picker v-model="row.signInStart" value-format="HH:mm:ss" placeholder="开始时间" />
          </template>
        </el-table-column>
        <el-table-column label="结束时间" min-width="150">
          <template #default="{ row }">
            <el-time-picker v-model="row.signInEnd" value-format="HH:mm:ss" placeholder="结束时间" />
          </template>
        </el-table-column>
        <el-table-column label="迟到阈值" width="140">
          <template #default="{ row }">
            <el-input-number v-model="row.lateThresholdMinutes" :min="1" :max="120" />
          </template>
        </el-table-column>
        <el-table-column label="签到码长度" width="130">
          <template #default="{ row }">
            <el-input-number v-model="row.signCodeLength" :min="4" :max="6" />
          </template>
        </el-table-column>
        <el-table-column label="有效期" width="120">
          <template #default="{ row }">
            <el-input-number v-model="row.codeTtlMinutes" :min="1" :max="180" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="90" fixed="right">
          <template #default="{ $index }">
            <el-button link type="danger" @click="removeSchedule($index)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <template #footer>
        <el-button @click="scheduleDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingSchedules" @click="saveSchedulesAction">保存排班</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="reviewDialogVisible" title="修正考勤记录" width="560px">
      <el-form label-width="110px">
        <el-form-item label="学生">
          <div>{{ reviewForm.realName }} / {{ reviewForm.studentId }}</div>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="reviewForm.signStatus">
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
        <el-button @click="reviewDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingReview" @click="submitReview">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import MetricCard from '@/components/common/MetricCard.vue'
import SearchToolbar from '@/components/common/SearchToolbar.vue'
import StatusTag from '@/components/common/StatusTag.vue'
import TablePageCard from '@/components/common/TablePageCard.vue'
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

const taskLoading = ref(false)
const leaveLoading = ref(false)
const savingTask = ref(false)
const savingSchedules = ref(false)
const uploadingPhoto = ref(false)
const savingReview = ref(false)
const taskDialogVisible = ref(false)
const scheduleDialogVisible = ref(false)
const reviewDialogVisible = ref(false)
const tasks = ref([])
const colleges = ref([])
const currentTask = ref(null)
const scheduleRows = ref([])
const currentSession = reactive({
  id: null,
  status: null,
  sessionDate: '',
  signStartTime: '',
  signEndTime: '',
  sessionCode: '',
  codeReady: false,
  codeExpireTime: '',
  codeRemainingSeconds: 0,
  attendanceRate: 0,
  records: [],
  totalCount: 0
})
const leaveRows = ref([])

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const leavePagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const filters = reactive({
  collegeId: undefined,
  keyword: ''
})

const leaveFilters = reactive({
  leaveStatus: 'PENDING',
  keyword: ''
})
const taskStatusLabels = {
  draft: '草稿',
  published: '已发布'
}
const taskStatusTypes = {
  draft: 'info',
  published: 'success'
}

const taskForm = reactive({
  id: null,
  collegeId: undefined,
  semesterName: '',
  taskName: '',
  description: '',
  startDate: '',
  endDate: ''
})

const taskDateRange = ref([])

const reviewForm = reactive({
  sessionId: null,
  userId: null,
  realName: '',
  studentId: '',
  signStatus: 'normal',
  remark: '',
  changedReason: ''
})

const isSchoolDirector = computed(() => Boolean(userStore.userInfo?.schoolDirector))
const canManageTasks = computed(() => userStore.hasPermission('attendance:task:manage'))
const canReviewRecords = computed(() => userStore.hasPermission('attendance:record:manage'))
const hasLabScope = computed(() => Boolean(userStore.userInfo?.managedLabId || userStore.userInfo?.labId))

const summaryCards = computed(() => [
  {
    label: '任务数',
    value: pagination.total,
    tip: '当前管理范围内的考勤任务数'
  },
  {
    label: '已发布',
    value: tasks.value.filter((item) => item.status === 'published').length,
    tip: '已进入执行状态的任务'
  },
  {
    label: '待审批请假',
    value: leaveRows.value.filter((item) => item.leaveStatus === 'PENDING').length,
    tip: '等待审核的请假申请'
  },
  {
    label: '当前记录',
    value: currentSession.records?.length || 0,
    tip: '当前场次中的成员记录数'
  }
])

const weekOptions = [
  { label: '周一', value: 1 },
  { label: '周二', value: 2 },
  { label: '周三', value: 3 },
  { label: '周四', value: 4 },
  { label: '周五', value: 5 },
  { label: '周六', value: 6 },
  { label: '周日', value: 7 }
]
const SESSION_POLL_INTERVAL_MS = 15000
let sessionPollTimer = null

const sessionCodeDisplay = computed(() => {
  if (!currentSession.id) {
    return '-'
  }
  if (currentSession.status === 'pending') {
    return '待开始'
  }
  if (currentSession.status === 'closed') {
    return '已关闭'
  }
  if (currentSession.codeReady && currentSession.sessionCode) {
    return currentSession.sessionCode
  }
  return '生成中'
})

const sessionCodeHint = computed(() => {
  if (!currentSession.id) {
    return '当前没有考勤场次'
  }
  if (currentSession.status === 'pending') {
    return '到达签到开始时间后自动生成'
  }
  if (currentSession.status === 'closed') {
    return '签到窗口已结束'
  }
  if (currentSession.codeReady && currentSession.codeExpireTime) {
    return `有效至 ${formatTime(currentSession.codeExpireTime)}`
  }
  return '页面会自动刷新当前动态码'
})

const resetTaskForm = () => {
  Object.assign(taskForm, {
    id: null,
    collegeId: userStore.userInfo?.managedCollegeId || undefined,
    semesterName: '',
    taskName: '',
    description: '',
    startDate: '',
    endDate: ''
  })
  taskDateRange.value = []
}

const buildTaskQuery = () => ({
  pageNum: pagination.pageNum,
  pageSize: pagination.pageSize,
  collegeId: isSchoolDirector.value ? filters.collegeId : userStore.userInfo?.managedCollegeId,
  keyword: filters.keyword || undefined
})

const loadOptions = async () => {
  if (!canManageTasks.value) {
    return
  }
  const response = await getCollegeOptions()
  colleges.value = response.data || []
  if (!isSchoolDirector.value) {
    filters.collegeId = userStore.userInfo?.managedCollegeId
  }
}

const loadTasks = async () => {
  if (!canManageTasks.value) {
    tasks.value = []
    pagination.total = 0
    return
  }
  taskLoading.value = true
  try {
    const response = await getAttendanceTaskPage(buildTaskQuery())
    tasks.value = response.data?.records || []
    pagination.total = response.data?.total || 0
  } finally {
    taskLoading.value = false
  }
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
      codeRemainingSeconds: 0,
      attendanceRate: 0,
      records: [],
      totalCount: 0
    })
    return
  }

  try {
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
      codeRemainingSeconds: 0,
      attendanceRate: 0,
      records: [],
      totalCount: 0,
      ...(response.data || {})
    })
  } catch (error) {
    Object.assign(currentSession, {
      id: null,
      status: null,
      sessionDate: '',
      signStartTime: '',
      signEndTime: '',
      sessionCode: '',
      codeReady: false,
      codeExpireTime: '',
      codeRemainingSeconds: 0,
      attendanceRate: 0,
      records: [],
      totalCount: 0
    })
  }
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

const loadLeaves = async () => {
  if (!hasLabScope.value) {
    leaveRows.value = []
    leavePagination.total = 0
    return
  }
  leaveLoading.value = true
  try {
    const response = await getAttendanceLeavePage({
      pageNum: leavePagination.pageNum,
      pageSize: leavePagination.pageSize,
      leaveStatus: leaveFilters.leaveStatus || undefined,
      keyword: leaveFilters.keyword || undefined
    })
    leaveRows.value = response.data?.records || []
    leavePagination.total = response.data?.total || 0
  } finally {
    leaveLoading.value = false
  }
}

const loadPageData = async () => {
  await Promise.all([loadOptions(), loadTasks(), loadCurrentSession(), loadLeaves()])
}

const openTaskDialog = (row) => {
  resetTaskForm()
  if (row) {
    Object.assign(taskForm, {
      id: row.id,
      collegeId: row.collegeId,
      semesterName: row.semesterName,
      taskName: row.taskName,
      description: row.description || '',
      startDate: row.startDate,
      endDate: row.endDate
    })
    taskDateRange.value = [row.startDate, row.endDate]
  }
  taskDialogVisible.value = true
}

const saveTaskAction = async () => {
  if (!taskForm.collegeId) {
    ElMessage.warning('请先选择学院')
    return
  }
  if (!taskForm.semesterName.trim() || !taskForm.taskName.trim()) {
    ElMessage.warning('学期和任务名称不能为空')
    return
  }
  if (!taskDateRange.value?.length) {
    ElMessage.warning('请先选择任务日期范围')
    return
  }

  savingTask.value = true
  try {
    await saveAttendanceTask({
      ...taskForm,
      startDate: taskDateRange.value[0],
      endDate: taskDateRange.value[1]
    })
    ElMessage.success('考勤任务已保存')
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
  if (!currentTask.value?.id) {
    return
  }
  if (!scheduleRows.value.length) {
    ElMessage.warning('至少保留一条排班')
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
  ElMessage.success('考勤任务已发布')
  await loadTasks()
}

const openReviewDialog = (row) => {
  Object.assign(reviewForm, {
    sessionId: currentSession.id,
    userId: row.userId,
    realName: row.realName,
    studentId: row.studentId,
    signStatus: row.signStatus === 'makeup_approved' ? 'supplement' : row.signStatus || 'normal',
    remark: row.remark || '',
    changedReason: ''
  })
  reviewDialogVisible.value = true
}

const submitReview = async () => {
  if (!reviewForm.changedReason.trim()) {
    ElMessage.warning('请先填写修正原因')
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
  let value
  try {
    const result = await ElMessageBox.prompt(
      approved ? '请输入通过意见' : '请输入驳回原因',
      approved ? '通过请假申请' : '驳回请假申请',
      {
        confirmButtonText: approved ? '通过' : '驳回',
        cancelButtonText: '取消',
        inputPattern: /.+/,
        inputErrorMessage: '审核意见不能为空'
      }
    )
    value = result.value
  } catch (error) {
    return
  }

  if (approved) {
    await approveAttendanceLeave(row.id, { reviewComment: value })
    ElMessage.success('请假申请已通过')
  } else {
    await rejectAttendanceLeave(row.id, { reviewComment: value })
    ElMessage.success('请假申请已驳回')
  }

  await Promise.all([loadLeaves(), loadCurrentSession()])
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

const handleSearch = () => {
  pagination.pageNum = 1
  loadTasks()
}

const handlePageChange = (page) => {
  pagination.pageNum = page
  loadTasks()
}

const handleLeaveSearch = () => {
  leavePagination.pageNum = 1
  loadLeaves()
}

const handleLeavePageChange = (page) => {
  leavePagination.pageNum = page
  loadLeaves()
}

const formatDateTime = (value) => (value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-')
const formatTime = (value) => (value ? dayjs(value).format('HH:mm') : '-')

onMounted(() => {
  resetTaskForm()
  loadPageData()
  startSessionPolling()
})

onUnmounted(() => {
  stopSessionPolling()
})
</script>

<style scoped>
.two-column-form {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 16px;
}

.session-meta {
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

.schedule-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.schedule-title {
  font-size: 15px;
  font-weight: 600;
  color: #0f172a;
}

.photo-upload {
  margin-bottom: 16px;
}

.mt-16 {
  margin-top: 16px;
}

@media (max-width: 768px) {
  .two-column-form,
  .session-meta {
    grid-template-columns: 1fr;
  }

  .schedule-toolbar {
    align-items: flex-start;
    gap: 12px;
    flex-direction: column;
  }
}
</style>
