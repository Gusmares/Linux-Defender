
#!/usr/bin/env bash
#
# Viewer.sh - Detector de Atividades Anormais
#
# Autor:      Sirius
# GitHub:    https://github.com/Gusmares
# ------------------------------------------------------------------------ #
#  Ferramenta que compara seu padrão normal de comandos e
#  alerta quando um comando fora do padrão aparece.
#
#  Exemplos:
#      $ ./Viewer.sh -d 1
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.2.37
# ------------------------------------------------------------------------ #
# Agradecimentos:
# 	Ao Slayer.
# ------------------------------- VARIÁVEIS ----------------------------------------- #

version="v1.0"
help="
┌───────────────────────────────────────────────┐
│              LINUX DEFENDER v1.0              │
└───────────────────────────────────────────────┘

Usage: ./defender.sh [options]

Options:
  --dependencies, -d    🔧  Set up logging environment and required variables.
  --scan, -s            🔍  Scan your command history for suspicious activity.
  --learn, -l           🧠  Learn and whitelist your current command patterns.
  --report              📄  Show recent commands flagged as suspicious.
  --reset               ♻️  Clear whitelist and anomaly logs.
  --help, -h            ❓  Display this help menu.
  --version, -v         📦  Show tool version.

Examples:
  ./defender.sh --learn           # Build a whitelist from your usage
  ./defender.sh --scan            # Scan for suspicious commands
  ./defender.sh --report          # View flagged anomalies

Files Used:
  ~/.bash_command_log             →  User's command history
  ./whitelist.txt                 →  List of trusted (safe) commands
  ./logs/anomalias.txt            →  Log of detected threats

💡 Tip: Run `--learn` first to baseline your normal behavior.

Stay sharp. Stay safe. 🛡️
"

# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #

# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #

dependencies() {
    echo -e "\n\033[1;34m[⚙️] Setting up history variables...\033[0m"
    sleep 2

    grep -q 'HISTFILE=~/.bash_command_log' ~/.bashrc || echo 'export HISTFILE=~/.bash_command_log' >> ~/.bashrc
    grep -q "PROMPT_COMMAND='history -a'" ~/.bashrc || echo "export PROMPT_COMMAND='history -a'" >> ~/.bashrc
    grep -q 'HISTCONTROL=ignoredups:erasedups' ~/.bashrc || echo 'export HISTCONTROL=ignoredups:erasedups' >> ~/.bashrc

    if [ ! -f /var/log/bash_commands.log ]; then
        echo -e "\033[1;36m[🔐] Creating /var/log/bash_commands.log with proper permissions...\033[0m"
        sudo touch /var/log/bash_commands.log
        sudo chown "$USER":"$USER" /var/log/bash_commands.log
        sudo chmod 664 /var/log/bash_commands.log
    fi

    grep -q 'trap '\''echo "$(date +%F_%T) $(whoami) $(pwd) $BASH_COMMAND" >> /var/log/bash_commands.log'\'' DEBUG' ~/.bashrc || \
    echo 'trap '\''echo "$(date +%F_%T) $(whoami) $(pwd) $BASH_COMMAND" >> /var/log/bash_commands.log'\'' DEBUG' >> ~/.bashrc

    export HISTFILE=~/.bash_command_log
    export PROMPT_COMMAND='history -a'
    export HISTCONTROL=ignoredups:erasedups
    trap 'echo "$(date +%F_%T) $(whoami) $(pwd) $BASH_COMMAND" >> /var/log/bash_commands.log' DEBUG

    echo -e "\033[1;32m[✔️] Configuration successfully applied and added to .bashrc!\033[0m"
}
scaner() {
  scn="/var/log/bash_commands.log"
  sus=("nmap" "hydra" "sqlmap" "rm -rf" "chmod 777" "wget http" "curl http" "nc -lvp" "bash -i" "scp" "sshpass")

  echo -e "\n\033[1;34m[🔍] Scanning log file:\033[0m \033[1;36m$scn\033[0m"
  echo -e "\033[1;30m-------------------------------------------\033[0m"

  if [[ ! -f "$scn" ]]; then
    echo -e "\033[1;31m[❌] Log file not found!\033[0m"
    exit 1
  fi

  mkdir -p "$HOME/Linux-Defender/ToolLog/logs"
  touch "$HOME/Linux-Defender/ToolLog/logs/anomalia.txt"

  while IFS= read -r linha; do
    for suspeito in "${sus[@]}"; do
      if echo "$linha" | grep -qi "$suspeito"; then
        echo -e "\033[1;33m[⚠️] Suspicious command detected:\033[0m \033[1;31m$linha\033[0m"
        echo "$linha" >> "$HOME/Linux-Defender/ToolLog/logs/anomalia.txt"
      fi
    done
  done < "$scn"

  echo -e "\033[1;32m[✔] Scan completed. Check the log for suspicious commands.\033[0m"
}
learn() {
  n=0
  echo -e "\n\033[1;34m[🔍] Learning known commands from history...\033[0m"
  lrn=$(awk '{print $4}' /var/log/bash_commands.log | sort | uniq -i)

  while IFS= read -r line; do
    if grep -Fxq "$line" whitelist.txt; then
      echo -e "\033[1;32m[✔️] No new commands to add. Whitelist is up to date.\033[0m"
      exit 0
    else
      echo "$line" >> whitelist.txt
      ((n++))
      echo -e "\033[1;33m[+] Added new command to whitelist: \033[0m$line"
    fi
  done <<< "$lrn"

  echo -e "\n\033[1;36m[✓] Learning completed. Total new commands added: $n\033[0m"
}

#flags
while [ -n "$1" ]; do
  case $1 in
    -h) echo "$help" && exit 0
      ;;
    -s) scaner && exit 0
      ;;
    --scan) scaner && exit 0
      ;;
    -r)
      ;;
    -Rp)
      ;;
    --learn) learn && exit 0
      ;;
    -l) learn && exit 0
      ;;
    -v) echo "$version" && exit 0
      ;;
    -d) dependencies && exit 0
      ;;
    --dependencies) dependencies && exit 0
      ;;
  esac
  shift
done

#valida se o parametro é real/funfa
if [[ "$1" == "-h" || "$1" == "-s" || "$1" == "-r" || "$1" == "-Rp" || "$1" == "-l" || "$1" == "-v" ]]; then
  exit 0
else
  echo "inválido, consulte o help utilizando o comando '$ ./defender.sh -h'"
fi

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #

# ------------------------------------------------------------------------ #
