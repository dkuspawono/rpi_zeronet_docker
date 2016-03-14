FROM resin/rpi-raspbian:jessie
MAINTAINER James Doig <jamesdoig@gmail.com>

#Base settings
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

#Use updated version of tor
RUN gpg --keyserver keys.gnupg.net --recv 886DDD89
RUN gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
RUN echo "deb http://deb.torproject.org/torproject.org jessie main" >> /etc/apt/sources.list

#Update package lists
RUN apt-get -y update && sudo apt-get upgrade

#Install Tor
RUN apt-get install -y tor deb.torproject.org-keyring && apt-get install -y tor

#Install ZeroNet deps
RUN apt-get install msgpack-python python-gevent python-pip python-dev -y
RUN pip install msgpack-python --upgrade

#Add Zeronet source
ADD . /root
VOLUME /root/data

#Slimming down Docker containers
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Configure tor
RUN echo "ControlPort 9051" >> /etc/tor/torrc
RUN echo "SocksPort 9050" >> /etc/tor/torrc
RUN echo "CookieAuthentication 1" >> /etc/tor/torrc


#Set upstart command
WORKDIR $HOME
CMD service tor start && python zeronet.py --ui_ip 0.0.0.0

#Expose ports
EXPOSE 43110
EXPOSE 15441