{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # sops-nix использует SSH-ключ хоста (/etc/ssh/ssh_host_ed25519_key) 
    # или пользовательский age-ключ (~/.config/sops/age/keys.txt) для расшифровки
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      github_ssh_key = {
        path = "/home/bebra/.ssh/id_github";
        owner = "bebra";
        group = "users";
        mode = "0600";
      };
      gitlab_ssh_key = {
        path = "/home/bebra/.ssh/id_gitlab";
        owner = "bebra";
        group = "users";
        mode = "0600";
      };
    };
  };
}
