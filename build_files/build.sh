#!/bin/bash
# Bazzite-DX for the SCOTT domain: the packages ad-join's bazzite/1-layer.sh would otherwise layer, so a fresh install
# goes straight to bazzite/2-join.sh (it checks them with rpm -q) with no layering reboot. Configuration (krb5, SSSD,
# CA, sudo, polkit, PAM) stays in ad-join: 2-join.sh writes it per machine and keeps backups.

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# AD client: oddjob-mkhomedir creates home folders at first login, krb5-workstation gives klist/kinit, sssd-tools
# gives sssctl. TPM PIN sign-in (ad-join common/pin-enroll): tpm2-pkcs11 + tools, and krb5-pkinit, without which SSSD
# can't use the certificate ("System error"). pkcs11-provider is already in Bazzite. gcc builds tpm-enroll.sh's
# tpm2-pkcs11-removable adapter.
dnf5 install -y \
    sssd-ad adcli oddjob-mkhomedir krb5-workstation sssd-tools \
    krb5-pkinit tpm2-pkcs11 tpm2-pkcs11-tools gcc
