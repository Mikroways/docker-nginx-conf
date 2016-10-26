# Nginx-conf
Docker container basado en https://github.com/rancher/catalog-dockerfiles/tree/master/utils/containers/confd para definir un archivo de configuracion de nginx a partir de metadatos de Rancher.

## Como funciona
Este contenedor recolecta metadatos definidos en Rancher. Para esto se tiene definido dentro de la carpeta conf.d un archivo en donde se define: que template leera confd, donde almacenara el archivo generado y un conjunto de claves. https://github.com/Mikroways/docker-wordpress-nginx/blob/master/conf.d/nginx.toml 
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
        try _files $$uri @app;
      upstream_location_options: |
      static_files_regexp_location: \\.(icoco|css|gif|jpe?g|png|js)(\?[0-9]+)$$
```
Los campos a partir de metadata son los que nos importan.
Los campos posibles de editar son los siguientes:
* server: nombre para un upstream
* upstream: dentro de este se puede definir 
      
      **not_upstream**: si se define este campo no se creara un upstream, sino se creara uno con el nombre **app**. Por defecto si no esta definido server: 127.0.0.1
      
      **port**: este define el puerto del upstream, por defecto 8080
* root: campo que indica el document root de nginx. Campo opcional, si no se indica este campo con un valor esta opción no es agregada
* server_custom_options: en este campo se pueden definir diferentes configuraciones que se deseen agregar.
* root_location_options: este campo agregara, si es que se define, dentro de "location /" las opciones indicadas
```yml
    location / {
        <<<contenido de root_location_options>>>
    }
```
* upstream_location_options: este campo define "location @app", se agregaran otras opciones a las ya definidas. Si este campo no es especificado no se creara este location
```yml
  server {
    .
    .
    location @app {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://app;
      <<<contenido de upstream_location_options>>>
    }
    .
    .
  }  
```
El location para servir los archivos estaticos por defecto es agregado y se puede editar la expresion regular como se indica. Este location puede eliminarse si se define la opcion **no_static_files_location**
* static_files_regexp_location: campo para editar la expresion regular que sirve el contenido estatico. Por defecto:
```yml
location ~* \.(ico|css|gif|jpe?g|png|js)(\?[0-9]+)?$
```
* fpm_options: este campo define "location ~ [^/]\.php(/|$)".Si este campo no es especificado no se creara este location"
Dentro de esta se pueden definir otras dos opciones:
  * options: se agregan opciones a las ya definidas por defecto
  * port: puerto fpm
contendido de fpm_options por defecto:
```yml
metadata:
    nginx-conf:
      root: /var/www/html;    
      server_custom_options: |
        listen 8060;
        keepalive_timeout 10;
        client_max_body_size 250m;
        index index.php;
        location ~ /.well-known {
          allow all;
        }
        location ~* /(?:uploads|files)/.*\.php$$ {
          deny all;
        }
        location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
        }
      root_location_options: |
        try_files $$uri $$uri/ /index.php$$uri?$$args
      fpm_options: |
        port:
        options:
```
## Ejemplo de uso

docker-compose.yml
```yml
  nginx-conf:
    container_name: nginx-conf
    image: mikroways/docker-nginx-conf:v1.0.1
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always
    command: ["--backend", "rancher", "--prefix", "/2015-07-25"]
  nginx:
    container_name: nginx
    image: nginx
    volumes_from:
      - nginx-conf
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: nginx-conf
      io.rancher.container.pull_image: always
```

Configuración de rancher-compose de manera que genere una configuracion de Nginx con un upstream determinado y sin el location que sirve archivos estaticos:

rancher-compose.yml
```yml

nginx:
  scale: 1
  health_check:
    port: 80
    interval: 2000
    unhealthy_threshold: 3
    strategy: recreate
    response_timeout: 2000
    healthy_threshold: 2
  metadata:
    nginx-conf:
      server: www.mikroways.net
      upstream:
        active:
        port: 3000
      server_custom_options: |
        listen 80;
        keepalive_timeout 10;
        client_max_body_size 250m;
        index index.html;
      root_location_options: |
        try_files $$uri $$uri/ /index.php$$uri?$$args;
      no_static_files_location:
```
