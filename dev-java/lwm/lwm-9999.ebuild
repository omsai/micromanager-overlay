# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit git-2 java-utils-2

DESCRIPTION="Local Weighted Mean"
HOMEPAGE="https://github.com/arthuredelstein/lwm"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

EGIT_REPO_URI="https://github.com/arthuredelstein/lwm.git"

DEPEND=">=virtual/jdk-1.6"

RDEPEND=">=dev-lang/clojure-1.3.0
	dev-java/commons-math"
#	dev-java/gaussian"

src_unpack() {
	git-2_src_unpack

	mkdir ${WORKDIR}/${P}/classes || die "mkdir failed"
	ls ${WORKDIR}/${P}
}

src_compile() {
	java \
		-cp ./src:./classes:$(java-pkg_getjars clojure-1.3,commons-math-2) \
		-Djava.awt.headless=true \
		-Dclojure.compile.path=classes \
		clojure.lang.Compile lwm.core || die "Compile failed"
}
