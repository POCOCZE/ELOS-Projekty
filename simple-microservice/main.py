# Import potřebných knihoven
from fastapi import FastAPI, HTTPException # type: ignore
from prometheus_client import Counter, generate_latest
from dotenv import load_dotenv
import os

# Načíst proměnná prostředí - env
load_dotenv()

# Získání proměnné prostředí - env
# Popřípadě použití nastavené výchozích hodnot
API_KEY = os.getenv("API_KEY", "my-default-key123")
MESSAGE = os.getenv("MESSAGE", "Hello ELOS!")

app = FastAPI(title="Simple Microservice")

# Použití Prometheus metrik a počítání HTTP požadavků
requests_counter = Counter('http_requests_total', 'Total HTTP Requests')

# Dočasné ukládání zpráv v operační paměti
messages = []

@app.get("/health")
async def health_check():
  """"Health Check Endpoint"""
  return {"status": "Healthy"}

@app.get("/metrics")
async def metrics():
  """"Prometheus Metrics"""
  return generate_latest()

@app.get("/message")
async def get_message():
  """"Get Message From Env Variable"""
  return {"message": MESSAGE}

@app.get("/message")
async def create_message():
  """"Create New Message"""
  return {"status": "Success!", "message": text}

@app.get("/messages")
async def get_messages():
  """"Print All Messages"""
  return {"messages": messages}
