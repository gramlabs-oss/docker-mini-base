FROM hentioe/elixir:1.18.4-otp-28-void

ARG TARGETARCH

ENV RUST_VERSION="1.88.0" \
    RUSTUP_VERSION="1.28.2" \
    IMAGE_MAGICK_VERSION="7.1.1-34" \
    MAGICK_DOWNLOAD_SHA256="19f4303774b56be182c576b266c34bc824fcaef1d1d243192344d015adb0ec28" \
    RUSTUP_DOWNLOAD_SHA256_AARCH64="e3853c5a252fca15252d07cb23a1bdd9377a8c6f3efa01531109281ae47f841c" \
    RUSTUP_DOWNLOAD_SHA256_X86_64="20a06e644b0d9bd2fbdbfd52d42540bdde820ea7df86e92e533c073da0cdd43c" \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    # 此路径包含 ImageMagick 的库，它不在 pkg-config 的默认搜索路径下（仅 Void Linux）。
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

COPY version-check.sh /usr/bin/version-check

RUN set -xe \
    && if [ "$TARGETARCH" = "arm64" ]; then \
    # Support arm64.
    export RUST_ARCH="aarch64-unknown-linux-gnu"; \
    export RUSTUP_DOWNLOAD_SHA256="$RUSTUP_DOWNLOAD_SHA256_AARCH64"; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
    # Support amd64.
    export RUST_ARCH="x86_64-unknown-linux-gnu"; \
    export RUSTUP_DOWNLOAD_SHA256="$RUSTUP_DOWNLOAD_SHA256_X86_64"; \
    fi \
    && RUSTUP_DOWNLOAD_URL="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_ARCH}/rustup-init" \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && fetchDeps=' \
    curl' \
    # Skip extraction of `/etc/hosts` file (it is read-only)
    && echo noextract=/etc/hosts >> /etc/xbps.d/noextract.conf \
    && xbps-install -Suy \
    && xbps-install -Ay $fetchDeps \
    # 下载并校验文件
    && curl -fSL -o magick-src.tar.gz "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  magick-src.tar.gz" | sha256sum -c - \
    && curl -fSL -o rustup-init "$RUSTUP_DOWNLOAD_URL" \
    && echo "$RUSTUP_DOWNLOAD_SHA256  rustup-init" | sha256sum -c - \
    # 安装构建依赖
    && buildDeps=' \
    make \
    gcc \
    pkg-config \
    # 添加 JPEG 支持
    libjpeg-turbo-devel \
    libgomp-devel' \
    # 此处的 `runtimeDeps` 不仅表示 app 的运行时依赖，它还包括构建 app 所需的依赖。
    && runtimeDeps=' \
    # Elixir 运行时依赖
    libstdc++ \
    libssl3 \
    lksctp-tools \
    ncurses-libs \
    # 构建 Rust 代码需要
    gcc \
    clang \
    pkg-config \
    # ImageMagick API 依赖
    libjpeg-turbo \
    libgomp' \
    && xbps-install -Ay $buildDeps \
    # 编译安装 ImiageMagick
    && export MAGICK_SRC="/usr/src/magick-src-${IMAGE_MAGICK_VERSION}}" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf magick-src.tar.gz -C $MAGICK_SRC --strip-components=1 \
    && ( cd $MAGICK_SRC \
    # 禁用 ImageMagick 的 HDRI 功能
    && ./configure --disable-hdri \
    && make -j$(nproc) \
    && make install ) \
    # 安装 Rust
    && chmod +x rustup-init \
    && ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host $RUST_ARCH \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    # 清理构建依赖
    && xbps-remove -Roy $fetchDeps $buildDeps \
    # 安装运行时依赖
    && xbps-install -y $runtimeDeps \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC rustup-init magick-src.tar.gz \
    # 执行 Void Linux 的清理脚本
    && void-cleanup

CMD ["version-check"]
