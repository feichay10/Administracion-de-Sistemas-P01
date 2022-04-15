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
alu=
slappassword=
ldapadmin=

##### Estilos #####
TEXT_BOLD=$(tput bold)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_RED=$(tput setaf 1)
TEXT_PURPLE=$(tput setaf 5)


##### Funciones #####
Installation()
{
    dnf install wget
    wget -q https://repo.symas.com/configs/SOFL/rhel8/sofl.repo -O /etc/yum.repos.d/sofl.repo
    dnf update
    dnf install symas-openldap-clients symas-openldap-servers
    systemctl start slapd
    wget http://mirror.centos.org/altarch/7/os/aarch64/Packages/migrationtools-47-15.el7.noarch.rpm
    dnf install migrationtools-47-15.el7.noarch.rpm
}

LDAPconfig()
{
    mkdir /root/P02; cd /root/P02
    touch confbas.ldif
    touch monitor.ldif
    echo "Introduzca ahora una contraseña para el LDAP: "
    slappasswd
    echo "Copie la salida del comando de la contraseña LDAP"
    echo "Introduzca la salida de la contraseña del LDAP: "
    read slappassword
    echo "Introduzca su alu: "
    read alu
    echo "Introduzca el administrador del LDAP (puede ser cualquier usuario, no tiene porque pertenecer a /etc/passwd): "
    read ldapadmin
}

writeConfbas()
{
    echo "dn: olcDatabase={2}mdb,cn=config" > confbas.ldif
    echo "changetype: modify" >> confbas.ldif
    echo "replace: olcSuffix" >> confbas.ldif
    echo "olcSuffix: dc=$alu,dc=local" >> confbas.ldif
    echo "" >> confbas.ldif
    echo "dn: olcDatabase={2}mdb,cn=config" >> confbas.ldif
    echo "changetype: modify" >> confbas.ldif
    echo "replace: olcRootDN" >> confbas.ldif
    echo "olcRootDN: cn=$ldapadmin,dc=$alu,dc=local" >> confbas.ldif
    echo "" >> confbas.ldif
    echo "dn: olcDatabase={2}mdb,cn=config" >> confbas.ldif
    echo "changetype: modify" >> confbas.ldif
    echo "replace: olcRootPW" >> confbas.ldif
    echo "olcRootPW: $slappassword" >> confbas.ldif

    ldapmodify -Y EXTERNAL -H ldapi:/// -f confbas.ldif

    # Especificamos el DN del administrador
    echo "dn: olcDatabase={1}monitor,cn=config" > monitor.ldif
    echo "changetype: modify" >> monitor.ldif
    echo "replace: olcAccess" >> monitor.ldif
    echo "olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth\" read by dn.base=\"cn=$ldapadmin,dc=$alu,dc=local\" read by * none" >> monitor.ldif

    ldapadd -Y EXTERNAL -H ldapi:/// -f monitor.ldif

    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
}

sourceEntrance()
{
    touch source.ldif
    echo "dn: dc=$alu,dc=local" > source.ldif
    echo "dc: $alu" >> source.ldif
    echo "objectClass: domain" >> source.ldif
    echo "" >> source.ldif
    echo "dn: ou=People,dc=$alu,dc=local" >> source.ldif
    echo "objectClass: organizationalUnit" >> source.ldif
    echo "ou: People"
    echo "" >> source.ldif
    echo "dn: ou=Group,dc=$alu,dc=local" >> source.ldif
    echo "objectClass: organizationalUnit" >> source.ldif
    echo "ou: Group"

    ldapadd -xD "cn=$ldapadmin,dc=$alu,dc=local" -W -f prueba.ldif
}

firewall()
{
    if [ "$(firewall-cmd --state)" != "running" ]; then 
        systemctl start firewalld
    fi
    firewall-cmd --permanent --add-service=ldap
    firewall-cmd --reload
}

migrate_common()
{
    cd /usr/share/migrationtools

    cp migrate_common.ph copy_migrate_common.ph

    echo "Editando el fichero ./migrate_common.ph..."
    echo -n "\$NETINFOBRIDGE = (-x \"/usr/sbin/mkslapdconf\");

    if (\$NETINFOBRIDGE) {
            \$NAMINGCONTEXT{'aliases'}           = \"cn=aliases\";
            \$NAMINGCONTEXT{'fstab'}             = \"cn=mounts\";
            \$NAMINGCONTEXT{'passwd'}            = \"cn=users\";
            \$NAMINGCONTEXT{'netgroup_byuser'}   = \"cn=netgroup.byuser\";
            \$NAMINGCONTEXT{'netgroup_byhost'}   = \"cn=netgroup.byhost\";
            \$NAMINGCONTEXT{'group'}             = \"cn=groups\";
            \$NAMINGCONTEXT{'netgroup'}          = \"cn=netgroup\";
            \$NAMINGCONTEXT{'hosts'}             = \"cn=machines\";
            \$NAMINGCONTEXT{'networks'}          = \"cn=networks\";
            \$NAMINGCONTEXT{'protocols'}         = \"cn=protocols\";
            \$NAMINGCONTEXT{'rpc'}               = \"cn=rpcs\";
            \$NAMINGCONTEXT{'services'}          = \"cn=services\";
    } else {
            \$NAMINGCONTEXT{'aliases'}           = \"ou=Aliases\";
            \$NAMINGCONTEXT{'fstab'}             = \"ou=Mounts\";
            \$NAMINGCONTEXT{'passwd'}            = \"ou=People\";
            \$NAMINGCONTEXT{'netgroup_byuser'}   = \"nisMapName=netgroup.byuser\";
            \$NAMINGCONTEXT{'netgroup_byhost'}   = \"nisMapName=netgroup.byhost\";
            \$NAMINGCONTEXT{'group'}             = \"ou=Group\";
            \$NAMINGCONTEXT{'netgroup'}          = \"ou=Netgroup\";
            \$NAMINGCONTEXT{'hosts'}             = \"ou=Hosts\";
            \$NAMINGCONTEXT{'networks'}          = \"ou=Networks\";
            \$NAMINGCONTEXT{'protocols'}         = \"ou=Protocols\";
            \$NAMINGCONTEXT{'rpc'}               = \"ou=Rpc\";
            \$NAMINGCONTEXT{'services\'}          = \"ou=Services\";
    }

    # Default DNS domain
    \$DEFAULT_MAIL_DOMAIN = \"$alu.local\";

    # Default base
    \$DEFAULT_BASE = \"dc=$alu,dc=local\";

    \$EXTENDED_SCHEMA = 0;

    if (defined(\$ENV{'LDAP_BASEDN'})) {
            \$DEFAULT_BASE = \$ENV{'LDAP_BASEDN'};
    }

    if (defined(\$ENV{'LDAP_DEFAULT_MAIL_DOMAIN'})) {
            \$DEFAULT_MAIL_DOMAIN = \$ENV{'LDAP_DEFAULT_MAIL_DOMAIN'};
    }

    if (defined(\$ENV{'LDAP_DEFAULT_MAIL_HOST'})) {
            \$DEFAULT_MAIL_HOST = \$ENV{'LDAP_DEFAULT_MAIL_HOST'};
    }

    # binddn used for alias owner (otherwise uid=root,...)
    if (defined(\$ENV{'LDAP_BINDDN'})) {
            \$DEFAULT_OWNER = \$ENV{'LDAP_BINDDN'};
    }

    if (defined(\$ENV{'LDAP_EXTENDED_SCHEMA'})) {
            \$EXTENDED_SCHEMA = \$ENV{'LDAP_EXTENDED_SCHEMA'};
    }

    # If we haven't set the default base, guess it automagically.
    if (!defined(\$DEFAULT_BASE)) {
            \$DEFAULT_BASE = &domain_expand(\$DEFAULT_MAIL_DOMAIN);
            \$DEFAULT_BASE =~ s/,$//o;
    }

    # Default Kerberos realm
    #if (\$EXTENDED_SCHEMA) {
    #       \$DEFAULT_REALM = \$DEFAULT_MAIL_DOMAIN;
    #       \$DEFAULT_REALM =~ tr/a-z/A-Z/;
    #}

    if (-x \"/usr/sbin/revnetgroup\") {
            \$REVNETGROUP = \"/usr/sbin/revnetgroup\";
    } elsif (-x \"/usr/lib/yp/revnetgroup\") {
            \$REVNETGROUP = \"/usr/lib/yp/revnetgroup\";
    }

    \$classmap{'o'} = 'organization';
    \$classmap{'dc'} = 'domain';
    \$classmap{'l'} = 'locality';
    \$classmap{'ou'} = 'organizationalUnit';
    \$classmap{'c'} = 'country';
    \$classmap{'nismapname'} = 'nisMap';
    \$classmap{'cn'} = 'container';

    sub parse_args
    {
            if (\$#ARGV < 0) {
                    print STDERR \"Usage: \$PROGRAM infile [outfile]\n\";
                    exit 1;
            }

            \$INFILE = \$ARGV[0];

            if (\$#ARGV > 0) {
                    \$OUTFILE = \$ARGV[1];
            }
    }

    sub open_files
    {
            open(INFILE);
            if (\$OUTFILE) {
                    open(OUTFILE,\">\$OUTFILE\");
                    \$use_stdout = 0;
            } else {
                    \$use_stdout = 1;
            }
    }

    sub domain_expand
    {
            local(\$first) = 1;
            local(\$dn);
            local(@namecomponents) = split(/\./, \$_[0]);
            foreach \$_ (@namecomponents) {
                    \$first = 0;
                    \$dn .= \"dc=\$_,\";
            }
            \$dn .= \$DEFAULT_BASE;
            return \$dn;
    }

    # case insensitive unique
    sub uniq
    {
            local(\$name) = shift(@_);
            local(@vec) = sort {uc(\$a) cmp uc(\$b)} @_;
            local(@ret);
            local(\$next, \$last);
            foreach \$next (@vec) {
                    if ((uc(\$next) ne uc(\$last)) &&
                            (uc(\$next) ne uc(\$name))) {
                            push (@ret, \$next);
                    }
                    \$last = \$next;
            }
            return @ret;
    }

    # concatenate naming context and
    # organizational base
    sub getsuffix
    {
            local(\$program) = shift(@_);
            local(\$nc);
            \$program =~ s/^migrate_(.*)\.pl$/\$1/;
            \$nc = \$NAMINGCONTEXT{\$program};
            if (\$nc eq \"\") {
                    return \$DEFAULT_BASE;
            } else {
                    return \$nc . ',' . \$DEFAULT_BASE;
            }
    }

    sub ldif_entry
    {
    # remove leading, trailing whitespace
            local (\$HANDLE, \$lhs, \$rhs) = @_;
            local (\$type, \$val) = split(/\=/, \$lhs);
            local (\$dn);

            if (\$rhs ne \"\") {
                    \$dn = \$lhs . ',' . \$rhs;
            } else {
                    \$dn = \$lhs;
            }

            \$type =~ s/\s*$//o;
            \$type =~ s/^\s*//o;
            \$type =~ tr/A-Z/a-z/;
            \$val =~ s/\s*$//o;
            \$val =~ s/^\s*//o;

            print \$HANDLE \"dn: \$dn\n\";
            print \$HANDLE \"\$type: \$val\n\";
            print \$HANDLE \"objectClass: top\n\";
            print \$HANDLE \"objectClass: \$classmap{\$type}\n\";
            if (\$EXTENDED_SCHEMA) {
                    if (\$DEFAULT_MAIL_DOMAIN) {
                            print \$HANDLE \"objectClass: domainRelatedObject\n\";
                            print \$HANDLE \"associatedDomain: \$DEFAULT_MAIL_DOMAIN\n\";
                    }
            }

            print \$HANDLE \"\n\";
    }

    # Added Thu Jun 20 16:40:28 CDT 2002 by Bob Apthorpe
    # <apthorpe@cynistar.net> to solve problems with embedded plusses in
    # protocols and mail aliases.
    sub escape_metacharacters
    {
            local(\$name) = @_;

            local(\$leader, \$body, \$trailer) = ();
            if ((\$leader, \$body, \$trailer) = (\$name =~ m#^( *)(.*\S)( *)\$#o)) {
                    \$leader =~ s# #\\ #og;
                    \$trailer =~ s# #\\ #og;
                    \$name = \$leader . \$body . \$trailer;
            }

            # 3) Quote leading octothorpe (#)
            \$name =~ s/^#/\\#/o;

            # 4) Quote comma, plus, double-quote, less-than, greater-than,
            # and semicolon
            \$name =~ s#([,+\"<>;])#\\\$1#g;

            return \$name;
    }

    1; " > migrate_common.ph
}

migrationtools()
{
    mkdir /root/P02/migration
    cd /root/P02/migration
    cat /etc/passwd > ./mypasswd
    cat /etc/group > ./mygroup

    echo "Ahora en en el fichero mypasswd tenemos que borrar los usuarios que no sean los creados en la Practica 01"
    vi mypasswd

    echo "Ahora en en el fichero mygroup tenemos que borrar los grupos que no sean los creados en la Practica 01"
    vi mygroup

    ./migrate_passwd.pl /root/P02/migration/mypasswd /root/P02/migration/mypasswd.ldif
    ./migrate_group.pl /root/P02/migration/mygroup /root/P02/migration/mygroup.ldif

    ldapadd -xD "cn=$ldapadmin,dc=$alu,dc=local" -W -f mypasswd.ldif
    ldapadd -xD "cn=$ldapadmin,dc=$alu,dc=local" -W -f mygroup.ldif
}

nfs_server()
{
    echo "nfs"
}

#Script a ejecutar en el servidor
##### Funcion Principal #####
if [ "$(whoami)" == "root" ]; then
    echo "¿Estás en la maquina ${TEXT_BOLD}${TEXT_RED}SERVIDORA${TEXT_RESET}? [Y/n] "
    read opcion
    if [ "$opcion" == "y" ] || [ "$opcion" == "Y" ] ; then
        Installation
        LDAPconfig
        writeConfbas
        sourceEntrance
        firewall
        migrate_common
        migrationtools
        nfs_server
    elif [ "$opcion" == "n" ] || [ "$opcion" == "N" ]; then
        echo "Se ha procedido a cerrar el script, ejecute el siguiente programa en la maquina servidora"
        exit 0
    else
        echo "${TEXT_BOLD}${TEXT_RED}Opcion no soportada${TEXT_RESET}"
        exit 1
    fi
else 
    echo "${TEXT_BOLD}${TEXT_RED}Para ejecutar el script tienes que ser root${TEXT_RESET}"
    exit 0
fi