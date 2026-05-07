# Aftourism-文旅系统
![Aftourism](https://socialify.git.ci/Aftnos/Aftourism/image?custom_description=%E5%9F%BA%E4%BA%8ESpringBoot3%2BVue3%E7%9A%84%E5%85%A8%E6%A0%88%E6%97%85%E6%B8%B8%E6%9C%8D%E5%8A%A1%E5%B9%B3%E5%8F%B0&custom_language=Java&description=1&font=Source+Code+Pro&forks=1&issues=1&language=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F128480098&name=1&owner=1&pattern=Circuit+Board&pulls=1&stargazers=1&theme=Auto)
Aftourism-server 是一个基于 Spring Boot 和 Vue 3 的全栈旅游服务平台，采用前后端分离架构。后端使用 Java 21 和 Spring Boot 3.5.7 构建，集成文件管理、监控统计等核心模块；前端使用 Vue 3 + TypeScript + Element Plus 实现现代化管理门户。项目支持权限管理、内容管理等完整功能，为旅游行业提供一站式解决方案。

>项目尚未完工、请持续关注！QAQ

## 📊 核心功能

### 管理后台
- 用户管理与权限控制
- 新闻公告发布管理
- 景点与场地信息管理
- 活动申请审核工作流
- 系统监控与数据统计

### 前台门户
- 用户注册登录
- 新闻资讯浏览
- 景点场馆展示
- 活动在线申报
- 收藏与留言功能
  
## 🔐 认证与安全

- **JWT Token**: 用于用户认证和授权
- **RBAC 权限控制**: 基于角色的访问控制
- **密码加密**: BCrypt 加密存储
- **接口鉴权**: Spring Security 安全框架

## 🚀 技术栈

### 后端技术
- **框架**: Spring Boot 3.5.7
- **语言**: Java 21
- **数据库**: MySQL 8.0+
- **缓存**: Redis
- **ORM**: MyBatis 3.0.5
- **安全**: Spring Security + JWT
- **构建工具**: Maven

### 前端技术
- **框架**: Vue 3.4.37
- **语言**: TypeScript
- **UI组件**: Element Plus 2.8.1
- **状态管理**: Pinia 2.1.7
- **路由**: Vue Router 4.4.3
- **构建工具**: Vite 5.4.3
- **HTTP客户端**: Axios

## 📁 项目结构

```
Aftourism-server/
├── docs/                     # 项目文档
│   ├── Project_Structure_Guide.md
│   ├── SQL/                  # 数据库脚本
│   └── all/                  # API 文档
├── src/main/java/aftnos/aftourismserver/
│   ├── common/               # 公共模块
│   ├── admin/                # 后台管理模块
│   ├── portal/               # 前台门户模块
│   ├── file/                 # 文件管理模块
│   └── monitor/              # 系统监控模块
├── web/                      # 前端项目
│   ├── src/
│   │   ├── api/              # API 接口
│   │   ├── components/       # 公共组件
│   │   ├── layouts/          # 布局组件
│   │   ├── pages/            # 页面组件
│   │   ├── router/           # 路由配置
│   │   └── store/            # 状态管理
│   └── package.json
└── pom.xml                   # Maven 配置
```

## 🏗️ 模块说明

| 模块 | 功能描述 |
|------|----------|
| **Common** | 公共实体类、统一返回结果、异常处理、工具类、常量定义 |
| **Admin** | 管理员登录、新闻管理、活动审核、日志与统计 |
| **Portal** | 用户注册、新闻浏览、景区/场馆展示、活动申报、收藏留言 |
| **File** | 本地文件上传、文件访问路径处理、OSS 上传逻辑（预留） |
| **Monitor** | 系统资源性能监控、Redis 性能测试、访问量统计 |

## 🛠️ 环境要求

- **JDK**: 21+
- **Maven**: 3.6+
- **MySQL**: 8.0+
- **Redis**: 6.0+
- **Node.js**: 16+
- **npm**: 8+

## 📦 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/Aftnos/Aftourism-server.git
cd Aftourism-server
```

### 2. 数据库初始化
```bash
# 创建数据库
mysql -u root -p < "docs/SQL/全量备份2026-4-22.sql"
```

### 3. 后端启动
```bash
# 安装依赖
mvn clean install

# 启动应用
mvn spring-boot:run
```

### 4. 前端启动
```bash
cd web
npm install
npm run dev
```

## 🔧 配置说明

### 数据库配置
在 `src/main/resources/application.yml` 中配置数据库连接：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/aftourism_server
    username: root
    password: your_password
```

### Redis 配置
```yaml
spring:
  redis:
    host: localhost
    port: 6379
    password: your_redis_password
```

## 📖 API 文档

当前接口资料以仓库内静态文档为准：

- 登录接口：[docs/login/login.md](docs/login/login.md)
- RBAC 权限：[docs/RBAC/RBAC.md](docs/RBAC/RBAC.md)
- 门户 OpenAPI：[docs/PortalAPI/openapi.yaml](docs/PortalAPI/openapi.yaml)
- 后台补充接口：[docs/PortalAPI](docs/PortalAPI)

## 🧪 测试

```bash
# 运行后端测试
mvn test

# 运行前端测试
cd web
npm run test
```

## 📝 开发规范

- 遵循 RESTful API 设计规范
- 使用统一的响应格式和异常处理
- 代码注释使用 JavaDoc 格式
- 前端组件采用 Composition API
- Git 提交信息遵循 Conventional Commits

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 Apache-2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目维护者: Aftnos
- 邮箱: alyfk@qq.com
- 项目地址: https://github.com/Aftnos/Aftourism-server

---

## 📚 文档导航

想要深入了解项目？可以查看以下文档：

- [开发者手册](docs/DEVELOPER_GUIDE.md)：项目架构、本地启动、后端/前端代码地图、核心机制、数据库说明与常见开发任务
- [项目包结构说明](docs/Project.md)：后端模块和包结构概览
- [登录接口文档](docs/login/login.md)：管理员与门户用户登录协议
- [RBAC 权限文档](docs/RBAC/RBAC.md)：后台角色、菜单、按钮与资源权限设计
- [门户 API 文档](docs/PortalAPI/openapi.yaml)：前台门户接口 OpenAPI 说明
- [最新数据库全量备份](docs/SQL/全量备份2026-4-22.sql)：当前数据库结构与数据快照，开发核对时优先级高于旧 SQL 文档
