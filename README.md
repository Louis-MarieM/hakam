# Hakam
Hakam is a homelab deployer project. It install and configure a VPN, a NAS and a server to deploy application on a Debian based server.

## Installation and run
### Prerequisites to installation
- Windows or Linux distribution
- [Docker](https://docs.docker.com/get-started/get-docker/) installed (version 26.1.1 worked).
- Debian server with available SSH connection.

### Installation of Hakam
- Clone the project.
- (Optionnal) Configure a file [`.env`](/config/.env) (cf. [Hakam configuration](#hakam-configuration)).

### Build and run Hakam
- Open a shell into parent directory `/hakam`, where there is the docker-compose file.
- Run this command to **build and run** Hakam container :
    ```sh
    docker-compose -f docker-compose.yml --env-file config/.env up --build
    ```

## Hakam configuration
### Environment variables
Configuration is managed through [`.env`](/config/.env.example) files in the [`config/`](/config) directory.

| Variable      | Description                                       | Default   | Values                                    |
| :---          |:---                                               |:---       |:---                                       |
| `VERSION`     | Application version (to update at each merge)     | `0.1.0`   |Current version                            |


</br>

---

</br>

**Version**: 0.2.0</br>
**Format**: November 2025</br>
**Maintainer**: Louis-Marie M.