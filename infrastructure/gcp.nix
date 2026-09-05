# infrastructure/gcp.nix
#
# GCP Cloud Infrastructure definitions in pure Terranix Nix.

{ config, ... }:

let
  gcp = config.infrastructure.gcp;
in
{
  resource = {
    google_project_service = {
      iam = {
        project = gcp.projectId;
        service = "iam.googleapis.com";
      };

      iamcredentials = {
        project = gcp.projectId;
        service = "iamcredentials.googleapis.com";
      };

      secretmanager = {
        project = gcp.projectId;
        service = "secretmanager.googleapis.com";
      };

      logging = {
        project = gcp.projectId;
        service = "logging.googleapis.com";
      };

      billingbudgets = {
        project = gcp.projectId;
        service = "billingbudgets.googleapis.com";
      };
    };

    random_id.terraform_remote_backend = {
      byte_length = 8;
    };

    google_storage_bucket = {
      terraform_remote_backend = {
        name = "\${random_id.terraform_remote_backend.hex}-terraform-remote-backend";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
      };

      dominicegginton = {
        name = "dominicegginton";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
        soft_delete_policy = {
          retention_duration_seconds = 604800; # 7 days
        };
        retention_policy = {
          retention_period = 2592000; # 30 days
          is_locked = false;
        };
      };

      immich_backup = {
        name = "immich-backup-\${random_id.terraform_remote_backend.hex}";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
        lifecycle_rule = [
          {
            action = {
              type = "Delete";
            };
            condition = {
              days_since_noncurrent_time = 30;
            };
          }
        ];
        soft_delete_policy = {
          retention_duration_seconds = 604800;
        };
        retention_policy = {
          retention_period = 2592000;
          is_locked = false;
        };
      };

      silverbullet_backup = {
        name = "silverbullet-backup-\${random_id.terraform_remote_backend.hex}";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
        lifecycle_rule = [
          {
            action = {
              type = "Delete";
            };
            condition = {
              days_since_noncurrent_time = 30;
            };
          }
        ];
        soft_delete_policy = {
          retention_duration_seconds = 604800;
        };
        retention_policy = {
          retention_period = 2592000;
          is_locked = false;
        };
      };

      frigate_backup = {
        name = "frigate-backup-\${random_id.terraform_remote_backend.hex}";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
        lifecycle_rule = [
          {
            action = {
              type = "Delete";
            };
            condition = {
              days_since_noncurrent_time = 30;
            };
          }
        ];
        soft_delete_policy = {
          retention_duration_seconds = 604800;
        };
        retention_policy = {
          retention_period = 2592000;
          is_locked = false;
        };
      };

      tailscale_logs = {
        name = "tailscale-logs-\${random_id.terraform_remote_backend.hex}";
        location = "EUROPE-WEST2";
        force_destroy = false;
        public_access_prevention = "enforced";
        uniform_bucket_level_access = true;
        versioning = {
          enabled = true;
        };
      };
    };

    google_service_account = {
      immich_backup = {
        account_id = "immich-backup";
        display_name = "Immich Backup Service Account";
      };

      silverbullet_backup = {
        account_id = "silverbullet-backup";
        display_name = "Silverbullet Backup Service Account";
      };

      frigate_backup = {
        account_id = "frigate-backup";
        display_name = "Frigate Backup Service Account";
      };

      tailscale_logstream = {
        account_id = "tailscale-logstream";
        display_name = "Tailscale Logstream Service Account";
      };

      gcp_logging = {
        account_id = "vector-gcp-logging";
        display_name = "Vector GCP Cloud Logging Service Account";
      };
    };

    google_service_account_key = {
      immich_backup = {
        service_account_id = "\${google_service_account.immich_backup.name}";
      };

      silverbullet_backup = {
        service_account_id = "\${google_service_account.silverbullet_backup.name}";
      };

      frigate_backup = {
        service_account_id = "\${google_service_account.frigate_backup.name}";
      };

      tailscale_logstream = {
        service_account_id = "\${google_service_account.tailscale_logstream.name}";
      };

      gcp_logging = {
        service_account_id = "\${google_service_account.gcp_logging.name}";
      };
    };

    google_storage_bucket_iam_member = {
      immich_backup = {
        bucket = "\${google_storage_bucket.immich_backup.name}";
        role = "roles/storage.objectAdmin";
        member = "serviceAccount:\${google_service_account.immich_backup.email}";
      };

      silverbullet_backup = {
        bucket = "\${google_storage_bucket.silverbullet_backup.name}";
        role = "roles/storage.objectAdmin";
        member = "serviceAccount:\${google_service_account.silverbullet_backup.email}";
      };

      frigate_backup = {
        bucket = "\${google_storage_bucket.frigate_backup.name}";
        role = "roles/storage.objectAdmin";
        member = "serviceAccount:\${google_service_account.frigate_backup.email}";
      };

      tailscale_logstream = {
        bucket = "\${google_storage_bucket.tailscale_logs.name}";
        role = "roles/storage.objectAdmin";
        member = "serviceAccount:\${google_service_account.tailscale_logstream.email}";
      };
    };

    google_project_iam_member.gcp_logging_writer = {
      project = gcp.projectId;
      role = "roles/logging.logWriter";
      member = "serviceAccount:\${google_service_account.gcp_logging.email}";
    };

    google_secret_manager_secret = {
      tailscale_api_key = {
        secret_id = "secretspec-${gcp.projectId}-default-TF_VAR_tailscale_api_key";
        replication = {
          auto = { };
        };
        depends_on = [ "google_project_service.secretmanager" ];
      };

      tailscale_tailnet = {
        secret_id = "secretspec-${gcp.projectId}-default-TF_VAR_tailscale_tailnet";
        replication = {
          auto = { };
        };
        depends_on = [ "google_project_service.secretmanager" ];
      };
    };

    google_billing_budget.budget = {
      count = "\${var.gcp_billing_account_id != \"\" && var.gcp_billing_account_id != null ? 1 : 0}";
      billing_account = "\${var.gcp_billing_account_id}";
      display_name = "GCP Project Budget Alert";

      budget_filter = {
        projects = [ "projects/\${data.google_project.current.number}" ];
        credit_types_treatment = "INCLUDE_ALL_CREDITS";
      };

      amount = {
        specified_amount = {
          currency_code = "GBP";
          units = "10";
        };
      };

      threshold_rules = [
        {
          threshold_percent = 0.5;
          spend_basis = "CURRENT_SPEND";
        }
        {
          threshold_percent = 0.9;
          spend_basis = "CURRENT_SPEND";
        }
        {
          threshold_percent = 1.0;
          spend_basis = "CURRENT_SPEND";
        }
        {
          threshold_percent = 1.0;
          spend_basis = "FORECASTED_SPEND";
        }
      ];

      depends_on = [ "google_project_service.billingbudgets" ];
    };
  };

  data.google_project.current = { };

  output = {
    gcp_project_id = {
      description = "GCP Project ID";
      value = "\${google_project_service.iam.project}";
    };

    terraform_backend_bucket = {
      description = "GCS Bucket name for Terraform remote backend";
      value = "\${google_storage_bucket.terraform_remote_backend.name}";
    };

    dominicegginton_bucket = {
      description = "GCS Bucket name for dominicegginton";
      value = "\${google_storage_bucket.dominicegginton.name}";
    };

    immich_backup_key = {
      description = "GCP Service Account Key for Immich backup (base64 encoded)";
      value = "\${google_service_account_key.immich_backup.private_key}";
      sensitive = true;
    };

    silverbullet_backup_key = {
      description = "GCP Service Account Key for SilverBullet backup (base64 encoded)";
      value = "\${google_service_account_key.silverbullet_backup.private_key}";
      sensitive = true;
    };

    frigate_backup_key = {
      description = "GCP Service Account Key for Frigate backup (base64 encoded)";
      value = "\${google_service_account_key.frigate_backup.private_key}";
      sensitive = true;
    };

    gcp_logging_key = {
      description = "GCP Service Account Key for Vector Cloud Logging (base64 encoded)";
      value = "\${google_service_account_key.gcp_logging.private_key}";
      sensitive = true;
    };
  };
}
