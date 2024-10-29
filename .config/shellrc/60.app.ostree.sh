#!/bin/sh
if command -v rpm-ostree >/dev/null; then
  export OSTREE_IMAGE_DIR="/var/cache/image"
  if [ -d "$OSTREE_IMAGE_DIR" ]; then
    oti() {
      IMAGE="$HOME/Downloads/system.ociarchive"
      if ! buildah bud -t "oci-archive:$IMAGE" "$HOME/.config/ostree/Containerfile"; then
        echo "build failed"
        return
      fi
      TARGET="$OSTREE_IMAGE_DIR/system.ociarchive"
      echo "deploying..."
      if [ -e "$TARGET" ]; then
        if ! sudo mv "$TARGET" "$TARGET.last"; then
          echo "failed to backup last target"
          return
        fi
      fi
      if ! sudo mv "$IMAGE" "$TARGET"; then
        echo "failed to place image"
        return
      fi
      echo "bootc --transport=oci-archive $TARGET"
    }
  fi
fi
