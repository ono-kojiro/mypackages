BUILD ORDER

 1. zck
 2. rpm
 3. modulemd
 4. libsolv
 5. librepo
 6. libdnf
 7. libcomps
 8. dnf
 9. createrepo_c

ALIAS
 $ alias dnf='fakeroot fakechroot dnf -y --installroot=$HOME/myroot'


