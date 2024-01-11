# services
Overview of all OpenML components including a docker-compose to run OpenML services locally



TODO: 
- add documentation, including an overview of all the components
- add evaluation engine
- add issues to describe shortcomings (url of minio)


## Prerequisites
- Linux/MacOS/Windows (should all work)
- [Docker](https://docs.docker.com/get-docker/) 
- [Docker Compose](https://docs.docker.com/compose/install/) version 2.21.0 or higher

## Usage

You run all OpenML services locally using
```bash
docker compose --profile all up -d
```
Stop it again using 
```bash
docker compose --profile all down
```


You can use different profiles, for example:
```bash
docker compose --profile all up -d    # all services
docker compose up -d                  # only the database
docker compose --profile frontend -d  # Frontend, rest-api, elasticsearch and database
```
Use the same profile for your `down` command.


## Debugging
Some usefull commands:
```bash
docker logs openml-php-rest-api -f              # tail the logs of the php rest api
docker exec -it openml-php-rest-api /bin/bash   # go into the php rest api container
./scripts/connect_db.sql                        # access the database
```

## Development
TODO