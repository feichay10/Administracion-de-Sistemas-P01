#!/bin/bash

##### Variables y Constantes #####
WHICH_GCC="which gcc"

##### Estilos #####
TEXT_BOLD=$(tput bold)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_RED=$(tput setaf 1)
TEXT_PURPLE=$(tput setaf 5)
TEXT_YELLOW=$(tput setaf 3)
TEXT_BLUE_CYAN=$(tput setaf 6)

##### Funciones #####
error_exit()
{
  echo "${PROGNAME}: ${1:-"Error desconocido"}" 1>&2
  exit 1
}

Users_creation()
{
  echo "${TEXT_BOLD}Creamos los usuarios y configuramos las contraseñas de cada usuario...${TEXT_RESET}"
  echo "${TEXT_BOLD}Creando los usuarios...${TEXT_RESET}"
  for i in {1..6}; do
    echo "Creando el usuario $i: "
    useradd -m usu$i
    echo "La contraseña tiene que ser la misma que el usuario --> <usu$i>"
    passwd usu$i
    chage -M 90 usu$i
    chage -W 1 usu$i
    chage -I 2 usu$i

    if [ "$?" != "0" ]; then
      error_exit
    fi
    echo
  done

  echo

  echo "${TEXT_BOLD}Creando los ejecutivos...${TEXT_RESET}"
  for i in {1..2}; do
    echo "Creando el ejecutivo $i: "
    useradd -m ejec$i
    echo "La contraseña tiene que ser la misma que el usuario --> <ejec$i>"
    passwd ejec$i
    chage -M 90 ejec$i
    chage -W 1 ejec$i
    chage -I 2 ejec$i

    if [ "$?" != "0" ]; then
      error_exit
    fi
    echo
  done
}

Groups_creation()
{
  echo "${TEXT_BOLD}Creamos los grupos...${TEXT_RESET}"
  groupadd Usuarios_Aeropuerto
  for i in {2..5}; do
    usermod -a -G Usuarios_Aeropuerto usu$i
  done

  groupadd Ejecutivos_Aeropuerto
  groupadd Ejecutivos
  for i in {1..2}; do
    usermod -a -G Ejecutivos_Aeropuerto ejec$i
    usermod -a -G Ejecutivos ejec$i
  done

  groupadd Usuarios_CC
  usermod -a -G Usuarios_CC usu1
  for i in {3..5}; do
    usermod -a -G Usuarios_CC usu$i
  done
  
  groupadd Ejecutivos_CC
  usermod -a -G Ejecutivos_CC ejec2

  groupadd Usuarios_Parque
  for i in {5..6}; do
    usermod -a -G Usuarios_Parque usu$i
  done
  
  groupadd Ejecutivos_Parque
  usermod -a -G Ejecutivos_Parque ejec1
}

Users_directory()
{
  echo "${TEXT_BOLD}Directorio de cada usuario: ${TEXT_RESET}"
  for i in {1..6}; do
    chown root /home/usu$i
    chgrp usu$i /home/usu$i
    chmod 770 /home/usu$i
  done

  for i in {1..2}; do
    chown root /home/ejec$i
    chgrp ejec$i /home/ejec$i
    chmod 770 /home/ejec$i
  done
}

Creation_directory()
{
  echo "${TEXT_BOLD}Creando el directorio /export/proyectos...${TEXT_RESET}"
  mkdir /export
  mkdir /export/proyectos
  cd /export/proyectos
  mkdir Aeropuerto Centro_Comercial Parque Comun

  chgrp Usuarios_Aeropuerto Aeropuerto
  chmod 2770 Aeropuerto

  chgrp Usuarios_CC Centro_Comercial
  chmod 2770 Centro_Comercial

  chgrp Usuarios_Parque Parque
  chmod 2770 Parque

  chmod 1777 /export/proyectos/Comun
}

Access_Control_List()
{
  echo "${TEXT_BOLD}Configurando las ACL de los proyectos..."
  setfacl -m "g:Ejecutivos_Aeropuerto:rx" Aeropuerto
  setfacl -m "g:Usuarios_CC:rx" Centro_Comercial
  setfacl -m "g:Ejecutivos_Parque:rx" Parque
}

ls_program()
{
  echo "${TEXT_BOLD}Creacion de los ficheros ls...${TEXT_RESET}"
  cd /usr/local/bin
  $WHICH_GCC > /dev/null || yum install gcc.x86_64 "${TEXT_RED}No tiene el programa cpp instalado en el sistema, se procede a instalarlo...${TEXT_RESET}"
  touch ls_R_Aeropuerto.c ls_R_CC.c ls_R_Parque.c

  echo "#include <unistd.h>" > ls_R_Aeropuerto.c 
  echo "#include <stdio.h>" >> ls_R_Aeropuerto.c 
  echo "#include <stdlib.h>" >> ls_R_Aeropuerto.c 
  echo "int main(){" >> ls_R_Aeropuerto.c 
  echo "execl(\"/bin/ls\",\"/bin/ls\",\"-l\",\"-R\",\"/export/proyectos/Aeropuerto\",NULL);" >> ls_R_Aeropuerto.c 
  echo "return 0;" >> ls_R_Aeropuerto.c 
  echo "}" >> ls_R_Aeropuerto.c 

  echo "#include <unistd.h>" > ls_R_CC.c 
  echo "#include <stdio.h>" >> ls_R_CC.c 
  echo "#include <stdlib.h>" >> ls_R_CC.c 
  echo "int main(){" >> ls_R_CC.c 
  echo "execl(\"/bin/ls\",\"/bin/ls\",\"-l\",\"-R\",\"/export/proyectos/Centro_Comercial\",NULL);" >> ls_R_CC.c
  echo "return 0;" >> ls_R_CC.c 
  echo "}" >> ls_R_CC.c 

  echo "#include <unistd.h>" > ls_R_Parque.c 
  echo "#include <stdio.h>" >> ls_R_Parque.c 
  echo "#include <stdlib.h>" >> ls_R_Parque.c 
  echo "int main(){" >> ls_R_Parque.c
  echo "execl(\"/bin/ls\",\"/bin/ls\",\"-l\",\"-R\",\"/export/proyectos/Parque\",NULL);" >> ls_R_Parque.c
  echo "return 0;" >> ls_R_Parque.c
  echo "}" >> ls_R_Parque.c 
}

Compilation_ls()
{
  echo "${TEXT_BOLD}Compilando los ficheros ls...${TEXT_RESET}"
  cd /usr/local/bin
  gcc ls_R_Aeropuerto.c -o ls_R_Aeropuerto
  chgrp Ejecutivos ls_R_Aeropuerto
  chmod 4750 ls_R_Aeropuerto
  rm ls_R_Aeropuerto.c

  gcc ls_R_CC.c -o ls_R_CC
  chgrp Ejecutivos ls_R_CC
  chmod 4750 ls_R_CC
  rm ls_R_CC.c

  gcc ls_R_Parque.c -o ls_R_Parque
  chgrp Ejecutivos ls_R_Parque
  chmod 4750 ls_R_Parque
  rm ls_R_Parque.c
}

##### Programa Principal #####
echo "${TEXT_BOLD}${TEXT_PURPLE}Script para crear la practica 1 de Administración de Sistemas: ${TEXT_RESET}"
echo
if [ "$(whoami)" == "root" ]; then
  Users_creation
  echo
  Groups_creation
  echo
  Users_directory
  echo
  Creation_directory
  echo
  Access_Control_List
  echo 
  ls_program
  echo
  Compilation_ls
  echo
else 
  echo "${TEXT_BOLD}${TEXT_RED}Para ejecutar el script tienes que ser root${TEXT_RESET}"
  exit 0
fi