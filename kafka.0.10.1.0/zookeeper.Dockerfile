FROM centos:6.6

RUN mkdir /etc/yum.repos.d/backup &&\
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

RUN yum -y install nc vim lsof wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel pwgen python-pip

RUN mkdir /opt/java &&\
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz -P /opt/java

RUN tar zxvf /opt/java/jdk-8u171-linux-x64.tar.gz -C /opt/java &&\
	JAVA_HOME=/opt/java/jdk1.8.0_171 &&\
	sed -i "/^PATH/i export JAVA_HOME=$JAVA_HOME" /root/.bash_profile &&\
	sed -i "s%^PATH.*$%&:$JAVA_HOME/bin%g" /root/.bash_profile &&\
	source /root/.bash_profile

ENV ZOOKEEPER_VERSION "3.4.8"

RUN mkdir /opt/zookeeper &&\
	wget http://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz -P /opt/zookeeper

RUN tar zxvf /opt/zookeeper/zookeeper*.tar.gz -C /opt/zookeeper

RUN echo "source /root/.bash_profile" > /opt/zookeeper/start.sh &&\
	echo "cp /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo_sample.cfg /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg" >> /opt/zookeeper/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_PORT"" ] && sed -i 's%.*clientPort=.*$%clientPort='$""ZOOKEEPER_PORT'""%g'  /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg" >> /opt/zookeeper/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_ID"" ] && mkdir -p /tmp/zookeeper && echo $""ZOOKEEPER_ID > /tmp/zookeeper/myid" >> /opt/zookeeper/start.sh &&\
	echo "[[ ! -z $""ZOOKEEPER_SERVERS"" ]] && for server in $""ZOOKEEPER_SERVERS""; do echo $""server"" >> /opt/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/conf/zoo.cfg; done" >> /opt/zookeeper/start.sh &&\
	echo "/opt/zookeeper/zookeeper-$"ZOOKEEPER_VERSION"/bin/zkServer.sh start-foreground" >> /opt/zookeeper/start.sh

EXPOSE 2181

WORKDIR /opt/zookeeper/zookeeper-$ZOOKEEPER_VERSION

ENTRYPOINT ["sh", "/opt/zookeeper/start.sh"]










