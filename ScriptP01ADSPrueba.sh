#!/bin/bash
if [ "$(whoami)" == "root" ]; then
    for i in {1..6}; do
        userdel usu$i
    done

    for i in {1..2}; do
        userdel ejec$i
    done

    groupdel Usuarios_Aeropuerto
    groupdel Ejecutivos_Aeropuerto
    groupdel Ejecutivos
    groupdel Usuarios_CC
    groupdel Ejecutivos_CC
    groupdel Usuarios_Parque
    groupdel Ejecutivos_Parque

    for i in {1..6}; do
        rm -r /home/usu$i
    done

    for i in {1..2}; do
        rm -r /home/ejec$i
    done

    rm -r /export

    rm -r /usr/local/bin/ls_R_Aeropuerto
    rm -r /usr/local/bin/ls_R_CC
    rm -r /usr/local/bin/ls_R_Parque
else 
  echo "${TEXT_BOLD}${TEXT_RED}Para ejecutar el script tienes que ser root${TEXT_RESET}"
  exit 0
fi