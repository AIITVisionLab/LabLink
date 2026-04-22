<template>
  <div class="shell admin-shell">
    <aside class="sidebar" :class="{ 'is-collapsed': isCollapse }">
      <div class="sidebar-inner">
        <div class="sidebar-brand">
          <BrandLogo title="LabLink" subtitle="高校实验室管理平台" tone="dark" size="sm" />
        </div>

        <el-menu
          ref="menuRef"
          :default-active="activeMenuPath"
          :default-openeds="activeGroupKey ? [activeGroupKey] : []"
          :unique-opened="true"
          router
          class="sidebar-menu grouped-menu"
          :collapse="false"
        >
          <el-sub-menu v-for="group in menuGroups" :key="group.key" :index="group.key">
            <template #title>
              <el-icon><component :is="group.icon" /></el-icon>
              <span>{{ group.label }}</span>
            </template>

            <el-menu-item v-for="item in group.items" :key="item.path" :index="item.path">
              <el-icon><component :is="item.icon" /></el-icon>
              <span>{{ item.label }}</span>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </div>
    </aside>
    <div v-if="sidebarVisible" class="sidebar-mask" @click="closeSidebar"></div>

    <div class="main-shell">
      <header class="topbar">
        <div class="topbar-left">
          <el-button class="collapse-btn" text @click="toggleCollapse">
            <el-icon :size="20">
              <component :is="isCollapse ? Expand : Fold" />
            </el-icon>
          </el-button>
          <div class="topbar-title">
            <p class="topbar-label">管理后台</p>
            <h2>{{ $route.meta.title || '工作台' }}</h2>
          </div>
        </div>
        <el-dropdown @command="handleCommand">
          <div class="user-chip">
            <el-avatar :size="34">{{ userInitial }}</el-avatar>
            <div>
              <strong>{{ userStore.realName || '管理员' }}</strong>
              <span>{{ roleLabel }}</span>
            </div>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人资料</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </header>

      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { Expand, Fold } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BrandLogo from '@/components/BrandLogo.vue'
import { useUserStore } from '@/stores/user'
import { ensureAuthContext } from '@/utils/auth-context'
import { resolveAdminDesktopMenuGroups, resolveMenuActivePath } from '@/utils/portal-menu'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const menuRef = ref(null)

const isMobile = ref(typeof window !== 'undefined' ? window.innerWidth <= 960 : false)
const isCollapse = ref(isMobile.value)
const sidebarVisible = computed(() => isMobile.value && !isCollapse.value)

const updateViewport = () => {
  const mobile = window.innerWidth <= 960
  if (mobile !== isMobile.value) {
    isMobile.value = mobile
    isCollapse.value = mobile
    return
  }
  isMobile.value = mobile
}

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const closeSidebar = () => {
  if (isMobile.value) {
    isCollapse.value = true
  }
}

const isSchoolDirector = computed(() => Boolean(userStore.userInfo?.schoolDirector))
const isCollegeManager = computed(() => Boolean(userStore.userInfo?.collegeManager))
const isLabManager = computed(() => Boolean(userStore.userInfo?.labManager))
const canAuditCreateApplies = computed(() => userStore.hasPermission('lab:create:audit'))
const canAuditTeacherRegister = computed(() => userStore.hasPermission('teacher:register:audit'))
const canManageMembers = computed(() => userStore.hasPermission('member:manage'))
const canManageNotices = computed(() => userStore.hasPermission('notice:manage'))
const canManageLabDomain = computed(() => isSchoolDirector.value || isCollegeManager.value || isLabManager.value)
const canReviewProfiles = computed(() => userStore.hasPermission('profile:review') || canManageLabDomain.value)
const canViewAudit = computed(() => userStore.hasPermission('audit:view') || canManageLabDomain.value)
const canViewStatistics = computed(
  () =>
    userStore.hasPermission('statistics:school:view') ||
    userStore.hasPermission('statistics:college:view') ||
    userStore.hasPermission('statistics:lab:view') ||
    canManageLabDomain.value
)

const roleLabel = computed(() => {
  if (isSchoolDirector.value) return '学校管理员'
  if (isCollegeManager.value) return '学院管理员'
  if (isLabManager.value) return '实验室管理员'
  return userStore.userRole === 'super_admin' ? '学校管理员' : '管理员'
})

const userInitial = computed(() => userStore.realName?.charAt(0) || 'A')

const fallbackMenuItems = computed(() =>
  [
    { path: '/admin/dashboard', label: '工作台', icon: 'DataBoard' },
    isSchoolDirector.value || isCollegeManager.value ? { path: '/admin/search', label: '综合搜索', icon: 'Search' } : null,
    isSchoolDirector.value ? { path: '/admin/colleges', label: '学院管理', icon: 'OfficeBuilding' } : null,
    canManageLabDomain.value ? { path: '/admin/labs', label: '实验室管理', icon: 'FolderOpened' } : null,
    canManageMembers.value ? { path: '/admin/members', label: '成员管理', icon: 'UserFilled' } : null,
    canManageLabDomain.value ? { path: '/admin/plans', label: '招新计划', icon: 'Tickets' } : null,
    canAuditCreateApplies.value ? { path: '/admin/create-applies', label: '创建审批', icon: 'Tickets' } : null,
    canAuditTeacherRegister.value ? { path: '/admin/teacher-register-applies', label: '教师注册审批', icon: 'UserFilled' } : null,
    canManageLabDomain.value ? { path: '/admin/applications', label: '入组申请', icon: 'Tickets' } : null,
    canReviewProfiles.value ? { path: '/admin/profiles', label: '资料审核', icon: 'Files' } : null,
    canManageLabDomain.value ? { path: '/admin/attendance-dashboard', label: '今日看板', icon: 'DataBoard' } : null,
    canManageLabDomain.value ? { path: '/admin/attendance-tasks', label: '考勤管理', icon: 'Calendar' } : null,
    canManageLabDomain.value ? { path: '/admin/attendance-stats', label: '考勤统计', icon: 'TrendCharts' } : null,
    canManageLabDomain.value ? { path: '/admin/attendance-anomaly', label: '异常处理', icon: 'Tickets' } : null,
    canManageLabDomain.value ? { path: '/admin/attendance-leave', label: '请假审批', icon: 'UserFilled' } : null,
    canManageLabDomain.value ? { path: '/admin/exam-hub', label: '笔试中心', icon: 'EditPen' } : null,
    canManageLabDomain.value ? { path: '/admin/exam-manage', label: '笔试管理', icon: 'EditPen' } : null,
    canManageLabDomain.value ? { path: '/admin/question-bank', label: '题库管理', icon: 'Files' } : null,
    canManageLabDomain.value ? { path: '/admin/paper-compose', label: '组卷', icon: 'EditPen' } : null,
    canManageLabDomain.value ? { path: '/admin/grading-center', label: '阅卷中心', icon: 'EditPen' } : null,
    canManageLabDomain.value ? { path: '/admin/exam-statistics', label: '成绩统计', icon: 'TrendCharts' } : null,
    canManageLabDomain.value ? { path: '/admin/ai-interview-modules', label: 'AI 面试模块', icon: 'ChatDotRound' } : null,
    canManageLabDomain.value ? { path: '/admin/ai-interview-records', label: 'AI 面试记录', icon: 'DataBoard' } : null,
    canManageLabDomain.value ? { path: '/admin/workspace', label: '资料空间', icon: 'Files' } : null,
    canManageLabDomain.value ? { path: '/admin/devices', label: '设备管理', icon: 'Monitor' } : null,
    canManageNotices.value ? { path: '/admin/notices', label: '公告管理', icon: 'Bell' } : null,
    canViewStatistics.value ? { path: '/admin/statistics', label: '统计分析', icon: 'TrendCharts' } : null,
    canViewAudit.value ? { path: '/admin/audit', label: '审计日志', icon: 'Tickets' } : null,
    { path: '/admin/notifications', label: '消息中心', icon: 'Bell' },
    { path: '/admin/profile', label: '个人资料', icon: 'UserFilled' }
  ].filter(Boolean)
)

const menuGroups = computed(() => resolveAdminDesktopMenuGroups(userStore.menus, fallbackMenuItems.value))
const flatMenuItems = computed(() => menuGroups.value.flatMap((group) => group.items))
const activeMenuPath = computed(() => resolveMenuActivePath(route.path, flatMenuItems.value))
const activeGroupKey = computed(
  () => menuGroups.value.find((group) => group.items.some((item) => item.path === activeMenuPath.value))?.key || ''
)

const ensureContext = async () => {
  await ensureAuthContext(userStore, { force: true })
}

const syncOpenedGroup = async () => {
  if (!activeGroupKey.value) {
    return
  }

  await nextTick()

  menuGroups.value.forEach((group) => {
    if (group.key === activeGroupKey.value) {
      menuRef.value?.open?.(group.key)
      return
    }
    menuRef.value?.close?.(group.key)
  })
}

const handleCommand = async (command) => {
  if (command === 'profile') {
    await router.push('/admin/profile')
    return
  }
  if (command === 'logout') {
    await ElMessageBox.confirm('确认退出当前账号吗？', '退出登录', { type: 'warning' })
    userStore.clearUserInfo()
    await router.push('/login')
  }
}

watch(
  () => route.fullPath,
  () => {
    closeSidebar()
    syncOpenedGroup()
  }
)

watch(menuGroups, () => {
  syncOpenedGroup()
})

onMounted(() => {
  updateViewport()
  window.addEventListener('resize', updateViewport)
  ensureContext()
  syncOpenedGroup()
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateViewport)
})
</script>

<style scoped>
.shell {
  min-height: 100vh;
  display: flex;
  background-color: #ffffff;
  overflow: hidden;
  position: relative;
}

.sidebar {
  width: 260px;
  background: #f9f9f9;
  color: #0f172a;
  transition: margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1), transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
  overflow: hidden;
  flex-shrink: 0;
  border-right: 1px solid #e5e5e5;
}

.sidebar.is-collapsed {
  margin-left: -260px;
}

.sidebar-inner {
  width: 260px;
  padding: 20px 16px;
  display: flex;
  flex-direction: column;
  height: 100%;
  box-sizing: border-box;
}

.sidebar-brand {
  margin-bottom: 24px;
  padding: 0 8px;
}

.sidebar-menu {
  border: 0;
  background: transparent;
  flex: 1;
  overflow-y: auto;
}

.sidebar-menu::-webkit-scrollbar {
  width: 4px;
}

.sidebar-menu::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
}

.sidebar-menu :deep(.el-menu-item) {
  height: 42px;
  border-radius: 10px;
  color: #475569;
  margin-bottom: 4px;
  font-size: 14px;
}

.sidebar-menu :deep(.el-menu-item:hover) {
  background: #e7eef6;
}

.sidebar-menu :deep(.el-menu-item.is-active) {
  color: #0f766e;
  background: #ffffff;
  font-weight: 600;
  box-shadow: 0 8px 20px rgba(15, 118, 110, 0.12);
}

.grouped-menu :deep(.el-sub-menu) {
  margin-bottom: 10px;
  border-radius: 16px;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.72);
  box-shadow: inset 0 0 0 1px rgba(226, 232, 240, 0.9);
}

.grouped-menu :deep(.el-sub-menu__title) {
  height: 48px;
  border-radius: 16px;
  color: #0f172a;
  font-size: 14px;
  font-weight: 700;
  padding: 0 14px;
}

.grouped-menu :deep(.el-sub-menu__title:hover) {
  background: #eff6ff;
}

.grouped-menu :deep(.el-sub-menu__title .el-icon) {
  color: #0f766e;
}

.grouped-menu :deep(.el-sub-menu.is-opened) {
  background: linear-gradient(180deg, rgba(240, 253, 250, 0.96), rgba(255, 255, 255, 0.92));
  box-shadow: inset 0 0 0 1px rgba(20, 184, 166, 0.12);
}

.grouped-menu :deep(.el-menu--inline) {
  background: transparent;
  padding: 0 8px 10px;
}

.grouped-menu :deep(.el-sub-menu .el-menu-item) {
  margin-left: 26px;
  margin-right: 4px;
}

.grouped-menu :deep(.el-sub-menu__icon-arrow) {
  color: #94a3b8;
}

.main-shell {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
  height: 100vh;
}

.sidebar-mask {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(2px);
  z-index: 90;
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: #ffffff;
  gap: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.topbar-left {
  display: flex;
  align-items: center;
  gap: 16px;
  min-width: 0;
}

.topbar-title {
  min-width: 0;
}

.collapse-btn {
  color: #475569;
  padding: 8px;
}

.collapse-btn:hover {
  background-color: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
}

.topbar-label {
  color: #0f766e;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.topbar h2 {
  margin-top: 2px;
  margin-bottom: 0;
  color: #0f172a;
  font-size: 20px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 12px;
  border-radius: 999px;
  background: #fff;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  cursor: pointer;
}

.user-chip strong {
  display: block;
  color: #0f172a;
  font-size: 14px;
}

.user-chip span {
  display: block;
  color: #64748b;
  font-size: 12px;
}

.content {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 24px;
  background: #f8fafc;
}

@media (max-width: 960px) {
  .sidebar {
    position: fixed;
    top: 0;
    bottom: 0;
    left: 0;
    z-index: 100;
  }

  .topbar {
    padding: 14px 16px;
  }

  .content {
    padding: 16px 12px;
  }
}
</style>
