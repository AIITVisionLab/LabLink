import request from '@/utils/request'

export function login(data) {
  return request({
    url: '/api/auth/login',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function register(data) {
  return request({
    url: '/api/auth/register',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function sendRegisterCode(data) {
  return request({
    url: '/api/auth/register/send-code',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function sendTeacherRegisterCode(data) {
  return request({
    url: '/api/auth/teacher-register/send-code',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function registerTeacher(data) {
  return request({
    url: '/api/auth/teacher-register',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function sendPasswordResetCode(data) {
  return request({
    url: '/api/auth/password-reset/send-code',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function resetPassword(data) {
  return request({
    url: '/api/auth/password-reset/confirm',
    method: 'post',
    data,
    skipAuth: true
  })
}

export function getUserInfo() {
  return request({
    url: '/api/auth/me',
    method: 'get'
  })
}

export function getAuthMenus() {
  return request({
    url: '/api/auth/menus',
    method: 'get'
  })
}

export function getAuthPermissions() {
  return request({
    url: '/api/auth/permissions',
    method: 'get'
  })
}

export function logout() {
  return request({
    url: '/api/user/logout',
    method: 'post'
  })
}
