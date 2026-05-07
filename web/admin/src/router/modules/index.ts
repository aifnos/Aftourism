import { AppRouteRecord } from '@/types/router'
import { dashboardRoutes } from './dashboard'
import { systemRoutes } from './system'
import { userRoutes } from './user'

import { safeguardRoutes } from './safeguard'
import { newsRoutes } from './news'// 新闻管理
import { helpRoutes } from './help'
import { feedbackRoutes } from './feedback'
import { exchangeRoutes } from './exchange'

/**
 * 导出所有模块化路由
 */
export const routeModules: AppRouteRecord[] = [
  dashboardRoutes,
  userRoutes,
  systemRoutes,
  feedbackRoutes,
  exchangeRoutes,
  safeguardRoutes,
  newsRoutes,
  ...helpRoutes
]
