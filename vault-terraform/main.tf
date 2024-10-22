terraform {
  required_providers {
    # Konfigurace poskytovatele, který bude použit - HC Vault
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

# Použití Vault s údaji z `config.hcl`
provider "vault" {
  # Je možno použít i VAULT_ADDR pomocí env
  address = "http://127.0.0.1:8200"

  # VAULT_TOKEN je env (proměnná prostředí)
}

# Aktivování KV Verze 2 secrets engine
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Verze 2 secret engine"
}

# Vytvoření secret
resource "vault_kv_secret_v2" "secret" {
  mount = vault_mount.kvv2.path
  name = "my-secret"

  data_json = jsonencode({
    password = file("vault-learn.txt")
  })

  depends_on = [ vault_mount.kvv2 ]
}
