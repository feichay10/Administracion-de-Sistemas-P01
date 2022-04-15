#!/bin/bash

# En caso de problemas, eliminar y reiniciar todo el LDAP
# rm -rf /etc/openldap
# systemctl stop slapd
# systemctl disable slapd
# yum -y remove openldap-servers openldap-clients 
# rm -rf /var/lib/ldap
# userdel ldap
# rm -rf /etc/openldap

##### Variables y Constantes #####
opcion=

##### Estilos #####
TEXT_BOLD=$(tput bold)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_RED=$(tput setaf 1)
TEXT_PURPLE=$(tput setaf 5)


##### Funciones #####
Installation()
{
    dnf install nfs4-acl-tools
    dnf install nfs
    dnf install autofs
}

autofs_client()
{
  /import/casa    /etc/auto.casa
  /import/proyectos       /etc/auto.proyectos
  /import/info/comun      /etc/auto.comun 

  # Comando a poner despues de configurar los ficheros auto.
  systemctl restart autofs
}

#Script a ejecutar en el servidor
##### Funcion Principal #####
if [ "$(whoami)" == "root" ]; then
    echo "¿Estás en la maquina ${TEXT_BOLD}${TEXT_RED}CLIENTE${TEXT_RESET}? [Y/n] "
    read opcion
    if [ "$opcion" == "y" ] || [ "$opcion" == "Y" ] ; then






    elif [ "$opcion" == "n" ] || [ "$opcion" == "N" ]; then
        echo "Se ha procedido a cerrar el script, ejecute el siguiente programa en la maquina cliente"
    else
        echo "${TEXT_BOLD}${TEXT_RED}Opcion no soportada${TEXT_RESET}"
        exit 1
    fi
else 
    echo "${TEXT_BOLD}${TEXT_RED}Para ejecutar el script tienes que ser root${TEXT_RESET}"
    exit 0
fi