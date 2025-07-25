import requests
import json

api_url = "http://localhost:9011"

# Ejemplo: Obtener estado de una tarea inexistente
try:
    response = requests.post(f"{api_url}/task_status", json={"task_id": "test1234"})
    response.raise_for_status() # Lanza un error si la respuesta es 4xx o 5xx
    print("Respuesta de /task_status:")
    print(response.json())
except requests.exceptions.RequestException as e:
    print(f"Error al conectar con la API: {e}")

# Ejemplo: Intentar iniciar una tarea TTS (fallará porque el archivo no existe DENTRO del contenedor)
# ¡OJO! La ruta 'C:/ruta/local/...' NO funcionará. Debes usar rutas relativas a '/app/' dentro del contenedor.
# Por ejemplo, si pones 'video.srt' en tu carpeta 'media' local, la ruta DENTRO del contenedor sería '/app/media/video.srt'
# Este ejemplo probablemente dará error, pero ilustra cómo llamar a otro endpoint.
try:
    tts_payload = {
        "name": "/app/media/no_existe.srt", # Ruta DENTRO del contenedor
        "voice_role": "zh-CN-YunjianNeural", # Ejemplo, ajusta según necesites
        "target_language_code": "zh-cn",
        "tts_type": 0 # 0 para Edge-TTS
    }
    response = requests.post(f"{api_url}/tts", json=tts_payload)
    response.raise_for_status()
    print("\nRespuesta de /tts:")
    print(response.json())
except requests.exceptions.RequestException as e:
    print(f"\nError al llamar a /tts: {e}")
    if e.response is not None:
        try:
            print("Detalle del error:", e.response.json())
        except json.JSONDecodeError:
            print("Respuesta no es JSON:", e.response.text)