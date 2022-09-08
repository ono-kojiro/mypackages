all : zck rpm modulemd libsolv libcomps \
	libdnf dnf createrepo

zck :
	cd "$@" && sh build.sh && sh build.sh sysinstall

rpm :
	cd "$@" && sh build.sh && sh build.sh sysinstall

modulemd :
	cd "$@" && sh build.sh && sh build.sh sysinstall

libsolv :
	cd "$@" && sh build.sh && sh build.sh sysinstall

librepo :
	cd "$@" && sh build.sh && sh build.sh sysinstall

libdnf :
	cd "$@" && sh build.sh && sh build.sh sysinstall


libcomps :
	cd "$@" && sh build.sh && sh build.sh sysinstall

dnf :
	cd "$@" && sh build.sh && sh build.sh sysinstall

createrepo_c :
	cd "$@" && sh build.sh && sh build.sh sysinstall

.PHONY : \
	zck rpm modulemd libsolv librepo libcomps \
		libdnf dnf createrepo_c


