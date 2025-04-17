# 🛡️ Linux Defender

**Linux Defender** é uma ferramenta simples e poderosa de monitoramento de comandos executados no terminal. Ideal para administradores de sistemas, entusiastas de segurança e pentesters que querem manter um olho nos comandos executados em sistemas Linux.

> ⚙️ Feita em Bash. Leve, rápida e pronta pra evoluir.

---

## 🚀 Funcionalidades

- 📄 Analisa logs de comandos executados
- 🔍 Detecta comandos potencialmente perigosos ou suspeitos
- ⚠️ Alerta o usuário com destaque no terminal
- 🧠 Facilmente extensível para novos padrões

---

## 📂 Estrutura
ToolLog/ ├── defender.sh # Script principal ├── logs/ # (opcional) Diretório para armazenar logs customizados └── README.md # Este arquivo

---

## 📌 Como usar

1. Dê permissão de execução:

```bash
chmod +x defender.sh

2. Rode o scan:

```bash
./defender.sh -s

