FROM tomcat:8-jre8

MAINTAINER MerhylStudio

ENV VERSION=7.1.0

#=== Download source code, patch and build war ===
RUN set -xe; \
  \
  buildDeps=' \
    ant \
    openjdk-8-jdk \
  ' \
  && apt-get update && apt-get install -y --no-install-recommends ${buildDeps} \
  \
  && wget -q -P /tmp/ https://github.com/jgraph/draw.io/archive/v${VERSION}.zip \
  && unzip /tmp/v${VERSION}.zip -d /tmp \
  \
  && sed -i /tmp/drawio-${VERSION}/etc/build/build.xml \
       -e "s~ excludes=\"\*\*/EmbedServlet2\.java\"~~" \
  \
  && sed -i /tmp/drawio-${VERSION}/src/com/mxgraph/online/EmbedServlet2.java \
       -e "/import com\.google\.appengine\.api\.utils\.SystemProperty;/d" \
       -e "/lastModified = httpDateFormat\.format(uploadDate);/a\lastModified = new SimpleDateFormat(\"EEE, dd MMM yyyy HH\:mm\:ss z\", Locale\.US)\.format(new Date());" \
       -e "/\/\/ Uses deployment date as lastModified header/,/lastModified = httpDateFormat\.format(uploadDate);/d" \
  \
  && cd /tmp/drawio-${VERSION}/etc/build \
  && ant war \
  && cd ${CATALINA_HOME} \
  \
  && cp -rp /tmp/drawio-${VERSION}/build/draw.war ${CATALINA_HOME}/webapps/ \
  && rm -rf /tmp/drawio-${VERSION} \
  && rm -rf /tmp/v${VERSION}.zip \
  \
  && apt-get autoremove -y ${buildDeps} \
  && rm -rf /var/lib/apt/lists/*

#=== Update server.xml to set 'draw' webapp to root ===
RUN set -xe; \
  \
  buildDeps=' \
    xmlstarlet \
  ' \
  && apt-get update && apt-get install -y --no-install-recommends ${buildDeps} \
  \
  && xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context' -t 'attr' -n 'path' -v '/' \
    -i '/Server/Service/Engine/Host/Context[@path="/"]' -t 'attr' -n 'docBase' -v 'draw' \
    -s '/Server/Service/Engine/Host/Context[@path="/"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context[not(@path="/")]' -t 'attr' -n 'path' -v '/ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'attr' -n 'docBase' -v 'ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
  ${CATALINA_HOME}/conf/server.xml \
  \
  && apt-get autoremove -y ${buildDeps} \
  && rm -rf /var/lib/apt/lists/*

