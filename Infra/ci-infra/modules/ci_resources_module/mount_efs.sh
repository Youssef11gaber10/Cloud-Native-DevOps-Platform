#!/bin/bash
# Mounts the persistent EFS filesystem to /var/lib/jenkins.
# No formatting needed - EFS is already a filesystem the moment it's created.
# Works identically regardless of which AZ this instance launched in,
# since EFS mount targets exist in every subnet/AZ.

set -euo pipefail

MOUNT_POINT="/var/lib/jenkins"
EFS_ID="${1:?Usage: $0 <efs-file-system-id>}" # gets the EFS ID from the user
REGION="eu-north-1"

echo "==> Installing amazon-efs-utils (gives us TLS-encrypted, resilient NFS mounts)"
if ! command -v mount.efs &>/dev/null; then
    yum install -y amazon-efs-utils
fi

echo "==> Creating mount point $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

echo "==> Mounting EFS $EFS_ID"
mount -t efs -o tls "${EFS_ID}:/" "$MOUNT_POINT"

# Persist across reboots. _netdev ensures it waits for networking;
# nofail prevents a failed mount from blocking boot entirely.
if ! grep -q "$EFS_ID" /etc/fstab; then
    echo "${EFS_ID}:/  ${MOUNT_POINT}  efs  _netdev,tls,nofail  0  0" >> /etc/fstab
fi

echo "==> Setting ownership for jenkins user (jenkins package will create this user on install)"
chown -R jenkins:jenkins "$MOUNT_POINT" 2>/dev/null || true

echo "==> Mount complete. Contents of $MOUNT_POINT:"
ls -la "$MOUNT_POINT"