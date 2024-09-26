#!/bin/bash

SCRIPT_REPO="https://git.savannah.gnu.org/git/libiconv.git"
SCRIPT_COMMIT="0d94621c1e182f5a13a9504523afcb01ec546b37"

# https://github.com/jellyfin/jellyfin-ffmpeg/pull/466
GNULIB_COMMIT="d4ec02b3cc70cddaaa5183cc5a45814e0afb2292" # tag v1.0

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf iconv && git clone '$SCRIPT_REPO' iconv\" && git -C iconv checkout \"$SCRIPT_COMMIT\""
    echo "cd iconv && retry-tool ./autopull.sh && ./gitsub.sh checkout gnulib \"$GNULIB_COMMIT\""
}

ffbuild_dockerbuild() {
    (unset CC CFLAGS GMAKE && ./autogen.sh)

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-extra-encodings
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
