# Nginx-conf
Esta imagen comienza un contenedor basado en https://github.com/rancher/catalog-dockerfiles/tree/master/utils/containers/confd para definir un
archivo de configuracion de nginx a partir de metadatos de Rancher.

## Como funciona
Este contenedor toma metadatos definidos en Rancher. Para esto se tiene definido dentro de la carpeta conf.d un archivo en donde se define: que template leera confd, donde almacenara el archivo generado y un conjunto de claves. https://github.com/Mikroways/docker-wordpress-nginx/blob/master/conf.d/nginx.toml 
El template mediante el cual generara el archivo de configuración en templates/nginx.conf.tmpl. https://github.com/Mikroways/docker-wordpress-nginx/blob/master/templates/nginx.conf.tmpl


Los metadatos en Rancher deben ser definidos de la siguiente manera, ejemplo de rancher-compose.yml:

```yml
nginx:
  scale: 1
  metadata:
    nginx-conf:
      root: /opt/pepe;
      upstream:
        port: 3000
      server_custom_options: |
        client_max_body_size 30m;


        location /admin {

        }
      root_location_options: |
        #allow {}
      upstream_location_options: |
      static_files_regexp_location: \\.(icoco|css|gif|jpe?g|png|js)(\?[0-9]+)$$
```

Los campos a partir de metadata son los que nos importan.
Los campos posibles de editar son los siguientes:
* root: campo que indica el document root de nginx. Campo opcional, por defecto /usr/share/nginx/html
* port: campo que indica el puerto del server
* server_custom_options: en este campo se pueden definir diferentes configuraciones que se deseen agregar.
* root_location_options: este campo agregara, si es que se define, dentro de "location /" las opciones indicadas
```yml
    location / {
        try_files $uri @app;
        <<<contenido de root_location_options>>>
    }
```
* upstream_location_options: del mismo modo que root_location_options, dentro de "location @app" se agregaran otras opciones a las ya definidas
```yml
  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
    <<<contenido de upstream_location_options>>>
  }
```
* static_files_regexp_location: campo para editar la expresion regular que sirve el contenido estatico. Por defecto:
```yml
location ~* \.(ico|css|gif|jpe?g|png|js)(\?[0-9]+)?$
```
