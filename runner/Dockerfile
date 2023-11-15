FROM debian:bullseye

ENV IMAGE_MAGICK_VERSION="7.1.1-21"

COPY env-test.sh /usr/bin/env-test

RUN set -xe \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && MAGICK_DOWNLOAD_SHA256="09402e5f17c6575ef9f010bb2e21ae1710f1f3426f115ad4317ee9129c32608e" \
    && fetchDeps=' \
    curl \
    ca-certificates' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $fetchDeps \
    && curl -fSL -o magick-src.tar.gz "$MAGICK_DOWNLOAD_URL" \
    && echo "$MAGICK_DOWNLOAD_SHA256  magick-src.tar.gz" | sha256sum -c - \
    && buildDeps=' \
    make \
    gcc \
    g++ \
    pkg-config \
    # 添加 JPEG 支持
    libjpeg-dev \
    # Ghostscript 支持
    libgs-dev \
    libfontconfig-dev \
    libfreetype-dev \
    libtiff5-dev' \ 
    && runtimeDeps=' \
    # Erlang 运行时依赖
    libssl1.1 \
    libsctp1 \
    # ImageMagick API 依赖
    libjpeg62-turbo \
    libgomp1 \
    libgs9 \
    libfontconfig1 \
    libfreetype6 \
    libtiff5 \
    # FreeMono 等字体（水印渲染）
    fonts-freefont-ttf' \
    && apt-get install -y --no-install-recommends $buildDeps \
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
    # 刷新库缓存
    && ldconfig /user/local/lib \
    # 清理构建依赖
    && apt-get purge -y --auto-remove $fetchDeps $buildDeps \
    # 安装运行时依赖
    && apt-get install -y --no-install-recommends $runtimeDeps \
    # 删除构建目录和下载文件
    && rm -rf $MAGICK_SRC \
    && rm magick-src.tar.gz \
    # 删除 apt 缓存
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*

CMD ["env-test"]