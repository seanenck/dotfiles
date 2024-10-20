dotfiles
===

Personal dotfiles

## deployment

using sparse checkout
```
cd <wd}
git clone --no-checkout
cd dotfiles
git config core.sparseCheckout true
printf '*\n!LICENSE\n!README.md' > .git/info/sparse-checkout
git checkout <branch>
rsync -avc . ~/
```
