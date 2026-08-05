{...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/var/lib/copyparty/Music";
      Address = "127.0.0.1";
      Port = 4533;
    };
  };
}
