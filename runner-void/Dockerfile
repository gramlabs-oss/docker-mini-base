FROM ghcr.io/void-linux/void-glibc-busybox:20231003R1

ENV IMAGE_MAGICK_VERSION="7.1.1-22"

COPY cleanup.sh /usr/bin/void-cleanup
COPY env-test.sh /usr/bin/env-test

RUN set -xe \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && MAGICK_DOWNLOAD_SHA256="6dc2ac4292319b995c6f46de117cbe33089006371c7f1e1310748dfdfda35441" \
    && fetchDeps=' \
    curl' \
    && xbps-install -Sy \
    && xbps-install -y $fetchDeps \
    && curl -fSL -o magick-src.tar.gz "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  magick-src.tar.gz" | sha256sum -c - \
    && buildDeps=' \
    make \
    gcc \
    pkg-config \
    # JPEG 支持
    libjpeg-turbo-devel \
    # Ghostscript 支持
    ghostscript-devel \
    # Fontconfig 支持
    fontconfig-devel \
    # FreeType 支持
    freetype-devel \
    ' \ 
    && runtimeDeps=' \
    # Erlang 运行时依赖
    libssl3 \
    lksctp-tools \
    # ImageMagick API 依赖
    libjpeg-turbo \
    libgs \
    fontconfig \
    freetype \
    # FreeMono 等字体（水印渲染）
    freefont-ttf \
    ' \
    && xbps-install -y $buildDeps \
    # 编译安装 ImiageMagick
    && export MAGICK_SRC="/usr/src/magick-src-${IMAGE_MAGICK_VERSION}}" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf magick-src.tar.gz -C $MAGICK_SRC --strip-components=1 \
    && ( cd $MAGICK_SRC \
    # 定制 ImageMagick 的编译选项：
    # - 禁用 HDRI 支持
    # - 启用 Ghostscript/FreeType 支持
    && ./configure --disable-hdri --with-freetype --with-fontconfig --with-gslib \
    && make -j$(nproc) \
    # TODO: 只安装必要的库文件（自定义 prefix 安装到指定目录，再指定文件的安装过程，最后清理安装目标目录）
    && make install ) \
    # 清理构建依赖
    && xbps-remove -Ry $fetchDeps $buildDeps \
    # 安装运行时依赖
    && xbps-install -y $runtimeDeps \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC magick-src.tar.gz \
    # 执行 VoidLinux 的清理脚本
    && void-cleanup

CMD ["env-test"]