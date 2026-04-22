import { createStore } from 'vuex'
import request from '@/utils/request'
import { clearAuth, getToken, getUserInfo, setToken as setAuthToken, setUserInfo as setAuthUserInfo } from '@/utils/auth'

export default createStore({
  state: {
    user: getUserInfo(),
    token: getToken() || '',
    role: localStorage.getItem('userRole') || ''
  },

  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.role,
    currentUser: (state) => state.user
  },

  mutations: {
    SET_TOKEN(state, token) {
      state.token = token
      setAuthToken(token)
    },

    SET_USER(state, user) {
      state.user = user
      setAuthUserInfo(user)
    },

    SET_ROLE(state, role) {
      state.role = role
      localStorage.setItem('userRole', role)
    },

    CLEAR_AUTH(state) {
      state.token = ''
      state.user = null
      state.role = ''
      clearAuth()
      localStorage.removeItem('userRole')
    }
  },

  actions: {
    async studentLogin({ commit }, credentials) {
      try {
        const response = await request.post('/api/auth/student/login', credentials)
        const data = response.data

        if (data.token) {
          commit('SET_TOKEN', data.token)
          commit('SET_ROLE', 'USER')
          commit('SET_USER', {
            id: data.id,
            username: data.username,
            email: data.email,
            realName: data.realName,
            studentId: data.studentId,
            major: data.major
          })
          return { success: true }
        }
        return { success: false, message: '登录失败' }
      } catch (error) {
        return {
          success: false,
          message: error.response?.data?.message || '登录失败'
        }
      }
    },

    async adminLogin({ commit }, credentials) {
      try {
        const response = await request.post('/api/auth/admin/login', credentials)
        const data = response.data

        if (data.token) {
          commit('SET_TOKEN', data.token)
          commit('SET_ROLE', 'ADMIN')
          commit('SET_USER', {
            id: data.id,
            username: data.username,
            email: data.email,
            realName: data.realName
          })
          return { success: true }
        }
        return { success: false, message: '登录失败' }
      } catch (error) {
        return {
          success: false,
          message: error.response?.data?.message || '登录失败'
        }
      }
    },

    async studentRegister(_, userData) {
      try {
        const response = await request.post('/api/auth/student/register', userData)
        return { success: true, data: response.data }
      } catch (error) {
        return {
          success: false,
          message: error.response?.data?.message || '注册失败'
        }
      }
    },

    logout({ commit }) {
      commit('CLEAR_AUTH')
    },

    async fetchUserInfo({ commit, state }) {
      if (!state.token) return

      try {
        const endpoint = state.role === 'ADMIN' ? '/api/auth/admin/info' : '/api/auth/student/info'
        const response = await request.get(endpoint)
        commit('SET_USER', response.data)
        return { success: true }
      } catch (error) {
        commit('CLEAR_AUTH')
        return {
          success: false,
          message: error.response?.data?.message || '获取用户信息失败'
        }
      }
    }
  }
})
