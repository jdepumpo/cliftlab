{
  config,
  vars,
  ...
}: {
  sops.secrets."authelia-jwt-secret".owner = "authelia-main";
  sops.secrets."authelia-session-secret".owner = "authelia-main";
  sops.secrets."authelia-storage-key".owner = "authelia-main";
  sops.secrets."authelia-user-password-hash" = {};
  sops.secrets."authelia-smtp-password" = {};
  sops.secrets."authelia-oidc-hmac-secret".owner = "authelia-main";
  sops.secrets."authelia-oidc-jwk-rsa-key" = {
    format = "binary";
    sopsFile = ./../secrets/authelia-oidc-jwk-rsa-key.pem;
    owner = "authelia-main";
  };
  sops.secrets."miniflux-oidc-client-secret-hash".owner = "authelia-main";

  sops.templates."authelia-env" = {
    content = ''
      AUTHELIA_NOTIFIER_SMTP_PASSWORD=${config.sops.placeholder."authelia-smtp-password"}
    '';
    owner = "authelia-main";
  };

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

  sops.templates."authelia-oidc-clients" = {
    owner = "authelia-main";
    content = ''
      identity_providers:
        oidc:
          clients:
            - client_id: opencloud
              client_name: OpenCloud
              public: true
              authorization_policy: two_factor
              pkce_challenge_method: S256
              redirect_uris:
                - https://cloud.clift.one/
                - https://cloud.clift.one/oidc-callback.html
              scopes:
                - openid
                - profile
                - email
                - groups
              userinfo_signed_response_alg: none
            - client_id: miniflux
              client_name: Miniflux
              client_secret: '${config.sops.placeholder."miniflux-oidc-client-secret-hash"}'
              public: false
              authorization_policy: one_factor
              redirect_uris:
                - https://rss.clift.one/oauth2/oidc/callback
              scopes:
                - openid
                - profile
                - email
                - groups
              userinfo_signed_response_alg: none
    '';
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
    settingsFiles = [config.sops.templates."authelia-oidc-clients".path];
    settings = {
      theme = "dark";
      default_2fa_method = "webauthn";
      server.address = "tcp://127.0.0.1:9092";

      authentication_backend.file.path = config.sops.templates."authelia-users".path;

      session.cookies = [
        {
          domain = "clift.one";
          authelia_url = "https://auth.clift.one";
          default_redirection_url = "https://clift.one";
        }
      ];

      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      notifier.smtp = {
        address = "submissions://mail.depumpo.com:465";
        username = "links@jfd.is";
        sender = "CliftONE Auth <auth@jfd.is>";
      };

      access_control.default_policy = "two_factor";

      webauthn = {
        disable = false;
        display_name = "clift.one";
        attestation_conveyance_preference = "indirect";
        selection_criteria.user_verification = "preferred";
      };
    };

    secrets = {
      jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
      sessionSecretFile = config.sops.secrets."authelia-session-secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia-storage-key".path;
      oidcHmacSecretFile = config.sops.secrets."authelia-oidc-hmac-secret".path;
      oidcIssuerPrivateKeyFile = config.sops.secrets."authelia-oidc-jwk-rsa-key".path;
    };
  };

  systemd.services."authelia-main".serviceConfig.EnvironmentFile =
    config.sops.templates."authelia-env".path;
}
