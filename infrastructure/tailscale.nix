# infrastructure/tailscale.nix
#
# Tailscale network configuration, ACLs, logstreaming, and device authorizations in Terranix Nix.

{ config, lib, ... }:

let
  tailnet = config.infrastructure.tailscale.tailnet;
  devices = [
    {
      name = "latitude-7390";
      tags = [ "tag:device-latitude-7390" ];
    }
    {
      name = "ghost-gs60";
      tags = [ "tag:device-ghost-gs60" ];
    }
    {
      name = "steamdeck";
      tags = [ "tag:device-steamdeck" ];
    }
    {
      name = "steammachine";
      tags = [ "tag:device-steammachine" ];
    }
    {
      name = "doms-pixel-9";
      tags = [ ];
      waitFor = "10s";
    }
    {
      name = "beszel";
      tags = [ "tag:service-beszel" ];
      waitFor = "10s";
    }
    {
      name = "frigate";
      tags = [ "tag:service-frigate" ];
      waitFor = "10s";
    }
    {
      name = "idp";
      tags = [ "tag:service-idp" ];
    }
    {
      name = "immich";
      tags = [ "tag:service-immich" ];
    }
    {
      name = "jellyfin";
      tags = [ "tag:service-jellyfin" ];
    }
    {
      name = "silverbullet";
      tags = [ "tag:service-silverbullet" ];
    }
    {
      name = "transmission";
      tags = [ "tag:service-transmission" ];
    }
    {
      name = "cache";
      tags = [ "tag:service-cache" ];
      waitFor = "10s";
    }
  ];
in

{
  resource = {
    tailscale_contacts.contacts = {
      account = {
        email = "dominic.egginton@gmail.com";
      };
      support = {
        email = "dominic.egginton@gmail.com";
      };
      security = {
        email = "dominic.egginton@gmail.com";
      };
    };

    tailscale_tailnet_settings.settings = {
      acls_externally_managed_on = false;
      devices_approval_on = true;
      devices_auto_updates_on = true;
      devices_key_duration_days = 5;
      users_approval_on = true;
      users_role_allowed_to_join_external_tailnet = "member";
      https_enabled = true;
    };

    tailscale_dns_configuration.dns_configuration = {
      nameservers = [
        {
          address = "\${data.nextdns_setup_endpoint.ribble.ipv6[0]}";
          use_with_exit_node = true;
        }
        {
          address = "\${data.nextdns_setup_endpoint.ribble.ipv6[1]}";
          use_with_exit_node = true;
        }
      ];
      search_paths = [ ];
      override_local_dns = true;
      magic_dns = true;
    };

    tailscale_acl.acl = {
      acl = builtins.readFile ./tailscale_acl.json;
      overwrite_existing_content = true;
    };

    tailscale_logstream_configuration.gcs_logstream = {
      log_type = "configuration";
      destination_type = "gcs";
      gcs_bucket = "\${google_storage_bucket.tailscale_logs.name}";
      gcs_credentials = "\${base64decode(google_service_account_key.tailscale_logstream.private_key)}";
      gcs_scopes = [ "https://www.googleapis.com/auth/devstorage.read_write" ];

      lifecycle = {
        ignore_changes = [ "gcs_credentials" ];
      };
    };

    # Declarative device authorizations
    tailscale_device_authorization = lib.listToAttrs (
      map (dev: {
        name = dev.name;
        value = {
          device_id = "\${data.tailscale_device.${dev.name}.node_id}";
          authorized = true;
        };
      }) devices
    );

    # Declarative device tags
    tailscale_device_tags = lib.listToAttrs (
      map (dev: {
        name = dev.name;
        value = {
          device_id = "\${data.tailscale_device.${dev.name}.node_id}";
          tags = dev.tags;
          depends_on = [ "tailscale_acl.acl" ];
        };
      }) devices
    );
  };

  # Declarative device data sources
  data = {
    tailscale_users.all-users = { };

    tailscale_device = lib.listToAttrs (
      map (dev: {
        name = dev.name;
        value = {
          name = "${dev.name}.${tailnet}";
        }
        // lib.optionalAttrs (dev ? waitFor) {
          wait_for = dev.waitFor;
        };
      }) devices
    );
  };
}
