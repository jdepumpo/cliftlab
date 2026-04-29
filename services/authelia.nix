{
  config,
  vars,
  ...
}: {
  sops.secrets."authelia-jwt-secret".owner = "authelia-main";
  sops.secrets."authelia-session-secret".owner = "authelia-main";
  sops.secrets."authelia-storage-key".owner = "authelia-main";
  sops.secrets."authelia-user-password-hash" = {};

  sops.templates."authelia-users" = {
    content = ''
      users:
        ${vars.userName}:
          displayname: "${vars.fullName}"
          password: "${config.sops.placeholder."authelia-user-password-hash"}"
          email: ${vars.userEmail}
          groups:
            - admins
    '';
    owner = "authelia-main";
  };

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/authelia-main";
      user = "authelia-main";
      group = "authelia-main";
      mode = "0700";
    }
  ];

  services.authelia.instances.main = {
    enable = true;
    settings = {
      theme = "dark";
      default_2fa_method = "webauthn";
      server.address = "tcp://127.0.0.1:9092";

      authentication_backend.file = {
        path = config.sops.templates."authelia-users".path;
        watch = true;
      };

      session.cookies = [
        {
          domain = "clift.one";
          authelia_url = "https://auth.clift.one";
          default_redirection_url = "https://clift.one";
        }
      ];

      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

      access_control.default_policy = "two_factor";

      webauthn = {
        disable = false;
        enable_passkeys = true;
        display_name = "clift.one";
        attestation_conveyance_preference = "indirect";
        user_verification = "preferred";
      };
    };

    secrets = {
      jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
      sessionSecretFile = config.sops.secrets."authelia-session-secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia-storage-key".path;
    };
  };
}
