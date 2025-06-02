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
# import face_recognition  # Removed - requires dlib/CMake
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
        
        # OpenCV Haar Cascade ile yüz tespiti
        gray_image = cv2.cvtColor(opencv_image, cv2.COLOR_BGR2GRAY)
        
        # Haar cascade klasörü (OpenCV ile gelir)
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
        # Yüz tespiti
        face_rects = face_cascade.detectMultiScale(
            gray_image,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30)
        )
        
        # Sonuçları formatla
        faces = []
        for i, (x, y, w, h) in enumerate(face_rects):
            faces.append({
                "id": i,
                "coordinates": {
                    "top": int(y),
                    "right": int(x + w),
                    "bottom": int(y + h),
                    "left": int(x)
                },
                "width": int(w),
                "height": int(h),
                "confidence": 0.85  # Haar cascade için ortalama güven skoru
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

@app.post("/compare-faces")
async def compare_faces(
    reference_image: str = Form(..., description="Base64 encoded reference image of the person"),
    target_image: str = Form(..., description="Base64 encoded target image to search in"),
    threshold: float = Form(default=0.6, description="Similarity threshold (0.1-1.0)")
):
    """
    İki görsel arasında yüz karşılaştırması yapar
    Reference image'deki kişinin target image'de olup olmadığını kontrol eder
    """
    try:
        # Base64'ten image'e dönüştür
        ref_image = decode_base64_image(reference_image)
        target_img = decode_base64_image(target_image)
        
        # Reference image'den yüz çıkar
        gray_ref = cv2.cvtColor(ref_image, cv2.COLOR_BGR2GRAY)
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
        ref_faces = face_cascade.detectMultiScale(gray_ref, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
        
        if len(ref_faces) == 0:
            return {
                "success": False,
                "error": "No face found in reference image",
                "matches": []
            }
        
        # En büyük yüzü referans olarak al
        ref_face = max(ref_faces, key=lambda face: face[2] * face[3])
        ref_x, ref_y, ref_w, ref_h = ref_face
        ref_face_region = gray_ref[ref_y:ref_y+ref_h, ref_x:ref_x+ref_w]
        
        # Target image'de yüzleri bul
        gray_target = cv2.cvtColor(target_img, cv2.COLOR_BGR2GRAY)
        target_faces = face_cascade.detectMultiScale(gray_target, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
        
        matches = []
        
        for i, (x, y, w, h) in enumerate(target_faces):
            target_face_region = gray_target[y:y+h, x:x+w]
            
            # Template matching ile basit benzerlik hesapla
            # Önce boyutları eşitle
            ref_resized = cv2.resize(ref_face_region, (w, h))
            
            # Normalized correlation coefficient
            result = cv2.matchTemplate(target_face_region, ref_resized, cv2.TM_CCOEFF_NORMED)
            _, max_val, _, _ = cv2.minMaxLoc(result)
            
            similarity = float(max_val)
            
            if similarity >= threshold:
                matches.append({
                    "face_id": i,
                    "coordinates": {
                        "top": int(y),
                        "right": int(x + w),
                        "bottom": int(y + h),
                        "left": int(x)
                    },
                    "width": int(w),
                    "height": int(h),
                    "similarity": similarity,
                    "confidence": min(similarity * 1.2, 1.0)  # Confidence ayarlaması
                })
        
        return {
            "success": True,
            "reference_face_found": True,
            "target_faces_count": len(target_faces),
            "matches_count": len(matches),
            "matches": matches,
            "threshold_used": threshold
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Face comparison error: {str(e)}")

@app.post("/scan-gallery")
async def scan_gallery_for_person(
    reference_image: str = Form(..., description="Base64 encoded reference image of the person"),
    gallery_images: List[str] = Form(..., description="List of base64 encoded gallery images"),
    threshold: float = Form(default=0.6, description="Similarity threshold"),
    person_name: str = Form(default="Unknown", description="Name of the person being searched")
):
    """
    Galeriden gelen tüm fotoğraflarda belirli bir kişiyi arar
    """
    try:
        results = []
        total_matches = 0
        
        for idx, gallery_image in enumerate(gallery_images):
            try:
                # Her galeri fotoğrafı için yüz karşılaştırması yap
                comparison_result = await compare_faces(
                    reference_image=reference_image,
                    target_image=gallery_image,
                    threshold=threshold
                )
                
                if comparison_result["success"] and comparison_result["matches_count"] > 0:
                    total_matches += comparison_result["matches_count"]
                    results.append({
                        "image_index": idx,
                        "found": True,
                        "matches": comparison_result["matches"],
                        "matches_count": comparison_result["matches_count"]
                    })
                else:
                    results.append({
                        "image_index": idx,
                        "found": False,
                        "matches": [],
                        "matches_count": 0
                    })
                    
            except Exception as e:
                # Tek fotoğraf hata verirse diğerlerini etkilemesin
                results.append({
                    "image_index": idx,
                    "found": False,
                    "error": str(e),
                    "matches": [],
                    "matches_count": 0
                })
        
        return {
            "success": True,
            "person_name": person_name,
            "total_images_scanned": len(gallery_images),
            "total_matches_found": total_matches,
            "images_with_matches": len([r for r in results if r["found"]]),
            "threshold_used": threshold,
            "scan_results": results,
            "scan_completed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gallery scan error: {str(e)}")

@app.post("/process-matched-photos")
async def process_matched_photos(
    images_with_matches: List[str] = Form(..., description="List of base64 images that contain matches"),
    face_coordinates_list: List[str] = Form(..., description="List of JSON face coordinates for each image"),
    processing_type: str = Form(..., description="Processing type: blur, avatar, artistic"),
    processing_params: str = Form(default="{}", description="Additional processing parameters")
):
    """
    Eşleşen fotoğraflarda toplu işlem yapar (bulanıklaştırma, avatar, sanatsal dönüştürme)
    """
    try:
        params = json.loads(processing_params)
        processed_results = []
        
        for idx, (image, coords_json) in enumerate(zip(images_with_matches, face_coordinates_list)):
            try:
                coords = json.loads(coords_json)
                
                if processing_type == "blur":
                    result = await blur_face(
                        image=image,
                        face_coordinates=coords_json,
                        blur_intensity=params.get("blur_intensity", 15)
                    )
                elif processing_type == "avatar":
                    result = await replace_with_avatar(
                        image=image,
                        face_coordinates=coords_json,
                        avatar_style=params.get("avatar_style", "cartoon")
                    )
                elif processing_type == "artistic":
                    result = await artify_photo(
                        image=image,
                        art_style=params.get("art_style", "van_gogh")
                    )
                else:
                    raise ValueError(f"Unknown processing type: {processing_type}")
                
                processed_results.append({
                    "index": idx,
                    "success": result["success"],
                    "processed_image": result.get("processed_image"),
                    "processing_info": result.get("processing_info", {})
                })
                
            except Exception as e:
                processed_results.append({
                    "index": idx,
                    "success": False,
                    "error": str(e),
                    "processed_image": None
                })
        
        successful_count = len([r for r in processed_results if r["success"]])
        
        return {
            "success": True,
            "processing_type": processing_type,
            "total_images": len(images_with_matches),
            "successful_processing": successful_count,
            "failed_processing": len(images_with_matches) - successful_count,
            "results": processed_results,
            "processed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch processing error: {str(e)}")

@app.post("/count-people")
async def count_people_in_photo(
    image: str = Form(..., description="Base64 encoded image")
):
    """
    Fotoğrafta kaç kişi olduğunu tespit eder (akıllı silme için)
    """
    try:
        opencv_image = decode_base64_image(image)
        
        # OpenCV ile yüz tespiti
        gray_image = cv2.cvtColor(opencv_image, cv2.COLOR_BGR2GRAY)
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
        face_rects = face_cascade.detectMultiScale(
            gray_image,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30)
        )
        
        # Vücut tespiti de ekle (daha accurate)
        body_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_fullbody.xml')
        body_rects = body_cascade.detectMultiScale(gray_image, scaleFactor=1.1, minNeighbors=3)
        
        # Face ve body detection'ı birleştir
        total_people = max(len(face_rects), len(body_rects))
        
        faces = []
        for i, (x, y, w, h) in enumerate(face_rects):
            faces.append({
                "id": i,
                "type": "face",
                "coordinates": {
                    "top": int(y),
                    "right": int(x + w), 
                    "bottom": int(y + h),
                    "left": int(x)
                },
                "width": int(w),
                "height": int(h)
            })
        
        bodies = []
        for i, (x, y, w, h) in enumerate(body_rects):
            bodies.append({
                "id": i,
                "type": "body",
                "coordinates": {
                    "top": int(y),
                    "right": int(x + w),
                    "bottom": int(y + h), 
                    "left": int(x)
                },
                "width": int(w),
                "height": int(h)
            })
        
        # Akıllı silme önerisi
        suggestion = ""
        if total_people == 0:
            suggestion = "delete_photo"  # Kişi bulunamadı, fotoğraf silinebilir
        elif total_people == 1:
            suggestion = "delete_photo"  # Tek kişi var, fotoğraf silinebilir
        else:
            suggestion = "smart_remove"  # Birden fazla kişi, AI inpainting kullan
        
        return {
            "success": True,
            "total_people": total_people,
            "faces_detected": len(face_rects),
            "bodies_detected": len(body_rects),
            "faces": faces,
            "bodies": bodies,
            "smart_suggestion": suggestion,
            "processed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"People counting error: {str(e)}")

@app.post("/smart-remove-person")
async def smart_remove_person(
    image: str = Form(..., description="Base64 encoded image"),
    target_face_coordinates: str = Form(..., description="JSON coordinates of person to remove"),
    removal_method: str = Form(default="auto", description="auto, delete_photo, inpaint")
):
    """
    Akıllı kişi silme - tek kişiyse fotoğrafı sil, çoklu kişiyse AI inpainting
    """
    try:
        opencv_image = decode_base64_image(image)
        target_coords = json.loads(target_face_coordinates)
        
        # Önce kaç kişi olduğunu tespit et
        people_count_result = await count_people_in_photo(image)
        total_people = people_count_result["total_people"]
        
        result = {
            "success": True,
            "total_people_detected": total_people,
            "removal_method_used": "",
            "processed_image": None,
            "should_delete_photo": False,
            "processing_info": {
                "target_coordinates": target_coords,
                "processed_at": datetime.now().isoformat()
            }
        }
        
        if removal_method == "auto":
            if total_people <= 1:
                removal_method = "delete_photo"
            else:
                removal_method = "inpaint"
        
        if removal_method == "delete_photo":
            # Fotoğraf tamamen silinecek (frontend'te handle edilir)
            result["removal_method_used"] = "delete_photo"
            result["should_delete_photo"] = True
            result["message"] = "Fotoğrafta sadece hedef kişi var. Fotoğraf tamamen silinecek."
            
        elif removal_method == "inpaint":
            # AI inpainting ile kişiyi çıkar
            result["removal_method_used"] = "inpaint"
            inpainted_image = apply_advanced_inpainting(opencv_image, target_coords)
            result["processed_image"] = encode_image_to_base64(inpainted_image)
            result["message"] = "Hedef kişi fotoğraftan AI ile çıkarıldı. Diğer kişiler korundu."
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Smart removal error: {str(e)}")

def apply_advanced_inpainting(image: np.ndarray, target_coords: dict) -> np.ndarray:
    """
    Gelişmiş AI inpainting - kişiyi çıkarıp arka planı gerçekçi şekilde doldur
    """
    try:
        # Target koordinatları al
        top = target_coords["top"]
        bottom = target_coords["bottom"] 
        left = target_coords["left"]
        right = target_coords["right"]
        
        # Güvenlik için koordinatları kontrol et
        h, w = image.shape[:2]
        top = max(0, min(top, h))
        bottom = max(0, min(bottom, h))
        left = max(0, min(left, w))
        right = max(0, min(right, w))
        
        # Mask oluştur (silinecek alan)
        mask = np.zeros((h, w), dtype=np.uint8)
        
        # Yüz alanını biraz genişlet (daha iyi inpainting için)
        margin = 20
        top_expanded = max(0, top - margin)
        bottom_expanded = min(h, bottom + margin)
        left_expanded = max(0, left - margin)
        right_expanded = min(w, right + margin)
        
        # Circular mask (daha doğal görünüm için)
        center_x = (left_expanded + right_expanded) // 2
        center_y = (top_expanded + bottom_expanded) // 2
        radius = max((right_expanded - left_expanded) // 2, (bottom_expanded - top_expanded) // 2)
        
        cv2.circle(mask, (center_x, center_y), radius, 255, -1)
        
        # OpenCV TELEA inpainting algoritması kullan
        inpainted = cv2.inpaint(image, mask, inpaintRadius=3, flags=cv2.INPAINT_TELEA)
        
        # Daha gelişmiş inpainting için NS (Navier-Stokes) de dene
        inpainted_ns = cv2.inpaint(image, mask, inpaintRadius=3, flags=cv2.INPAINT_NS)
        
        # İki sonucu blend et (daha iyi sonuç için)
        alpha = 0.7
        final_result = cv2.addWeighted(inpainted, alpha, inpainted_ns, 1-alpha, 0)
        
        return final_result
        
    except Exception as e:
        print(f"Inpainting error: {e}")
        # Fallback: basit blur ile doldur
        result = image.copy()
        
        # Gaussian blur ile basit inpainting
        top = target_coords["top"]
        bottom = target_coords["bottom"]
        left = target_coords["left"] 
        right = target_coords["right"]
        
        # Çevredeki alanın rengini al ve blend et
        if top > 0 and bottom < image.shape[0] and left > 0 and right < image.shape[1]:
            # Çevredeki piksellerin ortalamasını al
            surroundings = []
            if top > 10:
                surroundings.append(image[top-10:top, left:right])
            if bottom < image.shape[0] - 10:
                surroundings.append(image[bottom:bottom+10, left:right])
            if left > 10:
                surroundings.append(image[top:bottom, left-10:left])
            if right < image.shape[1] - 10:
                surroundings.append(image[top:bottom, right:right+10])
            
            if surroundings:
                # Ortalama rengi hesapla
                avg_color = np.mean([np.mean(s, axis=(0,1)) for s in surroundings], axis=0)
                
                # Gaussian noise ekle (daha doğal görünüm)
                noise = np.random.normal(0, 15, (bottom-top, right-left, 3))
                fill_color = np.clip(avg_color + noise, 0, 255).astype(np.uint8)
                
                result[top:bottom, left:right] = fill_color
        
        return result

@app.post("/closure-ceremony")
async def perform_closure_ceremony(
    images: List[str] = Form(..., description="List of base64 images containing the person"),
    person_name: str = Form(..., description="Name of the person for emotional context"),
    art_style: str = Form(default="van_gogh", description="Art style for transformation"),
    ceremony_type: str = Form(default="artistic", description="Type: artistic, dreamy, abstract, healing")
):
    """
    Kapanış Seremonisi - Anıları sanat eserine dönüştürerek duygusal iyileşme
    """
    try:
        processed_images = []
        ceremony_messages = []
        
        # Seremoni türüne göre mesajlar
        ceremony_messages_map = {
            "artistic": [
                f"{person_name} ile olan anıların artık güzel birer sanat eseri oldu. 🎨",
                "Acı veren anılar, güzel tablolara dönüştü. İyileşme başladı. ✨",
                "Geçmiş artık bir müze gibi - güzel ama dokunulmaz. 🏛️"
            ],
            "dreamy": [
                f"{person_name} ile olan anıların rüya gibi, yumuşak bir hale geldi. ☁️",
                "Keskin kenarlar yumuşadı, acı azaldı. 💫",
                "Anılar artık bir rüya gibi - uzak ama güzel. 🌙"
            ],
            "abstract": [
                f"{person_name} ile olan bağların artık soyut bir sanat eseri. 🎭",
                "Gerçeklik dönüştü, yeni bir form aldı. 🌈",
                "Anılar artık yoruma açık, özgün bir eser. 🎪"
            ],
            "healing": [
                f"{person_name} ile olan anıların iyileştirici bir enerji taşıyor. 💚",
                "Her fotoğraf bir şifa hikayesi oldu. 🌿",
                "Kapanış tamamlandı, yeni bir başlangıç. 🌱"
            ]
        }
        
        for i, image_b64 in enumerate(images):
            try:
                # Her fotoğrafa özel sanatsal dönüşüm
                if ceremony_type == "artistic":
                    result = await artify_photo(image_b64, art_style)
                elif ceremony_type == "dreamy":
                    # Dreamy effect - soft blur + pastel colors
                    opencv_image = decode_base64_image(image_b64)
                    dreamy_image = apply_dreamy_effect(opencv_image)
                    result = {
                        "success": True,
                        "processed_image": encode_image_to_base64(dreamy_image)
                    }
                elif ceremony_type == "abstract":
                    # Abstract effect - geometrical transformation
                    opencv_image = decode_base64_image(image_b64)
                    abstract_image = apply_abstract_effect(opencv_image)
                    result = {
                        "success": True,
                        "processed_image": encode_image_to_base64(abstract_image)
                    }
                elif ceremony_type == "healing":
                    # Healing effect - warm colors + soft glow
                    opencv_image = decode_base64_image(image_b64)
                    healing_image = apply_healing_effect(opencv_image)
                    result = {
                        "success": True,
                        "processed_image": encode_image_to_base64(healing_image)
                    }
                
                if result["success"]:
                    processed_images.append({
                        "index": i,
                        "original_image": image_b64,
                        "transformed_image": result["processed_image"],
                        "transformation_type": ceremony_type
                    })
                    
            except Exception as e:
                print(f"Error processing image {i}: {e}")
                continue
        
        # Rastgele iyileştirici mesaj seç
        messages = ceremony_messages_map.get(ceremony_type, ceremony_messages_map["artistic"])
        selected_message = messages[len(processed_images) % len(messages)]
        
        return {
            "success": True,
            "ceremony_type": ceremony_type,
            "person_name": person_name,
            "total_images_processed": len(processed_images),
            "processed_images": processed_images,
            "ceremony_message": selected_message,
            "emotional_guidance": f"Kapanış seremonin tamamlandı. {person_name} ile olan anıların artık güzel birer eser. İyileşme yolculuğun başladı. 💙",
            "ceremony_completed_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Closure ceremony error: {str(e)}")

def apply_dreamy_effect(image: np.ndarray) -> np.ndarray:
    """Dreamy/rüya gibi efekt uygula"""
    # Soft blur
    dreamy = cv2.GaussianBlur(image, (15, 15), 0)
    
    # Pastel renk dönüşümü
    dreamy = cv2.addWeighted(image, 0.4, dreamy, 0.6, 0)
    
    # Brightness ve contrast ayarı
    dreamy = cv2.convertScaleAbs(dreamy, alpha=1.1, beta=20)
    
    # Warm tone ekleme
    dreamy[:, :, 0] = np.clip(dreamy[:, :, 0] * 0.9, 0, 255)  # Blue azalt
    dreamy[:, :, 2] = np.clip(dreamy[:, :, 2] * 1.1, 0, 255)  # Red artır
    
    return dreamy

def apply_abstract_effect(image: np.ndarray) -> np.ndarray:
    """Abstract/soyut efekt uygula"""
    # Color quantization
    data = image.reshape((-1, 3))
    data = np.float32(data)
    
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 4, 1.0)
    _, labels, centers = cv2.kmeans(data, 8, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)
    
    centers = np.uint8(centers)
    abstract = centers[labels.flatten()]
    abstract = abstract.reshape(image.shape)
    
    # Edge detection overlay
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)
    edges = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
    
    # Combine
    abstract = cv2.addWeighted(abstract, 0.8, edges, 0.2, 0)
    
    return abstract

def apply_healing_effect(image: np.ndarray) -> np.ndarray:
    """Healing/iyileştirici efekt uygula"""
    # Warm color tone
    healing = image.copy()
    
    # Soft glow effect
    glow = cv2.GaussianBlur(healing, (35, 35), 0)
    healing = cv2.addWeighted(healing, 0.7, glow, 0.3, 0)
    
    # Green-blue healing tones
    healing[:, :, 1] = np.clip(healing[:, :, 1] * 1.15, 0, 255)  # Green artır
    healing[:, :, 0] = np.clip(healing[:, :, 0] * 1.05, 0, 255)  # Blue biraz artır
    
    # Contrast yumuşat
    healing = cv2.convertScaleAbs(healing, alpha=0.9, beta=15)
    
    return healing

if __name__ == "__main__":
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    ) 