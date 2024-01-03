# OSync
Script para sincronizar archivos con las plataformas de cloud compatibles con rclone.

Este script en su origen ha sido creado para sincronizar mis archivos de Obsidian con GoogleDrive, pero puede ser utilzado para sincronizar cualquier tipo contenido con cualquier plataforma de cloud compatible con rclone. Para hacer uso de este script necesitareis tener instalado el paquete inotify-tools ya que hace uso de la herramienta inotifywait y como ya se ha mencionado, tambien necesitareis instalar rclone.

Si ejecutais el script sin las dependencias instaladas, en el output os facilitará informacion para instalarlas.

Quizas sea necesario modificar el codigo para hacer uso del mismo con otras plataformas de cloud ya que solo esta testeado con GoogleDrive.

El script puede ser configurado editando ciertas variables en el codigo y por defecto configurado para sincronizarse como maximo 1 vez por minuto (min_sync_delay) y para generar un archivo de log cada dia (se puede modificar cambiando el formato de salida del comando date en la variable "log_file", se podrian añadir otros metodos pero para mi es sufiente con este) almacenando hasta un maximo de 3 (max_log_files), el nombre de la carpeta donde se almacenan los archivos de log tambien puede ser modificado asi como su ubicacion (log_path), por defecto esta se llamara "OSync_logs" y estará ubicada en el mismo directorio que el script.
