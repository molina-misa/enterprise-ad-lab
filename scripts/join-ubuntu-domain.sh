#!/bin/bash
# ==============================================================================
# Script de integración de Ubuntu 22.04/24.04 LTS a Active Directory (agmimo.local)
# Ejecutar con permisos de superusuario: sudo bash join-ubuntu-domain.sh
# ==============================================================================

set -e

DOMAIN="agmimo.local"
DOMAIN_UPPER="AGMIMO.LOCAL"
DC_IP="192.168.50.254"
HOSTNAME="UBUNTU-HOST"

echo "[1/6] Configurando Hostname y DNS..."
hostnamectl set-hostname "$HOSTNAME"

echo "[2/6] Instalando paquetes necesarios (sssd, adcli, realmd, kerberos)..."
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    realmd \
    sssd \
    sssd-tools \
    adcli \
    krb5-user \
    samba-common-bin \
    packagekit \
    pam-auth-update

echo "[3/6] Descubriendo el dominio Active Directory..."
realm discover "$DOMAIN"

echo "[4/6] Uniendo la máquina al dominio $DOMAIN..."
echo "Introduce las credenciales del Administrador de Dominio:"
realm join --verbose --user=Administrator "$DOMAIN"

echo "[5/6] Configurando creación automática de directorios home para usuarios de AD..."
pam-auth-update --enable mkhomedir

echo "[6/6] Reiniciando y verificando servicio SSSD..."
systemctl restart sssd
systemctl enable sssd

echo "=============================================================================="
echo " OK: Host $HOSTNAME unido exitosamente al dominio$DOMAIN"
echo " Probar login: su - usuario@$DOMAIN"
echo "=============================================================================="
