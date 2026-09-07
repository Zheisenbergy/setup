#!/bin/bash
# ============================================================
# 终端环境一键配置脚本
# 生成日期: 2026-09-07
# 内容: Ghostty + Fish + Starship + CLI 工具 + Claude 品牌主题
# 用法: bash setup-terminal.sh
# 说明: 只影响 Ghostty(通过 command= 强制使用 fish),
#       系统默认 shell / Terminal.app 不受影响,保持 zsh。
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "本脚本仅支持 macOS"
    exit 1
fi

# ─── 1. Homebrew ─────────────────────────────────────────────
echo ""; echo -e "${BOLD}=== 1/6 Homebrew ===${NC}"
if ! command -v brew &>/dev/null; then
    info "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -d /opt/homebrew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
    else eval "$(/usr/local/bin/brew shellenv)"; fi
else
    success "Homebrew 已安装"
fi

# ─── 2. Ghostty + Fish + Starship ────────────────────────────
echo ""; echo -e "${BOLD}=== 2/6 Ghostty + Fish + Starship ===${NC}"
brew list --cask ghostty &>/dev/null || brew install --cask ghostty
brew list fish &>/dev/null || brew install fish
brew list starship &>/dev/null || brew install starship
success "Ghostty / Fish / Starship 安装完成"

FISH_PATH="$(command -v fish)"

# ─── 3. Nerd Font ────────────────────────────────────────────
echo ""; echo -e "${BOLD}=== 3/6 MesloLGS NF 字体 ===${NC}"
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
declare -A FONTS=(
    ["MesloLGS NF Regular.ttf"]="MesloLGS%20NF%20Regular.ttf"
    ["MesloLGS NF Bold.ttf"]="MesloLGS%20NF%20Bold.ttf"
    ["MesloLGS NF Italic.ttf"]="MesloLGS%20NF%20Italic.ttf"
    ["MesloLGS NF Bold Italic.ttf"]="MesloLGS%20NF%20Bold%20Italic.ttf"
)
for name in "${!FONTS[@]}"; do
    if [[ ! -f "$FONT_DIR/$name" ]]; then
        info "下载字体: $name"
        curl -fsSL "$BASE_URL/${FONTS[$name]}" -o "$FONT_DIR/$name" || warn "下载失败: $name,可手动从 https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k 下载"
    fi
done
success "字体安装完成"

# ─── 4. CLI 工具 ─────────────────────────────────────────────
echo ""; echo -e "${BOLD}=== 4/6 命令行工具 ===${NC}"
TOOLS=(bat eza fd ripgrep btop zoxide jq tldr git-delta lazygit fzf)
for tool in "${TOOLS[@]}"; do
    brew list "$tool" &>/dev/null || brew install "$tool"
done
success "CLI 工具安装完成: ${TOOLS[*]}"

# ─── 5. 部署配置文件 ─────────────────────────────────────────
echo ""; echo -e "${BOLD}=== 5/6 部署配置文件 ===${NC}"

GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_THEMES_DIR="$HOME/.config/ghostty/themes"
mkdir -p "$GHOSTTY_DIR" "$GHOSTTY_THEMES_DIR" "$HOME/.config/fish" "$HOME/.config"

# --- Ghostty 主配置(备份已有的) ---
[[ -f "$GHOSTTY_DIR/config.ghostty" ]] && cp "$GHOSTTY_DIR/config.ghostty" "$GHOSTTY_DIR/config.ghostty.bak.$(date +%s)"
cat > "$GHOSTTY_DIR/config.ghostty" << EOF

theme = Claude Light
font-family = MesloLGS NF
font-size = 14

# 强制 Ghostty 始终用 fish,不依赖系统默认 shell
command = $FISH_PATH

# 窗口
window-padding-x = 12
window-padding-y = 8
EOF

# --- Ghostty 自定义主题: Claude Dark ---
cat > "$GHOSTTY_THEMES_DIR/Claude Dark" << 'EOF'
palette = 0=#3a3835
palette = 1=#d97757
palette = 2=#7a9b76
palette = 3=#c9a227
palette = 4=#6a8fae
palette = 5=#b083a3
palette = 6=#7a9e9f
palette = 7=#e8e6e0
palette = 8=#5a5754
palette = 9=#e08b6a
palette = 10=#8fb08a
palette = 11=#dbb84a
palette = 12=#84a8c4
palette = 13=#c497ba
palette = 14=#8fbdbe
palette = 15=#f5f4ee

background = 262624
foreground = e8e6e0
cursor-color = d97757
cursor-text = 262624
selection-background = 44413c
selection-foreground = e8e6e0
EOF

# --- Ghostty 自定义主题: Claude Light ---
cat > "$GHOSTTY_THEMES_DIR/Claude Light" << 'EOF'
palette = 0=#e8e6df
palette = 1=#c85f3d
palette = 2=#5a7d56
palette = 3=#a17f14
palette = 4=#3d6d94
palette = 5=#8f5f80
palette = 6=#4f8384
palette = 7=#1f1e1d
palette = 8=#b5b2a9
palette = 9=#d97757
palette = 10=#729a6d
palette = 11=#c19a2e
palette = 12=#5a8ab0
palette = 13=#a878a0
palette = 14=#6ba5a6
palette = 15=#1f1e1d

background = f5f4ee
foreground = 1f1e1d
cursor-color = d97757
cursor-text = f5f4ee
selection-background = e0ddd3
selection-foreground = 1f1e1d
EOF

success "Ghostty 配置 + 主题 部署完成"

# --- Starship 配置(备份已有的) ---
[[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak.$(date +%s)"
cat > "$HOME/.config/starship.toml" << 'EOF'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](red)\
$os\
$username\
[](bg:peach fg:red)\
$directory\
[](bg:yellow fg:peach)\
$git_branch\
$git_status\
[](fg:yellow bg:green)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:green bg:sapphire)\
$conda\
[](fg:sapphire bg:lavender)\
$time\
[ ](fg:lavender)\
$cmd_duration\
$line_break\
$character"""

palette = 'claude_light'

[os]
disabled = false
style = "bg:red fg:crust"

[os.symbols]
Windows = ""
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
AOSC = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:red fg:crust"
style_root = "bg:red fg:crust"
format = '[ $user]($style)'

[directory]
style = "bg:peach fg:crust"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:yellow"
format = '[[ $symbol $branch ](fg:crust bg:yellow)]($style)'

[git_status]
style = "bg:yellow"
format = '[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)'

[nodejs]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[c]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[rust]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[golang]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[php]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[java]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[kotlin]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[haskell]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[python]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)'

[docker_context]
symbol = ""
style = "bg:sapphire"
format = '[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)'

[conda]
symbol = "  "
style = "fg:crust bg:sapphire"
format = '[$symbol$environment ]($style)'
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:lavender"
format = '[[  $time ](fg:crust bg:lavender)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[❯](bold fg:green)'
error_symbol = '[❯](bold fg:red)'
vimcmd_symbol = '[❮](bold fg:green)'
vimcmd_replace_one_symbol = '[❮](bold fg:lavender)'
vimcmd_replace_symbol = '[❮](bold fg:lavender)'
vimcmd_visual_symbol = '[❮](bold fg:yellow)'

[cmd_duration]
show_milliseconds = true
format = " in $duration "
style = "bg:lavender"
disabled = false
show_notifications = true
min_time_to_notify = 45000

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
mauve = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"

[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"
text = "#c6d0f5"
subtext1 = "#b5bfe2"
subtext0 = "#a5adce"
overlay2 = "#949cbb"
overlay1 = "#838ba7"
overlay0 = "#737994"
surface2 = "#626880"
surface1 = "#51576d"
surface0 = "#414559"
base = "#303446"
mantle = "#292c3c"
crust = "#232634"

[palettes.catppuccin_latte]
rosewater = "#dc8a78"
flamingo = "#dd7878"
pink = "#ea76cb"
mauve = "#8839ef"
red = "#d20f39"
maroon = "#e64553"
peach = "#fe640b"
yellow = "#df8e1d"
green = "#40a02b"
teal = "#179299"
sky = "#04a5e5"
sapphire = "#209fb5"
blue = "#1e66f5"
lavender = "#7287fd"
text = "#4c4f69"
subtext1 = "#5c5f77"
subtext0 = "#6c6f85"
overlay2 = "#7c7f93"
overlay1 = "#8c8fa1"
overlay0 = "#9ca0b0"
surface2 = "#acb0be"
surface1 = "#bcc0cc"
surface0 = "#ccd0da"
base = "#eff1f5"
mantle = "#e6e9ef"
crust = "#dce0e8"

[palettes.claude_dark]
rosewater = "#e8b3a3"
flamingo = "#e8b3a3"
pink = "#c497ba"
mauve = "#b083a3"
red = "#d97757"
maroon = "#e08b6a"
peach = "#e08b6a"
yellow = "#c9a227"
green = "#7a9b76"
teal = "#7a9e9f"
sky = "#84a8c4"
sapphire = "#6a8fae"
blue = "#6a8fae"
lavender = "#b083a3"
text = "#e8e6e0"
subtext1 = "#c9c6bf"
subtext0 = "#a8a5a0"
overlay2 = "#8a8783"
overlay1 = "#6f6c68"
overlay0 = "#5a5754"
surface2 = "#4a4844"
surface1 = "#3a3835"
surface0 = "#302e2b"
base = "#262624"
mantle = "#201f1d"
crust = "#1a1918"

[palettes.claude_light]
rosewater = "#c85f3d"
flamingo = "#c85f3d"
pink = "#a878a0"
mauve = "#8f5f80"
red = "#d97757"
maroon = "#c85f3d"
peach = "#c85f3d"
yellow = "#a17f14"
green = "#5a7d56"
teal = "#4f8384"
sky = "#5a8ab0"
sapphire = "#3d6d94"
blue = "#3d6d94"
lavender = "#8f5f80"
text = "#1f1e1d"
subtext1 = "#3a3835"
subtext0 = "#55524d"
overlay2 = "#706c66"
overlay1 = "#8a867f"
overlay0 = "#a5a199"
surface2 = "#c0bcb2"
surface1 = "#d5d1c5"
surface0 = "#e0ddd1"
base = "#f5f4ee"
mantle = "#ece9df"
crust = "#e0ddd1"

[palettes.catppuccin_macchiato]
rosewater = "#f4dbd6"
flamingo = "#f0c6c6"
pink = "#f5bde6"
mauve = "#c6a0f6"
red = "#ed8796"
maroon = "#ee99a0"
peach = "#f5a97f"
yellow = "#eed49f"
green = "#a6da95"
teal = "#8bd5ca"
sky = "#91d7e3"
sapphire = "#7dc4e4"
blue = "#8aadf4"
lavender = "#b7bdf8"
text = "#cad3f5"
subtext1 = "#b8c0e0"
subtext0 = "#a5adcb"
overlay2 = "#939ab7"
overlay1 = "#8087a2"
overlay0 = "#6e738d"
surface2 = "#5b6078"
surface1 = "#494d64"
surface0 = "#363a4f"
base = "#24273a"
mantle = "#1e2030"
crust = "#181926"
EOF

success "Starship 配置部署完成"

# --- Fish 配置(备份已有的) ---
[[ -f "$HOME/.config/fish/config.fish" ]] && cp "$HOME/.config/fish/config.fish" "$HOME/.config/fish/config.fish.bak.$(date +%s)"
cat > "$HOME/.config/fish/config.fish" << 'EOF'
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Syntax highlighting (Claude Light, matches Ghostty/Starship)
set -g fish_color_normal 1f1e1d
set -g fish_color_command 5a7d56
set -g fish_color_keyword 8f5f80
set -g fish_color_quote a17f14
set -g fish_color_redirection a878a0
set -g fish_color_end c85f3d
set -g fish_color_error d97757
set -g fish_color_param 3d6d94
set -g fish_color_comment 8a867f
set -g fish_color_selection --background=d5d1c5
set -g fish_color_search_match --background=d5d1c5
set -g fish_color_operator a17f14
set -g fish_color_escape 4f8384
set -g fish_color_autosuggestion 8a867f
set -g fish_color_cancel d97757
set -g fish_color_option 4f8384
set -g fish_pager_color_prefix 8f5f80
set -g fish_pager_color_completion 1f1e1d
set -g fish_pager_color_description 8a867f
set -g fish_pager_color_selected_background --background=d5d1c5

# Homebrew (auto-detect Apple Silicon vs Intel)
if test -d /opt/homebrew
    fish_add_path /opt/homebrew/bin
else if test -d /usr/local/Cellar
    fish_add_path /usr/local/bin
end

# Starship prompt
if command -q starship
    source (starship init fish --print-full-init | psub)
end

# fnm (Node version manager) — only if installed
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# SSH key switcher (fallback for multi-account setups)
# Usage: set-ssh-key lewis-official-20260224
# Prefer ~/.ssh/config Host aliases for automatic matching.
function set-ssh-key
    set -l key "$HOME/.ssh/$argv[1]"
    if not test -f "$key"
        echo "Key not found: $key" >&2
        echo "Available keys:" >&2
        for f in ~/.ssh/*.pub
            echo "  "(basename $f .pub) >&2
        end
        return 1
    end
    ssh-add -D 2>/dev/null
    ssh-add "$key"
    echo "Active SSH key: $argv[1]"
end

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Abbreviations (compatible with Fish 3.x and 4.x)
if status is-interactive
    abbr -a ls "eza --icons --group-directories-first"
    abbr -a ll "eza -la --icons --group-directories-first"
    abbr -a lt "eza --tree --icons --level=2"
    abbr -a cat "bat"
    abbr -a find "fd"
    abbr -a grep "rg"
    abbr -a top "btop"
    abbr -a lg "lazygit"
    abbr -a cd "z"
end

# Catppuccin theme switcher — usage: catppuccin mocha | latte | frappe | macchiato
function catppuccin --argument-names flavor
    set -l valid mocha latte frappe macchiato
    if not contains -- "$flavor" $valid
        echo "Usage: catppuccin mocha|latte|frappe|macchiato" >&2
        return 1
    end

    set -l ghostty_theme_name Mocha
    switch $flavor
        case mocha;     set ghostty_theme_name "Catppuccin Mocha"
        case latte;     set ghostty_theme_name "Catppuccin Latte"
        case frappe;    set ghostty_theme_name "Catppuccin Frappe"
        case macchiato; set ghostty_theme_name "Catppuccin Macchiato"
    end

    # --- color maps for fish syntax highlighting ---
    switch $flavor
        case mocha
            set normal cdd6f4; set cmd a6e3a1; set kw cba6f7; set quote f9e2af
            set redir f5c2e7; set end fab387; set err f38ba8; set param 89b4fa
            set comment 6c7086; set esc eba0ac; set option 94e2d5; set sel 45475a
        case latte
            set normal 4c4f69; set cmd 40a02b; set kw 8839ef; set quote df8e1d
            set redir ea76cb; set end fe640b; set err d20f39; set param 1e66f5
            set comment 9ca0b0; set esc e64553; set option 179299; set sel bcc0cc
        case frappe
            set normal c6d0f5; set cmd a6d189; set kw ca9ee6; set quote e5c890
            set redir f4b8e4; set end ef9f76; set err e78284; set param 8caaee
            set comment 737994; set esc ea999c; set option 81c8be; set sel 51576d
        case macchiato
            set normal cad3f5; set cmd a6da95; set kw c6a0f6; set quote eed49f
            set redir f5bde6; set end f5a97f; set err ed8796; set param 8aadf4
            set comment 6e738d; set esc ee99a0; set option 8bd5ca; set sel 494d64
    end

    # --- 1. Ghostty ---
    set -l ghostty_conf "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
    if test -f "$ghostty_conf"
        sed -i '' "s/^theme = .*/theme = $ghostty_theme_name/" "$ghostty_conf"
    end

    # --- 2. Starship ---
    set -l starship_conf "$HOME/.config/starship.toml"
    if test -f "$starship_conf"
        sed -i '' "s/^palette = .*/palette = 'catppuccin_$flavor'/" "$starship_conf"
    end

    # --- 3. Fish syntax highlighting (this file) ---
    set -l this_conf "$HOME/.config/fish/config.fish"
    sed -i '' \
        -e "s/^set -g fish_color_normal .*/set -g fish_color_normal $normal/" \
        -e "s/^set -g fish_color_command .*/set -g fish_color_command $cmd/" \
        -e "s/^set -g fish_color_keyword .*/set -g fish_color_keyword $kw/" \
        -e "s/^set -g fish_color_quote .*/set -g fish_color_quote $quote/" \
        -e "s/^set -g fish_color_redirection .*/set -g fish_color_redirection $redir/" \
        -e "s/^set -g fish_color_end .*/set -g fish_color_end $end/" \
        -e "s/^set -g fish_color_error .*/set -g fish_color_error $err/" \
        -e "s/^set -g fish_color_param .*/set -g fish_color_param $param/" \
        -e "s/^set -g fish_color_comment .*/set -g fish_color_comment $comment/" \
        -e "s/^set -g fish_color_operator .*/set -g fish_color_operator $quote/" \
        -e "s/^set -g fish_color_escape .*/set -g fish_color_escape $esc/" \
        -e "s/^set -g fish_color_autosuggestion .*/set -g fish_color_autosuggestion $comment/" \
        -e "s/^set -g fish_color_cancel .*/set -g fish_color_cancel $err/" \
        -e "s/^set -g fish_color_option .*/set -g fish_color_option $option/" \
        -e "s/^set -g fish_color_selection --background=.*/set -g fish_color_selection --background=$sel/" \
        -e "s/^set -g fish_color_search_match --background=.*/set -g fish_color_search_match --background=$sel/" \
        -e "s/^set -g fish_pager_color_prefix .*/set -g fish_pager_color_prefix $kw/" \
        -e "s/^set -g fish_pager_color_completion .*/set -g fish_pager_color_completion $normal/" \
        -e "s/^set -g fish_pager_color_description .*/set -g fish_pager_color_description $comment/" \
        -e "s/^set -g fish_pager_color_selected_background --background=.*/set -g fish_pager_color_selected_background --background=$sel/" \
        "$this_conf"

    echo "Switched to Catppuccin $flavor — reloading fish..."
    exec fish
end

# Claude-brand theme switcher — usage: claude-theme dark | light
function claude-theme --argument-names flavor
    set -l valid dark light
    if not contains -- "$flavor" $valid
        echo "Usage: claude-theme dark|light" >&2
        return 1
    end

    set -l ghostty_theme_name "Claude Dark"
    set -l starship_palette claude_dark
    switch $flavor
        case dark
            set ghostty_theme_name "Claude Dark"
            set starship_palette claude_dark
            set normal e8e6e0; set cmd 7a9b76; set kw b083a3; set quote c9a227
            set redir c497ba; set end e08b6a; set err d97757; set param 6a8fae
            set comment 8a8783; set esc 7a9e9f; set option 7a9e9f; set sel 4a4844
        case light
            set ghostty_theme_name "Claude Light"
            set starship_palette claude_light
            set normal 1f1e1d; set cmd 5a7d56; set kw 8f5f80; set quote a17f14
            set redir a878a0; set end c85f3d; set err d97757; set param 3d6d94
            set comment 8a867f; set esc 4f8384; set option 4f8384; set sel d5d1c5
    end

    # --- 1. Ghostty ---
    set -l ghostty_conf "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
    if test -f "$ghostty_conf"
        sed -i '' "s/^theme = .*/theme = $ghostty_theme_name/" "$ghostty_conf"
    end

    # --- 2. Starship ---
    set -l starship_conf "$HOME/.config/starship.toml"
    if test -f "$starship_conf"
        sed -i '' "s/^palette = .*/palette = '$starship_palette'/" "$starship_conf"
    end

    # --- 3. Fish syntax highlighting (this file) ---
    set -l this_conf "$HOME/.config/fish/config.fish"
    sed -i '' \
        -e "s/^set -g fish_color_normal .*/set -g fish_color_normal $normal/" \
        -e "s/^set -g fish_color_command .*/set -g fish_color_command $cmd/" \
        -e "s/^set -g fish_color_keyword .*/set -g fish_color_keyword $kw/" \
        -e "s/^set -g fish_color_quote .*/set -g fish_color_quote $quote/" \
        -e "s/^set -g fish_color_redirection .*/set -g fish_color_redirection $redir/" \
        -e "s/^set -g fish_color_end .*/set -g fish_color_end $end/" \
        -e "s/^set -g fish_color_error .*/set -g fish_color_error $err/" \
        -e "s/^set -g fish_color_param .*/set -g fish_color_param $param/" \
        -e "s/^set -g fish_color_comment .*/set -g fish_color_comment $comment/" \
        -e "s/^set -g fish_color_operator .*/set -g fish_color_operator $quote/" \
        -e "s/^set -g fish_color_escape .*/set -g fish_color_escape $esc/" \
        -e "s/^set -g fish_color_autosuggestion .*/set -g fish_color_autosuggestion $comment/" \
        -e "s/^set -g fish_color_cancel .*/set -g fish_color_cancel $err/" \
        -e "s/^set -g fish_color_option .*/set -g fish_color_option $option/" \
        -e "s/^set -g fish_color_selection --background=.*/set -g fish_color_selection --background=$sel/" \
        -e "s/^set -g fish_color_search_match --background=.*/set -g fish_color_search_match --background=$sel/" \
        -e "s/^set -g fish_pager_color_prefix .*/set -g fish_pager_color_prefix $kw/" \
        -e "s/^set -g fish_pager_color_completion .*/set -g fish_pager_color_completion $normal/" \
        -e "s/^set -g fish_pager_color_description .*/set -g fish_pager_color_description $comment/" \
        -e "s/^set -g fish_pager_color_selected_background --background=.*/set -g fish_pager_color_selected_background --background=$sel/" \
        "$this_conf"

    echo "Switched to Claude $flavor — reloading fish..."
    exec fish
end

# zoxide
zoxide init fish | source

# fzf
fzf --fish | source
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
end
EOF

success "Fish 配置部署完成"

# --- git delta ---
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
success "git-delta 配置完成"

# ─── 6. 完成 ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✅ 配置完成!${NC}"
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo ""
echo -e "  下一步:"
echo -e "    1. 打开 Ghostty(不需要改系统默认 shell,Ghostty 已强制用 fish)"
echo -e "    2. 主题切换命令: ${BOLD}catppuccin mocha|latte|frappe|macchiato${NC}"
echo -e "                     ${BOLD}claude-theme dark|light${NC}"
echo -e "    3. Claude Code 的网关配置(apiKeyHelper / 自定义模型 ID)"
echo -e "       需要单独在 ~/.claude/settings.json 里配置,本脚本不涉及"
echo -e "       (因为 API key 存在 macOS Keychain 里,属于每台机器单独设置)"
echo ""
