FROM lyasper/sshd:centos7

#RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
#RUN yum clean all
#RUN yum makecache

#RUN yum -y update && yum -y install which openssh-clients net-tools less iproute && yum clean all 

COPY rpms.tar.gz /root/
RUN mkdir -p /root/rpms && tar -xzf /root/rpms.tar.gz -C /root/rpms && rm -f /root/rpms.tar.gz
RUN ls -l /root/rpms/; sleep 2

RUN rpm -Uvh --replacepkgs /root/rpms/python-deltarpm-*.rpm /root/rpms/deltarpm-*.rpm /root/rpms/python-kitchen-*.rpm /root/rpms/createrepo-*.rpm

# 生成本地仓库元数据
RUN createrepo /root/rpms

# 配置本地 YUM 源
RUN echo -e "[local]\nname=Local Repository\nbaseurl=file:///root/rpms\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/local.repo

# 禁用所有远程源（如果基础镜像中已配置），只使用本地源
RUN sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/*.repo || true

# 现在用 yum 安装所有需要的包（自动解决依赖）
RUN yum clean all && yum install -y --disablerepo=* --enablerepo=local \
    iproute \
    less \
    net-tools \
    openssh \
    openssh-clients \
    openssh-server \
    which

# 可选：删除临时文件以减小镜像体积
RUN mkdir -p /home/gpadmin/.ssh

RUN ssh-keygen  -f /home/gpadmin/.ssh/id_rsa -N ""
RUN cp /home/gpadmin/.ssh/id_rsa.pub /home/gpadmin/.ssh/authorized_keys
RUN chmod 0400 /home/gpadmin/.ssh/authorized_keys

ADD ./sh/gpinitsystem_config_template /home/gpadmin/artifact/gpinitsystem_config_template
COPY sh/*.py sh/*.sh /home/gpadmin/artifact/
RUN chmod 755 /home/gpadmin/artifact/*.sh

COPY sh/config /home/gpadmin/.ssh/config
RUN chmod 0400 /home/gpadmin/.ssh/config

RUN mkdir -p /home/gpadmin/master /home/gpadmin/data  /home/gpadmin/mirror

RUN chown -R gpadmin /home/gpadmin
RUN chown -R gpadmin /home/gpadmin/.ssh
