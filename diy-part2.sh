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
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-bootstrap
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/luci/applications/luci-app-vsftpd
rm -rf feeds/luci/applications/luci-app-samba4
rm -rf feeds/luci/applications/luci-app-wol
rm -rf feeds/luci/applications/luci-app-arpbind
rm -rf feeds/luci/applications/luci-app-vlmcsd
rm -rf feeds/luci/applications/luci-app-accesscontrol
rm -rf feeds/luci/applications/luci-app-ddns
rm -rf feeds/luci/applications/luci-app-zerotier
rm -rf feeds/luci/applications/luci-app-autoreboot

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
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot

git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-adguardhome
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-openclash
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-jellyfin luci-lib-taskd
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-xunlei
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-qbittorrent
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-transmission
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-linkease linkease
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-filebrowser filebrowser
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-aliddns
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-dockerman dockerd

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 移除 bootstrap 主题
sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/' .config

# 移除 zerotier、KMS、网络唤醒、网络共享、FTP
sed -i 's/CONFIG_PACKAGE_luci-app-zerotier=y/CONFIG_PACKAGE_luci-app-zerotier=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-vsftpd=y/CONFIG_PACKAGE_luci-app-vsftpd=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-vlmcsd=y/CONFIG_PACKAGE_luci-app-vlmcsd=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-samba4=y/CONFIG_PACKAGE_luci-app-samba4=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-wol=y/CONFIG_PACKAGE_luci-app-wol=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-accesscontrol=y/CONFIG_PACKAGE_luci-app-accesscontrol=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-arpbind=y/CONFIG_PACKAGE_luci-app-arpbind=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-ddns=y/CONFIG_PACKAGE_luci-app-ddns=n/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-autoreboot=y/CONFIG_PACKAGE_luci-app-autoreboot=n/' .config

echo "
# luci-theme-argon
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y

# openclash
#CONFIG_PACKAGE_luci-app-openclash=y

# adguardhome
#CONFIG_PACKAGE_luci-app-adguardhome=y

# mosdns
#CONFIG_PACKAGE_luci-app-mosdns=y

# pushbot
#CONFIG_PACKAGE_luci-app-pushbot=y

# Jellyfin
#CONFIG_PACKAGE_luci-app-jellyfin=y
#CONFIG_PACKAGE_app-meta-jellyfin=y
#CONFIG_PACKAGE_luci-i18n-jellyfin-zh-cn=y

# xunlei
#CONFIG_PACKAGE_luci-app-xunlei=y

# qbittorrent
#CONFIG_PACKAGE_luci-app-qbittorrent=y

# transmission
#CONFIG_PACKAGE_luci-app-transmission=y
#CONFIG_PACKAGE_transmission-daemon=y
#CONFIG_PACKAGE_luci-i18n-transmission-zh-cn=y
#CONFIG_PACKAGE_app-meta-transmission=y
#CONFIG_PACKAGE_transmission-web-control=y
#CONFIG_PACKAGE_transmission-daemon-openssl=y

# nas
CONFIG_PACKAGE_luci-app-dockerman=y
#CONFIG_PACKAGE_luci-app-linkease=y
#CONFIG_PACKAGE_luci-app-quickstart=y

# uhttpd
#CONFIG_PACKAGE_luci-app-uhttpd=y

# 阿里DDNS
#CONFIG_PACKAGE_luci-app-aliddns=y

# filebrowser
#CONFIG_PACKAGE_luci-app-filebrowser=y
" >> .config
