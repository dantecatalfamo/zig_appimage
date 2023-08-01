#!/bin/sh


function create {
    arch=$1
    runtime="https://github.com/AppImage/AppImageKit/releases/download/13/runtime-${arch}"
    zig_json="$(curl https://ziglang.org/download/index.json)"
    zig_tarball=$(echo "$zig_json" | jq -r .master.\"${arch}-linux\".tarball)
    zig_tar_filename=$(basename $zig_tarball)
    zig_directory=$(echo $zig_tar_filename | sed 's/\.tar\.xz//')
    echo "Downloading zig master $zig_tar_filename"
    curl -O $zig_tarball
    echo "Extracting $zig_tar_filename"
    tar -xJf $zig_tar_filename
    echo "Downloading AppImage runtime"
    curl -OL $runtime
    chmod +x "runtime-${arch}"
    cd $zig_directory
    mv zig AppRun
    cd ..
    echo "Creating squashfs"
    mksquashfs "$zig_directory" "zig-$arch.squashfs"
    cat "runtime-${arch}" "zig-${arch}.squashfs" > "zig-${arch}.AppImage"
    chmod +x "zig-${arch}.AppImage"
}

function cleanup {
    rm runtime-*
    rm *.tar.zx
    rm -r zig-linux*
    rm *.squashfs
}

archs="x86_64 aarch64"

for arch in $archs; do
    echo "Creating $arch"
    create $arch
    echo "Done $arch"
done

echo "Cleaning up"
cleanup
