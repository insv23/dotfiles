# 项目概述

> 本文档提供项目的全局概念和架构指导，帮助开发者快速理解项目结构和开发规范。

## 🎯 项目目标与理念 (What & Why)

**核心目标**: [在此描述项目的主要目标和价值主张]

**设计理念**:
- **简洁高效**: 优先使用成熟、轻量的技术栈
- **类型安全**: 严格的类型注解，减少运行时错误
- **测试驱动**: 代码覆盖率优先，确保质量
- **API优先**: 清晰的接口设计，便于前后端分离

## 🛠 技术栈

### 核心技术
- **Python 3.11+** - 主要开发语言
- **UV** - 现代化的 Python 包管理器
- **FastAPI** - 高性能 Web 框架
- **Pydantic v2** - 数据验证和序列化
- **SQLAlchemy** - ORM 和数据库交互

### 开发工具
- **Pytest** - 单元测试框架
- **Ruff** - 代码格式化和 Linting
- **MyPy** - 静态类型检查
- **Python-dotenv** - 环境变量管理

### 数据库 (可选)
- **PostgreSQL** - 生产环境推荐
- **SQLite** - 开发和测试环境

## 📁 目录结构与职责

```
project-root/
├── src/                    # 主要源代码
│   ├── api/               # API 路由和端点
│   ├── models/            # 数据库模型 (SQLAlchemy)
│   ├── schemas/           # API 数据模式 (Pydantic)
│   ├── services/          # 业务逻辑层
│   ├── database/          # 数据库配置和 CRUD 操作
│   ├── utils/             # 公共工具函数
│   └── main.py            # 应用入口点
├── tests/                 # 测试文件
│   ├── unit/              # 单元测试
│   ├── integration/       # 集成测试
│   └── fixtures/          # 测试数据和工具
├── docs/                  # 项目文档
├── scripts/               # 构建和部署脚本
├── .claude/               # Claude AI 配置
├── pyproject.toml         # 项目配置和依赖
├── uv.lock               # 锁定的依赖版本
└── README.md             # 项目说明
```

### 目录职责说明

- **`src/api/`**: REST API 端点定义，路由配置
- **`src/models/`**: 数据库模型 (SQLAlchemy ORM 实体)
- **`src/schemas/`**: API 数据模式 (Pydantic 请求/响应模型)
- **`src/services/`**: 核心业务逻辑，不依赖特定框架
- **`src/database/`**: 数据库连接、迁移、CRUD 基础操作
- **`src/utils/`**: 可复用的工具函数和助手类
- **`tests/`**: 完整的测试套件，镜像 src/ 结构

## 🏗 架构模式与数据流

### 三层架构
```
API Layer (FastAPI) → Service Layer (业务逻辑) → Data Layer (SQLAlchemy)
```

### 数据流设计
1. **请求处理**: FastAPI 路由接收 HTTP 请求
2. **数据验证**: Pydantic 模型验证输入数据
3. **业务逻辑**: Service 层处理核心逻辑
4. **数据持久化**: 通过 Repository 模式访问数据库
5. **响应格式**: 统一的 JSON 响应格式

### 关键模式
- **Repository Pattern**: 数据访问抽象
- **Dependency Injection**: FastAPI 的依赖注入系统
- **Schema-Model Separation**: 严格区分 API schemas (Pydantic) 和 DB models (SQLAlchemy)
- **Error Handling**: 统一的异常处理机制

## 📋 编码规范与重要原则

### 类型安全
- **必须使用类型注解**: 所有函数参数和返回值
- **禁止 `Any` 类型**: 使用 `Union` 或 `Optional`
- **严格模式**: MyPy 配置为最严格检查

### API 设计
- **RESTful 风格**: 遵循 REST 原则
- **统一响应格式**: 
  ```python
  {
    "success": true,
    "data": {...},
    "message": "操作成功"
  }
  ```
- **错误处理**: HTTP 状态码 + 详细错误信息

### 代码质量
- **测试优先**: 新功能必须有对应测试
- **文档字符串**: Google 风格的函数文档
- **代码复用**: 最大化组件和函数的可复用性
- **性能意识**: 数据库查询优化，避免 N+1 问题

## 🔧 开发工作流

### 虚拟环境
```bash
# 使用 UV 管理依赖
uv venv
source .venv/bin/activate  # Linux/Mac
```

### 代码质量检查
```bash
uv run ruff check .        # 代码检查
uv run ruff format .       # 代码格式化
uv run mypy src/           # 类型检查
uv run pytest tests/      # 运行测试
```

### 开发服务器
```bash
uv run python src/main.py  # 启动开发服务器
```

## 🔗 相关文档

- `CLAUDE.md` - AI 协作规范和编码标准
- `.claude/ROADMAP.md` - 项目需求和任务跟踪
- `.claude/commands/` - 开发工作流命令
- `README.md` - 快速开始指南

---

*💡 提示: 随着项目发展，请及时更新此文档以保持准确性*