# Administracion-de-Sistemas-P01
Script que realiza automáticamente la practica 01 de la asignatura de Administración de Sistemas.

## Funcionamiento
El funcionamiento del Script es la de automatizar la practica 01 de la asignatura de Administracion de Sistemas con un script de BASH. Lo unico que hay que hacer es ejecutar el script y lo hara todo automaticamente. 

## Guión de la práctica:
### Situacion actual de la Organización
Actualmente, se tiene la siguiente situación:
- Existen 3 proyectos: Aeropuerto, Centro Comercial y Parque
- Dos ejecutivos: ejec1 y ejec2
- La distribución de los usuarios y ejecutivos por proyectos es de la siguiente forma:

| USUARIO          |  Aeropuerto |               Centro Comercial             |  Parque   |
| :--------------: | :---------: | :----------------------------------------: | :-------: |
| usu1             |             |                       X                    |           |
| usu2             |      X      |                                            |           |
| usu3             |      X      |                       X                    |           |
| usu4             |      X      |                       X                    |           |
| usu5             |      X      |                       X                    |     X     |
| usu6             |             |                                            |     X     |
|                  |             |                                            |           |
| ejec1            |      X      |                                            |     X     |
| ejec2            |      X      |                       X                    |           |

### 1. Contraseñas
- Los usuarios deben cambiar sus contraseñas cada 3 meses.
- Es necesario notificar a los usuarios 1 día antes de que su contraseña caduque.
- Transcurridos 2 días desde la caducidad del password, la cuenta ha de quedar desactivada.
- En la práctica, la contraseña de cada usuario coincidirá con el nombre de usuario.

### 2. Directorio de cada usuario
- Todo usuario del sistema debe poseer un subdirectorio del directorio /home cuyo nombre debe coincidir con el de la cuenta del usuario.
- En este directorio, el usuario debe poder crear y borrar ficheros y directorios, pero **no** debe poder modificar los permisos de su directorio de conexión.
- Ningún otro usuario del sistema podrá acceder a dicho directorio ni a su contenido

### 3. Proyectos en ejecución
La Organización tiene varios proyectos en curso. Para estos proyectos, se ha de cumplir:
- Cada proyecto debe tener un directorio bajo el directorio /export/proyectos donde se almacenará la documentación asociada al mismo.
- Todos los usuarios que participan en un proyecto deben tener la posibilidad de leer, modificar, crear y borrar los archivos que forman parte del proyecto.
- Cuando un usuario cree un archivo en el directorio del proyecto, por defecto, éste debe poder ser leído, modificado o borrado por cualquier otro usuario del mismo proyecto.
- Ningún otro usuario podrá acceder a estos directorios
- Existirá un directorio /export/proyectos/comun donde se almacenará información común a todos los proyectos de tal forma que todos los usuarios puedan añadir y modificar información a este directorio, pero sólo el propietario de cada archivo o carpeta pueda eliminarlo.

### 4. Ejecutivos
En la empresa existen varios ejecutivos que tienen asignada la evaluación de algunos de los proyectos existentes con las siguientes restricciones:
- Los ejecutivos asociados a un determinado proyecto podrán leer la información de ese proyecto, pero no podrán modificarla.
- Los ejecutivos que no pertenezcan a un proyecto no deben poder acceder directamente a los directorios de los proyectos
- Para que estos ejecutivos puedan controlar el estado de cada proyecto al que no pertenecen, deben existir en el directorio /usr/local/bin tantos programas como proyectos existan.
- Estos programas internamente han de realizar un “ls” sobre el directorio del proyecto correspondiente.
- El programa que permite evaluar cada proyecto, debe cumplir lo siguiente:
    - Debe poder ser ejecutado únicamente por los ejecutivos de la organización.
    - Debe tener asignado los permisos suficientes para poder ejecutar el “ls” sobre el directorio correspondiente.
Por ejemplo, atendiendo a la situación actual de la organización (tabla 2), el usuario ejec1 podría acceder directamente a los directorios Aeropuerto y Parque y leer la información que allí se encuentre. Sin embargo, sólo podrá acceder al directorio Centro Comercial a través del programa realizado para ello (por ejemplo, /usr/local/bin/lee_cc.exe).

## Ejecución
Para ejecutar el script hay que ser root.

```bash
./Script_P01ADS.sh
```
