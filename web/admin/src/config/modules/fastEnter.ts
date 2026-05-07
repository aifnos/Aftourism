/**
 * 快速入口配置
 * 包含当前后台实际业务页面的常用入口。
 */
import type { FastEnterConfig } from '@/types/config'

const fastEnterConfig: FastEnterConfig = {
  // 显示条件（屏幕宽度）
  minWidth: 1200,
  // 应用列表
  applications: [
    {
      name: '工作台',
      description: '系统概览与数据统计',
      icon: 'ri:pie-chart-line',
      iconColor: '#377dff',
      enabled: true,
      order: 1,
      routeName: 'Console'
    },
    {
      name: '分析页',
      description: '数据分析与可视化',
      icon: 'ri:line-chart-line',
      iconColor: '#ff3b30',
      enabled: true,
      order: 2,
      routeName: 'Analysis'
    },
    {
      name: '新闻管理',
      description: '新闻内容发布与维护',
      icon: 'ri:newspaper-line',
      iconColor: '#ffb100',
      enabled: true,
      order: 3,
      routeName: 'NewsPage'
    },
    {
      name: '通知公告',
      description: '公告信息发布与管理',
      icon: 'ri:notification-3-line',
      iconColor: '#7A7FFF',
      enabled: true,
      order: 4,
      routeName: 'NoticePage'
    },
    {
      name: '景点管理',
      description: '景点资料与展示维护',
      icon: 'ri:map-pin-line',
      iconColor: '#13DEB9',
      enabled: true,
      order: 5,
      routeName: 'ScenicPage'
    },
    {
      name: '场馆管理',
      description: '场馆信息与票务维护',
      icon: 'ri:building-2-line',
      iconColor: '#38C0FC',
      enabled: true,
      order: 6,
      routeName: 'VenuePage'
    },
    {
      name: '活动管理',
      description: '活动发布与报名管理',
      icon: 'ri:calendar-event-line',
      iconColor: '#ff6b6b',
      enabled: true,
      order: 7,
      routeName: 'ActivityPage'
    },
    {
      name: '活动审核',
      description: '活动报名与发布审核',
      icon: 'ri:shield-check-line',
      iconColor: '#FB7299',
      enabled: true,
      order: 8,
      routeName: 'ActivityAuditPage'
    }
  ],
  // 快速链接
  quickLinks: [
    {
      name: '前台用户',
      enabled: true,
      order: 1,
      routeName: 'PortalUser'
    },
    {
      name: '资质审核',
      enabled: true,
      order: 2,
      routeName: 'QualificationAudit'
    },
    {
      name: '首页配置',
      enabled: true,
      order: 3,
      routeName: 'HomeConfig'
    },
    {
      name: '留言反馈',
      enabled: true,
      order: 4,
      routeName: 'FeedbackManage'
    },
    {
      name: '交流文章',
      enabled: true,
      order: 5,
      routeName: 'ExchangeArticleManage'
    },
    {
      name: '举报管理',
      enabled: true,
      order: 6,
      routeName: 'ExchangeReportManage'
    },
    {
      name: '菜单管理',
      enabled: true,
      order: 7,
      routeName: 'Menus'
    },
    {
      name: '回收站',
      enabled: true,
      order: 8,
      routeName: 'RecycleBin'
    }
  ]
}

export default Object.freeze(fastEnterConfig)
