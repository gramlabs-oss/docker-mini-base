FROM hentioe/elixir:1.15.7-otp-26-slim

ENV IMAGE_MAGICK_VERSION="7.1.1-21"

COPY version-check.sh /usr/bin/version-check

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
    # JPEG 支持
    libjpeg-dev' \ 
    && runtimeDeps=' \
    # Magick 依赖
    libjpeg62-turbo \
    libgomp1' \
    && apt-get install -y --no-install-recommends $buildDeps \
    && apt-get install -y --no-install-recommends $runtimeDeps \
    && export MAGICK_SRC="/usr/src/magick-src-${IMAGE_MAGICK_VERSION}}" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf magick-src.tar.gz -C $MAGICK_SRC --strip-components=1 \
    && ( cd $MAGICK_SRC \
    && ./configure \
    && make -j$(nproc) \
    && make install ) \
    # 刷新库缓存
    && ldconfig /user/local/lib \
    # 执行清理
    && apt-get purge -y --auto-remove $fetchDeps $buildDeps \
    && rm -rf $MAGICK_SRC \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*

CMD ["version-check"]