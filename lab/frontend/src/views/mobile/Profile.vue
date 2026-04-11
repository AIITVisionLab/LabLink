<template>
  <div class="m-page">
    <section class="hero-card">
      <div class="hero-main">
        <el-avatar :size="58">{{ userInitial }}</el-avatar>
        <div>
          <strong>{{ userStore.realName || userStore.userName || '用户' }}</strong>
          <p>{{ roleLabel }}</p>
        </div>
      </div>
      <el-button plain :loading="loading" @click="refresh">刷新</el-button>
    </section>

    <section class="panel-card">
      <div class="info-row"><span>账号</span><strong>{{ userStore.userName || '-' }}</strong></div>
      <div class="info-row"><span>姓名</span><strong>{{ userStore.realName || '-' }}</strong></div>
      <div class="info-row"><span>学院</span><strong>{{ userStore.userInfo?.collegeName || userStore.userInfo?.college || '-' }}</strong></div>
      <div class="info-row"><span>实验室</span><strong>{{ userStore.userInfo?.labName || (userStore.userInfo?.labId ? `#${userStore.userInfo.labId}` : '未加入') }}</strong></div>
    </section>

    <section class="panel-card">
      <div class="section-head">
        <div>
          <strong>简历材料</strong>
          <p>实验室报名、成员升级等场景会使用这份简历材料。</p>
        </div>
        <el-button size="small" type="primary" @click="openResumeDialog">{{ hasResume ? '更新' : '上传' }}</el-button>
      </div>
      <div class="info-row">
        <span>模板文件</span>
        <a class="file-link" :href="resumeTemplateUrl" download>下载模板</a>
      </div>
      <div class="info-row">
        <span>当前文件</span>
        <a v-if="hasResume" class="file-link" :href="currentResumeUrl" target="_blank">{{ currentResumeName }}</a>
        <strong v-else>未上传</strong>
      </div>
    </section>

    <section class="action-card">
      <button class="action-row" type="button" @click="router.push(resolvePortalHome(userStore.userInfo, { surface: 'mobile' }))">
        <div>
          <strong>返回首页</strong>
          <p>继续使用移动端功能</p>
        </div>
        <el-icon :size="18"><ArrowRight /></el-icon>
      </button>
      <button class="action-row" type="button" @click="switchDesktop">
        <div>
          <strong>切换桌面端</strong>
          <p>进入原有 Web 管理界面</p>
        </div>
        <el-icon :size="18"><ArrowRight /></el-icon>
      </button>
      <button class="action-row danger" type="button" @click="logout">
        <div>
          <strong>退出登录</strong>
          <p>清除本地登录状态</p>
        </div>
        <el-icon :size="18"><ArrowRight /></el-icon>
      </button>
    </section>

    <el-dialog v-model="dialogVisible" title="上传简历" width="92%">
      <div class="dialog-copy">
        <p>请先下载《成员入驻申请表》模板，完善内容后上传 PDF、DOC 或 DOCX 文件。</p>
        <a class="file-link" :href="resumeTemplateUrl" download>下载成员入驻申请表模板</a>
      </div>
      <el-upload class="resume-upload" :show-file-list="false" :http-request="uploadResumeFile" accept=".pdf,.doc,.docx">
        <el-button type="primary" plain :loading="uploading">选择简历文件</el-button>
      </el-upload>
      <div class="upload-result">
        <span>待保存文件：</span>
        <strong>{{ tempResumeName || '未选择' }}</strong>
      </div>
      <template #footer>
        <div class="dialog-actions">
          <el-button @click="closeResumeDialog">取消</el-button>
          <el-button type="primary" :loading="saving" @click="saveResume">保存简历</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ArrowRight } from '@element-plus/icons-vue'
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'
import { getFileNameFromUrl, resolveFileUrl } from '@/utils/file'
import { resolvePortalHome, resolvePortalLogin, resolvePortalRole, setPortalSurface } from '@/utils/portal'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const dialogVisible = ref(false)
const uploading = ref(false)
const saving = ref(false)
const tempResumeUrl = ref('')
const tempResumeName = ref('')
const resumeTemplateUrl = '/templates/member-application-template.docx'

const userInitial = computed(() => userStore.realName?.charAt(0) || userStore.userName?.charAt(0) || 'U')
const hasResume = computed(() => Boolean(userStore.userInfo?.resume))
const currentResumeUrl = computed(() => resolveFileUrl(userStore.userInfo?.resume))
const currentResumeName = computed(() => getFileNameFromUrl(userStore.userInfo?.resume, '已上传简历'))
const roleLabel = computed(() => ({ admin: '管理员', teacher: '教师', student: '学生' }[resolvePortalRole(userStore.userInfo)] || '用户'))

const refresh = async () => {
  loading.value = true
  try {
    const response = await request.get('/api/access/profile')
    userStore.setUserInfo(response.data || {})
  } finally {
    loading.value = false
  }
}

const openResumeDialog = () => {
  tempResumeUrl.value = userStore.userInfo?.resume || ''
  tempResumeName.value = userStore.userInfo?.resume ? currentResumeName.value : ''
  dialogVisible.value = true
}

const closeResumeDialog = () => {
  dialogVisible.value = false
  tempResumeUrl.value = ''
  tempResumeName.value = ''
}

const uploadResumeFile = async ({ file }) => {
  uploading.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('scene', 'resume')
    const response = await request.post('/api/files/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    tempResumeUrl.value = response.data?.url || response.data?.path || response.data || ''
    tempResumeName.value = file.name
    ElMessage.success('文件上传成功，点击保存后生效')
  } finally {
    uploading.value = false
  }
}

const saveResume = async () => {
  if (!tempResumeUrl.value) {
    ElMessage.warning('请先上传简历文件')
    return
  }
  saving.value = true
  try {
    await request.put('/api/user/info', { resume: tempResumeUrl.value })
    userStore.setUserInfo({ ...(userStore.userInfo || {}), resume: tempResumeUrl.value })
    ElMessage.success('简历已保存')
    closeResumeDialog()
  } finally {
    saving.value = false
  }
}

const switchDesktop = async () => {
  setPortalSurface('desktop')
  await router.push('/login')
}

const logout = async () => {
  await ElMessageBox.confirm('确认退出当前账号吗？', '退出登录', { type: 'warning' })
  setPortalSurface('mobile')
  userStore.clearUserInfo()
  await router.push(resolvePortalLogin({ surface: 'mobile' }))
}

onMounted(() => {
  if (!userStore.userInfo?.id) {
    refresh()
  }
})
</script>

<style scoped>
.m-page {
  display: grid;
  gap: 14px;
}

.hero-card,
.panel-card,
.action-card {
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(226, 232, 240, 0.92);
}

.hero-card {
  padding: 16px;
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.hero-main {
  display: flex;
  align-items: center;
  gap: 12px;
}

.hero-main strong,
.section-head strong,
.info-row strong,
.action-row strong {
  color: #0f172a;
}

.hero-main p,
.section-head p,
.info-row span,
.action-row p,
.dialog-copy p,
.upload-result span {
  color: #64748b;
}

.hero-main p,
.section-head p,
.action-row p,
.dialog-copy p {
  margin: 6px 0 0;
  line-height: 1.6;
}

.panel-card {
  padding: 14px;
}

.section-head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: flex-start;
  margin-bottom: 10px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(226, 232, 240, 0.82);
}

.info-row:last-child {
  border-bottom: 0;
}

.file-link {
  color: #2563eb;
  text-decoration: none;
  font-weight: 700;
}

.action-card {
  overflow: hidden;
}

.action-row {
  width: 100%;
  padding: 14px;
  border: 0;
  background: transparent;
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
  text-align: left;
  border-top: 1px solid rgba(226, 232, 240, 0.82);
}

.action-row:first-child {
  border-top: 0;
}

.action-row.danger strong,
.action-row.danger .el-icon {
  color: #b91c1c;
}

.dialog-copy {
  margin-bottom: 12px;
}

.resume-upload {
  margin-bottom: 12px;
}

.upload-result {
  display: flex;
  gap: 8px;
  align-items: center;
  color: #0f172a;
}

.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
