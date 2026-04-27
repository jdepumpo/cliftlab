{vars, ...}: {
  home.file.".ssh/allowed_signers".text = "* ${vars.sshPublicKeyPersonal}";

  programs.git = {
    enable = true;
    settings = {
      user.name = vars.fullName;
      user.email = vars.userEmail;
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = vars.sshPublicKeyPersonal;
    };
  };
}
