{ config, pkgs, username, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # sops-nix использует SSH-ключ хоста (/etc/ssh/ssh_host_ed25519_key)
    # или пользовательский age-ключ (~/.config/sops/age/keys.txt) для расшифровки
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      github_ssh_key = {
        path = "/home/${username}/.ssh/id_github";
        owner = username;
        group = "users";
        mode = "0600";
      };
      gitlab_ssh_key = {
        path = "/home/${username}/.ssh/id_gitlab";
        owner = username;
        group = "users";
        mode = "0600";
      };
      # Полная строка nix.conf (не голый токен), т.к. подключается через
      # `!include` в nix.extraOptions (modules/system/nix-settings.nix).
      # owner = username, а не root: `nix flake update`, запущенный без sudo,
      # тоже должен уметь её прочитать; root читает любой файл вне зависимости
      # от прав, так что sudo nixos-rebuild switch это не задевает.
      nix_access_tokens = {
        owner = username;
        group = "users";
        mode = "0400";
      };
    };
  };
}
