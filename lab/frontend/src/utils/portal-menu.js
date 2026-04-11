import {
  Bell,
  Calendar,
  DataBoard,
  Files,
  FolderOpened,
  Monitor,
  OfficeBuilding,
  Search,
  Tickets,
  TrendCharts,
  User,
  UserFilled
} from '@element-plus/icons-vue'

const MENU_ICON_MAP = {
  Bell,
  Calendar,
  DataBoard,
  Files,
  FolderOpened,
  Monitor,
  OfficeBuilding,
  Search,
  Tickets,
  TrendCharts,
  User,
  UserFilled
}

function normalizeItems(items = [], pathKey) {
  return items
    .map((item) => {
      const path = item?.[pathKey]
      if (!item || !path) {
        return null
      }
      return {
        ...item,
        path,
        icon: MENU_ICON_MAP[item.icon] || DataBoard
      }
    })
    .filter(Boolean)
}

export function resolveDesktopMenuItems(items = [], fallbackItems = []) {
  const normalizedItems = normalizeItems(items, 'path')
  return normalizedItems.length ? normalizedItems : normalizeItems(fallbackItems, 'path')
}

export function resolveMobileMenuItems(items = [], fallbackItems = []) {
  const normalizedItems = normalizeItems(items, 'mobilePath')
  return normalizedItems.length ? normalizedItems : normalizeItems(fallbackItems, 'mobilePath')
}
