{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "flatdict";
  version = "3.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0rqlyd0bi17vfh8jplmiaailp5chkbzhxzkysh3qszxsblgqb7w1";
  };

  doCheck = false;

  meta = {
    homepage = "https://flatdict.readthedocs.io/en/stable/";
    description = "FlatDict is a dict object that allows for single level, delimited key/value pair mapping of nested dictionaries.";
    longdescription = ''
      FlatDict is a dict object that allows for single level, delimited key/value
      pair mapping of nested dictionaries. You can interact with FlatDict like a
      normal dictionary and access child dicts as you normally would or with the
      composite key.
    '';
  };
}

