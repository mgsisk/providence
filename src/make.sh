#!/bin/sh
#
# Build the provisioning script.
# ------------------------------------------------------------------------------

mkdir -p dist
tail -n+6    \
src/init.sh  \
src/lib/*.sh \
src/bin/*.sh \
src/etc/*.sh \
src/opt/*.sh \
src/term.sh  \
>dist/provisioner.sh
sed -i '' '/^==>.*/d' dist/provisioner.sh
sed -i '' '1s|^|#!/bin/sh\n|' dist/provisioner.sh
