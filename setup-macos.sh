#!/usr/bin/env bash
# =============================================================================
#  Zorin OS 18 Core -> visual macOS (WhiteSur)
#  Tema: WhiteSur GTK, ícones, cursores, fontes SF Pro, wallpaper estilo macOS.
#  Uso:  bash setup-macos.sh
#        bash setup-macos.sh --no-nvidia   (pula a pergunta do driver NVIDIA)
#        bash setup-macos.sh --restore     (restaura visual original)
# =============================================================================
set -euo pipefail

# ------------------------- config -------------------------
ACCENT="default"        # default|blue|purple|pink|red|orange|yellow|green|grey
SHELL_ICON="apple"      # ícone Apple na barra superior
PANEL_OPACITY="45"      # 30 | 45 | 60 | 75 -> transparência da barra
COLOR_SCHEME="dark"     # light | dark
USER_THEME="WhiteSur-Dark"
USER_ICON="WhiteSur-Dark"
USER_CURSOR="McMojave"
USER_FONT="SF Pro Display 11"
USER_MONO="JetBrains Mono 11"
WP_REPO="vinceliuice/WhiteSur-wallpapers"

WORKDIR="${HOME}/.cache/macos-setup"
BACKUP="${HOME}/.config/macos-setup-backup.conf"
B=0; DRIVER="ask"

for arg in "$@"; do
  case "$arg" in
    --restore) B=1 ;;
    --no-nvidia) DRIVER="skip" ;;
  esac
done

# ------------------------- util -------------------------
log()  { printf '\033[1;36m[macos]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[erro]\033[0m %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' não encontrado."; }

check_distro() {
  . /etc/os-release
  case "$ID" in
    zorin|ubuntu|pop) : ;;
    *) warn "Distribuição '$ID' não testada (o alvo é Zorin OS 18)." ;;
  esac
  need git; need curl
}

fix_apt() {
  log "Corrigindo possíveis estados quebrados do apt (problema conhecido do Zorin Core)..."
  sudo apt-get update -y
  sudo apt-get install -y --fix-broken || true
  sudo apt-get upgrade -y || true
}

install_base_pkgs() {
  log "Instalando pacotes base..."
  sudo apt-get install -y \
    gnome-tweaks gnome-shell-extension-manager \
    sassc libxml2-utils libglib2.0-dev-bin libgtk-3-bin \
    fonts-jetbrains-mono fontconfig
}

install_nvidia() {
  lspci 2>/dev/null | grep -qi nvidia || { log "Nenhuma placa NVIDIA detectada. Pulando."; return; }
  case "$DRIVER" in
    skip) return ;;
    ask)
      read -r -n1 -p "Placa NVIDIA detectada. Instalar driver recomendado agora? (s/N) " r
      echo
      [[ "${r,,}" == "s" ]] || { log "Driver NVIDIA pulado (pode instalar depois com 'sudo ubuntu-drivers autoinstall')."; return; }
      ;;
  esac
  log "Instalando driver NVIDIA recomendado..."
  sudo ubuntu-drivers autoinstall
  warn "Driver instalado. Um reboot será necessário ao final."
}

backup_visual() {
  log "Salvando aparência atual em '${BACKUP}'..."
  {
    echo "# backup gerado em $(date)"
    echo "gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme)"
    echo "icon_theme=$(gsettings get org.gnome.desktop.interface icon-theme)"
    echo "cursor_theme=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null)"
    echo "font_name=$(gsettings get org.gnome.desktop.interface font-name)"
    echo "mono_font=$(gsettings get org.gnome.desktop.interface monospace-font-name)"
    echo "color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)"
    echo "background=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null)"
    echo "bg_dark=$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null)"
  } > "$BACKUP"
}

restore_visual() {
  [[ -f "$BACKUP" ]] || die "Arquivo de backup não encontrado: $BACKUP"
  log "Restaurando aparência original..."
  . "$BACKUP"
  gsettings set org.gnome.desktop.interface gtk-theme "${gtk_theme:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "${icon_theme:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface font-name "${font_name:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface monospace-font-name "${mono_font:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "${color_scheme:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri "${background:-}" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "${bg_dark:-}" 2>/dev/null || true
  log "Feito. Saia e entre de novo na sessão."
}

clone_repo() { # repositório, destino
  local repo="$1" dest="$2"
  [[ -d "$dest" ]] || git clone --depth=1 "https://github.com/$repo.git" "$dest"
}

install_gtk_theme() {
  log "Instalando tema WhiteSur GTK (accent: $ACCENT, scheme: $COLOR_SCHEME)..."
  clone_repo "vinceliuice/WhiteSur-gtk-theme" "$WORKDIR/WhiteSur-gtk-theme"
  ( cd "$WORKDIR/WhiteSur-gtk-theme"
    ./install.sh -c "$COLOR_SCHEME" -t "$ACCENT" -a alt -m \
      --shell -i "$SHELL_ICON" -p "$PANEL_OPACITY" -l )
}

install_icon_theme() {
  log "Instalando ícones WhiteSur..."
  clone_repo "vinceliuice/WhiteSur-icon-theme" "$WORKDIR/WhiteSur-icon-theme"
  ( cd "$WORKDIR/WhiteSur-icon-theme"
    ./install.sh -t "$ACCENT" -a -b )
}

install_cursors() {
  log "Instalando cursores McMojave..."
  clone_repo "vinceliuice/McMojave-cursors" "$WORKDIR/McMojave-cursors"
  ( cd "$WORKDIR/McMojave-cursors"
    ./install.sh -d "${HOME}/.local/share/icons" )
}

install_fonts() {
  log "Instalando fonte SF Pro..."
  clone_repo "sannajm/SF-Pro" "$WORKDIR/SF-Pro"
  mkdir -p "${HOME}/.local/share/fonts/SF-Pro"
  cp -n "$WORKDIR"/SF-Pro/SF-Pro-*.otf "${HOME}/.local/share/fonts/SF-Pro/" 2>/dev/null || true
  fc-cache -f >/dev/null 2>&1
}

install_wallpaper() {
  log "Baixando wallpapers estilo macOS (WhiteSur)..."
  clone_repo "$WP_REPO" "$WORKDIR/WhiteSur-wallpapers"
  mkdir -p "${HOME}/.local/share/backgrounds/WhiteSur"
  cp -n "$WORKDIR"/WhiteSur-wallpapers/WhiteSur-wallpapers/*.png \
        "${HOME}/.local/share/backgrounds/WhiteSur/" 2>/dev/null || true
  local pics=("${HOME}"/.local/share/backgrounds/WhiteSur/*.png)
  if [[ ${#pics[@]} -gt 0 ]]; then
    gsettings set org.gnome.desktop.background picture-uri "file://${pics[0]}"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://${pics[0]}"
  fi
}

apply_visual() {
  log "Aplicando tema, ícones, cursor e fontes..."
  gsettings set org.gnome.desktop.interface gtk-theme "$USER_THEME"
  gsettings set org.gnome.desktop.interface icon-theme "$USER_ICON"
  gsettings set org.gnome.desktop.interface cursor-theme "$USER_CURSOR"
  gsettings set org.gnome.desktop.interface font-name "$USER_FONT"
  gsettings set org.gnome.desktop.interface monospace-font-name "$USER_MONO"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-$COLOR_SCHEME"
  gsettings set org.gnome.shell.extensions.user-theme name "$USER_THEME" 2>/dev/null || true
}

main() {
  if [[ "$B" == 1 ]]; then restore_visual; exit 0; fi

  check_distro
  fix_apt
  install_base_pkgs
  [[ "$DRIVER" != "skip" ]] && install_nvidia

  backup_visual
  install_gtk_theme
  install_icon_theme
  install_cursors
  install_fonts
  install_wallpaper
  apply_visual

  echo
  log "Visual macOS aplicado!"
  warn "Saia e entre de novo na sessão (ou reinicie) para ver o GNOME Shell."
  warn "Se algo não aplicar, use Zorin Appearance -> Aparência e selecione WhiteSur / McMojave."
  [[ "$DRIVER" != "ask" ]] || true
}

main "$@"