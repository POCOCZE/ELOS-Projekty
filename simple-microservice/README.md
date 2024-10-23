# Návrh a vývoj bezstavové mikroslužby (Stateless Simple Microservice Implementation (volitelně))

## Základní info

Návrh a vývoj bezstavové mikroslužby (dle 12factor app principu), používající proměnnou prostředí a proměnnou z API volání, přístupnou pomocí REST API (stačí metody GET a POST), vystavení health-checks a případně metrik.

Projekt bude používat Python framework FastAPI:

- FastAPI snadno implementuje health-checky a metriky což je jedním z požadavků v projektu
- Má podboru pro proměnné prostředí, za použití souboru `.env`
- Asynchronně zpracovává požadavky

### 12 faktorová aplikace má

1. Kód v repu jako třeba Github, Gitea nebo GitLab
2. Dependencies (Závislosti) jsou explicitně deklarované v `requirements.txt` pro příklad
3. Konfigurace je uložena pomocí proměnných prostředí (env. variables) - soubor `.env`
4. Všechny externí služby jsou připojeny pomocí URL - velmi často přes `localhost`, pokud třeba databáze běží ve stejném podu
5. Oddělení buildu a běhu znamená, že je oddělena kompilace aplikace a samotný běh pro zajištěná vyšší bezpečnosti, minitoringu procesu
6. Bezstavová (Stateless) znamená, že aplikace neuchovává žádná data lokálně v aplikaci, ale třeba v Redis cache databázi - každý požadavek na server je klientovi poslán jednou zprávou (po navázání zabezpečeného spojení) - v produkci data ukládány do externí databáze
7. Služba je dostupná přes zvolený port - třeba neprivilegovaný 8080 nebo 8000
8. Dá se horizontálně škálovat - aplikaci lze replikovat pro zajištění výkonu a stability
9. Rychle spustitelná - lze docílit použitím docker kontejnerů a image, která obsahuje jen ty nejdůležitější komponenty a knihovny k běhu
10. Vývojové a produkční prostředí jsou velmi podobné pro zajíštění reprodukovatelnosti
11. Aplikace vypisuje logy pro zjištění aktuálního stavu a fungování aplikace
12. Jednorázové úlohy (migrace databáze, zálohy) jsou prováděny odděleně od hlavní aplikace pomocí jiného kódu

## Hlavní části

### Bezstavovost (Statelessness)

- Seznam uložených zpráv je uložen v `messsages` dočasně v operační paměti
- Zprávy NEJSOU uloženy na disk pomocí PVC

### Proměnné prostředí (environment variables)

- používá soubor `.env`, který obsahuje potřebnou konfiguraci pro běh aplikace
- funkcionalitu zajištuje knihovna Pythonu `dotenv`
- načítá systémové proměnné prostředí `API_KEY` a `MESSAGE`

### REST API

Obsahuje následující HTTP metody:

| HTTP Metoda | Název Endpointu |         Popis          |
| ----------- | --------------- | ---------------------- |
|     GET     |     /health     | Health-check endpoint  |
|     GET     |     /metrics    | Prometheus mwtriky     |
|     GET     |     /message    | Získání zprávy z env   |
|     POST    |     /messages   | Vytvoření nové zprávy  |
|     GET     |     /message    | Výpis všech zpráv      |

### Metriky a monitoring

- Implementace Prometheus metrik
- Počítání HTTP požadavků

### Kontejnerizace

- Použitím Dockerfile pro vytvoření Docker Image

## Spuštění

```bash
# PRO MacOS
# Instalace nutných závislostí (dependencies) 
pipx install -r requirements.txt

# Spuštění serveru
uvicorn main:app --reload

# PRO Linux
pip install -r requirements.txt

# Spuštění serveru
uvicorn main:app --reload
```

