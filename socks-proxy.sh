#!/bin/bash
PROXY_PORT=1808

disable_proxy() {
  networksetup -setsocksfirewallproxystate Wi-Fi off
  # networksetup -setsocksfirewallproxystate Ethernet off
  echo "SOCKS proxy disabled."
}
trap disable_proxy INT

networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 $PROXY_PORT
# networksetup -setsocksfirewallproxy Ethernet 127.0.0.1 $PROXY_PORT
networksetup -setsocksfirewallproxystate Wi-Fi on
# networksetup -setsocksfirewallproxystate Ethernet on 

# Ethernet gives error: 'Unable to find item in network database"
# Maybe because I'm testing this on wifi?
echo "SOCKS proxy enabled (skipped Ethernet in ~/configs/proxy.sh)"

echo "Tunneling..."
ssh -ND $PROXY_PORT aray
