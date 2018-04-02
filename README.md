# alpine-self-signed

Alpine Docker image that automatically generates a self-signed certificate using LibreSSL.

## Usage

This image will output a self-signed certificate and associated data (CA, CSR, etc.) to `/certs` within the container.

### localhost

```sh
docker run --rm -v $PWD:/certs dpyro/alpine-self-signed
```

### example.com

```sh
docker run --rm -v $PWD:/certs -e SSL_SUBJECT=example.com dpyro/alpine-self-signed
```
