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

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 移除要替换的包
#rm -rf feeds/luci/applications/luci-app-vsftpd
#rm -rf feeds/luci/applications/luci-app-samba4
#rm -rf feeds/luci/applications/luci-app-wol
#rm -rf feeds/luci/applications/luci-app-arpbind
#rm -rf feeds/luci/applications/luci-app-vlmcsd
#rm -rf feeds/luci/applications/luci-app-accesscontrol
#rm -rf feeds/luci/applications/luci-app-ddns
#rm -rf feeds/luci/applications/luci-app-zerotier
#rm -rf feeds/luci/applications/luci-app-autoreboot

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
#git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-argon-config
#git clone https://github.com/kenzok8/golang feeds/packages/lang/golang

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 移除 bootstrap 主题
#sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/' .config

