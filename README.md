# scott-bazzite

Bazzite-DX (`ghcr.io/ublue-os/bazzite-dx:stable`) with the packages a machine needs to join the SCOTT domain and use TPM
PIN sign-in, so [`scott/ad-join`](https://git.davidallanscott.ca/scott/ad-join)'s `bazzite/1-layer.sh` and its
reboot aren't needed. Built from [ublue-os/image-template](https://github.com/ublue-os/image-template); GitHub
Actions rebuilds it every day, so it follows Bazzite-DX's updates.

What's added is in [`build_files/build.sh`](build_files/build.sh). Configuration stays in ad-join, which writes it
per machine.

## Install

- **New machine:** run the *Build disk images* workflow and install from its `anaconda-iso` artifact. The installer
  switches to this image at the end (`disk_config/iso.toml`).
- **Existing Bazzite:**
  ```bash
  sudo bootc switch ghcr.io/mrdavid5465/scott-bazzite:latest
  ```
  then reboot.

Then, from a clone of ad-join: `bazzite/2-join.sh`, the fresh-home or in-place steps, and `common/tpm-enroll.sh`.

## Signing

The build signs each image with cosign. Generate a key pair once (`cosign generate-key-pair`), add
`cosign.key` as the repo secret `SIGNING_SECRET`, and commit `cosign.pub`. Never commit `cosign.key`.
