# docker-confluence
Atlassian Confluence Docker Container

```
# retrieve the docker-confluence/Dockerfile
git clone https://github.com/infotechsoft/docker-confluence.git

# build the docker image
docker build -t infotechsoft/confluence docker-confluence

# retrieve the centos/postgresql docker image
docker pull centos/postgresql

# start the postgres container
docker run -d \
     --rm \
     --volumes-from postgres-data \
     --publish 5432:5432
     --name postgres \
     centos/postgresql

# create a confluence-data volume container
docker volume create --name confluence-data
docker run -v confluence-data:/var/atlassian/confluence 

# start the confluence container
docker run -d \
     --rm \
     --volumes-from confluence-data \
     -p 8090:8090 \
     --link postgres:db \
     --name confluence \
     --env "CATALINA_OPTS= -Xms1g -Xmx1g" \
     infotechsoft/confluence
```
