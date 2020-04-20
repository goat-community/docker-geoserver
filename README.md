# Docker Geoserver


This is Geoserver image made to work with 


## Usage



As example docker run:
```
docker run -v ./geoserver:/var/local/geoserver \
    -p 8080:8080 goatcommunity/geoserver
```

Acesss http://127.0.0.1:8080/geoserver/web/ and use the default credentials:
```
Username: admin
Password: geoserver
```

### Environment Variables


### Volume data

The data directory you should volume to outside the container is on `/var/local/geoserver`