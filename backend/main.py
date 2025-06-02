from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import uvicorn
import cv2
import numpy as np
import base64
import io
from PIL import Image, ImageFilter, ImageDraw
import requests
import os
import uuid
import tempfile
from datetime import datetime
import face_recognition
from typing import List, Optional
import json

app = FastAPI(
    title="FaceFade AI Backend",
    description="AI-powered face detection, removal and avatar generation API",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Environment variables (add to .env file)
HUGGINGFACE_TOKEN = os.getenv("HUGGINGFACE_TOKEN", "")
REPLICATE_TOKEN = os.getenv("REPLICATE_TOKEN", "")

# Temporary storage directory
TEMP_DIR = "temp_files"
os.makedirs(TEMP_DIR, exist_ok=True)

def decode_base64_image(base64_string: str) -> np.ndarray:
    """Base64 stringi OpenCV image'e dönüştür"""
    try:
        # Base64 decode
        image_data = base64.b64decode(base64_string)
        # PIL Image'e dönüştür
        pil_image = Image.open(io.BytesIO(image_data))
        # RGB'ye dönüştür
        pil_image = pil_image.convert('RGB')
        # OpenCV formatına dönüştür
        opencv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
        return opencv_image
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid base64 image: {str(e)}")

def encode_image_to_base64(image: np.ndarray) -> str:
    """OpenCV image'i base64 stringe dönüştür"""
    try:
        # OpenCV'den PIL'e dönüştür
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        pil_image = Image.fromarray(image_rgb)
        
        # Base64'e encode et
        buffer = io.BytesIO()
        pil_image.save(buffer, format='JPEG', quality=95)
        img_str = base64.b64encode(buffer.getvalue()).decode()
        return img_str
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image encoding error: {str(e)}")

@app.get("/")
async def root():
    return {"message": "FaceFade AI Backend is running!", "version": "1.0.0"}

@app.post("/detect-face")
async def detect_faces(
    image: str = Form(..., description="Base64 encoded image")
):
    """
    Görseldeki yüzleri tespit eder
    Input: Base64 encoded image
    Output: Yüz sayısı ve koordinatları
    """
    try:
        # Base64'ten image'e dönüştür
        opencv_image = decode_base64_image(image)
        
        # face_recognition kullanarak yüz tespiti
        rgb_image = cv2.cvtColor(opencv_image, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_image, model="hog")
        face_encodings = face_recognition.face_encodings(rgb_image, face_locations)
        
        # Sonuçları formatla
        faces = []
        for i, (top, right, bottom, left) in enumerate(face_locations):
            faces.append({
                "id": i,
                "coordinates": {
                    "top": int(top),
                    "right": int(right),
                    "bottom": int(bottom),
                    "left": int(left)
                },
                "width": int(right - left),
                "height": int(bottom - top),
                "confidence": 0.95  # face_recognition varsayılan güven skoru
            })
        
        return {
            "success": True,
            "face_count": len(faces),
            "faces": faces,
            "image_dimensions": {
                "width": opencv_image.shape[1],
                "height": opencv_image.shape[0]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Face detection error: {str(e)}")

@app.post("/blur-face")
async def blur_face(
    image: str = Form(..., description="Base64 encoded image"),
    face_coordinates: str = Form(..., description="JSON string of face coordinates"),
    blur_intensity: int = Form(default=15, description="Blur intensity (5-50)")
):
    """
    Belirtilen yüzü bulanıklaştırır
    """
    try:
        # Parameters validation
        if blur_intensity < 5 or blur_intensity > 50:
            blur_intensity = 15
            
        # Base64'ten image'e dönüştür
        opencv_image = decode_base64_image(image)
        
        # Koordinatları parse et
        coords = json.loads(face_coordinates)
        top = coords["top"]
        right = coords["right"]
        bottom = coords["bottom"]
        left = coords["left"]
        
        # Yüz bölgesini extract et
        face_region = opencv_image[top:bottom, left:right]
        
        # Gaussian blur uygula
        blurred_face = cv2.GaussianBlur(face_region, (blur_intensity, blur_intensity), 0)
        
        # Blurred face'i orijinal image'e geri koy
        result_image = opencv_image.copy()
        result_image[top:bottom, left:right] = blurred_face
        
        # Base64'e encode et
        result_base64 = encode_image_to_base64(result_image)
        
        return {
            "success": True,
            "processed_image": result_base64,
            "processing_info": {
                "blur_intensity": blur_intensity,
                "face_coordinates": coords,
                "processed_at": datetime.now().isoformat()
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Face blur error: {str(e)}")

@app.post("/replace-with-avatar")
async def replace_with_avatar(
    image: str = Form(..., description="Base64 encoded image"),
    face_coordinates: str = Form(..., description="JSON string of face coordinates"),
    avatar_style: str = Form(default="cartoon", description="Avatar style: cartoon, anime, realistic, abstract")
):
    """
    Yüzü AI-generated avatar ile değiştirir
    """
    try:
        # Base64'ten image'e dönüştür
        opencv_image = decode_base64_image(image)
        
        # Koordinatları parse et
        coords = json.loads(face_coordinates)
        top = coords["top"]
        right = coords["right"]
        bottom = coords["bottom"]
        left = coords["left"]
        
        # Yüz bölgesinin boyutlarını al
        face_width = right - left
        face_height = bottom - top
        
        # Basit avatar generation (gerçek AI avatar için Stable Diffusion kullanılabilir)
        avatar_image = generate_simple_avatar(face_width, face_height, avatar_style)
        
        # Avatar'ı orijinal image'e yerleştir
        result_image = opencv_image.copy()
        result_image[top:bottom, left:right] = avatar_image
        
        # Base64'e encode et
        result_base64 = encode_image_to_base64(result_image)
        
        return {
            "success": True,
            "processed_image": result_base64,
            "processing_info": {
                "avatar_style": avatar_style,
                "face_coordinates": coords,
                "processed_at": datetime.now().isoformat()
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Avatar replacement error: {str(e)}")

def generate_simple_avatar(width: int, height: int, style: str) -> np.ndarray:
    """Basit avatar generation (demo amaçlı)"""
    # PIL ile basit geometrik avatar oluştur
    avatar = Image.new('RGB', (width, height), color='lightblue')
    draw = ImageDraw.Draw(avatar)
    
    if style == "cartoon":
        # Basit cartoon yüz
        draw.ellipse([width//4, height//4, 3*width//4, 3*height//4], fill='peachpuff', outline='black')
        # Gözler
        draw.ellipse([width//3, height//3, width//3 + width//8, height//3 + height//12], fill='black')
        draw.ellipse([2*width//3 - width//8, height//3, 2*width//3, height//3 + height//12], fill='black')
        # Ağız
        draw.arc([width//3, height//2, 2*width//3, 3*height//4], 0, 180, fill='red', width=3)
    elif style == "anime":
        # Anime tarzı yüz
        draw.ellipse([width//6, height//6, 5*width//6, 5*height//6], fill='wheat', outline='black')
        # Büyük gözler
        draw.ellipse([width//4, height//3, width//2, 2*height//3], fill='lightblue', outline='black')
        draw.ellipse([width//2, height//3, 3*width//4, 2*height//3], fill='lightblue', outline='black')
    else:
        # Abstract
        colors = ['red', 'blue', 'green', 'yellow', 'purple']
        for i in range(5):
            x = (i * width) // 5
            draw.rectangle([x, 0, x + width//5, height], fill=colors[i])
    
    # PIL'den OpenCV'ye dönüştür
    return cv2.cvtColor(np.array(avatar), cv2.COLOR_RGB2BGR)

@app.post("/artify-photo")
async def artify_photo(
    image: str = Form(..., description="Base64 encoded image"),
    art_style: str = Form(default="van_gogh", description="Art style: van_gogh, picasso, monet, glitch, vaporwave, sketch")
):
    """
    Fotoğrafı sanatsal stille dönüştürür
    """
    try:
        # Base64'ten image'e dönüştür
        opencv_image = decode_base64_image(image)
        
        # Art style'a göre filter uygula
        stylized_image = apply_art_style(opencv_image, art_style)
        
        # Base64'e encode et
        result_base64 = encode_image_to_base64(stylized_image)
        
        return {
            "success": True,
            "processed_image": result_base64,
            "processing_info": {
                "art_style": art_style,
                "processed_at": datetime.now().isoformat()
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Photo artify error: {str(e)}")

def apply_art_style(image: np.ndarray, style: str) -> np.ndarray:
    """Sanatsal stil filtrelerini uygular"""
    if style == "van_gogh":
        # Van Gogh tarzı (swirl effect + color enhancement)
        result = cv2.bilateralFilter(image, 15, 80, 80)
        result = cv2.addWeighted(result, 0.8, cv2.GaussianBlur(result, (15, 15), 0), 0.2, 0)
        
    elif style == "picasso":
        # Picasso tarzı (edge detection + color quantization)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        edges = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 7, 7)
        edges = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
        result = cv2.bitwise_and(image, edges)
        
    elif style == "monet":
        # Monet tarzı (soft, impressionist)
        result = cv2.bilateralFilter(image, 20, 200, 200)
        result = cv2.addWeighted(result, 0.7, cv2.GaussianBlur(result, (25, 25), 0), 0.3, 0)
        
    elif style == "glitch":
        # Glitch effect
        result = image.copy()
        h, w = result.shape[:2]
        for i in range(10):
            y = np.random.randint(0, h-20)
            shift = np.random.randint(-20, 20)
            result[y:y+10, :] = np.roll(result[y:y+10, :], shift, axis=1)
            
    elif style == "vaporwave":
        # Vaporwave effect (purple/pink tint)
        result = image.copy()
        result[:, :, 0] = np.clip(result[:, :, 0] * 1.2, 0, 255)  # Blue channel
        result[:, :, 2] = np.clip(result[:, :, 2] * 1.5, 0, 255)  # Red channel
        
    elif style == "sketch":
        # Pencil sketch effect
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        gray_blur = cv2.medianBlur(gray, 5)
        edges = cv2.adaptiveThreshold(gray_blur, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 7, 7)
        result = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
        
    else:
        result = image
        
    return result

@app.post("/batch-process")
async def batch_process_images(
    images: List[str] = Form(..., description="List of base64 encoded images"),
    operation: str = Form(..., description="Operation: detect, blur, artify"),
    parameters: str = Form(default="{}", description="JSON parameters for operation")
):
    """
    Birden fazla resmi toplu işleme tabi tutar
    """
    try:
        params = json.loads(parameters)
        results = []
        
        for i, image_b64 in enumerate(images):
            if operation == "detect":
                result = await detect_faces(image_b64)
            elif operation == "artify":
                art_style = params.get("art_style", "van_gogh")
                result = await artify_photo(image_b64, art_style)
            # Diğer operasyonlar...
            
            results.append({
                "image_index": i,
                "result": result
            })
        
        return {
            "success": True,
            "processed_count": len(results),
            "results": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch processing error: {str(e)}")

@app.get("/health")
async def health_check():
    """Backend sağlık kontrolü"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    ) 