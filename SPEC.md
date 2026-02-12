# SPEC: sec-scan 镜像工具集成到 workflow skill

## Overview

将 sec-scan Docker 镜像的 5 个安全工具（Trivy、Gitleaks、Semgrep、Syft、Cosign）全部集成到 workflow skill 的 `scan security` 子命令中。当前仅集成了 Trivy 和 Gitleaks，需新增 Semgrep、Syft、Cosign。

## Design Reference

> See [DESIGN.md](DESIGN.md) for product design details (user stories, business logic, Cosign 双重门控等).

## Goals

- [ ] Semgrep SAST 扫描集成，默认启用
- [ ] Syft SBOM 生成集成，默认禁用
- [ ] Cosign 镜像签名验证集成，默认禁用，双重门控
- [ ] JSON 输出扩展为 5 个扫描器字段
- [ ] 测试覆盖新增扫描器的 strict/loose 和 task-aware 模式
- [ ] 修复 coding gate 遗漏 untracked 文件检测

## Non-Goals

- 不修改 `ansible-ee-build` 仓库的任何文件
- 不增加新的 scan 子命令（复用现有 `scan security`）
- 不改变现有 trivy/gitleaks 的行为

## Background

sec-scan 镜像（`ansible-ee-build/images/sec-scan/`）预装了 Semgrep 1.67.0、Gitleaks 8.21.2、Trivy 0.58.2、Syft 1.18.1、Cosign 2.4.1。workflow skill 的 `security-scan.sh` 目前仅使用其中 2 个。

## Design

### Architecture

遵循现有 scan 架构（三层）：

```
cmd/task.sh::cmd_scan_security()     — 任务编排层（task-aware / standalone）
    ↓
lib/security-scan.sh::main()         — 扫描调度层（聚合 5 个扫描器）
    ↓
scan_trivy / scan_gitleaks / ...     — 扫描执行层（每个工具独立函数）
```

新增 3 个函数 `scan_semgrep()`、`scan_syft()`、`scan_cosign()` 插入扫描执行层。

### Config Changes

`_config.sh` 新增 6 个配置项：

```bash
SEMGREP_ENABLED="${SEMGREP_ENABLED:-true}"
SYFT_ENABLED="${SYFT_ENABLED:-false}"
COSIGN_ENABLED="${COSIGN_ENABLED:-false}"
SEMGREP_ARGS="${SEMGREP_ARGS:-scan --config auto --error}"
SYFT_ARGS="${SYFT_ARGS:-dir:.}"
COSIGN_IMAGE="${COSIGN_IMAGE:-}"
COSIGN_ARGS="${COSIGN_ARGS:-verify}"
```

## Implementation Plan

1. [ ] `_config.sh` — 添加 SEMGREP/SYFT/COSIGN 配置默认值（7 行）
2. [ ] `security-scan.sh` — 添加 `scan_semgrep()` 函数（同 scan_trivy pattern）
3. [ ] `security-scan.sh` — 添加 `scan_syft()` 函数（同 pattern）
4. [ ] `security-scan.sh` — 添加 `scan_cosign()` 函数（双重门控）
5. [ ] `security-scan.sh` — 更新 `main()` 聚合 5 个结果 + JSON 输出
6. [ ] `cmd/gate.sh` — coding gate 增加 untracked 文件检测
7. [ ] `docs/commands/scan.md` — 文档化全部 5 个扫描工具及配置
8. [ ] `tests/test_security_scan_strict_mode.sh` — 覆盖新增扫描器
9. [ ] `tests/test_workflow_scan_security_runner_task_mode.sh` — 覆盖 task-aware 模式

## Testing Strategy

- [ ] 单元测试: strict mode 下工具缺失 → 3 个新扫描器均返回 exit 1
- [ ] 单元测试: loose mode 下工具缺失 → 3 个新扫描器均返回 exit 0
- [ ] 集成测试: task-aware 模式下 strict 失败正确生成 blocked 文件
- [ ] 回归测试: 全部 10 个现有 workflow 测试保持通过

## Security Considerations

- 新增扫描器增强安全能力，无负面安全影响
- Cosign 验证需要公钥/keyless 配置，由用户通过 `COSIGN_ARGS` 传入

## Rollback Plan

所有变更在 agent-shared 仓库的 feature 分支上，回滚方式：`git revert` 或删除分支。

## References

- [docs/sec-scan.md](docs/sec-scan.md) — sec-scan 镜像 spec
- [DESIGN.md](DESIGN.md) — 产品设计文档
