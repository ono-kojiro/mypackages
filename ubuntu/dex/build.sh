#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

if [ ! -e ".env" ]; then
  touch .env
fi

set -a
. ./.env
envsubst < config-ldap.yaml.template > config-ldap.yaml
set +a

realname="dex"
pkgname="${realname}"
pkgver="2.45.1"

src_urls=""
src_urls="$src_urls https://github.com/dexidp/dex/archive/refs/tags/v${pkgver}.tar.gz"

url="https://github.com/dexidp/dex"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

outputdir=$top_dir

all()
{
  fetch
  extract
  patch
  configure
  compile
  install
  custom_install
  package
}

help()
{
  cat - << EOF
usage: sh build.sh TARGET
EOF
}

fetch()
{
  mkdir -p $sourcedir

  for src_url in $src_urls; do
    archive=`basename $src_url`
    case $src_url in
      *.gz | *.zip )
        if [ ! -e "$sourcedir/$archive" ]; then
            wget $src_url
            mv -f $archive $sourcedir/
        else
            echo "skip $src_url"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${sourcedir}/${dirname}" ]; then
            mkdir -p ${sourcedir}
            git -C ${sourcedir} clone $src_url
        else
            echo "skip git-clone"
        fi
        ;;
      * )
        echo "ERROR : unknown extension, $src_url"
        exit 1
        ;;
    esac
  done

}

extract()
{
  mkdir -p ${builddir}
  
  for src_url in $src_urls; do
    archive=`basename $src_url`
    basename=`basename $src_url .tar.gz`
    case $src_url in
      *.gz )
        if [ ! -d "${builddir}/${basename}" ]; then
          tar -C ${builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        if [ ! -d "${builddir}/${basename}" ]; then
          unzip ${sourcedir}/${archive} -d ${builddir}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${builddir}/${dirname}" ]; then
            mkdir -p ${builddir}
            cp -a ${sourcedir}/${dirname} ${builddir}/
        else
            echo "skip extract"
        fi
        ;;
      * )
        echo "ERROR : unknown extension, $src_url"
        exit 1
        ;;
    esac
  done

}

prepare()
{
  sudo apt install golang
}

patch()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${pkgname}-${pkgver}
  #command patch -p0 -i ${top_dir}/0001-enable_x509.patch
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make
  make examples
  cd ${top_dir}
}

clean()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make clean
  cd ${top_dir}
}

build()
{
  compile
}

server()
{
  #cp -f ${builddir}/${pkgname}-${pkgver}/examples/ldap/config-ldap.yaml .

  cd ${builddir}/${pkgname}-${pkgver}
  ./bin/dex serve ${top_dir}/config-ldap.yaml
  cd ${top_dir}
}

app()
{
  cp -f ${TLS_CERT} ${builddir}/${pkgname}-${pkgver}
  cp -f ${TLS_KEY}  ${builddir}/${pkgname}-${pkgver}

  cd ${builddir}/${pkgname}-${pkgver}
  ./bin/example-app \
    --listen ${LISTEN_URL} \
    --issuer ${ISSUER_URL} \
    --redirect-uri ${REDIRECT_URI} \
    --tls-cert ${TLS_CERT} \
    --tls-key  ${TLS_KEY} \
    --issuer-root-ca /etc/ssl/certs/ca-certificates.crt \
    --debug

  cd ${top_dir}
}

install()
{
  install_main
  install_example

  custom_install
}

install_main()
{
  destdir=${top_dir}/work/dest/${pkgname}-${pkgver}
  rm -rf ${destdir}

  cd ${builddir}/${pkgname}-${pkgver}
  #make install DESTDIR=${destdir}
  mkdir -p ${destdir}/usr/bin/
  mkdir -p ${destdir}/etc/dex/
  mkdir -p ${destdir}/usr/lib/systemd/system/
  command install bin/dex         ${destdir}/usr/bin
  #command install bin/example-app ${destdir}/usr/bin
  command install bin/grpc-client ${destdir}/usr/bin
  command install -m 640 ${top_dir}/config/config-ldap.yaml ${destdir}/etc/dex
  command install -m 644 ${top_dir}/config/dex.service ${destdir}/usr/lib/systemd/system/
  #command install -m 644 ${top_dir}/config/example-app.service ${destdir}/lib/systemd/system/
  #command install ${top_dir}/config/example-app.conf    ${destdir}/etc/dex/
  cd ${top_dir}

  custom_install
}

install_example()
{
  destdir=$top_dir/work/dest/${pkgname}-example-${pkgver}
  rm -rf ${destdir}
  
  cd ${builddir}/${pkgname}-${pkgver}
  mkdir -p ${destdir}/usr/bin/
  mkdir -p ${destdir}/etc/dex/
  mkdir -p ${destdir}/lib/systemd/system/
  command install bin/example-app ${destdir}/usr/bin
  command install -m 644 ${top_dir}/config/example-app.service ${destdir}/lib/systemd/system/
  command install ${top_dir}/config/example-app.conf    ${destdir}/etc/dex/
  cd ${top_dir}
}

custom_install()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

package()
{
  package_main
  package_example
}

package_main()
{
  pkgname="${realname}"
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}
  mkdir -p $destdir/DEBIAN

  username=`git config user.name`
  email=`git config user.email`

cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Architecture: amd64
Version: $pkgver
Description: $pkgname
EOS
  
  cp -f postinst $destdir/DEBIAN/
  cp -f postrm   $destdir/DEBIAN/
  cp -f prerm    $destdir/DEBIAN/
  fakeroot dpkg-deb --build $destdir $outputdir
}

package_example()
{
  pkgname="${realname}-example"
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}
  
  mkdir -p ${destdir}/DEBIAN

  username=`git config user.name`
  email=`git config user.email`

cat << EOS > ${destdir}/DEBIAN/control
Package: ${pkgname}
Maintainer: ${username} <${email}>
Architecture: amd64
Version: ${pkgver}
Description: ${pkgname}
EOS
  
  cp -f postinst ${destdir}/DEBIAN/
  cp -f postrm   ${destdir}/DEBIAN/
  cp -f prerm    ${destdir}/DEBIAN/
  fakeroot dpkg-deb --build ${destdir} ${outputdir}
}


info()
{
  dpkg -c ${pkgname}_${pkgver}_amd64.deb
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb

}

check()
{
  info
}

mclean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  cp -f ./${pkgname}_${pkgver}_amd64.deb /tmp/
  sudo apt -y install /tmp/${pkgname}_${pkgver}_amd64.deb
  postinst
  sudo systemctl daemon-reload
  sudo systemctl restart dex
  #sudo systemctl restart example-app
}

sysinst()
{
  sysinstall
}

sysuninstall()
{
  stop

  sudo apt -y remove --purge ${pkgname}
  echo "INFO: remove /etc/dex"
  sudo rm -rf /etc/dex/
}

sysuninst()
{
  sysuninstall
}

install_certs()
{
  sudo sh -s << EOF
    cp -f dex.crt /etc/dex/certs/
    cp -f dex.key /etc/dex/certs/
    cp -f example-app.crt /etc/dex/certs/
    cp -f example-app.key /etc/dex/certs/

    chmod 664 /etc/dex/certs/dex.crt
    chmod 660 /etc/dex/certs/dex.key
    chmod 664 /etc/dex/certs/example-app.crt
    chmod 660 /etc/dex/certs/example-app.key

    chown -R dex:dex /etc/dex/certs/
EOF
}

install_configs()
{
  sudo sh -s << EOF
    cp -f config-ldap.yaml /etc/dex/
    chown dex:dex /etc/dex/config-ldap.yaml
    chmod 660 /etc/dex/config-ldap.yaml
    
    cp -f example-app.conf /etc/dex/
    chown dex:dex /etc/dex/example-app.conf
    chmod 660 /etc/dex/example-app.conf
EOF

}

postinst()
{
  install_certs
  install_configs
}

start()
{
  sudo systemctl start dex
  #sudo systemctl start example-app
}

stop()
{
  sudo systemctl stop dex
  #sudo systemctl stop example-app
}

restart()
{
  sudo systemctl restart dex
  #sudo systemctl restart example-app
}

status()
{
  res=`systemctl is-active dex`
  echo "INFO: dex is $res"

  #res=`systemctl is-active example-app`
  #echo "INFO: example-app is $res"
}


debug()
{
  cd / && sudo -u dex /usr/bin/dex serve /etc/dex/config-ldap.yaml
}

debug_example()
{
  cd / && sudo -u dex /bin/sh -s << EOF
  {
     . /etc/dex/example-app.conf
     echo "DEBUG: TLS_CERT is $TLS_CERT"
     cd / && /usr/bin/example-app \
       --listen $LISTEN_URL \
       --issuer $ISSUER_URL \
       --redirect-uri $REDIRECT_URI \
       --tls-cert $TLS_CERT \
       --tls-key  $TLS_KEY \
       --issuer-root-ca /etc/ssl/certs/ca-certificates.crt
  }
EOF

}

keys()
{
  cmd="curl -k -s https://${DEX_IP_PORT}/dex/keys"
  echo "CMD: $cmd"
  $cmd  | jq .
}

device_code()
{
   curl -s -k -X POST https://${DEX_IP_PORT}/dex/device/code \
     -d "client_id=myclient" \
     -d "scope=openid email profile groups offline_access" \
   | jq . | tee device_code.json
}

device()
{
  device_code
}

auth()
{
   verification_uri_complete=`cat device_code.json \
     | jq -r ".verification_uri_complete"`
   lynx ${verification_uri_complete}
}

refresh_token()
{
  code=`cat device_code.json | jq -r ".device_code"`
  client_id="myclient"

  grant_type="urn:ietf:params:oauth:grant-type:device_code"
  curl -k -s -X POST https://${DEX_IP_PORT}/dex/token \
          -d "grant_type=$grant_type" \
          -d "device_code=$code" \
          -d "client_id=$client_id" | jq . | tee refresh_token.json
}

refresh()
{
  refresh_token
}

access_token()
{
  ref=`cat refresh_token.json | jq -r ".refresh_token"`

  curl -k -s \
    -X POST https://${DEX_IP_PORT}/dex/token \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$ref" \
    -d "client_id=myclient" | jq . | tee access_token.json
}

access()
{
  access_token
}


if [ "$#" -eq 0 ]; then
  all
fi

for target in "$@"; do
	num=`LANG=C type $target 2>&1 | grep 'function' | wc -l`
	if [ $num -ne 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

