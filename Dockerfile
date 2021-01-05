FROM debian:buster-slim as base
ARG TARGETARCH
WORKDIR /tmp

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
COPY ./checksums.txt .
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    curl=7.64.0-4+deb10u1 \
    dirmngr=2.2.12-1+deb10u1 \
    fontconfig=2.13.1-2 \
    fonts-noto-cjk=1:20170601+repack1-3+deb10u1 \
    gnupg=2.2.12-1+deb10u1 \
    libssl-dev=1.1.1d-0+deb10u4 \
    libx11-6=2:1.6.7-1+deb10u1 \
    libxext6=2:1.3.3-1+b2 \
    libxrender1=1:0.9.10-1 \
    node-less=1.6.3~dfsg-3 \
    npm=5.8.0+ds6-4+deb10u2 \
    python3-num2words=0.5.6-1 \
    python3-pdfminer=20181108+dfsg-3 \
    python3-pip=18.1-5 \
    python3-phonenumbers=8.9.10-1 \
    python3-pyldap=3.1.0-2 \
    python3-qrcode=6.1-1 \
    python3-renderpm=3.5.13-1+deb10u1 \
    python3-setuptools=40.8.0-1 \
    python3-slugify=2.0.1-1 \
    python3-vobject=0.9.6.1-0.1 \
    python3-watchdog=0.9.0-1 \
    python3-xlrd=1.1.0-1 \
    python3-xlwt=1.3.0-2 \
    wget=1.20.1-1.1 \
    xfonts-75dpi=1:1.0.4+nmu1 \
    xfonts-base=1:1.0.5 \
    xz-utils=5.2.4-1 && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

FROM base as base_amd64
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  echo "**** download wkhtmltox package ****" && \
  wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
  sha1sum ./wkhtmltox_0.12.6-1.buster_amd64.deb | sha1sum -c ./checksums.txt --ignore-missing || if [[ "$?" -eq "141" ]]; then true; else exit $?; fi && \
  mv ./wkhtmltox_0.12.6-1.buster_amd64.deb ./wkhtmltox.deb

FROM base as base_arm64
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  echo "**** download wkhtmltox package ****" && \
  wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_arm64.deb && \
  sha1sum ./wkhtmltox_0.12.6-1.buster_arm64.deb | sha1sum -c ./checksums.txt --ignore-missing || if [[ $? -eq 141 ]]; then true; else exit $?; fi && \
  mv ./wkhtmltox_0.12.6-1.buster_arm64.deb ./wkhtmltox.deb

FROM base as base_arm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  echo "**** download wkhtmltox package ****" && \
  wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.raspberrypi.buster_armhf.deb && \
  sha1sum ./wkhtmltox_0.12.6-1.raspberrypi.buster_armhf.deb | sha1sum -c ./checksums.txt --ignore-missing || if [[ $? -eq 141 ]]; then true; else exit $?; fi && \
  mv ./wkhtmltox_0.12.6-1.raspberrypi.buster_armhf.deb ./wkhtmltox.deb

# hadolint ignore=DL3008
FROM base_${TARGETARCH}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  # Avoid the pesky 141 exit code
  echo "**** install wkhtmltox ****" && \
  apt-get install -y --no-install-recommends ./wkhtmltox.deb && \
  rm -rf /var/lib/apt/lists/* ./wkhtmltox.deb && \
  echo "**** install latest postgresql-client ****" && \
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' && \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" && \
  gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc && \
  gpgconf --kill all && \
  rm -rf "$GNUPGHOME" && \
  apt-get update && \
  apt-get install --no-install-recommends -y postgresql-client=11+200+deb10u4 && \
  rm -f /etc/apt/sources.list.d/pgdg.list && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** Install rtlcss (on Debian buster) ****" && \
  npm config set strict-ssl false && \
  npm install -g rtlcss

# Install Odoo
ENV ODOO_VERSION 14.0
ARG ODOO_RELEASE=20201218
RUN \
  echo "**** install odoo ****" && \
  curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb && \
  #sha1sum odoo.deb | sha1sum -c ./checksums.txt --ignore-missing || if [[ $? -eq 141 ]]; then true; else exit $?; fi && \
  apt-get update && \
  apt-get -y install --no-install-recommends ./odoo.deb && \
  rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
WORKDIR /
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN \
  echo "**** Set permissions ****" && \
  chown odoo /etc/odoo/odoo.conf && \
  mkdir -p /mnt/extra-addons && \
  chown -R odoo /mnt/extra-addons && \
  chmod a+x /entrypoint.sh && \
  chmod a+x /usr/local/bin/wait-for-psql.py
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
