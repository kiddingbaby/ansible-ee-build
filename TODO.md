# TODO List

Generated from: SPEC.md
Branch: feat/integrate-sec-scan-workflow
Created: 2026-02-12

## Tasks

### [1] pending - 添加 Semgrep/Syft/Cosign 配置默认值到 _config.sh
- File: scripts/_config.sh
- Description: 新增 SEMGREP_ENABLED, SYFT_ENABLED, COSIGN_ENABLED, SEMGREP_ARGS, SYFT_ARGS, COSIGN_IMAGE, COSIGN_ARGS 配置项
- Dependencies: []
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

### [2] pending - 添加 scan_semgrep/scan_syft/scan_cosign 函数
- File: scripts/lib/security-scan.sh
- Description: 按现有 scan_trivy/scan_gitleaks pattern 实现三个新扫描器函数。scan_cosign 实现双重门控（COSIGN_ENABLED + COSIGN_IMAGE）
- Dependencies: [1]
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

### [3] pending - 更新 main() 聚合 5 个扫描结果
- File: scripts/lib/security-scan.sh
- Description: main() 调用 scan_semgrep/scan_syft/scan_cosign，聚合结果，JSON 输出扩展为 5 个 _passed 字段
- Dependencies: [2]
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

### [4] pending - 更新 scan 文档
- File: docs/commands/scan.md
- Description: 文档化 5 个扫描工具的配置项、默认值、使用说明
- Dependencies: [3]
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

### [5] pending - 更新测试覆盖新增扫描器
- File: tests/test_security_scan_strict_mode.sh, tests/test_workflow_scan_security_runner_task_mode.sh
- Description: 测试环境变量加入 SEMGREP_ENABLED=true SYFT_ENABLED=true COSIGN_ENABLED=false，验证 strict/loose 和 task-aware 模式
- Dependencies: [3]
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

### [6] pending - 修复 coding gate 遗漏 untracked 文件检测
- File: scripts/cmd/gate.sh
- Description: coding gate 原只检查 git diff（已跟踪文件变更），遗漏 untracked 新文件。增加 git ls-files --others --exclude-standard 检测，解决跨仓库场景下 gate 误报
- Dependencies: []
- Steps:
  - [ ] coding
  - [ ] tidy
  - [ ] lint
  - [ ] review
  - [ ] test
  - [ ] scan
  - [ ] pr

## Status

- Total: 6
- Pending: 6
- In Progress: 0
- Done: 0

## Notes

- Use `$coding <task-id>` to start implementing a task
- Use `$auto <task-id>` for fully automated execution
- Task status: pending | in_progress | done
