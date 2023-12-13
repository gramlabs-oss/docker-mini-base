FROM ghcr.io/void-linux/void-glibc-busybox:20231003R1

ENV IMAGE_MAGICK_VERSION="7.1.1-23" \
    # elixir expects utf8.
    LANG=C.UTF-8 

COPY cleanup.sh /usr/bin/void-cleanup
COPY env-test.sh /usr/bin/env-test

RUN set -xe \
    && export FREEFONT_ARCHIVE=freefont-ttf-20120503.zip \
    && export MAGICK_ARCHIVE=magick-src.tar.gz \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && MAGICK_DOWNLOAD_SHA256="7793a2de4f11c3ee08dd5d783713ca0bc0833da533bc00973d31eaee89bdb0d0" \
    && FREEFONT_DOWNLOAD_URL="https://ftp.gnu.org/gnu/freefont/$FREEFONT_ARCHIVE" \
    && FREEFONT_DOWNLOAD_SHA256="7c85baf1bf82a1a1845d1322112bc6ca982221b484e3b3925022e25b5cae89af" \
    && fetchDeps=' \
    curl' \
    && xbps-install -Sy \
    && xbps-install -y $fetchDeps \
    && curl -fSL -o $MAGICK_ARCHIVE "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  $MAGICK_ARCHIVE" | sha256sum -c - \
    && curl -fSL -o $FREEFONT_ARCHIVE "$FREEFONT_DOWNLOAD_URL" \
    && echo "$FREEFONT_DOWNLOAD_SHA256  $FREEFONT_ARCHIVE" | sha256sum -c - \
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
    && runtimeDeps=' \
    # Erlang 运行时依赖
    libssl3 \
    lksctp-tools \
    ncurses-libs \
    # ImageMagick API 依赖
    libjpeg-turbo \
    libgs \
    fontconfig \
    freetype \
    ' \
    && xbps-install -y $buildDeps \
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
    # 安装 FreeMono 字体
    && unzip -d freefont $FREEFONT_ARCHIVE && mv freefont/freefont-*/* freefont/ && rmdir freefont/freefont-* \
    && mkdir -p /usr/share/fonts/TTF \
    && install -m644 freefont/FreeMono*.ttf /usr/share/fonts/TTF \
    # strip 新安装的二进制文件（包括 ImageMagick）
    && scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
    && scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
    # 刷写字体缓存
    && fc-cache -f -v \
    # 刷新库缓存
    && ldconfig /usr/local/lib \
    # 清理 ImageMagick 的 .a 库文件
    && rm /usr/local/lib/libMagick*.a \
    # 清理构建依赖
    && xbps-remove -Ry $fetchDeps $buildDeps \
    # 安装运行时依赖
    && xbps-install -y $runtimeDeps \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC $MAGICK_ARCHIVE freefont $FREEFONT_ARCHIVE \
    # 执行 Void Linux 的清理脚本
    && void-cleanup

CMD ["env-test"]