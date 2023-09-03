#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

apt update
apt upgrade -y

apt install openvpn -y

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

read -p "Enter the configuration port (default is 443): " custom_port

if [ -z "$custom_port" ]; then
  custom_port=443
fi

sed -i "s/port 1194/port $custom_port/g" /etc/openvpn/server.conf

while true; do
  read -p "Username: " username
  if [ -n "$username" ]; then
    break
  else
    echo "Username is required. Please enter a valid value."
  fi
done

while true; do
  read -s -p "Password: " password
  echo
  if [ -n "$password" ]; then
    break
  else
    echo "Password is required. Please enter a valid value."
  fi
done

echo -e "$username\n$password" > /etc/openvpn/credentials

chmod 600 /etc/openvpn/credentials

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

systemctl restart openvpn@server

echo "OpenVPN configuration is complete. The server is configured to listen on port $custom_port."
