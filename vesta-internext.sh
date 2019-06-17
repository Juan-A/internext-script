#!/bin/bash

host="server.internext.local"

#### FUNCIONES MENÚ #####
title(){
	
	clear
echo "VESTA CP - GESTIÓN INTERNEXT"
echo "---------------/\-----------------"
} 
localelect(){
		if [ ! -d /usr/local/vesta ]
	then
		clear
		echo "Vesta no está instalado en este equipo, instálelo y entonces, ejecute este script."
	exit 0
	fi
	idusuario=$(id -u)
	if [ ! $idusuario -eq 0 ]
	then
	clear
	echo "Por favor, ejecute el script con permisos de administrador."
	exit 1
	fi
	echo ""
	echo "---\/----------------------------"
	echo "¡De acuerdo! - Vesta se encuentra instalado."
	read -p "Pulsa intro para acceder al menú de opciones."
	./usr/local/internext/scripts-local.sh
	} 
	
electrem(){
	echo ""
read -p "¿Has ejecutado anteriormente este script en la instalación ? [Ss / Nn ]" anteriormente #Esto descarga el script de automatización en el servidor, de no estarlo, en cualquier caso, sólo debemos seleccionar NO una única vez.
case $anteriormente in
[sS])
ssh root@server.internext.local -tt "/usr/local/internext/scripts-local.sh"
;;
[nN])
ssh root@$host "#!/bin/bash && if [ ! -x /usr/local/internext/scripts-local.sh ] && then && mkdir -p /usr/local/internext/ && curl -O https://raw.githubusercontent.com/Juan-A/internext-script/master/scripts-local.sh && mv scripts-local.sh /usr/local/internext/scripts-local.sh && chmod +x /usr/local/internext/scripts-local.sh && fi"
ssh root@$host -tt "/usr/local/internext/scripts-local.sh" #SI es la primera vez, he de introducir la password dos veces.
;;

*)
read -p "Opción no válida. Pulse intro para volver al menú."
eleclocalrem
;;
esac
} 
eleclocalrem() {
	
	read -p "¿Es el servidor local o remoto? [L -> Local / R -> Remoto ]": ubicacion
case $ubicacion in
[lL])
localelect	
;;
[rR])
electrem
;;
[Ss])
exit 0
;;
*)

title
echo ""
echo "-->No has seleccionado ninguna opción<--"
echo "--->Introduce S/s si deseas salir.<---"
echo ""
eleclocalrem
;;
esac
} 



title
eleclocalrem

