# devsecops-sre-challenge
Este repositorio contiene todos los archivos y análisis correspondiente a la solución del Challenge DevSecOps/SRE diseñado por LATAM Airlines.

## Contexto
Se requiere un sistema para ingestar y almacenar datos en una DB con la finalidad de hacer analítica avanzada. Posteriormente, los datos almacenados deben ser expuestos mediante una API HTTP para que puedan ser consumidos por terceros.

La solución propuesta en este repositorio será enfocada en el uso de servicios de AWS como Cloud provider.

## Parte 1:Infraestructura e IaC

### 1. Infraestructura necesaria para ingestar, almacenar y exponer datos

1. Base de datos: por simplicidad y reducción de costos, se propone una base de datos PostgreSQL instalada a partir de un Helm chart de Bitnami en un cluster de Kubernetes.

1. Esquema PubSub: esta implementación se puede realizar utilizando Kafka, por ejemplo, en el caso de AWS, utilizando MSK.

1. Microservicios en Kubernetes: se instalaron varios microservicios en el cluster de EKS. Una aplicación basada en NodeJS que permite interactuar con una base de datos a partir de información cargada en sus variables de entorno. Debido a simplicidad, en este caso se desplegó la base de datos dentro del mismo cluster de Kubernetes, de modo que el endpoint de comunicación corresponde al nombre del servicio de Kubernetes asociado de la base de datos.


### 2. Terraform IaC

El código de Terraform propuesto en este desafío despliega los siguientes recursos:
- VPC
    - Subnets privadas
    - Subnets públicas
- SecurityGroup
- Cluster de EKS
- Manifests de Kubernetes correspondientes al Deployment de la aplicación y Helm charts necesarios como parte del bootstrapping:
    - ArgoCD: herramienta de GitOps que permite el monitoreo constante de un repositorio de Git para el despliegue de objetos de Kubernetes de forma continua.
    - External Secrets Operator: operador de Kubernetes que permite la creación de Secrets de Kubernetes basados en datos que se guardan en algún proveedor como AWS Secrets Manager o Parameter Store.
    - AWS Load Balancer Controller: ingress controller seleccionado en esta ocasión para manejar la conexión hacia los servicios dentro del cluster mediante Ingress.
    - External DNS: permite automatizar la creación de registros DNS de Route53 según las reglas definidas en los Ingresses.
    - PostgreSQL: Helm chart correspondiente a base de datos Postgres basada en objetos de Kubernetes. Proveedor: Bitnami.

Se desarrollaron dos módulos con el fin de independizar lo mayor posible los distintos componentes de esta solución. Los recursos en el módulo de `kubernetes` corresponden a recursos que pueden ser creados a partir de `kubectl` y `helm`, los cuales requieren de un cluster de EKS ya funcional para poder ser corridos correctamente. Por esta razón, el módulo de `eks` corresponde a un wrapper alrededor de un módulo de EKS de AWS que permite simplificar su instalación.

En el directorio `terraform` se puede observar una estructura sobre los recursos de AWS que se mencionan anteriormente. Los módulos mencionados se encuentran en `terraform/modules/`.


## Parte 2: Aplicaciones y flujo CI/CD

Existe una distinción entre objetos desplegados y manejados por ArgoCD vs Terraform. Inicialmente los bootstrap resources requieren de menos cambios constantes pero una mayor automatización inicial de modo que los recursos funcionen inicialmente. Una vez se tiene esta base (bootstrap), el rol de ArgoCD es desplegar y administrar los recursos que le corresponden, como en este caso, los recursos observados en el directorio `charts/`. Cualquier nuevo recurso que se desee agregar al cluster se debe incluir dentro de este directorio.

Para el despliegue de la aplicación en AWS, se propone utilizar Terraform Cloud, tanto el API Gateway como la función Lambda son implementables mediante Terraform. Terraform Cloud facilita la conexión entre operaciones de Git y `terraform apply` de forma automática, ya sea a través de Pull Requests o Push directos a la rama.


## Parte 3: Pruebas de Integración y Puntos Críticos de Calidad

Se propone una implementación de unas pruebas de integración que corran una solicitud HTTP dummy a un record específico de la base de datos en una tabla para la cual el runner tendría mínimos permisos. Esto permitiría verificar que la totalidad de la aplicación está funcionando correctamente en caso de retornar los contenidos indicados adecuadamente.


## Parte 4: Métricas y Monitoreo

Se proponen las siguientes métricas: latencia, tiempo de respuesta de lectura y tiempo de respuesta de escritura en la base de datos. Este monitoreo se implementaría en una herramienta como Grafana, permite ser configurada para la obtención de CloudWatch Metrics que describen el estado de la aplicación y simplificar su disponibilidad. También es posible crear CloudWatch Dashboards como un primer acercamiento, pero es preferible una herramienta como Grafana. En caso de abordar un problema de escalabilidad, es necesario diseñar dashboards que permitan resumir toda la información relevante de forma simple, pero destacando particularmente sistemas outliers que se puedan encontrar en estado crítico.
