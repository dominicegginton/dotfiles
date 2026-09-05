# infrastructure/nextdns.nix
#
# NextDNS profiles, policies, parental control, and security configs in Terranix Nix.

{
  resource = {
    nextdns_profile = {
      ribble = {
        name = "Ribble";
      };

      quandon = {
        name = "quandon";
      };
    };

    nextdns_privacy = {
      ribble = {
        allow_affiliate = false;
        blocklists = [
          "nextdns-recommended"
          "adguard-dns-filter"
          "oisd"
        ];
        disguised_trackers = true;
        natives = [ ];
        profile_id = "\${var.nextdns_profile_ribble}";
      };

      quandon = {
        allow_affiliate = true;
        blocklists = [ ];
        disguised_trackers = false;
        natives = [ ];
        profile_id = "\${var.nextdns_profile_quandon}";
      };
    };

    nextdns_settings = {
      quandon = {
        profile_id = "\${var.nextdns_profile_quandon}";
        web3 = true;
        block_page = {
          enabled = true;
        };
        logs = {
          enabled = true;
          location = "eu";
          retention = "3 months";
          privacy = {
            log_clients_ip = true;
            log_domains = true;
          };
        };
        performance = {
          cache_boost = false;
          cname_flattening = false;
          ecs = false;
        };
      };

      ribble = {
        profile_id = "\${var.nextdns_profile_ribble}";
        web3 = true;
        block_page = {
          enabled = true;
        };
        logs = {
          enabled = true;
          location = "eu";
          retention = "3 months";
          privacy = {
            log_clients_ip = true;
            log_domains = true;
          };
        };
        performance = {
          cache_boost = true;
          cname_flattening = true;
          ecs = true;
        };
      };
    };

    nextdns_security = {
      ribble = {
        ai_threat_detection = true;
        crypto_jacking = true;
        csam = true;
        ddns = true;
        dga = true;
        dns_rebinding = true;
        google_safe_browsing = true;
        idn_homographs = true;
        nrd = true;
        parking = true;
        profile_id = "\${var.nextdns_profile_ribble}";
        threat_intelligence_feeds = true;
        tlds = [ ];
        typo_squatting = true;
      };

      quandon = {
        ai_threat_detection = false;
        crypto_jacking = false;
        csam = false;
        ddns = false;
        dga = false;
        dns_rebinding = false;
        google_safe_browsing = false;
        idn_homographs = false;
        nrd = false;
        parking = false;
        profile_id = "\${var.nextdns_profile_quandon}";
        threat_intelligence_feeds = false;
        tlds = [ ];
        typo_squatting = false;
      };
    };

    nextdns_parental_control = {
      ribble = {
        block_bypass = false;
        profile_id = "\${var.nextdns_profile_ribble}";
        safe_search = false;
        youtube_restricted_mode = false;
        recreation = {
          timezone = "";
        };
      };

      quandon = {
        block_bypass = false;
        profile_id = "\${var.nextdns_profile_quandon}";
        safe_search = false;
        youtube_restricted_mode = false;
        recreation = {
          timezone = "";
        };
      };
    };

    nextdns_allowlist = {
      quandon = {
        profile_id = "\${var.nextdns_profile_quandon}";
        domain = [
          {
            active = true;
            id = "analytics.google.com";
          }
          {
            active = true;
            id = "arup.com";
          }
          {
            active = true;
            id = "azure.com";
          }
          {
            active = true;
            id = "azurestaticapps.net";
          }
          {
            active = true;
            id = "dell.com";
          }
          {
            active = true;
            id = "qa.com";
          }
          {
            active = true;
            id = "reolink.com";
          }
          {
            active = true;
            id = "suunto.com";
          }
        ];
      };

      ribble = {
        profile_id = "\${var.nextdns_profile_ribble}";
        domain = [
          {
            active = true;
            id = "analytics.google.com";
          }
          {
            active = true;
            id = "arup.com";
          }
          {
            active = true;
            id = "azure.com";
          }
          {
            active = true;
            id = "azurestaticapps.net";
          }
          {
            active = true;
            id = "reolink.com";
          }
          {
            active = true;
            id = "suunto.com";
          }
        ];
      };
    };
  };

  data = {
    nextdns_setup_endpoint.ribble = {
      profile_id = "\${var.nextdns_profile_ribble}";
    };
  };
}
