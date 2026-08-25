{...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/var/lib/copyparty/Music";
      Address = "0.0.0.0";
      Port = 4533;
    };
  };
}
