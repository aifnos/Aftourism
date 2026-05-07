## 后端菜单接口文档

### 1. 接口基本信息

**接口名称：** 获取用户菜单列表  
**接口路径：** `GET /admin/auth/menus`  
**请求方式：** GET  
**认证要求：** 需要 JWT Token  

### 2. 响应数据结构

```typescript
// 响应格式
{
  "code": 200,
  "message": "success",
  "data": AppRouteRecord[]  // 菜单数据数组
}

// 菜单数据类型
interface AppRouteRecord {
  id?: number              // 菜单ID，后端管理使用
  path: string             // 路由路径
  name?: string            // 路由名称
  redirect?: string        // 重定向路径
  component?: string       // 组件路径
  meta: RouteMeta          // 菜单元数据
  children?: AppRouteRecord[]  // 子菜单（递归结构）
}

// 菜单元数据详细定义
interface RouteMeta {
  // 基础信息
  title: string                    // 【必填】菜单标题
  icon?: string                    // 菜单图标（Element Plus 图标名）
  
  // 显示控制
  isHide?: boolean                 // 是否在菜单中隐藏
  isHideTab?: boolean              // 是否在标签页中隐藏
  showBadge?: boolean              // 是否显示徽章
  showTextBadge?: string           // 徽章文本内容
  
  // 路由特性
  keepAlive?: boolean              // 是否缓存页面
  fixedTab?: boolean               // 是否固定标签页
  activePath?: string              // 激活菜单路径
  
  // 特殊功能
  link?: string                    // 外部链接地址
  isIframe?: boolean               // 是否为iframe页面
  isFullPage?: boolean             // 是否为全屏页面
  
  // 权限控制
  roles?: string[]                 // 可访问的角色列表
  authList?: Array<{               // 操作权限列表
    title: string                  // 权限显示名称
    authMark: string               // 权限标识符
  }>
  authMark?: string                // 页面权限标识
  
  // 层级控制
  isFirstLevel?: boolean           // 是否为一级菜单
  parentPath?: string              // 父级路径
  isAuthButton?: boolean           // 是否为权限按钮行
}
```

### 3. 完整示例数据(前端框架演示的请求示例)

```json
{
    "code": 200,
    "msg": "请求成功",
    "data": [
        {
            "name": "Dashboard",
            "path": "/dashboard",
            "component": "/index/index",
            "meta": {
                "title": "menus.dashboard.title",
                "icon": "ri:pie-chart-line"
            },
            "children": [
                {
                    "path": "console",
                    "name": "Console",
                    "component": "/dashboard/console",
                    "meta": {
                        "title": "menus.dashboard.console",
                        "icon": "ri:home-smile-2-line",
                        "keepAlive": false,
                        "fixedTab": true
                    }
                },
                {
                    "path": "analysis",
                    "name": "Analysis",
                    "component": "/dashboard/analysis",
                    "meta": {
                        "title": "menus.dashboard.analysis",
                        "icon": "ri:align-item-bottom-line",
                        "keepAlive": false
                    }
                }
            ]
        },
        {
            "path": "/system",
            "name": "System",
            "component": "/index/index",
            "meta": {
                "title": "menus.system.title",
                "icon": "ri:user-3-line"
            },
            "children": [
                {
                    "path": "user",
                    "name": "User",
                    "component": "/system/user",
                    "meta": {
                        "title": "menus.system.user",
                        "icon": "ri:user-line",
                        "keepAlive": true,
                        "roles": [
                            "R_SUPER",
                            "R_ADMIN"
                        ]
                    }
                },
                {
                    "path": "role",
                    "name": "Role",
                    "component": "/system/role",
                    "meta": {
                        "title": "menus.system.role",
                        "icon": "ri:user-settings-line",
                        "keepAlive": true,
                        "roles": [
                            "R_SUPER"
                        ]
                    }
                },
                {
                    "path": "user-center",
                    "name": "UserCenter",
                    "component": "/system/user-center",
                    "meta": {
                        "title": "menus.system.userCenter",
                        "icon": "ri:user-line",
                        "isHide": true,
                        "keepAlive": true,
                        "isHideTab": true
                    }
                },
                {
                    "path": "menu",
                    "name": "Menus",
                    "component": "/system/menu",
                    "meta": {
                        "title": "menus.system.menu",
                        "icon": "ri:menu-line",
                        "keepAlive": true,
                        "roles": [
                            "R_SUPER"
                        ],
                        "authList": [
                            {
                                "title": "新增",
                                "authMark": "add"
                            },
                            {
                                "title": "编辑",
                                "authMark": "edit"
                            },
                            {
                                "title": "删除",
                                "authMark": "delete"
                            }
                        ]
                    }
                }
            ]
        },
        {
            "path": "/safeguard",
            "name": "Safeguard",
            "component": "/index/index",
            "meta": {
                "title": "menus.safeguard.title",
                "icon": "ri:shield-check-line",
                "keepAlive": false
            },
            "children": [
                {
                    "path": "server",
                    "name": "SafeguardServer",
                    "component": "/safeguard/server",
                    "meta": {
                        "title": "menus.safeguard.server",
                        "icon": "ri:hard-drive-3-line",
                        "keepAlive": true
                    }
                }
            ]
        }
    ]
}
```

### 4. 字段详细说明

#### 4.1 基础字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | number | 否 | 菜单唯一标识，建议后端数据库主键 |
| `path` | string | 是 | 路由路径，一级菜单以 `/` 开头，子菜单不要 |
| `name` | string | 否 | 路由名称，用于命名路由 |
| `redirect` | string | 否 | 父级菜单的重定向路径 |
| `component` | string | 否 | 组件路径，相对于 `src/views/` 目录 |

#### 4.2 meta 核心字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `title` | string | 是 | 菜单显示标题 |
| `icon` | string | 否 | Element Plus 图标名称 |
| `isHide` | boolean | 否 | 是否在侧边栏菜单中隐藏 |
| `isHideTab` | boolean | 否 | 是否在浏览器标签页中隐藏 |
| `keepAlive` | boolean | 否 | 是否启用页面缓存 |

#### 4.3 权限控制字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `roles` | string[] | 可访问该菜单的角色列表，为空则所有人可访问 |
| `authList` | Array | 页面内操作按钮权限配置 |
| `authMark` | string | 页面访问权限标识符 |

#### 4.4 特殊功能字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `link` | string | 外部链接地址，设置后忽略 component |
| `isIframe` | boolean | 是否以 iframe 方式嵌入外部页面 |
| `isFullPage` | boolean | 是否全屏显示（隐藏侧边栏和头部） |
| `showBadge/showTextBadge` | boolean/string | 菜单徽章显示控制 |

### 5. 开发注意事项

1. **路径规范**：一级菜单路径以 `/` 开头，子菜单路径不包含 `/`，前端会自动拼接
2. **组件路径**：相对于 `src/views/` 目录，不需要 `.vue` 后缀
3. **权限控制**：与用户登录后返回的 [`roles`](src/types/api/api.d.ts#L51) 字段进行匹配
4. **菜单过滤**：前端会根据用户权限自动过滤菜单，参见 [`MenuProcessor.processBackendMenu()`](src/router/core/MenuProcessor.ts#L49-L53)
5. **递归结构**：支持无限层级嵌套，但建议不超过 3-4 层

### 6. 错误响应示例

```json
{
  "code": 401,
  "message": "未授权访问",
  "data": null
}

{
  "code": 500,
  "message": "服务器内部错误",
  "data": null
}
```



## 后端权限控制介绍：

### 原理

后端生成菜单列表。用户登录后，接口返回菜单数据，前端校验后动态注册路由，实现权限控制。

### 数据结构

菜单数据结构定义位于：`/src/router/routes/asyncRoutes.ts`

```
[
  {
    id: 4,
    path: "/system",
    name: "System",
    component: "/index/index",
    meta: {
      title: "menus.system.title",
      icon: "ri:user-3-line",
      keepAlive: false,
    },
    children: [
      {
        id: 41,
        path: "user",
        name: "User",
        component: "/system/user",
        meta: {
          title: "menus.system.user",
          keepAlive: true,
        },
      },
      {
        id: 42,
        path: "role",
        name: "Role",
        component: "/system/role",
        meta: {
          title: "menus.system.role",
          keepAlive: true,
        },
      },
    ],
  },
];
```

### 注意事项

- 后端返回的菜单数据结构必须与前端定义一致，否则可能导致路由注册失败。

  

## 按钮权限控制

按钮权限控制支持精细化管理，通过用户角色或接口返回的权限码动态控制按钮显示。

### 权限码

权限码适用于前端和后端控制模式：

- **前端控制模式**：登录接口需返回权限码列表。
- **后端控制模式**：菜单列表需包含 `authList` 字段，定义按钮权限。

#### 配置示例（后端控制模式）

```ts
[
  {
    id: 44,
    path: "menu",
    name: "Menus",
    component: "/system/menu",
    meta: {
      title: "menus.system.menu",
      keepAlive: true,
      authList: [
        { id: 441, title: "新增", authMark: "add" },
        { id: 442, title: "编辑", authMark: "edit" },
      ],
    },
  },
];
```

#### 使用方式

通过系统提供的 `hasAuth` 方法控制按钮显示：

```ts
import { useAuth } from "@/composables/useAuth";
const { hasAuth } = useAuth();
```

```html
<ElButton v-if="hasAuth('add')">添加</ElButton>
```

### 自定义指令（v-auth）

在后端控制模式下，可通过自定义指令 `v-auth` 基于 `authList` 的 `authMark` 控制按钮显示。

#### 配置示例

ts

```
[
  {
    id: 44,
    path: "menu",
    name: "Menus",
    component: "/system/menu",
    meta: {
      title: "menus.system.menu",
      keepAlive: true,
      authList: [
        { id: 441, title: "新增", authMark: "add" },
        { id: 442, title: "编辑", authMark: "edit" },
        { id: 443, title: "删除", authMark: "delete" },
      ],
    },
  },
];
```

#### 使用方式

vue

```
<ElButton v-auth="'add'">添加</ElButton>
```

### 自定义指令（v-roles）

可基于用户信息接口中返回的 `roles` 进行权限控制。

#### 用户接口

ts

```
{
    "userId": "1",
    "userName": "Super",
    "roles": [
        "R_SUPER"
    ],
    "buttons": [
        "B_CODE1",
        "B_CODE2",
        "B_CODE3"
    ]
}
```

#### 使用示例

ts

```
 <el-button v-roles="['R_SUPER', 'R_ADMIN']">按钮</el-button>
 <el-button v-roles="'R_ADMIN'">按钮</el-button>
```

## 注意事项

- 确保登录接口返回的角色或权限码与路由表配置一致。
- 后端控制模式下，菜单数据需严格遵循前端定义的结构。
- 测试权限控制时，验证不同角色用户的页面和按钮显示是否符合预期。
