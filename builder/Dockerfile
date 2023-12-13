FROM hentioe/elixir:1.16.0-rc.1-otp-26-slim

ENV RUST_VERSION="1.74.0" \
    IMAGE_MAGICK_VERSION="7.1.1-23" \
    RUSTUP_VERSION="1.26.0" \
    RUST_ARCH="x86_64-unknown-linux-gnu" \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

COPY version-check.sh /usr/bin/version-check

RUN set -xe \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && RUSTUP_DOWNLOAD_URL="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_ARCH}/rustup-init" \
    && MAGICK_DOWNLOAD_SHA256="7793a2de4f11c3ee08dd5d783713ca0bc0833da533bc00973d31eaee89bdb0d0" \
    && RUSTUP_DOWNLOAD_SHA256="0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db" \
    && fetchDeps=' \
    curl \
    ca-certificates' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $fetchDeps \
    && curl -fSL -o magick-src.tar.gz "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  magick-src.tar.gz" | sha256sum -c - \
    && buildDeps=' \
    make \
    g++ \
    # 添加 JPEG 支持
    libjpeg-dev' \ 
    # 此处的 `runtimeDeps` 不仅表示 app 的运行时依赖，它还包括构建 app 所需的依赖。
    && runtimeDeps=' \
    # 构建 `img_grider` 需要
    gcc \
    gcc-multilib \
    pkg-config \
    libclang-dev \
    # ImageMagick API 依赖
    libjpeg62-turbo \
    libgomp1' \
    && apt-get install -y --no-install-recommends $buildDeps \
    && apt-get install -y --no-install-recommends $runtimeDeps \
    # 编译安装 ImiageMagick
    && export MAGICK_SRC="/usr/src/magick-src-${IMAGE_MAGICK_VERSION}}" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf magick-src.tar.gz -C $MAGICK_SRC --strip-components=1 \
    && ( cd $MAGICK_SRC \
    # 禁用 ImageMagick 的 HDRI 功能
    && ./configure --disable-hdri \
    && make -j$(nproc) \
    && make install ) \
    # 编译安装 Rust
    && curl -fSL -o rustup-init $RUSTUP_DOWNLOAD_URL \
    && echo "$RUSTUP_DOWNLOAD_SHA256 rustup-init" | sha256sum -c - \
    && chmod +x rustup-init \
    && ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host $RUST_ARCH \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 清理构建依赖
    && apt-get purge -y --auto-remove $fetchDeps $buildDeps \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC \
    && rm rustup-init magick-src.tar.gz \
    # 删除 apt 缓存
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*

CMD ["version-check"]