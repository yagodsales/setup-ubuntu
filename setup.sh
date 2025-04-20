#!/bin/bash

# --- Solicita apenas a senha sudo ---
read -sp "🔐 Digite sua senha de sudo: " SUDOPASS
echo ""

# --- Função para sudo com senha armazenada ---
sudo_cmd() {
    echo "$SUDOPASS" | sudo -S "$@"
}

# --- Atualização inicial ---
echo "🔄 Atualizando o sistema..."
sudo_cmd apt update && sudo_cmd apt upgrade -y

# --- Função de checagem de instalação ---
is_installed() {
    command -v "$1" &> /dev/null
}

## --- Java ---
#if ! is_installed java; then
#    echo "☕ Instalando Java (OpenJDK 17)..."
#    sudo_cmd apt install -y openjdk-17-jdk
#else
#    echo "☕ Java já instalado. Pulando."
#fi

# --- Golang ---
if ! is_installed go; then
    echo "🐹 Instalando Golang..."
    sudo_cmd apt install -y golang-go
else
    echo "🐹 Golang já instalado. Pulando."
fi

# --- IntelliJ IDEA ---
if ! snap list | grep -q intellij-idea-community; then
    echo "💡 Instalando IntelliJ IDEA..."

    # Verifica se há transações em andamento
    SNAP_STATUS=$(snap changes | grep 'intellij-idea-community' | grep 'in-progress')
    if [[ ! -z "$SNAP_STATUS" ]]; then
        echo "⚠️ Detected an ongoing installation of IntelliJ IDEA. Skipping installation."
    else
        sudo_cmd snap install intellij-idea-community --classic
    fi
else
    echo "💡 IntelliJ IDEA já instalado. Pulando."
fi


# --- PyCharm ---
if ! snap list | grep -q pycharm-community; then
    echo "🐍 Instalando PyCharm..."
    sudo_cmd snap install pycharm-community --classic
else
    echo "🐍 PyCharm já instalado. Pulando."
fi

# --- VS Code ---
if ! snap list | grep -q code; then
    echo "📝 Instalando VS Code..."
    sudo_cmd snap install code --classic
else
    echo "📝 VS Code já instalado. Pulando."
fi

# --- Insomnia ---
if ! snap list | grep -q insomnia; then
    echo "🌙 Instalando Insomnia..."
    sudo_cmd snap install insomnia
else
    echo "🌙 Insomnia já instalado. Pulando."
fi

# --- Calibre ---
if ! is_installed calibre; then
    echo "📘 Instalando Calibre..."
    sudo_cmd apt install -y calibre
else
    echo "📘 Calibre já instalado. Pulando."
fi

# --- DBeaver ---
if ! dpkg -l | grep -q dbeaver-ce; then
    echo "🧩 Instalando DBeaver..."
    wget -O dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    sudo_cmd apt install -y ./dbeaver.deb
    rm dbeaver.deb
else
    echo "🧩 DBeaver já instalado. Pulando."
fi

# 🐳 Corrigindo instalação do Docker

if ! is_installed docker; then
    echo "🐳 Instalando Docker e Docker Compose..."

    # Remover versões antigas
    sudo_cmd apt remove -y docker docker-engine docker.io containerd runc

    # Instalar dependências
    sudo_cmd apt update
    sudo_cmd apt install -y ca-certificates curl gnupg lsb-release

    # Criar diretório da chave
    sudo_cmd install -m 0755 -d /etc/apt/keyrings

    # Baixar chave GPG da Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo_cmd gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo_cmd chmod a+r /etc/apt/keyrings/docker.gpg

    # Escrever repositório corretamente
    ARCH=$(dpkg --print-architecture)
    DISTRO=$(lsb_release -cs)
    echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $DISTRO stable" | sudo_cmd tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Atualizar e instalar Docker + Compose plugin
    sudo_cmd apt update
    sudo_cmd apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Adicionar usuário ao grupo docker
    sudo_cmd usermod -aG docker "$USER"

    echo "✅ Docker instalado com sucesso. Reinicie ou faça logout/login para ativar o grupo docker."
else
    echo "🐳 Docker já instalado. Pulando."
fi


echo ""
echo "✅ Instalação finalizada com sucesso!"
echo "⚠️ Recomenda-se reiniciar o sistema para aplicar todas as mudanças (ex: grupo Docker)."
