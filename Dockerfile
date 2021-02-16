FROM ubuntu:xenial

USER root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y curl cron bzip2 perl-modules lsof libc6-i386 lib32gcc1 sudo tzdata rsync && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install -y ca-certificates steamcmd language-pack-en

RUN ln -s /usr/games/steamcmd /usr/local/bin && \
    adduser --gecos "" --disabled-password steam

RUN curl -sL https://git.io/arkmanager | bash -s steam && \
    ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

RUN mkdir /ark && \
    mkdir /arkserver

COPY arkmanager/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY arkmanager/instance.cfg /etc/arkmanager/instances/main.cfg
COPY run.sh /arkserver/run.sh
COPY log.sh /arkserver/log.sh

RUN chown -R steam:steam /home/steam /ark /arkserver

RUN echo "%sudo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
    usermod -a -G sudo steam && \
    touch /home/steam/.sudo_as_admin_successful

WORKDIR /arkserver
USER steam

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=70 \
    am_ark_QueryPort=27015 \
    am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
    am_arkwarnminutes=15

VOLUME /ark

CMD [ "./run.sh" ]
