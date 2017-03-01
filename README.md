# Generic Group Model primitives

## Installation

*1*. Install [Opam](https://opam.ocaml.org/).

 * In Ubuntu,

~~~~~
apt-get install -y ocaml ocaml-native-compilers opam m4 camlp4-extra
~~~~~

 * In OS X, use homebrew,

~~~~~
brew install opam
~~~~~

*2*. Install Relic:

To install relic, clone the repository from https://github.com/relic-toolkit/relic and follow the instructions below:

~~~~~
mkdir build
cd build
cmake build --ALLOC=DYNAMIC --SHLIB=on ../
~~~~~

The flag --ALLOC=DYNAMIC may not work. Check that the file include/relic_conf.h contains the line "#define ALLOC   DYNAMIC" and fix it if necessary.

~~~~~
make
sudo make install
~~~~~

The installation works for commit 0e239a842b89126080e998e3836f83aff1078576 of relic.

*3*. Install the Ocaml Bindings for Relic:

Install opam packages:

~~~~~
git clone https://github.com/ZooCrypt/relic-ocaml-bindings.git
opam pin add relic-ocaml-bindings RELIC_OCAML_BINDINGS_DIR -n
opam install relic-ocaml-bindings --deps-only
~~~~~

Compile and install the bindings:

~~~~~
oasis setup
./configure
make
opam install relic-ocaml-bindings
~~~~~

*4*. To compile and test our implementation, execute:

~~~~~
make
~~~~~
