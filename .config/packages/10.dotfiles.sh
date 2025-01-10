#!/bin/sh -e
git_deploy "seanenck/dotfiles"
(cd "${PKGS_DIR}/dotfiles.git" && "./dotfiles")
