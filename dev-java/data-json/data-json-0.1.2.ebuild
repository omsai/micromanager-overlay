# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CLOJURE_VERSION="1.1"
WANT_CONTRIB="no"
inherit clojure

DESCRIPTION="JSON in Clojure"
HOMEPAGE="https://github.com/clojure/data.json"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE="source"

SRC_URI="https://github.com/clojure/data.json/tarball/data.json-0.1.2
         -> data.json-${PV}.tar.gz"
S=${WORKDIR}/clojure-data.json-5a17048

DEPEND=""
RDEPEND=""

src_prepare() {
	mvn ant:ant
}

src_install() {
	java-pkg_dojar target/data.json-${PV}.jar
}
