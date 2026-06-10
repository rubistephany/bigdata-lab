# DataStream Corp - Plataforma de Transacciones en Tiempo Real

Este repositorio contiene la solución e infraestructura crítica para la plataforma de procesamiento de transacciones financieras de **DataStream Corp**. El sistema ha sido auditado, corregido y estabilizado siguiendo los más altos estándares de seguridad, persistencia de datos y compatibilidad de entornos en arquitecturas Big Data.

---

## 1. Contexto del Proyecto
DataStream Corp opera un sistema de ingesta y análisis de transacciones bancarias en tiempo real. Recientemente, la infraestructura sufrió una serie de incidentes críticos en producción:
* **Pérdida de datos:** Los datos históricos almacenados en el sistema de archivos distribuido (HDFS) desaparecían cada vez que los Pods de Kubernetes se reiniciaban.
* **Vulnerabilidades de seguridad:** El contenedor principal de procesamiento se ejecutaba con privilegios de Administrador (`root`), exponiendo el servidor anfitrión.
* **Colapso del Pipeline:** El motor de ingesta en tiempo real (Apache Flink) fallaba intermitentemente debido a un error de incompatibilidad de versiones de Java (`UnsupportedClassVersionError`).
* **Operación a ciegas:** Falta de visibilidad y monitoreo sobre el estado de salud de los clústeres de Spark y Flink.

---

## 2. Objetivos del Laboratorio
1. **Garantizar la Persistencia:** Implementar un sistema de almacenamiento desacoplado del ciclo de vida de los contenedores mediante volúmenes permanentes.
2. **Mitigar Riesgos de Seguridad:** Configurar el principio de menor privilegio en las imágenes de contenedor eliminando el uso de usuarios raíz.
3. **Asegurar la Compatibilidad de Entornos:** Estandarizar las runtimes de ejecución a versiones LTS (Soporte a Largo Plazo) compatibles entre todos los componentes del ecosistema.
4. **Implementar Observabilidad:** Configurar un sistema centralizado de recolección de métricas para adelantarse a fallos de infraestructura.

---

## 3. Stack Tecnológico
La arquitectura se fundamenta en las siguientes herramientas de vanguardia para el ecosistema Big Data:

| Tecnología | Componente / Rol | Versión Seleccionada |
| :--- | :--- | :--- |
| **Docker & Docker Compose** | Contenerización y orquestación local del entorno multi-nodo. | Estandarizado con sintaxis v3.8 |
| **Eclipse Temurin (Java)** | Runtime de ejecución base segura y ligera. | 17-jre-jammy (LTS Fija) |
| **Apache Spark** | Motor de procesamiento analítico distribuido de datos históricos. | 3.5.0 (Hadoop 3.4.0) |
| **Apache Flink** | Motor de procesamiento de flujos (Streams) continuo en tiempo real. | 1.19 (LTS) |
| **Kubernetes** | Orquestador de infraestructura y gestión de recursos (PV, PVC, ConfigMaps). | v1.28+ (API v1) |
| **Prometheus** | Base de datos de series temporales para monitoreo y alertas. | Versión de producción |

---

## 4. Arquitectura General
El flujo de datos de la plataforma se divide en dos capas principales:
* **Capa de Ingesta (Tiempo Real):** Las transacciones bancarias entran al sistema a través de streams de datos distribuidos que son procesados de inmediato por el Pipeline de Apache Flink, gobernado bajo el entorno compatible de Java 17 para evitar colapsos de clases.
* **Capa de Almacenamiento y Cómputo (Batch):** Los datos se escriben de manera persistente en un sistema de archivos HDFS respaldado por un `PersistentVolumeClaim` en Kubernetes de 50GB. Apache Spark se conecta de forma segura como usuario no-root (`sparkuser 1001`) para realizar auditorías analíticas sin arriesgar la integridad del clúster.

---

## 5. Estructura del Proyecto
A continuación se detalla la distribución del repositorio, organizada de acuerdo a los pasos de resolución del incidente:

```text
mi-big-data/
├── Dockerfile                  # Imagen base optimizada con Java 17 y usuario 1001 (Paso 3)
├── pv-hdfs.yaml                # Manifiesto de Almacenamiento Persistente (PV y PVC de 50GB) (Paso 4)
├── configmap-spark.yaml        # Configuración inyectada para logs internos de Spark (Paso 4)
├── deploy-flink.sh             # Script Bash para inicializar el pipeline de tiempo real (Paso 5)
├── prometheus.yaml             # Configuración y targets del sistema de monitoreo (Paso 6)
├── docker-compose.yml          # Orquestador nativo de la arquitectura local
├── master-service.yaml         # Definición de red y servicios de Kubernetes
├── spark-deployment.yaml       # Despliegue del controlador máster de analítica
└── spark-master.yaml           # Configuración del nodo maestro de Spark

