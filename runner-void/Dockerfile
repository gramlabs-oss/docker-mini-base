FROM ghcr.io/void-linux/void-glibc-busybox:20231202R1

ENV IMAGE_MAGICK_VERSION="7.1.1-27" \
    # elixir expects utf8.
    LANG=C.UTF-8 \
    # Declare runtime dependencies.
    RUNTIME_DEPS=' \
    # Elixir 运行时依赖
    libstdc++ \
    libssl3 \
    lksctp-tools \
    ncurses-libs \
    # ImageMagick API 依赖
    libjpeg-turbo \
    libgs \
    fontconfig \
    freetype \
    '

COPY cleanup.sh /usr/bin/void-cleanup
COPY env-test.sh /usr/bin/env-test

RUN set -xe \
    && export LATOFONT_ARCHIVE=Lato2OFL.zip \
    && export MAGICK_ARCHIVE=magick-src.tar.gz \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && MAGICK_DOWNLOAD_SHA256="51114819ebed50b9f62403b6f7618ec3251dcaea1b1f5893728fbee02ceb3cfa" \
    && LATOFONT_DOWNLOAD_URL="https://www.latofonts.com/files/$LATOFONT_ARCHIVE" \
    && LATOFONT_DOWNLOAD_SHA256="42b54e96c07e299d967fc3227c7bd63a20d6cfb1dc8fd6dae83628091e20a5b8" \
    && fetchDeps=' \
    curl' \
    # Skip extraction of `/etc/hosts` file (it is read-only)
    && echo noextract=/etc/hosts >> /etc/xbps.d/noextract.conf \
    && xbps-install -Suy \
    && xbps-install -Ay $fetchDeps \
    && curl -fSL -o $MAGICK_ARCHIVE "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  $MAGICK_ARCHIVE" | sha256sum -c - \
    && curl -fSL -o $LATOFONT_ARCHIVE "$LATOFONT_DOWNLOAD_URL" \
    && echo "$LATOFONT_DOWNLOAD_SHA256  $LATOFONT_ARCHIVE" | sha256sum -c - \
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
    # Pregenerated locales
    glibc-locales \
    ' \ 
    && xbps-install -Ay $buildDeps \
    # Set locale to C.UTF-8
    && sed -i 's/^#C.UTF-8/C.UTF-8/' /etc/default/libc-locales \
    && xbps-reconfigure -f glibc-locales \
    # 编译安装 ImiageMagick
    && export MAGICK_SRC="/usr/src/magick-src-${IMAGE_MAGICK_VERSION}}" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf $MAGICK_ARCHIVE -C $MAGICK_SRC --strip-components=1 \
    && ( cd $MAGICK_SRC \
    # 定制 ImageMagick 的编译选项：
    # - 禁用 HDRI 支持
    # - 启用 Ghostscript/FreeType 支持
    && ./configure --disable-hdri --with-freetype --with-fontconfig --with-gslib \
    && make -j$(nproc) \
    && make install ) \
    # 安装字体
    && mkdir -p /usr/share/fonts/TTF \
    && unzip -d latofont $LATOFONT_ARCHIVE && mv latofont/Lato2OFL/* latofont/ && rmdir latofont/Lato2OFL \
    && latoFonts=' \
    latofont/Lato-Regular.ttf \
    latofont/Lato-Medium.ttf \
    latofont/Lato-Bold.ttf \
    latofont/Lato-Heavy.ttf \
    latofont/Lato-Black.ttf \
    ' \
    # 安装各个字重的 Lato 字体（Regular 到 Black）
    && install -m644 $latoFonts /usr/share/fonts/TTF \
    # strip 新安装的二进制文件（包括 ImageMagick）
    && scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
    && scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
    # 刷写字体缓存
    && fc-cache -fv \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 清理 ImageMagick 的 .a 库文件
    && rm /usr/local/lib/libMagick*.a \
    # 清理构建时依赖
    && xbps-remove -Roy $fetchDeps $buildDeps \
    # 安装运行时依赖
    && xbps-install -y $RUNTIME_DEPS \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC $MAGICK_ARCHIVE latofont $LATOFONT_ARCHIVE \
    # 执行 Void Linux 的清理脚本
    && void-cleanup

CMD ["env-test"]