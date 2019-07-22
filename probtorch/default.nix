{ lib, fetchFromGitHub, buildPythonPackage, pytorch }:

buildPythonPackage rec {
  pname = "probtorch";
  version = "0.0";

  src = fetchFromGitHub {
    owner = "probtorch";
    repo = "probtorch";
    rev = "4b7e1404354c05401fc4132c9cbe0a7e1ac52eb5";
    sha256= "1dgrvi0pjnxinaw7r5q9d3gyd40qn3dknm15yygbl105ybaym9i6";
  };

  doCheck = false;
  # checkInputs = [ pytest ];
  propagatedBuildInputs = [ pytorch ];

  meta = with lib; {
    homepage = https://github.com/probtorch/probtorch;
    description = "Probabilistic Torch is library for deep generative models that extends PyTorch";
    license = licenses.apache2;
    maintainers = with maintainers; [ stites ];
  };
}
