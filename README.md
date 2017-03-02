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

## Usage (Batch mode)

### Identity-Based Encryption

The tool supports four modes (corresponding to the four IBE algorithms) given as first argument:

- setup: outputs a master public key (mpk) and the corresponding master secret key (msk).

- encrypt: the encryption algorithm takes as input the master public key (mpk), a message and an identity *id*,
  it outputs a ciphertext *ct*.

- keygen: the key generation algorithm gets as input mpk and msk and an identity *id*,
  it outputs a secret key *sk*.
  Note that this algorithm needs the msk as input and thus, it is not a public algorithm. It
  is supposed to be runned by the master authority of the system.

- decrypt: the decryption algorithm takes as input *sk* and *ct* and outputs a message. It will
  succeed if and only if the identity associated to the ciphertext matches the identity associated to
  the key.

### Example

The master authority runs the algorithm:

~~~~
$ ../ibe.native setup -mpk mpk.txt -msk msk.txt
~~~~

This will produce two files, *mpk.txt* and *msk.txt*, containing the information of the master public
key and the master secret key respectively.

We will encrypt the message in file *message.txt* containing:

~~~~
L'essentiel est invisible pour les yeux
~~~~

For this, we run the encryption algorithm:

~~~~
$ ../ibe.native encrypt -mpk mpk.txt -id 1667 -msg message.txt -out ciphertext.txt
~~~~

Only users with a secret key corresponding to identity 1667 will be able to decrypt. As an example, we
create two secret keys corresponding to different identity:

~~~~
$ ../ibe.native keygen -mpk mpk.txt -msk msk.txt -id 1667 -out key1.txt
$ ../ibe.native keygen -mpk mpk.txt -msk msk.txt -id 1668 -out key2.txt
~~~~

Decryption will succeed only for the first key:

~~~~
$ ../ibe.native decrypt -mpk mpk.txt -ct ciphertext.txt -sk key1.txt
L'essentiel est invisible pour les yeux
~~~~

~~~~
$ ../ibe.native decrypt -mpk mpk.txt -ct ciphertext.txt -sk key2.txt
bad decrypt
~~~~

