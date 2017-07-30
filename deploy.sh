#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
cd ${WORKSPACE}/${NAME}${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
../configure \
--enable-shared \
--enable-static \
--prefix=${SOFT_DIR}
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/ARGTABLE-deploy"
setenv ARGTABLE_VERSION       $VERSION
setenv ARGTABLE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(ARGTABLE_DIR)/lib
prepend-path CFLAGS            "$CFLAGS -I$::env(ARGTABLE_DIR)/include"
prepend-path LDFLAGS           "$LDFLAGS -L$::env(ARGTABLE_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

module avail $NAME
module add  $NAME/$VERSION
