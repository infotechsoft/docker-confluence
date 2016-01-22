# docker-confluence
Atlassian Confluence Docker Container

```
# retrieve the docker-confluence/Dockerfile
git clone https://github.com/infotechsoft/docker-confluence.git

# build the docker image
docker build -t infotechsoft/confluence docker-confluence

# start the docker container
docker run -d \
     -v /var/atlassian/confluence:/var/atlassian/confluence \
     -p 8090:8090 \
     --link postgres:db \
     --name confluence \
     --env "CATALINA_OPTS= -Xms1g -Xmx1g" \
     infotechsoft/confluence
```
