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
  && rm -rf ${CATALINA_HOME}/webapps/*
  && cp -rp /tmp/drawio-${VERSION}/build/draw.war ${CATALINA_HOME}/webapps/ROOT.war \
  && rm -rf /tmp/drawio-${VERSION} \
  && rm -rf /tmp/v${VERSION}.zip \
  \
  && apt-get autoremove -y ${buildDeps} \
  && rm -rf /var/lib/apt/lists/*
