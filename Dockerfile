# 1. Base Image: Usar una imagen oficial de NVIDIA con CUDA y cuDNN
#    Ajusta la versión de CUDA (e.g., 11.8.0, 12.1.1) si sabes que pyVideoTrans requiere una específica.
#    Ubuntu 22.04 es una base moderna y común. '-devel' incluye herramientas de compilación.
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# 2. Establecer variables de entorno para evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 3. Instalar dependencias del sistema operativo
#    - python3 y pip
#    - git (a veces necesario para instalar paquetes pip)
#    - ffmpeg (CRUCIAL para procesamiento de video/audio)
#    - build-essential, python3-dev (para compilar extensiones C de algunos paquetes Python)
#    - Otros paquetes que puedan ser necesarios (añadir según sea necesario)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    ffmpeg \
    build-essential \
    python3-dev \
    libegl1 \
    iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. Crear un directorio de trabajo dentro del contenedor
WORKDIR /app

# 5. Copiar el archivo de requerimientos PRIMERO para aprovechar el caché de Docker
#    ASUMO que el archivo se llama 'requirements.txt'. ¡Verifica esto en el repositorio!
#    Si tiene otro nombre (e.g., requirements_gpu.txt), cámbialo aquí.
COPY requirements.txt .

# 6. Instalar dependencias de Python
#    Actualizar pip y luego instalar desde requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir -r requirements.txt

# 7. Copiar el resto del código de la aplicación al directorio de trabajo
COPY . .
RUN mkdir -p /root/.cache/huggingface/hub

# 8. (Opcional) Crear un usuario no-root para ejecutar la aplicación (mejor seguridad)
# RUN useradd -m appuser && chown -R appuser:appuser /app
# USER appuser
# Si descomentas esto, asegúrate de que las carpetas de volumen (media, models) tengan permisos correctos.

# 9. Exponer el puerto que usa la aplicación web (asumiendo 8080)
EXPOSE 9011

# 10. Comando por defecto para ejecutar la aplicación
#     ASUMO que se inicia con 'python main.py'. ¡Verifica esto!
#     Podría ser app.py, run.py, o usar un gestor como gunicorn o uvicorn.
#     Ajusta ['python3', 'main.py'] según sea necesario.
CMD ["python3", "api.py"]