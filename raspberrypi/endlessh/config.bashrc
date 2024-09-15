realname="endlessh"
pkgname="endlessh"
pkgver="1.0"

src_urls=""
src_urls="$src_urls https://github.com/skeeto/endlessh/releases/download/1.0/endlessh-1.0.tar.xz"

url="https://github.com/skeeto/endlessh"

dest()
{
  cd ${builddir}/${realname}-${pkgver}
  make install DESTDIR=${destdir} PREFIX=/usr
  mkdir -p ${destdir}/etc/endlessh/
  mkdir -p ${destdir}/lib/systemd/system/
  mkdir -p ${destdir}/etc/endlessh/
  mkdir -p ${destdir}/etc/rsyslog.d/
  command install -m 640 ${top_dir}/endlessh.conf \
    ${destdir}/etc/endlessh/config
  command install -m 640 ${top_dir}/endlessh.service \
    ${destdir}/lib/systemd/system/
  command install -m 640 ${top_dir}/rsyslog.conf \
    ${destdir}/etc/rsyslog.d/90-endlessh.conf
  cd ${top_dir}
}


