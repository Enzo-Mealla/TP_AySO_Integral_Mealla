#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista Dominios y URL
#
#  Tareas:
#  - Se debera generar la estructura de directorio pedida con 1 solo comando con las tecnicas enseñadas en clases
#  - Generar los archivos de logs requeridos.
#
###############################


LISTA="Lista_URL.txt"
BASE_DIR="/tmp/head-check"
LOG_FILE="/var/log/status_url.log"

# Verificar archivo de entrada
if [[ -z $LISTA ]]; then
    echo "Error: Debes proporcionar un archivo con la lista de URLs."
    exit 1
fi

if [[ ! -f $LISTA ]]; then
    echo "Error: El archivo $LISTA no existe."
    exit 1
fi

if [[ ! -f $LOG_FILE ]]; then
	sudo touch $LOG_FILE
	sudo chown $(whoami) $LOG_FILE
fi

#Directorios
mkdir -p "$BASE_DIR/ok" "$BASE_DIR/Error/cliente" "$BASE_DIR/Error/servidor"

#URLs
while IFS= read -r LINE; do

    [[ -z "$LINE" || "$LINE" == \#* ]] && continue


    DOMINIO=$(echo "$LINE" | awk '{print $1}')
    URL=$(echo "$LINE" | awk '{print $2}')


    STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}' -s "$URL")

    # Clasificar
    if [[ $STATUS_CODE -eq 200 ]]; then
        DIR="$BASE_DIR/ok"
    elif [[ $STATUS_CODE -ge 400 && $STATUS_CODE -lt 500 ]]; then
        DIR="$BASE_DIR/Error/cliente"
    elif [[ $STATUS_CODE -ge 500 && $STATUS_CODE -lt 600 ]]; then
        DIR="$BASE_DIR/Error/servidor"
    else
        DIR="$BASE_DIR/Error/cliente" # Manejo de códigos inesperados
        STATUS_CODE="Error"
    fi

    # Registrar en el archivo de log
    echo "$DOMINIO - $URL - Code: $STATUS_CODE" > "$DIR/$DOMINIO.log"
    echo "$(date) - Code: $STATUS_CODE - $URL" >> $LOG_FILE

done < "$LISTA"

echo "Proceso completado. Revisa la estructura en $BASE_DIR."
