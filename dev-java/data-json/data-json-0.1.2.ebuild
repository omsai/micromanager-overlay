# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit java-pkg-2 java-maven-2

DESCRIPTION="JSON in Clojure"
HOMEPAGE="https://github.com/clojure/data.json"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE="source"

SRC_URI="https://github.com/clojure/data.json/tarball/data.json-0.1.2
         -> data.json-${PV}.tar.gz"
S="${WORKDIR}/clojure-data.json-5a17048"

CDEPEND="=dev-lang/clojure-1.3"
DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"

JAVA_MAVEN_BUILD_SYSTEM="maven"
JAVA_MAVEN_CLASSPATH="clojure-1.3"


src_unpack() {
	java-maven-2_src_unpack
}
