from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root() -> str:
  return "Hello, World!"
