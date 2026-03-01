user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Redirecionamento Global de HTTP para HTTPS
    server {
        listen ${http_port};
        server_name _;
        return 301 https://$host$request_uri;
    }

    # Proxy para BOCA
    server {
        listen ${https_port} ssl;
        server_name ${server_name_boca};

        ssl_certificate     ${ssl_certificate};
        ssl_certificate_key ${ssl_certificate_key};

        location / {
            # O Nginx vai buscar esse IP via VPC Peering
            proxy_pass ${boca_primary_local_ip};
            #proxy_pass ${boca_secondary_local_ip};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Proxy para ANIMEITOR
    server {
        listen ${https_port} ssl;
        server_name ${server_name_animeitor};

        ssl_certificate     ${ssl_certificate};
        ssl_certificate_key ${ssl_certificate_key};

        location / {
            # O Nginx vai buscar esse IP via VPC Peering
            proxy_pass ${animeitor_local_ip};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
