# Embedded in Fedora's Everything netinstall ISO by .github/workflows/build-iso.yml (mkksiso). A partial kickstart:
# Anaconda still asks for the disk, the user, the time zone and so on, and installs this image instead of Fedora
# packages. The installer can't check signatures against this repo's key (its policy doesn't have it), so the
# install is unverified; the README's one rebase after the first boot turns signature checking on.
ostreecontainer --url=ghcr.io/mrdavid5465/scott-bazzite:latest --transport=registry --no-signature-verification
