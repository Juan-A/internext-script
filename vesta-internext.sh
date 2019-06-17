#!/bin/bash

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
	./funciones/scripts-local.sh
	} 
	
eleclocalrem() {
	
	read -p "¿Es el servidor local o remoto? [L -> Local / R -> Remoto ]": ubicacion
case $ubicacion in
[lL])
localelect	

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

