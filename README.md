# Hakam
Hakam is a homelab deployer project. It install and configure a VPN, a NAS and a server to deploy application on a Debian based server.

## Installation and run
### Prerequisites to installation
- Windows or Linux distribution
- [Docker](https://docs.docker.com/get-started/get-docker/) installed (version 26.1.1 worked).
- Debian server with SSH connection to him.

### Installation of Hakam
- Clone the project.
- (Optionnal) Configure a file [`.env`](/config/.env).

### Build and run Hakam
- Open a shell into parent directory `/hakam`, where there is the docker-compose file.
- Run this command to **build and run** Hakam container :
    ```sh
    docker-compose -f docker-compose.yml --env-file config/.env up --build
    ```