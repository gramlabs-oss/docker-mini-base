# docker-mini-base

Policr Mini 的基础镜像。

## 介绍

本项目的镜像总是基于统一的环境，当前是 [`void-linux/void-glibc-busybox:20240303R1`](https://github.com/void-linux/void-containers/pkgs/container/void-glibc-busybox)。这是 Void Linux 的官方镜像，基于 glibc/BusyBox 表明它同时具备体积小巧和兼容性高的优势。

_本仓库仍然保留了已过时的 `debian:bullseye` 系列镜像，但是它们不支持 `arm64` 环境。_

### 构建基础镜像

由于 Policr Mini 项目日渐复杂，它急需一个整合了多种编程语言的工具链和多个库依赖的单一环境来辅助编译，构建镜像为此而生。

构建环境较为庞大，因为它包含 Elixir/Rust 的完整工具链以及 ImageMagick 等必要的库依赖。构建镜像可以直接完成对前端以外的 Policr Mini 代码的编译（前端应作为独立的步骤构建）。

### 运行基础镜像

运行基础镜像是构建镜像的简化版本，它不包含 Rust 和其它编译期工具链，仅包含必要的运行时依赖库。通常来讲运行时镜像会尽可能的追求精简。

## 用途介绍

任何人通过本仓库制作的镜像可轻易完成对 Policr Mini 项目的手动构建，大幅度提升编译体验。同时它们也是 CI 步骤中构建和打包的所使用的基础镜像，可以 100% 复现线上版本。
