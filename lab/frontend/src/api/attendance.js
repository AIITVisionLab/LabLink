import request from '@/utils/request'

export function createAttendanceSession(data) {
  return request({
    url: '/api/attendance/session/create',
    method: 'post',
    data
  })
}

export function getActiveAttendanceSession(params) {
  return request({
    url: '/api/attendance/session/active',
    method: 'get',
    params
  })
}

export function getAttendanceSessionRecords(params) {
  return request({
    url: '/api/attendance/session/records',
    method: 'get',
    params
  })
}

export function expireAttendanceSession(data) {
  return request({
    url: '/api/attendance/session/expire',
    method: 'post',
    data
  })
}

export function finalizeAttendanceSession(data) {
  return request({
    url: '/api/attendance/session/finalize',
    method: 'post',
    data
  })
}

export function signAttendanceSession(data) {
  return request({
    url: '/api/attendance/session/sign',
    method: 'post',
    data
  })
}

export function getAttendanceManageList(params) {
  return request({
    url: '/api/attendance/manage/list',
    method: 'get',
    params
  })
}

export function tagAttendanceManage(data) {
  return request({
    url: '/api/attendance/manage/tag',
    method: 'post',
    data
  })
}

export function getAttendanceManageStat(params) {
  return request({
    url: '/api/attendance/manage/stat',
    method: 'get',
    params
  })
}

export function exportAttendanceManage(params) {
  return request({
    url: '/api/attendance/manage/export',
    method: 'get',
    params,
    responseType: 'blob'
  })
}
