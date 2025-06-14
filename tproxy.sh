#!/bin/bash

set -e

echo "🛠️ 配置 sing-box 透明代理策略路由与防火墙..."

# 路由表设置
echo "🔧 设置 IPv4 策略路由..."
ip rule list | grep -q "fwmark 0x1 lookup 100" || ip rule add fwmark 1 table 100
ip route show table 100 | grep -q "local 0.0.0.0/0 dev lo" || ip route add local 0.0.0.0/0 dev lo table 100

echo "🔧 添加静态路由：192.168.0.0/24 → 192.168.2.2"
ip route show | grep -q "192.168.0.0/24 via 192.168.2.2" || ip route add 192.168.0.0/24 via 192.168.2.2

echo "🔧 设置 IPv6 策略路由..."
ip -6 rule list | grep -q "fwmark 0x1 lookup 106" || ip -6 rule add fwmark 1 table 106
ip -6 route show table 106 | grep -q "local ::/0 dev lo" || ip -6 route add local ::/0 dev lo table 106

# 加载 nftables 规则
NFT_FILE="/etc/sing-box-nft.conf"

if [ ! -f "$NFT_FILE" ]; then
    echo "❌ 找不到 nftables 配置文件: $NFT_FILE"
    exit 1
fi

echo "🔥 加载 nftables 配置: $NFT_FILE"
nft -f "$NFT_FILE"

echo "✅ 已完成策略路由与防火墙设置。"
