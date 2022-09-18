yum install -y --enablerepo=powertools git autoconf pcre-devel \
  automake libtool make readline-devel texinfo net-snmp-devel pkgconfig \
  groff pkgconfig json-c-devel pam-devel bison flex python2-pytest \
  c-ares-devel python2-devel libcap-devel \
  elfutils-libelf-devel libunwind-devel cmake;
git clone https://github.com/CESNET/libyang.git;
cd libyang;
git checkout v2.0.0;
mkdir build; cd build;
cmake -D CMAKE_INSTALL_PREFIX:PATH=/usr \
      -D CMAKE_BUILD_TYPE:String="Release" ..;
make;
make install;  
groupadd -g 92 frr;
groupadd -r -g 85 frrvty;
useradd -u 92 -g 92 -M -r -G frrvty -s /sbin/nologin \
  -c "FRR FRRouting suite" -d /var/run/frr frr;
git clone https://github.com/frrouting/frr.git frr;
cd frr;
./bootstrap.sh;
./configure \
    --bindir=/usr/bin \
    --sbindir=/usr/lib/frr \
    --sysconfdir=/etc/frr \
    --libdir=/usr/lib/frr \
    --libexecdir=/usr/lib/frr \
    --localstatedir=/var/run/frr \
    --with-moduledir=/usr/lib/frr/modules \
    --enable-snmp=agentx \
    --enable-multipath=64 \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --disable-ldpd \
    --enable-fpm \
    --with-pkg-git-version \
    --with-pkg-extra-version=-MyOwnFRRVersion \
    SPHINXBUILD=/usr/bin/sphinx-build;
make;
make check;
make install;
mkdir /var/log/frr;
mkdir /etc/frr;
touch /etc/frr/zebra.conf;
touch /etc/frr/bgpd.conf;
touch /etc/frr/ospfd.conf;
touch /etc/frr/ospf6d.conf;
touch /etc/frr/isisd.conf;
touch /etc/frr/ripd.conf;
touch /etc/frr/ripngd.conf;
touch /etc/frr/pimd.conf;
touch /etc/frr/nhrpd.conf;
touch /etc/frr/eigrpd.conf;
touch /etc/frr/babeld.conf;
chown -R frr:frr /etc/frr/;
touch /etc/frr/vtysh.conf;
chown frr:frrvty /etc/frr/vtysh.conf;
chmod 640 /etc/frr/*.conf;
install -p -m 644 tools/etc/frr/daemons /etc/frr/;
chown frr:frr /etc/frr/daemons;
install -p -m 644 tools/frr.service /usr/lib/systemd/system/frr.service;
systemctl preset frr.service;
systemctl enable frr --now;
