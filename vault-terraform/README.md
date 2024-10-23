# HashiCorp Vault a Terraform

## Základní info

Implementace postupu pro správu citlivých údajů (secrets) v nástroji Hashicorp Vault pomocí deklarativního jazyka HCL s výstupy verzovanými v gitu.
Cílem workflow je přidat do Hashicorp Vaultu sadu secrets načtených z lokálních souborů.

- Hashicorp Vault je nástroj pro správu citlivých údajů
- Bezpečně je ukládá za pomocí kryptografie
- HCL (HashiCorp Configuration Language) je deklarativní jazyk, používá se společně s HashiCorp
- Git je verzovací systém, který neukládá samotné soubory, ale jen jejich změny mezi jednotlivými verzemi souborů

## Postup

1. Vytvoření `Secrets` souboru s názvem `vault-learn.txt`
2. Vytvoření konfiguračního souboru `config.hcl`, který bude Vault používat
3. Vytvoření souboru `main.tf`, který načítá a používá secrets z lokálního souboru

## Popis funkce

### Vytvoření potřebných souborů a složek

Základní konfigurace Vault serveru pomocí `config.hcl`:

- Data Vaultu jsou uloženy v `vault-data` složce
- Server dostupný na portu 8200 (výchozí)
- Není použito TLS (testování)

Terraform konfigurace pro správu secrets pomocí `main.tf`:

- Nastavuje poskytovatele (Provider) na HC Vault
- Používá KV (Key-Value) verzi 2 - podporuje verzování secrets
- Aktivuje KV secrets v2 engine poté automaticky načítá heslo ze souboru `vault-learn.txt`

Soubor `.gitignore` zajišťuje, že citlivá data nejsou nahrány na Git repo

### Spuštění a vytvoření nového Vaultu

```bash
# Spustí Vault server s konfigurací
vault server -config=config.hcl

# Proměnná prostředí kde najít Vault Server
export VAULT_ADDR='http://127.0.0.1:8200'

# Vytvoří nový Vault a vytvoří všechny tokeny a klíče
vault operator init
```

### Odemčení (UnSeal) a přihlášení

```bash
# Pro odemčení (unseal) je potřeba provést tento příkaz 3x s různými klíči
# Po restartu Vault Serveru je potřeba tento postup provést znovu!
vault operator unseal

# Přihlašuje uživatele pomocí tokenu - v tomto případě root tokenu
# Povoluje provádět změny ve Vaultu
vault login
```

### Nahrání secretu pomocí Terraform

```bash
# Stáhne pluginy definované v použitém poskytovateli (provider)
terraform init

# Tento krok je doporučený, ale je možné ho vynechat
# Ukáže danému uživateli prostředky, které budou vytvořeny, aby byla zajištěna správná konfigurace bez aplikování samotné konfigurace (něco jako Openshift --dry-run)
terraform plan

# Vytvoří secret ve Vaultu podle souboru `main.tf`
terraform apply
```

### Ověření uložení secretu

```bash
# Kontrola secret, že vše bylo provedeno správně
# Měl by být vytvořen soubor `my-secret` definovaný v Terraform `main.tf`
# Pokud je Vault odemčený (Unsealed), lze data přečíst nešifrované
vault kv get secret/my-secret
```

## Poznatky a principy

- Vault vždy šifruje data na disku za pomocí několika šifrovacích algoritmů
- Enkódování pomocí BASE64 nebo checksum MD5 použit není pro přímé šifrování - nejedná se o šifrovací algoritmy
- Unseal klíče jsou potřeba po každém restartu a to minimálně 3 různé!
- Při použití `vault operator init` je vygenerováno 5 klíčů a 1 root token
- Root token dává plný přístup ke všem citlivým údajům uložených ve Vault
- Existují i omezené tokeny, které povolují přístup jen k některým funkcionalitám (nemám zkušenost)
- Terraform automatizuje správu secrets, ale i zahájení a použití HashiCorp Vault pomocí poskytovatele Vault v `main.tf`
- Všechny citlivé údaje jsou verzovány pomocí Git a uloženy zabezpečně

Díky tomu máme šifrování dat a kontrolu přístupu uživatelů do Vaultu.
Máme funkční automatizaci pomocí Terraformu s verzováním konfigurace v Git repu.
