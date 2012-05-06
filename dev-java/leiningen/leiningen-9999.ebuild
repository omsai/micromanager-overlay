# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4


DESCRIPTION="Leiningen is a build utility for clojure projects."
HOMEPAGE="http://github.com/technomancy/leiningen/"
SRC_URI="http://github.com/technomancy/leiningen/raw/stable/bin/lein"

LICENSE="EPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5
         app-misc/rlwrap"
DEPEND=">=virtual/jdk-1.5"

MY_P="${PN}${SLOT}-${PV}"
MY_ENVD=20${PN}
S=${WORKDIR}

src_unpack() {
	cp /usr/portage/distfiles/${A} ${WORKDIR}
}

src_install() {
	/bin/bash lein self-install || die

	exeinto /var/ftp/distfiles
	doexe lein

	cat <<-EOF > ${MY_ENVD}
	PATH="/var/ftp/distfiles"
	ROOTPATH="/var/ftp/distfiles"
	EOF
	doenvd ${MY_ENVD}
	env-update && source /etc/profile
}
