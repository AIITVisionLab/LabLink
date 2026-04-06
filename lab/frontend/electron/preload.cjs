const { contextBridge } = require('electron')

contextBridge.exposeInMainWorld('labDesktop', {
  platform: process.platform
})
