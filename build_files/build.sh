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

# Trust this repo's cosign key for ghcr.io/mrdavid5465 (both variants), the way Bazzite trusts ublue-os's, so
# machines can rebase to ostree-image-signed:docker://ghcr.io/mrdavid5465/... and updates check the signature.
# The registries.d entry from system_files/ tells containers/image where the signatures are.
install -Dm0644 /ctx/cosign.pub /etc/pki/containers/scott-bazzite.pub
POLICY=/etc/containers/policy.json
test -f "$POLICY"
command -v jq >/dev/null || dnf5 install -y jq
jq '.transports.docker["ghcr.io/mrdavid5465"] = [{
      "type": "sigstoreSigned",
      "keyPath": "/etc/pki/containers/scott-bazzite.pub",
      "signedIdentity": {"type": "matchRepository"}
    }]' "$POLICY" > /tmp/policy.json
install -m0644 /tmp/policy.json "$POLICY"
