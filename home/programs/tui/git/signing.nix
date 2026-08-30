# Signs git commits with the same SSH key used to log in everywhere.
{
  home.file.".ssh/allowed_signers".text = "* ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo";

  programs.git = {
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
  };
}
