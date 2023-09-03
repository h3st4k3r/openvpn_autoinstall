#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

apt update
apt upgrade -y

apt install openvpn -y

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

read -p "Ingresa el puerto de configuración (por defecto 443): " custom_port

if [ -z "$custom_port" ]; then
  custom_port=443
fi

sed -i "s/port 1194/port $custom_port/g" /etc/openvpn/server.conf

while true; do
  read -p "Nombre de usuario: " username
  if [ -n "$username" ]; then
    break
  else
    echo "El nombre de usuario es obligatorio. Por favor, ingresa un valor válido."
  fi
done

while true; do
  read -s -p "Contraseña: " password
  echo
  if [ -n "$password" ]; then
    break
  else
    echo "La contraseña es obligatoria. Por favor, ingresa un valor válido."
  fi
done

echo -e "$username\n$password" > /etc/openvpn/credentials

chmod 600 /etc/openvpn/credentials

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

systemctl restart openvpn@server

echo "La configuración de OpenVPN se ha completado. El servidor se ha configurado para escuchar en el puerto $custom_port."
