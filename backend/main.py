from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from rembg import remove, new_session
import uvicorn
import io

app = FastAPI()

# Allow CORS for frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For local dev; restrict in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize a high-accuracy session (BiRefNet)
# This uses the GPU via CUDAExecutionProvider as confirmed by the environment setup
session = new_session("birefnet-general")

@app.post("/remove")
async def remove_background(file: UploadFile = File(...)):
    contents = await file.read()
    # Use the pre-initialized high-accuracy session
    output_image = remove(contents, session=session)
    return Response(content=output_image, media_type="image/png")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
