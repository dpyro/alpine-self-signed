# alpine-self-signed

Alpine Docker image that automatically generates a self-signed certificate using LibreSSL.

## Usage

```sh
docker run --rm -v $PWD:/certs dpyro/alpine-self-signed
```