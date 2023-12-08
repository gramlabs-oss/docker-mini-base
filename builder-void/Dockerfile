FROM hentioe/elixir:1.16.0-rc.0-otp-26-void

ENV RUST_VERSION="1.74.0" \
    IMAGE_MAGICK_VERSION="7.1.1-22" \
    RUSTUP_VERSION="1.26.0" \
    RUST_ARCH="x86_64-unknown-linux-gnu" \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    # 此路径包含 ImageMagick 的库，它不在 pkg-config 的默认搜索路径下（仅 voidlinux）。
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

COPY version-check.sh /usr/bin/version-check

RUN set -xe \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && RUSTUP_DOWNLOAD_URL="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_ARCH}/rustup-init" \
    && MAGICK_DOWNLOAD_SHA256="6dc2ac4292319b995c6f46de117cbe33089006371c7f1e1310748dfdfda35441" \
    && RUSTUP_DOWNLOAD_SHA256="0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db" \
    && fetchDeps=' \
    curl' \
    && xbps-install -Sy \
    && xbps-install -y $fetchDeps \
    # 下载并校验文件
    && curl -fSL -o magick-src.tar.gz "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  magick-src.tar.gz" | sha256sum -c - \
    && curl -fSL -o rustup-init "$RUSTUP_DOWNLOAD_URL" \
    && echo "$RUSTUP_DOWNLOAD_SHA256  rustup-init" | sha256sum -c - \
    # 安装构建依赖
    && buildDeps=' \
    make \
    gcc \
    # 添加 JPEG 支持
    libjpeg-turbo-devel \
    libgomp-devel' \ 
    # 此处的 `runtimeDeps` 不仅表示 app 的运行时依赖，它还包括构建 app 所需的依赖。
    && runtimeDeps=' \
    # 构建 Rust 代码需要
    gcc \
    pkg-config \
    libclang \
    # ImageMagick API 依赖
    libjpeg-turbo \
    libgomp' \
    && xbps-install -y $buildDeps \
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
    && xbps-remove -Ry $fetchDeps $buildDeps \
    # 安装运行时依赖
    && xbps-install -y $runtimeDeps \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC rustup-init magick-src.tar.gz \
    # 执行 VoidLinux 的清理脚本
    && void-cleanup

CMD ["version-check"]