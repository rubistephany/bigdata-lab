#!/bin/bash
# DataStream Corp - Flink Pipeline Deployment Script
# Resuelve el conflicto de UnsupportedClassVersionError forzando el entorno a JDK 17

echo "=== [DevOps] Iniciando Pipeline de Ingesta en Tiempo Real ==="

# Forzar al sistema a usar la ruta de Java 17 LTS compatible con Flink 1.19
export JAVA_HOME=/opt/java/openjdk
export PATH=$JAVA_HOME/bin:$PATH

echo "[INFO] Verificando entorno de ejecucion..."
java -version

echo "[INFO] Lanzando Job de Flink para procesamiento de transacciones bancarias..."
# Comando simulado para enviar el jar de procesamiento al cluster de Flink
flink run -d -c corp.datastream.pipeline.TransactionProcessor /app/flink-transaction-pipeline-1.0.jar --bootstrap.servers kafka:9092

if [ $? -eq 0 ]; then
    echo "=== [ÉXITO] Pipeline desplegado correctamente y procesando streams ==="
else
    echo "=== [ERROR] Fallo al levantar el pipeline de Flink ==="
    exit 1
fi
# Paso 5: Creacion del script de despliegue para Flink con compatibilidad JDK17
