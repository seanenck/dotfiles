#!/usr/bin/env pwsh
$pack = Join-Path "$HOME" ".config" | Join-Path -ChildPath "nvim" | Join-Path -ChildPath "pack" | Join-Path -ChildPath "plugins" | Join-Path -ChildPath "start"
$plugins = @(
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "vim-airline/vim-airline",
  "petertriho/nvim-scrollbar",
  "L3MON4D3/LuaSnip"
)
$apps = @(
  "alpinelinux/aports",
  "kovidgoyal/kitty"
)

function Fail-Message() {
    param (
        [string]$message
    )
    echo "=================="
    echo $message
    echo "=================="
    exit 1
}

function Update-NeovimPlugins() {
    echo "neovim plugins..."
    foreach ($plugin in $plugins) {
        $name = $plugin.split("/")[1]
        echo "========="
        echo "$name"
        echo "========="
        $dest = Join-Path "$pack" "$name"
        if (Test-Path "$dest") {
            $branch = git -C "$dest" rev-parse --abbrev-ref HEAD
            git -C "$dest" pull origin $branch
            if ($LastExitCode) {
                Fail-Message -message "unable to pull: $name"
            }
        } else {
            git clone "https://github.com/$url" "$dest" --single-branch
            if ($LastExitCode) {
                Fail-Message -message "unable to clone: $name"
            }
        }
        echo ""
    }
}

function Update-VersionState() {
    echo "app versions..."
    [System.Collections.ArrayList]$data = @()
    foreach ($app in $apps) {
        echo "getting state: $app"
        $tags = git ls-remote --tags "https://github.com/$app"
        foreach ($tag in $tags) {
            $ref = $tag -split '\s+'
            $ref = $ref[1]
            if ($ref.Contains("refs/tags") -and $ref -match "\d$") {
                $disp = "${app}: $ref"
                if (!$ref.Contains("{}") -and !$data.Contains($disp)) {
                    $data.Add($disp) | Out-Null
                }
            }
        }
    }
    $cache = Join-Path "$HOME" ".local" | Join-Path -ChildPath "state" | Join-Path -ChildPath "repos"
    $last = "$cache.prev"
    $data | Sort-Object | Out-File -FilePath "$cache"
    $save = 1
    if (Test-Path "$last") {
        diff -u "$last" "$cache"
        if ($LastExitCode) {
            $resp = Read-Host -Prompt "Update completed? (y/N)"
            if ($resp.ToLower() -ne 'y') {
                $save = 0
            }
        }
    }
    if ($save) {
        mv "$cache" "$last"
    }
    echo ""
}

function Sync-LocalData() {
    $parent = Join-Path "/mnt" "workdir" | Join-Path -ChildPath "host"
    echo "syncing data..."
    foreach ($dir in Get-ChildItem "$parent") {
        $path = $dir.FullName
        $name = $dir.Name
        rsync -avc --exclude="*.tmpfile" --delete-after "$path/" "store:/mnt/store/active/$name/"
        if ($LastExitCode) {
            Fail-Message -message "failed to sync: $name"
        }
    }
}

try {
    Update-NeovimPlugins
    Update-VersionState
    Sync-LocalData
} catch {
    echo "failed to update"
    $_
    exit 1
}
