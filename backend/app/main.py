from fastapi import FastAPI
from mangum import Mangum
import os

app = FastAPI(title="CreativeMarketplaceAPI_MVP")

# Example placeholder endpoint
@app.get("/api/products")
async def get_products():
    # In a real scenario, fetch from DynamoDB using boto3/aiobotocore
    return [
        {"id": "prod_1", "name": "API Artwork Print", "price": 50.00},
        {"id": "prod_2", "name": "API Handcrafted Mug", "price": 25.00},
    ]

@app.get("/api")
async def root():
    return {"message": "Welcome to the Backend API"}

# Mangum handler for AWS Lambda compatibility
handler = Mangum(app)

# --- To run locally for testing ---
# if __name__ == "__main__":
#    import uvicorn
#    uvicorn.run(app, host="0.0.0.0", port=8000)
