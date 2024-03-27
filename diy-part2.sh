#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/packages/net/v2ray-geodata
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/luci/applications/luci-app-mosdns

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-argon-config
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-aliddns
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-filebrowser filebrowser
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-jellyfin luci-lib-taskd luci-lib-xterm taskd
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-linkease linkease ffmpeg-remux
#git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 加入OpenClash核心
chmod -R a+x $GITHUB_WORKSPACE/preset-clash-core.sh
$GITHUB_WORKSPACE/preset-clash-core.sh

echo "
# openclash
CONFIG_PACKAGE_luci-app-openclash=y

# 阿里DDNS
CONFIG_PACKAGE_luci-app-aliddns=y

# filebrowser
CONFIG_PACKAGE_luci-app-filebrowser=y

# Jellyfin
CONFIG_PACKAGE_luci-app-jellyfin=y

# 易有云
CONFIG_PACKAGE_luci-app-linkease=y

" >> .config

# 修改默认IP
sed -i 's/192.168.1.1/192.168.0.2/g' package/base-files/files/bin/config_generate

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/argon/img/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/argon/img/argon.svg package/luci-theme-argon/htdocs/luci-static/argon/img/argon.svg
#cp -f $GITHUB_WORKSPACE/argon/background/background.jpg package/luci-theme-argon/htdocs/luci-static/argon/background/background.jpg
cp -f $GITHUB_WORKSPACE/argon/favicon.ico package/luci-theme-argon/htdocs/luci-static/argon/favicon.ico
cp -f $GITHUB_WORKSPACE/argon/icon/android-icon-192x192.png package/luci-theme-argon/htdocs/luci-static/argon/icon/android-icon-192x192.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-144x144.png package/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-144x144.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-60x60.png package/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-60x60.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-72x72.png package/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-72x72.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-16x16.png package/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-16x16.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-32x32.png package/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-32x32.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-96x96.png package/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-96x96.png
cp -f $GITHUB_WORKSPACE/argon/icon/ms-icon-144x144.png package/luci-theme-argon/htdocs/luci-static/argon/icon/ms-icon-144x144.png

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 取消默认的 autosamba 依赖的 luci-app-samba 到 slim 里
find  ./target/linux/ -maxdepth 2 -type f  -name Makefile -exec sed -i 's#autosamba##' {} \;
