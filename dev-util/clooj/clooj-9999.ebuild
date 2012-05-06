# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit java-pkg-2 eutils git-2

DESCRIPTION="Lightweight IDE for Clojure"
HOMEPAGE="https://github.com/arthuredelstein/clooj"
EGIT_REPO_URI="https://github.com/arthuredelstein/clooj.git"
SRC_URI="http://openiconlibrary.sourceforge.net/gallery2/open_icon_library-full/icons/png/32x32/apps/development-java-3.png"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""


RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6
	dev-java/leiningen"

src_unpack() {
	git-2_src_unpack

	cp ${DISTDIR}/development-java-3.png ${WORKDIR}/${P}/${PN}.png
}

src_compile() {
	addwrite ${ROOT}/root/.m2/
	addwrite ${ROOT}/root/.java/

	lein uberjar || die
}

src_install() {
	java-pkg_dojar clooj-*-standalone.jar

	java-pkg_dolauncher ${PN}

	doicon ${PN}.png
	make_desktop_entry ${PN} "Clooj (Clojure IDE)" ${PN} Development
}
