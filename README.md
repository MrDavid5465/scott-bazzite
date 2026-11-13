# scott-bazzite

Bazzite-DX with the packages a machine needs to join the SCOTT domain and use TPM PIN sign-in, so
[`scott/ad-join`](https://git.davidallanscott.ca/scott/ad-join)'s `bazzite/1-layer.sh` and its reboot aren't needed.
Built from [ublue-os/image-template](https://github.com/ublue-os/image-template); GitHub Actions rebuilds it every
day, so it follows Bazzite-DX's updates.

| Image | Base | For |
|---|---|---|
| `ghcr.io/mrdavid5465/scott-bazzite` | `bazzite-dx:stable` | Intel/AMD graphics (Thor) |
| `ghcr.io/mrdavid5465/scott-bazzite-nvidia` | `bazzite-dx-nvidia:stable` | NVIDIA graphics (superpotato) |

What's added is in [`build_files/build.sh`](build_files/build.sh): the packages, and a signature policy that trusts
[`cosign.pub`](cosign.pub) for `ghcr.io/mrdavid5465`. Configuration stays in ad-join, which writes it per machine.

## Install

**New machine (Intel/AMD):** run the *Build disk images* workflow and install from its `anaconda-iso` artifact. The
installer switches to `scott-bazzite` at the end ([`disk_config/iso.toml`](disk_config/iso.toml)). After the first
boot, turn on signature checking (the image now trusts its own key):

```bash
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/mrdavid5465/scott-bazzite:latest
```

**Existing Bazzite (rebase):** use `rpm-ostree rebase`, not `bootc switch`, so packages layered by `1-layer.sh`
are kept. It takes two rebases, because the machine doesn't trust this repo's key until it runs the image:

```bash
# 1. once, unverified: the current image doesn't know this key yet (use scott-bazzite-nvidia on NVIDIA)
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/mrdavid5465/scott-bazzite:latest
systemctl reboot
# 2. from now on, signed: every update checks the signature
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/mrdavid5465/scott-bazzite:latest
systemctl reboot
```

The packages the image now provides can then be dropped from the layer list by name (`rpm-ostree status` shows
what's layered): `sudo rpm-ostree uninstall sssd-ad adcli ...`. Don't use `rpm-ostree reset`, which also drops
anything else you layered.

Then, from a clone of ad-join: `bazzite/2-join.sh`, the fresh-home or in-place steps, and `common/tpm-enroll.sh`
(skip what an already-joined machine has done).

## Signing

The build signs each image with cosign. The private key is the repo secret `SIGNING_SECRET`; [`cosign.pub`](cosign.pub)
is committed, and the image installs it as `/etc/pki/containers/scott-bazzite.pub`. Never commit `cosign.key`. To
rotate: `cosign generate-key-pair`, `gh secret set SIGNING_SECRET < cosign.key`, commit the new `cosign.pub`, and
rebase machines unverified once more, since they only trust the old key until they run an image with the new one.
