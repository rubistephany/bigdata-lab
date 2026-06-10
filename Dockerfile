# Dockerfile CORREGIDO - DataStream Corp
# Base estable con versión LTS fija (Java 17) para evitar cambios imprevistos
FROM eclipse-temurin:17-jre-jammy

# Variables de entorno optimizadas y fijas
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3.4.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Preparación del sistema instalando solo herramientas necesarias y limpiando caché
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Descarga e instalación limpia de Apache Spark distribuido
RUN curl -L "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" | tar -xz -C /opt \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME}

# Instalación de librerías de Python fijando versiones estables para evitar conflictos
RUN pip3 install --no-cache-dir \
    pyspark==3.5.0 \
    pandas==2.2.2 \
    numpy==1.26.4

# SEGURIDAD CRÍTICA: Crear usuario sparkuser (ID 1001) para no correr como Root
RUN useradd -r -u 1001 -g root sparkuser

# Corrección de permisos para evitar fallos de "Acceso Denegado" al escribir temporales
RUN mkdir -p /opt/spark/work && chown -R 1001:root /opt/spark/work

# Establecer directorio de la aplicación y cambiar a usuario no-root
WORKDIR /app
COPY --chown=1001:root . .

USER 1001

EXPOSE 4040 8080

# Comando final de ejecución para levantar el Worker de Spark
CMD ["spark-class", "org.apache.spark.deploy.worker.Worker", "spark://spark-master:7077"]
# Paso 3: Correccion del Dockerfile con pautas de seguridad y versiones LTS
