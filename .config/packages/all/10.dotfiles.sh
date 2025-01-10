#!/bin/sh -e
git_deploy "seanenck/dotfiles" "$PKGS_ROOT"
(cd "${PKGS_ROOT}dotfiles" && "./dotfiles")
