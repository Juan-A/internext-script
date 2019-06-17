#!/bin/bash

##FUNCIONES##
menu(){
    clear
    menu=true
    while $menu true
    do
        clear
        echo "###########################################"
        echo "##                                       ##"
        echo "##         INTERNEXT Mini Util           ##"
        echo "##   VestaCP es un software OpenSurce.   ##"
        echo "##        GNU PUBLIC LICENSE V3          ##"
        echo "##                                       ##"
        echo "###########################################"
        echo ""
        echo "------------- Menú -------------------"
        echo "1.Exportar usuarios del panel [Datos incluidos] [ /backups ]"
        echo "2.Restaurar usuarios del panel [Datos y Usuarios]"
        echo "3.Añadir usuario[s] con perfil ALUMNOS"
        echo "4.Añadir usuarios con datos personalizados."
        echo "5.Eliminar usuario[s] con un determinado sufijo"
        echo "6.Eliminar usuarios individualmente"
        echo "10.Salir"
        
        echo ""
        read -p "Elige una opción: " opcion
        case $opcion in
            1)
                exportusuarios
            ;;
            2)
                importusuarios
            ;;
            3)
                crearusuarioalumno
            ;;
            4)
                crearusuariocustom
            ;;
            5)
                eliminarusuariosufijo
                
            ;;
            6)
            eliminarusuario
            ;;
            10)
                exit 0
            ;;
            *)
                read -p "Opción no válida, seleccione otra. [intro]"
            ;;
        esac
        
        
    done
}
exportusuarios(){
    echo ""
    read -p "Pulsar intro para continuar [CTRL + C -> Salida del script.]..."
    echo ""
    cuentalin=$( /usr/local/vesta/bin/v-list-sys-users | wc -l )
    cuentausuarios=$(( $cuentalin-2 ))
    ##Lista usuarios -> /usr/local/vesta/bin/v-list-sys-users | tail -n$cuentausuarios  
    
    while [ $cuentausuarios -gt 0 ] #Separamos usuario uno a uno para realizar la copia.
    do
        usuario=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$cuentausuarios | head -n1 )
        /usr/local/vesta/bin/v-backup-user $usuario 1>>/backup/logs.txt #Sólo imprimo en pantalla errores; de los que también se notifica por correo.
        cuentausuarios=$(( $cuentausuarios-1 ))
    done
    echo "Backup para los usuarios:"
    echo "-----------------------------------"
    cuentalin=$( /usr/local/vesta/bin/v-list-sys-users | wc -l )
    cuentausuarios=$(( $cuentalin-2 ))
    /usr/local/vesta/bin/v-list-sys-users | tail -n$cuentausuarios
        echo ""
    echo "-----------------------------------"
    echo "--------COPIA COMPLETADA--------"
    read -p "Pulse intro para volver al menú."
    
}

importusuarios(){
    clear
    echo "-->Se va a realizar una restauración de los datos"
    echo "   los antiguos pueden ser sobrescritos.<--"
    echo "--------------------------------------------------"
    echo "-->Backups Disponibles<--"
    echo "--------------------------------------------------"
    cd /backup
    ls -lt *.tar 2>/dev/null
    if [ ! $? -eq 0 ]
    then
    echo "No existen backups."
    read -p "Pulse intro para volver al menú."
    menu
    fi
    echo "--------------------------------------"
    echo "El backup será eliminado del sistema cuando sea restaurado."
    echo ""
    read -p "Copia y pega a continuación el nombre del fichero a restaurar[+intro]: " nombrebck
    read -p "Copia y pega a continuación el nombre del usuario a restaurar[+intro]: " nombreusr
    if [[ ! $nombrebck =~ ^$nombreusr.[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9].tar$ ]]
    then
        echo ""
        echo "--------\/----------"
        echo "El usuario introducido debe de ser el mismo que el original."
        read -p "Pulsa intro para volver al menú."
        menu
    fi
    
    
    
    
    if [ ! -f /backup/$nombrebck ]
    then
        read -p "El archivo introducido no existe. [Intro Para volver al menú]"
        
        menu
    fi
    clear
    echo "->Se ha iniciado el proceso<-"
    cd /backup
    /usr/local/vesta/bin/v-restore-user $nombreusr $nombrebck
    rm -f /backup/$nombrebck
    if [ ! $? -eq 0 ]
    then
        read -p "Hubo un error durante la restauración, revisa el nombre de usuario."
    fi
    read -p "Usuario restaurado correctamente. [Intro]"
    
    
}

crearusuarioalumno(){
    clear
    echo "---->Asistente en consola"
    echo "     de creación de usuarios<----"
    echo "---------------------------------"
    read -p "Introduzca el número de usuarios a crear: " numusers
    read -p "Introduzca sufijo del usuario [ alumno01.* ]: " sufijo
    read -p "Introduzca password por defecto para la tanda: " pdefecto
    if [[ ! $numusers =~ [1-9]+ ]]
    then
        clear
        echo "El número introducido no es correcto."
        read -p "Pulsa intro para volver al menú."
        menu
    fi
    
    while [ $numusers -ge 1 ]
    do
        /usr/local/vesta/bin/v-add-user alumno$numusers.$sufijo $pdefecto mail.invalid@internext.local Alumnos $sufijo
        numusers=$(( $numusers-1 ))
        
    done
    read -p "Proceso completado [Si saltó error, sólo debes de introducir un número superior ][Intro]"
}

eliminarusuariosufijo(){
    reset
    echo "---->Asistente en consola"
    echo "     de eliminación de usuarios<----"
    totallineas=$( /usr/local/vesta/bin/v-list-sys-users | wc -l )
    quitarprimeras=$(( $totallineas-2 ))
    echo ""

        #ALUMNOS ELIMINAR
            echo "----------------Sufijos/Grupos---------------------"
            /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep ^alumno[0-9]+ | cut -d. -f2 | uniq
            cuentaalumnos=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep ^alumno[0-9]+ | cut -d. -f2 | wc -l )
            
            if [  $cuentaalumnos -eq 0 ]
            then
                echo "No existen grupos."
                read -p "Pulse intro para volver al menú."
                menu
            fi
            read -p "¿Cuál de los anteriores grupos desea eliminar? -> " grupoeliminar
            grupodisponible=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep ^alumno[0-9]+ | cut -d. -f2 | uniq | grep $grupoeliminar )
            alumnos=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep ^alumno[0-9]+  )
            cuentaalumnosdegrupo=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep *$grupoeliminar$ | cut -d. -f2 | wc -l )
            
            
            if [[ $grupoeliminar = $grupodisponible  ]]
            then
                cuentaalumnosdegrupo=$( /usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep *$grupoeliminar$ | cut -d. -f2 | wc -l )
                
                echo "OK..."
                read -p "¿Seguro que desea eliminar el grupo $grupoeliminar? [Ss/Nn] -> " confirmacion
                case $confirmacion in
                    [Ss])
                        selectalumno=1
                        while [ $selectalumno -le $cuentaalumnosdegrupo ]
                        do
                            alumnotemp=$( /usr/local/vesta/bin/v-list-sys-users | egrep ^alumno[0-9]+.$grupoeliminar | head -n$selectalumno | tail -n1 )
                            arrayalumnos[$selectalumno]=$alumnotemp
                            /usr/local/vesta/bin/v-delete-user ${arrayalumnos[$selectalumno]}
                            selectalumno=$(( $selectalumno+1 ))
                        done
                        echo "Usuarios del grupo eliminados correctamente."
                        #/usr/local/vesta/bin/v-list-sys-usersv-delete-user
                    ;;
                    [nN])
                        clear
                        read -p "Pulse intro para volver al menú."
                        menu
                esac
            else
                echo "No se ha introducido un grupo válido."
                read -p "Pulse intro para volver al menú."
                menu
                
            fi
            #/usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | egrep ^alumno[0-9]+
            #/usr/local/vesta/bin/v-list-sys-users | tail -n$quitarprimeras | cut -d. -f2 | uniq
            echo "----------------------------------------------------"
            read -p "Pulse intro para volver al menú."

    
    
}

crearusuariocustom(){
    clear
    echo "---->Asistente en consola"
    echo "     de creación de usuarios<----"
    echo "---------------------------------"
    echo ""
    read -p "Introduzca el nombre de usuario deseado: " nomusuario
    if [[ $nomusuario =~ [\.] ]] #No permito puntos en los nombres de usuario.
    then
        echo "Los nombres de usuarios personales no pueden contener un punto separador."
        read -p "Usuario no válido, pulse intro para volver al menú."
        menu
    fi
    usuariovalido=false
    if [[ $nomusuario =~ .+ ]]
    then
        usuariovalido=true ##Valida usuario vacío
    fi
    if [ $usuariovalido == false ]
    then
        echo "El nombre de usuario no puede estar vacío."
        read -p "Usuario no válido, pulse intro para volver al menú."
        menu
    fi
    read -p "Introduzca el primer nombre[s] [Opcional]: " primernomusuario
    if [[ $primernomusuario =~ .+ ]] ##Valido primer nombre, si no hay entrada, no pide segundo nombre.
    then
        read -p "Introduzca el segundo nombre[s] [Opcional]: " segundonomusuario
    else
        echo "Introduzca el segundo nombre[s] [No se ha introducido un primer nombre] "
    fi
    
    read -p "Introduzca password de usuario: " pwdusuario
    pwdvalido=false ##Valida password -> No requerimos complejidad.
    if [[ $pwdusuario =~ .+ ]]
    then
        pwdvalido=true
    fi
    if [ $pwdvalido == false ]
    then
        echo "El password del usuario no puede estar vacío."
        read -p "Password no válido, pulse intro para volver al menú."
        menu
    fi
    read -p "Introduzca e-mail del usuario: " emailusuario
    emailvalido=false #Valido email.
    if [[ $emailusuario =~ [A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.\.[A-Za-z]+ ]]
    then
        emailvalido=true
    fi
    if [ $emailvalido == false ]
    then
        read -p "Email no válido, pulse intro para volver al menú."
        menu
    fi
    echo ""
    numpaquetes=$( /usr/local/vesta/bin/v-list-user-packages | wc -l )
    numpaquetes=$(( $numpaquetes-2 ))
    paquetes=$( /usr/local/vesta/bin/v-list-user-packages | tail -n$numpaquetes )
    contador=1
    while [ $contador -le $numpaquetes ]
    do
        selectorpaquete=$( /usr/local/vesta/bin/v-list-user-packages | cut -d" " -f1 | tail -n$numpaquetes | tail -n$contador | head -n1 )
        arraypaquetes[$contador]=$selectorpaquete
        echo "$contador ->  ${arraypaquetes[$contador]} "
        contador=$(( $contador+1 ))
    done
    echo ""
    read -p "¿Cuál de los planes anteriores desea aplicar? -> " numpaquete
    paqueteusuario=${arraypaquetes[$numpaquete]}
    
    paqvalido=false ##Valida paquete -> No se admiten caracteres.
    if [[ $numpaquete =~ [1-9]+ ]]
    then
        paqvalido=true
    fi
    if [ $paqvalido == false ]
    then
        echo "Paquete no válido."
        read -p "El valor debe de ser numérico, pulse intro para volver al menu"
        menu
    fi
    if [ $numpaquete -eq 0 -o $numpaquete -gt $numpaquetes ] #Valido que el paquete está entre los disponibles
    then
        echo "Paquete no válido."
        read -p "El paquete seleccionado no existe, pulse intro para volver al menú."
        menu
    fi
    /usr/local/vesta/bin/v-add-user $nomusuario $pwdusuario $emailusuario $paqueteusuario "$primernomusuario" "$segundonomusuario" 2>>/dev/null
    if [ ! $? -eq 0 ]
    then
        echo ""
        echo ""
        read -p "Hubo un error al crear el usuario, pulse intro para volver al menú principal."
    else
        echo ""
        echo ""
        read -p "Usuario creado con éxito, pulse intro para volver al menú principal."
    fi
}
eliminarusuario(){
	reset
    echo "---->Asistente en consola"
    echo "     de eliminación de usuarios<----"
    echo "Usuarios disponibles:"
    echo "--------------------"
	ls /usr/local/vesta/data/users | grep -v ^admin #Excluyo al administrador de la lista.
	listausuarios=$( ls /usr/local/vesta/data/users | grep -v ^admin )
	read -p "Introduzca el nombre del usuario que desea eliminar: "  usuarioeliminar
	echo $listausuarios | grep $usuarioeliminar &>>/dev/null
	if [ ! $? -eq 0 ]
	then
	echo "Usuario no encontrado o no válido."
	read -p "Introduzca un usuario válido. Pulse intro para volver al menú."
	menu
	fi
	read -p " Está seguro de que desea eliminar el usuario $usuarioeliminar? -> [Ss/Nn]" confirmaeliminar
	case $confirmaeliminar in
	[Ss])
		/usr/local/vesta/bin/v-delete-user $usuarioeliminar
	;;
	Nn)
	read -p "Pulse intro para volver al menú."
	menu
	;;
	*)
	read -p "No se continuará con el proceso; entrada no válida. Pulse intro para volver al menú."
	menu
	;;
	esac
		if [ ! $? -eq 0 ]
		then
		echo "Hubo un error al borrar el usuario."
		read -p "Pulse intro para volver al menú."
		
	else
	echo "Usuario eliminado correctamente."
		read -p "Pulse intro para volver al menú."
	fi 
	
	
	}
menu
