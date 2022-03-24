# Administracion-de-Sistemas-P01
Script que realiza automáticamente la practica 01 de la asignatura de Administración de Sistemas.

## Funcionamiento
El funcionamiento del Script es la de automatizar la practica 01 de la asignatura de Administracion de Sistemas con un script de BASH. Lo unico que hay que hacer ejecutar el script. Fijarse si la siquiente tabla de coincide con la tabla de la practica:

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

Si la situacion de la organización coincide con esta tabla ejecute el script, si es diferente modifique la función `Groups_creation`.

## Compilación
Para compilar el script hay que ser root.

```bash
./Script_P01ADS.sh
```
