# Zorin OS 18 Core -> visual macOS

Script de pós-instalação para deixar o Zorin OS 18 Core com visual macOS
(Big Sur/Monterey). Instala e aplica, de forma automática:

- **Tema**: WhiteSur GTK (janelas, botões à esquerda, barra superior translúcida com logo Apple)
- **Ícones**: WhiteSur (pastas e apps estilo Apple)
- **Cursores**: McMojave (ponteiro do macOS)
- **Fontes**: SF Pro (interface) + JetBrains Mono (terminal)
- **Wallpaper**: fundos estilo macOS
- **Driver NVIDIA**: instala o driver recomendado (pergunta antes)

## Como usar

Depois de instalar o Zorin OS 18, abra o terminal e rode **um único comando**:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tominsp-art/zorin-macos-setup/main/setup-macos.sh)"
```

Para **pular** a instalação do driver NVIDIA no modo único:

```bash
ZORIN_DRIVER=skip bash -c "$(curl -fsSL https://raw.githubusercontent.com/tominsp-art/zorin-macos-setup/main/setup-macos.sh)"
```

> Se preferir baixar para inspecionar antes de rodar:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/tominsp-art/zorin-macos-setup/main/setup-macos.sh -o setup-macos.sh && bash setup-macos.sh
> ```

O script pedirá a senha do sudo na instalação de pacotes e, se detectar
placa NVIDIA, perguntará se deseja instalar o driver.

Ao final, **saia e entre de novo na sessão** (ou reinicie).

### Modo local (clonando o repositório)

```bash
git clone https://github.com/tominsp-art/zorin-macos-setup.git
cd zorin-macos-setup && bash setup-macos.sh
```

### Opções

| Comando | Efeito |
|---|---|
| `bash -c "$(curl -fsSL <url-do-setup>)"` | Baixa e executa tudo | 
| `ZORIN_DRIVER=skip bash -c "$(curl -fsSL <url-do-setup>)"` | Pula a instalação do driver NVIDIA |
| `bash setup-macos.sh --no-nvidia` | Pula o driver NVIDIA |
| `bash setup-macos.sh --restore` | Restaura a aparência original (faz backup antes) |

## Ajustes manuais recomendados (pós-script)

1. **Dock estilo macOS** — Zorin tem isso nativo: abra **Zorin Appearance →
   Aparência → Layout** e escolha o layout estilo macOS (dock + botões de janela
   à esquerda).
2. Se a barra superior não ficar translúcida, ative a extensão
   **Blur My Shell** pelo *Extension Manager* (instalado pelo script).
3. Para aplicar o tema em apps Flatpak (Software, etc.), rode uma vez:

   ```bash
   sudo flatpak override --filesystem="$HOME/.themes" --filesystem="$HOME/.local/share/icons"
   ```

## Notas / problemas conhecidos

- **Aplicativos libadwaita** (GTK4): o script instala o tema via `-l`
  (config `~/.config/gtk-4.0`), o que funciona, mas deixa fixo o tema claro/escuro.
- **Zorin Core + `libglib2.0-dev-bin`**: versões intermediárias do Ubuntu podem
  deixar o apt com pacotes quebrados. O script roda `apt --fix-broken` antes de
  instalar as dependências para contornar.
- O script é **idempotente**: rodar de novo não quebra nada e atualiza os temas.

## Fontes

- https://github.com/vinceliuice/WhiteSur-gtk-theme
- https://github.com/vinceliuice/WhiteSur-icon-theme
- https://github.com/vinceliuice/McMojave-cursors
- https://github.com/vinceliuice/WhiteSur-wallpapers
- https://github.com/sannajm/SF-Pro