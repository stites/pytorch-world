{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pygtrie";
  # version = "2.3.2";
  version = "2.2";

  src = fetchPypi {
    inherit pname version;
    # sha256 = "08qfz19k4jz1ywz4ymrbqscfca48zqzc9ny2jl4dmpybsbnwv6b2";
    sha256 = "1lzrzybzwcgalvgf6cdzs1lwrmicin85rbpd576dd7qw3gsaiwh1";
  };

  doCheck = false;

  meta = {
    homepage = "https://github.com/mina86/pygtrie";
    description = "pygtrie is a Python library implementing a trie data structure.";
    longdescription = ''
      pygtrie is a Python library implementing a trie data structure.

      Trie data structure, also known as radix or prefix tree, is a tree associating
      keys to values where all the descendants of a node have a common prefix
      (associated with that node).

      The trie module contains Trie, CharTrie and StringTrie classes each implementing
      a mutable mapping interface, i.e. dict interface. As such, in most circumstances,
      Trie could be used as a drop-in replacement for a dict, but the prefix nature of
      the data structure is trie’s real strength.

      The module also contains PrefixSet class which uses a trie to store a set of
      prefixes such that a key is contained in the set if it or its prefix is stored
      in the set.
    '';
  };
}

