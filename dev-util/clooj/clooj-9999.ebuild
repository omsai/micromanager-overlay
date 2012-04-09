# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit git-2

DESCRIPTION="Lightweight IDE for Clojure"
HOMEPAGE="https://github.com/arthuredelstein/clooj"

SLOT="0"
LICENSE="EPL-1.0"
KEYWORDS="~amd64"
IUSE=""

EGIT_REPO_URI="https://github.com/arthuredelstein/clooj.git"

DEPEND=">=virtual/jdk-1.6"

RDEPEND="=dev-lang/clojure-1.3.0
	dev-lang/leiningen
	dev-lang/clj-inspector
	dev-lang/slamhound"

src_unpack() {
	git-2_src_unpack
}

src_compile() {
	lein uberjar || die "lein build failed"
}
