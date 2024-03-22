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

# Modify default IP
#sed -i 's/192.168.1.1/192.168.0.2/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 修改版本号
#sed -i "s/OpenWrt /MOLUN build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/kiddin9/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-bootstrap
rm -rf feeds/packages/net/v2ray-geodata
#rm -rf feeds/luci/themes/luci-theme-netgear
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/luci/applications/luci-app-mosdns

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/bg1.jpg feeds/innmonkey/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# x86 型号只显示 CPU 型号
#sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
#sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.html

# 加入OpenClash核心
chmod -R a+x $GITHUB_WORKSPACE/preset-clash-core.sh
$GITHUB_WORKSPACE/preset-clash-core.sh

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
git clone https://github.com/innmonkey/luci-theme-argon package/luci-theme-argon
#git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
#git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
#git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot

git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-adguardhome
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-openclash
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-jellyfin
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-xunlei
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-mosdns
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-pushbot
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-qbittorrent
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-transmission
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-argon-config
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-diskman luci-app-linkease luci-app-quickstart

echo "
# luci-theme-argon
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y

# openclash
CONFIG_PACKAGE_luci-app-openclash=y

# adguardhome
CONFIG_PACKAGE_luci-app-adguardhome=y

# mosdns
CONFIG_PACKAGE_luci-app-mosdns=y

# pushbot
CONFIG_PACKAGE_luci-app-pushbot=y

# Jellyfin
CONFIG_PACKAGE_luci-app-jellyfin=y

# xunlei
CONFIG_PACKAGE_luci-app-xunlei=y

# qbittorrent
CONFIG_PACKAGE_luci-app-qbittorrent=y

# transmission
CONFIG_PACKAGE_luci-app-transmission=y

# nas
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-dockerman=y
CONFIG_PACKAGE_luci-app-linkease=y
CONFIG_PACKAGE_luci-app-quickstart=y
" >> .config
