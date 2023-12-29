# Magick 的手动构建测试环境。
# 此镜像会下载并解压源代码，安装必要的构建工具链。

FROM ghcr.io/void-linux/void-glibc-busybox:20231003R1

ENV IMAGE_MAGICK_VERSION="7.1.1-24" \
    # elixir expects utf8.
    LANG=C.UTF-8

WORKDIR /src

RUN set -xe \
    && MAGICK_DOWNLOAD_URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGE_MAGICK_VERSION}.tar.gz" \
    && MAGICK_DOWNLOAD_SHA256="b98174148ddd875e64a861f5a4606c777bb7f33ac6b780886756f05ff971fb6f" \
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
    # FreeMono 等字体（水印渲染）
    freefont-ttf \
    ' \
    && xbps-install -y $buildDeps \
    # Set locale to C.UTF-8
    && sed -i 's/^#C.UTF-8/C.UTF-8/' /etc/default/libc-locales \
    && xbps-reconfigure -f glibc-locales \
    # 编译安装 ImiageMagick
    && export MAGICK_SRC="/src" \
    && mkdir -vp $MAGICK_SRC \
    && tar -xzf magick-src.tar.gz -C $MAGICK_SRC --strip-components=1
