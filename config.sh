#!/bin/bash
#Generando el certificado
#A mipassword la puedo pasar como una env var
#Los campos de '-subj' seran pasados tambien por env vars


/bin/bash -c "envsubst < /etc/nginx/conf.d/site-default > /etc/nginx/conf.d/default.conf"


exec "$@"
