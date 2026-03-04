user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # FLAG DE MANUTENÇÃO: 1 = Ativado (HTML), 0 = Desativado (Proxy)
    map "" $$maintenance_mode {
        default 0;
    }

    # Redirecionamento Global de HTTP para HTTPS
    server {
        listen ${http_port};
        server_name _;
        return 301 https://$$host$$request_uri;
    }

    # Configuracao para BOCA
    server {
        listen ${https_port} ssl;
        server_name ${server_name_boca};

        ssl_certificate     ${ssl_certificate};
        ssl_certificate_key ${ssl_certificate_key};

        # Pasta interna onde o HTML de manutenção será mapeado
        root /usr/share/nginx/html;
        index maintenance.html;

        location / {
            if ($maintenance_mode = 1) {
                rewrite ^ /maintenance.html last;
            }

            # Configuracao do Proxy (Ativo quando maintenance_mode = 0)
            proxy_pass ${boca_primary_local_ip};
            proxy_set_header Host $$host;
            proxy_set_header X-Real-IP $$remote_addr;
            proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $$scheme;
        }

        location = /maintenance.html {
            internal;
        }
    }

    # Configuracao para ANIMEITOR
    server {
        listen ${https_port} ssl;
        server_name ${server_name_animeitor};

        ssl_certificate     ${ssl_certificate};
        ssl_certificate_key ${ssl_certificate_key};

        root /usr/share/nginx/html;
        index maintenance.html;

        location / {
            if ($maintenance_mode = 1) {
                rewrite ^ /maintenance.html last;
            }

            # Configuracao do Proxy (Ativo quando maintenance_mode = 0)
            proxy_pass ${animeitor_local_ip};
            proxy_set_header Host $$host;
            proxy_set_header X-Real-IP $$remote_addr;
            proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $$scheme;
        }

        location = /maintenance.html {
            internal;
        }
    }
}