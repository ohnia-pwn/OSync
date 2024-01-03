#!/bin/bash

# Es necesario instalar el paquete inotify-tools y la herramienta rclone.
#
# Para configurar rclone son necesarias las credenciales de OAuth 2.0, las cuales se pueden obtener 
# facilemente siguiendo los pasos de esta guia: "https://github.com/glotlabs/gdrive/blob/main/docs/create_google_api_credentials.md"
#
# Para 
# Para configurar otras plataformas de cloud compatibles con rclone consultar el enlace: "https://rclone.org/docs/"
#
# Rclone puede instalarse mediante script a traves del comando: "sudo -v ; curl https://rclone.org/install.sh | sudo bash"
#

# Colores
redColour="\e[0;31m\033[1m"
greenColour="\e[0;32m\033[1m"
yellowColour="\e[0;33m\033[1m"
blueColour="\e[0;34m\033[1m"
purpleColour="\e[0;35m\033[1m"
underlineStyle="\e[4m"
# Fin de estilo y color
endStyle="\033[0m"

# Ruta de la carpeta que se va a monitorear
source="/home/ohniapwn/Obsidian"

# Ruta de la carpeta de GoogleDrive (¡¡¡EL CONTENIDO A LA IZQUIERA DE ":" CORREPONDE AL NOMBRE DE LA APP CONFIGURADA EN GOOGLE DRIVE,
# A LA DERECHA DE ":" SE INDICARA LA RUTA DEL CLOUD EN LA CUAL QUEREMOS REALIZAR LA SINCRONIZACION DE ARCHIVOS!!!)
# PARA OTROS CLOUD CONSULTAR -> "https://rclone.org/docs/"
destination="Obsidian:Obsidian"

# Comando a ejecutar cuando se detecten cambiosi
exec_cmd="rclone sync $source $destination -vv"

# Variable para almacenar la última hora de ejecución
last_exec=""

# Variable para indicar el intervalo de tiempo mínimo (en segundos) entre sincronizaciones
min_sync_interval="60"

# Ruta de rclone
rclone_path="$(which rclone | grep -v "not found")"

# Ruta de inotifywait
inotify_path="$(which inotifywait | grep -v "not found")"

# Chivato dependencias
dependencias=0

# Ruta de la carpeta de los archivos de log.
log_path="./OSync_logs/"

# Numero maximo de archivos de log
max_log_files=3

# Verificacion de dependencias
if [ ! $rclone_path ]; then
  echo -e "\n${redColour}Dependencias incumplidas -> rclone${endStyle}\n${greenColour}Puedes instalarlo ejecutando el comando:${endStyle} ${blueColour}sudo -v ; curl https://rclone.org/install.sh | sudo bash${endStyle}\n${greenColour}Para configurarlo con Google Drive puedes seguir estas${endStyle} ${purpleColour}${underlineStyle}instrucciones${endStyle}${purpleColour}:${endStyle}\n${purpleColour}Guia de obtención de credenciales OAuth 2.0->${endStyle} ${blueColour}https://github.com/glotlabs/gdrive/blob/main/docs/create_google_api_credentials.md${endStyle}\n${purpleColour}Guia de configuración de rclone con GoogleDrive->${endStyle} ${blueColour}https://rclone.org/drive/${endStyle}\n${greenColour}Para otras plataformas de cloud consultar->${endStyle} ${blueColour}https://rclone.org/docs/${endStyle}"
  dependencias+=1
fi
if [ ! $inotify_path ]; then
  echo -e "\n${redColour}Dependencias incumplidas -> inotify-tools${endStyle}\n${greenColour}Puedes instalarlo ejecutando el comando:${endStyle} ${blueColour}sudo apt install inotify-tools${endStyle}"
  dependencias+=1
fi
if [ $dependencias -gt 0 ]; then
  echo -e "\n${yellowColour}Instale las aplicaciones necesarias antes de ejecutar OSync.\nUna vez hecho esto puedes añadir el script al archivo de configuracion de tu terminal para que se ejecute en el arranque.${endStyle}\n${redColour}Saliendo...${endStyle}"
  exit 1
fi

# Verificacion/actualización de carpeta y archivo de log.
function check_log() {
  # Nombre de los archivos de log
  log_file="log_$(date +"%Y-%m-%d").log"
  if [[ ! $(/bin/ls $log_path 2>/dev/null) ]]; then
    mkdir $log_path && chmod +rw $log_path
    touch ${log_path}${log_file} && chmod +rw ${log_path}${log_file}
  fi
  if [[ ! $(/bin/ls ${log_path}${log_file} 2>/dev/null) ]]; then
      touch ${log_path}${log_file} && chmod +rw ${log_path}${log_file}
  fi
   # Si existen mas archivos de log de los deseados se eliminan.
  if [ $(find $log_path -maxdepth 1 -type f | wc -l) -gt $max_log_files ]; then
    /bin/ls -t $log_path | awk -v log_path="$log_path" 'NF{print log_path $NF}' | tail -n +4 | xargs /bin/rm -rf
  fi  
}

# Función para ejecutar el comando y registrar en el archivo de log
function doSync() {
    fecha_hora=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Ejecutar el comando y capturar la salida
    salida=$($exec_cmd 2>&1)

    check_log
    # Registrar en el archivo de log
    echo "Fecha y Hora: $fecha_hora" >> ${log_path}${log_file}
    echo "Comando Ejecutado: $exec_cmd" >> ${log_path}${log_file}
    echo "Output rclone:" >> ${log_path}${log_file}
    echo "$salida" >> ${log_path}${log_file}
    echo "----------------------------------------" >> ${log_path}${log_file}
 
}

#Sincronización inicial
if [ -z "$initial_sync" ]; then
 doSync
 inital_sync=true
fi

# Configuración de inotifywait
inotifywait -m -r -e modify,create,delete,move "$source" 2>/dev/null |
while read changes
do
   # Verificar si ha pasado al menos 1 minuto desde la última ejecución
    if [[ -z "$last_exec" || $(($(date +"%s") - $(date -d "$last_exec" +"%s"))) -ge $min_sync_interval ]]; then
      doSync
    fi
done
