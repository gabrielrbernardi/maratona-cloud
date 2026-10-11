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
            #proxy_pass ${boca_secondary_local_ip};
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

    server {
        listen ${https_port} ssl;
        server_name wallpaper.gabrielrb.com;

        ssl_certificate     ${ssl_certificate};
        ssl_certificate_key ${ssl_certificate_key};

        # Pasta interna onde o HTML de manutencao sera mapeado
        root /usr/share/nginx/html;
        index maintenance.html;

        location / {
	    # 1. The proxy_pass remains the same, but we need to ensure the headers align
            proxy_pass https://maratona-wallpapers.s3.us-east-1.amazonaws.com/wallpaper-maratona-regional-2026.png;

            # 2. This is the crucial part: S3 needs the Host header to match the bucket domain
            proxy_set_header Host maratona-wallpapers.s3.us-east-1.amazonaws.com;

            # 3. Clear potential auth headers that might confuse S3
            proxy_set_header Authorization "";
            proxy_hide_header x-amz-id-2;
            proxy_hide_header x-amz-request-id;

            # 4. SSL tweaks to ensure the handshake is valid
            proxy_ssl_server_name on;
            proxy_ssl_name s3.us-east-1.amazonaws.com;

            # Keep your other headers
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location = /maintenance.html {
            internal;
        }
    }

    # Main domain - HTTP with proxy to BOCA
    server {
        listen 80;
        server_name maratona.gabrielrb.com;

        root /usr/share/nginx/html;
        index maintenance.html;

        location / {
            if ($maintenance_mode = 1) {
                rewrite ^ /maintenance.html last;
            }

            proxy_pass ${boca_primary_local_ip};
            #proxy_pass ${boca_primary_local_ip};
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