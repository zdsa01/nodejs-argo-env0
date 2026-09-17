# nodejs-argo 在 env0 上部署指南

env0 是 **Infrastructure as Code (IaC)** 平台，本身不直接运行长期应用。  
本仓库提供了两种通过 env0 部署并运行 nodejs-argo 的方式：

1. **推荐：AWS App Runner**（Terraform）—— 最简单，自动获得公网 URL
2. **备选：Kubernetes**（Deployment + Service）—— 适合已有集群的用户

---

## 前置条件

1. 注册并登录 [app.env0.com](https://app.env0.com)
2. 在 env0 中连接你的云账号（AWS 或 Kubernetes 集群）
3. 拥有一个 Git 仓库（GitHub / GitLab 等），把本仓库代码推上去
4. 本地或 CI 能构建 Docker 镜像并推送到 **Amazon ECR**（或任意私有仓库）

---

## 方式一：通过 env0 + Terraform 部署到 AWS App Runner（推荐）

### 步骤 1：构建并推送 Docker 镜像到 ECR

```bash
# 登录 AWS
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# 创建仓库（只需一次）
aws ecr create-repository --repository-name nodejs-argo --region us-east-1

# 构建
cd app
docker build -t nodejs-argo .

# 打标签并推送
docker tag nodejs-argo:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/nodejs-argo:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/nodejs-argo:latest
```

记下镜像地址，例如：  
`123456789012.dkr.ecr.us-east-1.amazonaws.com/nodejs-argo:latest`

### 步骤 2：在 env0 创建 Template

1. 登录 app.env0.com → 进入你的 Project
2. 点击 **Templates** → **Create Template**
3. 选择 **Terraform**
4. 连接你的 Git 仓库
5. **Path** 填写：`terraform`（指向本仓库的 terraform 文件夹）
6. Terraform 版本建议 ≥ 1.5
7. 保存

### 步骤 3：创建 Environment 并设置变量

1. 在 Project 中点击 **Create New Environment**
2. 选择刚创建的 Template（VCS 或 Template 均可）
3. 配置以下 **Variables**（env0 支持敏感变量）：

| 变量名 | 类型 | 必填 | 示例 / 说明 |
|--------|------|------|-------------|
| `image_identifier` | string | **是** | `123456789012.dkr.ecr.us-east-1.amazonaws.com/nodejs-argo:latest` |
| `aws_region` | string | 否 | `us-east-1` |
| `service_name` | string | 否 | `nodejs-argo` |
| `uuid` | sensitive | 否 | 你的 UUID |
| `argo_domain` | string | 否 | 固定隧道域名（留空 = 临时隧道） |
| `argo_auth` | sensitive | 否 | 固定隧道 Token/JSON（留空 = 临时隧道） |
| `cfip` | string | 否 | `saas.sin.fan` |
| `cfport` | string | 否 | `443` |
| `name_prefix` | string | 否 | `env0` |
| `sub_path` | string | 否 | `sub` |
| `nezha_server` | string | 否 | 哪吒地址 |
| `nezha_key` | sensitive | 否 | 哪吒密钥 |
| `chat_id` | string | 否 | Telegram Chat ID |
| `bot_token` | sensitive | 否 | Telegram Bot Token |
| `cpu` | string | 否 | `1024`（1 vCPU） |
| `memory` | string | 否 | `2048`（2 GB） |

4. 确保已配置 AWS 凭证（env0 Credentials）
5. 点击 **Deploy**

### 步骤 4：获取结果

部署成功后，在 **Outputs** 中可以看到：

- `service_url`：App Runner 公网地址
- `subscription_url`：完整订阅地址（`https://xxxx.awsapprunner.com/sub`）

访问该 URL 即可获取节点订阅。

### 更新应用

1. 重新构建并推送镜像（可用相同 tag 或新 tag）
2. 如果使用新 tag，在 env0 更新 `image_identifier` 变量后重新 Deploy
3. 如果使用 `latest`，可在 App Runner 控制台手动触发重新部署，或修改 Terraform 添加 `auto_deployments_enabled = true`（需要额外配置）

---

## 方式二：通过 env0 部署到 Kubernetes

### 前置

- 已有 Kubernetes 集群，并在 env0 中配置好连接（kubeconfig 或云托管集群权限）
- 镜像已推送到集群可拉取的仓库（ECR / GHCR / 私有仓库）

### 步骤

1. 在 env0 创建 **Kubernetes** 类型的 Template
2. Path 指向 `k8s` 文件夹
3. 先手动或通过另一个 Template 创建 ConfigMap 和 Secret（参考 `k8s/configmap-secret-example.yaml`）
4. 修改 `k8s/deployment.yaml` 中的 `image:` 为你的镜像地址
5. 创建 Environment 并 Deploy

部署后使用 `kubectl port-forward` 或 Ingress 暴露服务，然后访问 `/sub`。

---

## 本地测试（强烈建议）

```bash
cd app
docker build -t nodejs-argo .
docker run -d -p 3000:3000 \
  -e UUID=你的UUID \
  -e PORT=3000 \
  --name argo-test nodejs-argo

# 等待 20-40 秒后测试
curl http://localhost:3000/sub
```

---

## 环境变量对照表（App Runner / K8s 通用）

| 变量 | 说明 | 默认 |
|------|------|------|
| UUID | 节点 UUID | 内置默认 |
| ARGO_DOMAIN | 固定隧道域名 | 空（临时隧道） |
| ARGO_AUTH | 固定隧道密钥 | 空（临时隧道） |
| CFIP | 优选 IP/域名 | saas.sin.fan |
| CFPORT | 优选端口 | 443 |
| NAME | 节点名前缀 | 空 |
| SUB_PATH | 订阅路径 | sub |
| FILE_PATH | 运行目录 | /tmp/.npm |
| NEZHA_SERVER / NEZHA_KEY | 哪吒探针 | 空 |
| CHAT_ID / BOT_TOKEN | Telegram 推送 | 空 |
| SHOW_LOG | 是否显示日志 | true |

---

## 注意事项

1. **临时隧道**：不填 ARGO_DOMAIN + ARGO_AUTH 即可，域名会随重启变化。
2. **固定隧道**：在 Cloudflare Zero Trust 创建 Tunnel 后填写对应值。
3. App Runner 有最低费用，注意成本。
4. 镜像必须能被 App Runner / 集群拉取（ECR 权限已通过 IAM 角色处理）。
5. 本项目仅限个人使用，请遵守当地法律法规。

---

## 文件结构

```
nodejs-argo-env0/
├── app/                      # 应用源码 + Dockerfile
│   ├── Dockerfile
│   ├── index.js
│   ├── index.html
│   └── package.json
├── terraform/                # AWS App Runner Terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── k8s/                      # Kubernetes 清单
│   ├── deployment.yaml
│   └── configmap-secret-example.yaml
└── README-ENV0.md            # 本文件
```

如有问题，请检查 env0 部署日志和 App Runner / Kubernetes 事件。
