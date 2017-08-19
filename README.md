# Draw.io container

[![Docker Build Status](https://img.shields.io/docker/build/merhylstudio/draw.io.svg)](https://hub.docker.com/r/merhylstudio/draw.io/)
[![Size](https://shields.beevelop.com/docker/image/image-size/merhylstudio/draw.io/alpine.svg)](https://hub.docker.com/r/merhylstudio/draw.io/)

draw.io (formerly Diagramly) is free online diagram software. You can use it as a flowchart maker, network diagram software, to create UML online, as an ER diagram tool, to design database schema, to build BPMN online, as a circuit diagram maker, and more. draw.io can import .vsdx, Gliffy™ and Lucidchart™ files .

> Heavy inspired by [fjudith](https://github.com/fjudith/docker-draw.io)

**To Run:**
```
docker run --rm -p 8080:8080 merhylstudio/draw.io
```

Start a web browser session to http://*ip*:8080/?offline=1&https=0

> **Note:**
> - `offline=1` is a security feature that disables support of cloud storage.
> - `https=0` disable automatic usage of SSL
