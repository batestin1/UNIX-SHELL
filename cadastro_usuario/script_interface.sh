#!/usr/bin/env bash
#
# script_interface.sh - Sistema para gerenciamento de usuários
#
# Site:       none
# Autor:      Maycon Cypriano
# Manutenção: Maycon Cypriano
#
# ------------------------------------------------------------------------ #
#  Este programa faz todas as funções de gerenciamento de usuários, como:
#  inserir, deletar, alterar. Uma especie de CRUD, versao Linux.
#
#  Exemplos:
#      $ source script_interface.sh
#      $ ListaUsuarios
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 23/11/2020, Maycon:
#                   --- Iniciado e Finalizado em um dia
#                   ---- Com aulas pelo Udemy
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 23.11.20
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #
ARQUIVO_BANCO_DE_DADOS="banco_de_dados.txt"
SEP=:
TEMP=temp.$$
VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #
[ ! -e "$ARQUIVO_BANCO_DE_DADOS" ] && echo "ERRO. Arquivo não existe." && exit 1
[ ! -r "$ARQUIVO_BANCO_DE_DADOS" ] && echo "ERRO. Arquivo não tem permissão de leitura." && exit 1
[ ! -w "$ARQUIVO_BANCO_DE_DADOS" ] && echo "ERRO. Arquivo não tem permissão de escrita." && exit 1
[ ! -x "$(which dialog)" ] && sudo apt install dialog 1> /dev/null 2>&1
# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #
ListaUsuarios () {
  egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort -h | tr : ' ' > "$TEMP"
  dialog --title "Lista de Usuários" --textbox "$TEMP" 20 40
  rm -f "$TEMP"
}

ValidaExistenciaUsuario () {
  grep -i -q "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS"
}

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #
while :ls -l
do
  acao=$(dialog --title "Gerenciamento de Usuários 2.0" \
                --stdout \
                --menu "Escolha uma das opções abaixo:" \
                0 0 0 \
                listar "Listar todos os usuários do sistema" \
                remover "Remover um usuário do sistema" \
                inserir "Inserir um novo usuário no sistema")
  [ $? -ne 0 ] && exit

  case $acao in
    listar)  ListaUsuarios  ;;
    inserir)
      ultimo_id=$(egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort -h | tail -n 1 | cut -d $SEP -f 1)
      proximo_id=$(($ultimo_id+1))

      nome=$(dialog --title "Cadastro de Usuários" --stdout --inputbox "Digite o seu nome" 0 0)
      [ ! "$nome" ] && exit 1

      ValidaExistenciaUsuario "$nome" && {
        dialog --title "ERRO FATAL!" --msgbox "Usuário já cadastrado no sistema!" 6 40
        exit 1
      }

      email=$(dialog --title "Cadastro de Usuários" --stdout --inputbox "Digite o seu E-mail" 0 0)
      [ $? -ne 0 ] && continue

      echo "$proximo_id$SEP$nome$SEP$email" >> "$ARQUIVO_BANCO_DE_DADOS"
      dialog --title "SUCESSO!" --msgbox "Usuário cadastrado com sucesso!" 6 40

      ListaUsuarios
    ;;
    remover)
      usuarios=$(egrep "^#|^$" -v "$ARQUIVO_BANCO_DE_DADOS" | sort -h | cut -d $SEP -f 1,2 | sed 's/:/ "/;s/$/"/')
      id_usuario=$(eval dialog --stdout --menu \"Escolha um usuário:\" 0 0 0 $usuarios)
      [ $? -ne 0 ] && continue

      grep -i -v "^$id_usuario$SEP" "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP"
      mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"

      dialog --msgbox "Usuário removido com sucesso!"
      ListaUsuarios
    ;;
  esac
done
# ------------------------------------------------------------------------ #
