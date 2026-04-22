const TOKEN_KEY = 'lab_token'
const LEGACY_TOKEN_KEY = 'token'
const USER_INFO_KEY = 'lab_user_info'
const AUTH_CACHE_KEYS = [
  TOKEN_KEY,
  LEGACY_TOKEN_KEY,
  USER_INFO_KEY,
  'userRole',
  'userPortalRole',
  'lab_user_menus',
  'lab_user_permissions'
]
const INVALID_TOKEN_VALUES = new Set(['', 'null', 'undefined', 'false', '[object Object]'])

function normalizeToken(token) {
  if (typeof token !== 'string') {
    return null
  }

  const normalized = token.trim()
  if (INVALID_TOKEN_VALUES.has(normalized)) {
    return null
  }

  return normalized.split('.').length === 3 ? normalized : null
}

function safeReadJson(key) {
  const raw = localStorage.getItem(key)
  if (!raw) {
    return null
  }

  try {
    return JSON.parse(raw)
  } catch (error) {
    localStorage.removeItem(key)
    return null
  }
}

export function getToken() {
  const primaryToken = normalizeToken(localStorage.getItem(TOKEN_KEY))
  const legacyToken = normalizeToken(localStorage.getItem(LEGACY_TOKEN_KEY))

  if (!primaryToken) {
    localStorage.removeItem(TOKEN_KEY)
  }
  if (!legacyToken) {
    localStorage.removeItem(LEGACY_TOKEN_KEY)
  }

  const token = primaryToken || legacyToken
  if (token && !primaryToken) {
    localStorage.setItem(TOKEN_KEY, token)
  }

  return token
}

export function setToken(token) {
  const normalizedToken = normalizeToken(token)
  if (normalizedToken) {
    localStorage.setItem(TOKEN_KEY, normalizedToken)
    localStorage.setItem(LEGACY_TOKEN_KEY, normalizedToken)
    return normalizedToken
  }
  removeToken()
  return null
}

export function removeToken() {
  localStorage.removeItem(TOKEN_KEY)
  return localStorage.removeItem(LEGACY_TOKEN_KEY)
}

export function getUserInfo() {
  return safeReadJson(USER_INFO_KEY)
}

export function setUserInfo(userInfo) {
  return localStorage.setItem(USER_INFO_KEY, JSON.stringify(userInfo))
}

export function clearAuth() {
  AUTH_CACHE_KEYS.forEach((key) => localStorage.removeItem(key))
}
