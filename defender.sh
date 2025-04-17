
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

Uso: ./defender.sh [opções]

Opções disponíveis:

  --scan             Analisa o histórico de comandos em busca de anomalias.
  --learn            Aprende os comandos atuais e atualiza a whitelist.
  --report           Mostra os últimos comandos considerados anômalos.
  --reset            Limpa a whitelist e os registros de anomalias.
  --help             Exibe esta tela de ajuda.

Exemplos:

  ./defender.sh --learn
  ./defender.sh --scan
  ./defender.sh --report

Arquivos utilizados:

  ~/.bash_command_log       ← Histórico de comandos do usuário
  ./whitelist.txt           ← Comandos considerados normais
  ./logs/anomalias.txt      ← Log dos comandos suspeitos detectados

Dica: rode primeiro o modo --learn para criar sua base de comandos conhecidos.

Stay paranoid. 🛡️

"

# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #

# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #

scaner() {
  scn="/var/log/bash_commands.log"
  sus=("nmap" "hydra" "sqlmap" "rm -rf" "chmod 777" "wget http" "curl http" "nc -lvp" "bash -i" "scp" "sshpass")
  anm=$(ToolLog/logs/anomalia.txt)
  echo -e "\n[🔍] Analisando: $scn"
  echo "-------------------------------------------"

  if [[ ! -f "$scn" ]]; then
    echo "[❌] Arquivo de log não encontrado!"
    exit 1
  fi
  mkdir $HOME/Bash/ToolLog/logs/anomalias.txt
  while IFS= read -r linha; do
    for suspeito in "${sus[@]}"; do
      if echo "$linha" | grep -qi "$suspeito"; then
        echo -e "[⚠️] Comando suspeito detectado: \033[1;31m$linha\033[0m"
        echo "$linha" >> "$HOME/Bash/ToolLog/logs/anomalias.txt"
      fi
    done
  done < "$scn"
}



learn() {
  n=0
  lrn=$(awk '{print $4}' /var/log/bash_commands.log | sort | uniq -i)
  while IFS= read -r linha; do
    if grep -Fxq "$linha" whitelist.txt; then
      echo "Nenhum novo comando a ser adicionado. A lista de comandos está atualizada e consistente." && exit 0
    else
      echo "$linha" >> whitelist.txt
      ((n++))
      echo "Comandos adicionados $n"
    fi
  done <<< "$lrn"
}

#flags
while [ -n "$1" ]; do
  case $1 in
    -h) echo "$help" && exit 0
      ;;
    -s) scaner && exit 0
      ;;
    --scann) scaner && exit 0
      ;;
    -r)
      ;;
    -Rp)
      ;;
    --learn)  learn && exit 0
      ;;
    -l)  learn && exit 0
      ;;
    -v) echo "$version" && exit 0
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
