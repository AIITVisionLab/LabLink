import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Capacitor } from '@capacitor/core'
import { clearAuth, getToken } from './auth'
import router from '@/router'
import { resolvePortalLogin } from '@/utils/portal'

const CLOUD_API_ORIGIN = 'http://101.35.79.76'
const PUBLIC_AUTH_PATHS = new Set([
  '/auth/login',
  '/auth/register',
  '/auth/register/send-code',
  '/auth/teacher-register',
  '/auth/teacher-register/send-code',
  '/auth/password-reset/send-code',
  '/auth/password-reset/confirm',
  '/user/login',
  '/user/register',
  '/api/auth/login',
  '/api/auth/register',
  '/api/auth/register/send-code',
  '/api/auth/teacher-register',
  '/api/auth/teacher-register/send-code',
  '/api/auth/password-reset/send-code',
  '/api/auth/password-reset/confirm',
  '/api/user/login',
  '/api/user/register'
])

function isNativePlatform() {
  try {
    return Boolean(Capacitor?.isNativePlatform?.())
  } catch (error) {
    return false
  }
}

function resolveApiBaseUrl() {
  const configuredBase = import.meta.env.VITE_API_BASE_URL
  if (configuredBase) {
    return configuredBase.replace(/\/$/, '')
  }

  if (isNativePlatform()) {
    return CLOUD_API_ORIGIN
  }

  return ''
}

function resolveRequestPath(url = '') {
  try {
    return new URL(url, 'http://localhost').pathname
  } catch (error) {
    return url
  }
}

function shouldAttachAuthHeader(config) {
  if (config?.skipAuth) {
    return false
  }

  return !PUBLIC_AUTH_PATHS.has(resolveRequestPath(config?.url))
}

const request = axios.create({
  baseURL: resolveApiBaseUrl(),
  timeout: 10000
})

request.interceptors.request.use(
  (config) => {
    if (!shouldAttachAuthHeader(config)) {
      if (config.headers?.Authorization) {
        delete config.headers.Authorization
      }
      return config
    }

    const token = getToken()
    if (token) {
      config.headers = config.headers || {}
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

request.interceptors.response.use(
  (response) => {
    if (response.config?.responseType === 'blob' || response.data instanceof Blob) {
      return response
    }

    const res = response.data
    const success = res?.code === 0 || res?.code === 200

    if (!success) {
      if (res?.code === 401) {
        clearAuth()
        ElMessageBox.confirm('登录状态已过期，是否重新登录？', '登录已过期', {
          confirmButtonText: '重新登录',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          router.push(resolvePortalLogin())
        })
      }

      ElMessage.error(res?.message || '请求失败')
      return Promise.reject(new Error(res?.message || '请求失败'))
    }

    return res
  },
  (error) => {
    let message = '请求失败'
    const responseData = error.response?.data

    if (error.response) {
      switch (error.response.status) {
        case 400:
          message = responseData?.message || '请求参数无效'
          break
        case 401:
          clearAuth()
          message = responseData?.message || '未登录或登录已过期，请重新登录'
          router.push(resolvePortalLogin())
          break
        case 403:
          message = responseData?.message || '无权限访问该资源'
          break
        case 404:
          message = responseData?.message || '资源不存在'
          break
        case 500:
          message = responseData?.message || '服务器内部错误'
          break
        default:
          message = responseData?.message || `请求失败，状态码 ${error.response.status}`
      }
    } else if (error.request) {
      message = '网络连接失败'
    } else {
      message = error.message
    }

    ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default request
