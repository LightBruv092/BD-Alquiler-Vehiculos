# Proyecto: Plataforma de Alquiler y Gestión de Vehículos

**Asignatura:** Bases de Datos I

---

##  Integrantes del equipo
 
| # | Nombre completo | Código | Usuario de GitHub | Correo |
|---|---|---|---|---|
| 1 | _Juan Jose Vargas Campuzano_ | 2251299 | Juan-var-camp | vargascampuzanojuanjose@gmail.com |
| 2 | _Juan Camilo Arrieta Méndez_ | 2251966 | ElJuank9  | jcarrieta0921@gmail.com |
| 3 | _David Santiago Lizarazo García_ | 2250146 | LightBruv092 | davidlizarazof@gmail.com |
| 4 | _Cristian Armando Aguilar Giraldo_ | 2242854 | SrLoon | crisagi088@gmail.com |
| 5 | _Juan Jose Parra Viviescas_ | 2231056 | Scireh | scjuanjop@gmail.com |

## 1. Descripción del Proyecto

Sistema de base de datos para una plataforma digital que gestione el alquiler de vehículos, permitiendo reservas completamente digitales, seguimiento en tiempo real y servicios adicionales integrados.


## 2. Objetivos Principales

- Automatizar el proceso de reserva y alquiler de vehículos
- Proporcionar disponibilidad en tiempo real
- Facilitar la gestión de flota vehicular
- Implementar seguimiento GPS y telemetría
- Ofrecer múltiples opciones de pago
- Mejorar la experiencia del usuario mediante una plataforma digital moderna


## 3. Conceptos importantes y relevantes de la temática

### 3.1 Conceptos del negocio de alquiler de vehículos

| Concepto | Qué es (en palabras simples) | Por qué importa para la base de datos |
|---|---|---|
| **Flota** | Conjunto de vehículos que la empresa tiene disponibles para alquilar. | Cada vehículo es un registro con identificador único (placa), estado y sede actual. |
| **Categoría / gama de vehículo** | Agrupación comercial (económico, SUV, camioneta 7 pasajeros, van, moto…). El cliente reserva una *categoría*, no un carro específico. Localiza, por ejemplo, aclara que la reserva garantiza uno de los modelos listados "o similar", sujeto a disponibilidad de la agenc. | Separar **Categoría** de **Vehículo** evita un error muy común: modelar la reserva contra un carro concreto antes de que exista la entrega. |
| **Sede / agencia** | Punto físico de recogida y devolución (aeropuertos, ciudades). | Toda reserva tiene sede de recogida y de devolución, que pueden ser distintas. |
| **Devolución en otra ciudad (*one-way*)** | El cliente recoge en una ciudad y devuelve en otra. Algunas rentadoras colombianas cobran un recargo por kilómetro entre ciudades. | Se necesita una relación entre pares de sedes (matriz de tasas de retorno). |
| **Tarifa dinámica y por temporada** | El precio cambia según ciudad, fecha, gama y número de días; Localiza indica en su FAQ que opera con tarifa dinámica atada a esas variables. | La tarifa no es un atributo fijo del vehículo: es una entidad con vigencia (fecha inicio/fin), categoría y ciudad. |
| **Tipos de cliente** | Ocasional, frecuente, corporativo. En alquileres a persona jurídica, el contrato de Localiza distingue entre *arrendatario* (la empresa o aseguradora) y *usuario* (la persona natural autorizada para retirar el vehículo y firmar). | Persona natural y empresa comparten datos pero también tienen diferencias: sugiere una **generalización** o una relación cliente–empresa. |
| **Conductor adicional** | Persona autorizada a conducir, que debe inscribirse en el contrato y pagar un cargo. Los valores varían entre rentadoras (p. ej., COP 10.472/día en una y COP 12.000/día en otra; son datos de referencia, que pueden cambiar con el tiempo). | Relación N:M entre contrato y conductor, con atributos propios (cargo diario). |
| **Membresías y programas de fidelidad** | Niveles con beneficios según uso. Localiza Fidelidad: categoría inicial *Verde*, *Gold* con mínimo 3.000 puntos categorizables en 12 meses y *Platinum* con 5.000; los beneficios (días gratis, conductor adicional gratis, tolerancia de horas al regreso, puntos bono) varían según país, categoría y tipo de contrato. | Entidades: Membresía/Nivel, Puntos (movimientos), Beneficios; y regla de recálculo anual. |
| **Reserva vs. contrato** | La reserva es la intención (con fechas y categoría); el contrato se abre cuando el cliente retira el vehículo. | Son entidades distintas, con ciclos de vida distintos. |
| **Seguros y coberturas** | Cada rentadora incluye protecciones básicas (daños, hurto, responsabilidad civil) y ofrece adicionales. | Entidad Cobertura/Seguro y su asociación a contratos. |
| **Garantía / depósito (pre-autorización)** | Bloqueo de cupo en tarjeta de crédito, generalmente a nombre del conductor principal; no es un cobro sino una retención. Alamo, por ejemplo, exige tarjeta de crédito y no acepta débito ni efectivo para la garantía; Localiza acepta solo ciertas franquicias y puede cobrar automáticamente a la tarjeta registrada si el pago no se hace a tiempo. | Modelar la garantía **separada del pago**: tiene estados (retenida, liberada, cobrada parcialmente). |
| **Inspección y estado del vehículo** | Registro del estado (daños, combustible, kilometraje) al entregar y al recibir. | Entidad Inspección (dos por contrato: entrega y devolución) con detalle de daños. |
| **Mantenimiento** | Servicios programados y correctivos que sacan al vehículo temporalmente de la disponibilidad. | Afecta la consulta de disponibilidad. |
| **Pagos y facturación** | Cobros de alquiler, adicionales, penalizaciones; emisión de factura. | Separar Pago de Factura; un contrato puede tener varios pagos. |
| **Penalizaciones, cancelaciones y multas de tránsito** | Cargos por devolución tardía, cancelación fuera de plazo, comparendos. Localiza tiene secciones específicas de FAQ para multas de tránsito, pico y placa, accidentes y hurto. | Entidades Penalización/Cargo adicional y Multa asociadas al contrato. |
| **Requisitos del conductor** | Documento de identidad, licencia vigente, edad mínima, tarjeta de crédito. La edad mínima **varía por empresa**: una rentadora indica 18 años sin costo extra, mientras un comparador señala que la mayoría exige 21. | La edad mínima y el cargo por conductor joven son **reglas parametrizables**, no constantes en el código. |

### 3.2 Ciclo de vida de un alquiler

```mermaid
flowchart LR
    A[Búsqueda de disponibilidad] --> B[Reserva]
    B --> C[Contrato y entrega<br/>+ inspección inicial<br/>+ garantía]
    C --> D[Uso del vehículo]
    D --> E[Devolución<br/>+ inspección final]
    E --> F[Cierre: cobros,<br/>penalizaciones, factura,<br/>liberación de garantía]
    B -. cancelación .-> G[Cancelada]
```

### 3.3 Conceptos de bases de datos aplicables

| Concepto BD | Aplicación en el proyecto |
|---|---|
| **Integridad de entidad** | Toda tabla tiene llave primaria única y no nula (p. ej., placa o un identificador sustituto para el vehículo). |
| **Integridad referencial** | Una reserva no puede apuntar a una sede o categoría inexistente; se garantiza con llaves foráneas. |
| **Integridad de dominio** | Restricciones `CHECK` (fecha de devolución posterior a la de recogida, tarifas positivas, estados válidos). |
| **Reglas de negocio en el esquema** | Cuando es posible, se codifican como restricciones (`CHECK`, `UNIQUE`) o triggers, en vez de depender solo de la aplicación. |
| **Transacciones (ACID)** | Crear una reserva implica varios pasos (verificar disponibilidad, insertar reserva, registrar pago/garantía). Deben ocurrir completos o no ocurrir. |
| **Concurrencia en reservas** | Dos clientes podrían reservar el último vehículo al mismo tiempo (*doble reserva*). Se resuelve con niveles de aislamiento, bloqueos (`SELECT … FOR UPDATE`) o, en PostgreSQL, con restricciones de exclusión sobre rangos de fechas. |
| **Disponibilidad como dato derivado** | La disponibilidad no debería guardarse como una columna que se actualiza a mano: se **calcula** a partir de reservas, contratos y mantenimientos que se solapan con el rango consultado. |
| **Histórico y auditoría** | Los precios, tarifas y condiciones de un contrato deben quedar "congelados" al momento de reserva, porque la tarifa cambia después. |
| **Normalización** | Evitar redundancia y anomalías . |
| **Índices** | Consultas frecuentes por ciudad, fechas y categoría requerirán índices. |



## 4. Tendencias actuales

Cada tendencia incluye la evidencia encontrada, su nivel de confianza y su **implicación para el diseño de la base de datos**.

### 4.1 Crecimiento del mercado y digitalización (Colombia)

- El artículo de El Carro Colombiano (octubre de 2025) reporta que, tras caídas de hasta 75 % durante la pandemia, el sector se ubicaría en 2025 entre 20 % y 30 % por encima de los niveles previos a 2019, impulsado por turismo, alquiler corporativo y movilidad flexible. También señala que las plataformas digitales permiten comparar precios, gestionar reservas y personalizar la experiencia. *(Confianza media; son estimaciones periodísticas.)*
- Ese mismo artículo, citando un análisis de Alkilautos (que integra 35 rentadoras), estima participaciones aproximadas: Localiza entre 45 % y 55 %, Equirent entre 15 % y 20 %, Enterprise Mobility cerca de 10 %, un grupo de rentadoras locales entre 10 % y 15 %, y Europcar/Sixt alrededor de 5 %.
- **Implicación:** el sistema debe soportar múltiples canales de reserva (web, app, comparadores) y varios operadores/sedes; conviene guardar el **canal de origen** de cada reserva.

### 4.2 Precios dinámicos y gestión de ingresos (*revenue management*)

- Localiza confirma el uso de tarifa dinámica en Colombia.
- Blogs de proveedores de software describen motores de precios que combinan demanda, ocupación de flota, estacionalidad, eventos, anticipación de la reserva y precios de la competencia, y varios prometen aumentos de ingresos del 5 % al 35 %. *(Confianza baja: son fuentes con interés comercial; no usar esas cifras como evidencia.)*
- **Implicación:** modelar tarifas con **vigencia, categoría, ciudad y reglas** (temporada, duración, anticipación) y conservar el histórico. Para el proyecto basta con tarifas por temporada y por tipo de cliente; un motor de IA queda como mejora futura.

### 4.3 Vehículos eléctricos e híbridos

- Un artículo de Semana (julio de 2026), citando registros de ANDI y Fenalco, reporta 157.620 vehículos matriculados, un 50,1 % más que en el mismo periodo de 2025, con especial impacto de eléctricos e híbridos . Renting Colombia, por su parte, indica que el mercado automotor creció 49,5 % en los primeros cuatro meses de 2026, impulsado en gran parte por eléctricos y nuevas marcas chinas. *(Los periodos y cifras no coinciden exactamente entre ambas fuentes; se citan como orden de magnitud.)*
- Renting Colombia ha ampliado su flota eléctrica (720 vehículos eléctricos en 2023 más 1.400 cuadriciclos en alianza con Muverang, que ofrece también motos, bicicletas y patinetas eléctricas) . Además, esa empresa menciona la Ley 1964 de 2019 como incentivo a los vehículos eléctricos.
- **Implicación:** el vehículo necesita atributos de **tipo de combustible/energía**, capacidad de batería o autonomía (opcionales) y, en el futuro, registro de **cargas**. Además, refuerza la necesidad de manejar **motos y vehículos ligeros** como tipos distintos de vehículo.

### 4.4 Apertura digital (*keyless*) y telemática/IoT

- Avis piloteó en 2017, junto con Continental, el bloqueo, desbloqueo y arranque del carro desde el celular. Turo introdujo en 2018 un dispositivo para monitoreo GPS y desbloqueo remoto, y en 2019 anunció *Turo Go Digital* para entrada sin llave sin dispositivo instalado. Un proveedor de telemática explica que este tipo de sistemas permite automatizar la entrega sin depender del horario de la sede.
- Una revisión de tendencias de IA en alquiler (marzo de 2026) menciona telemetría de flota (ubicación, kilometraje, batería o combustible, códigos de falla) como base para saber qué vehículos están listos y dónde están. *(Confianza baja-media: es un compendio no académico.)*
- **Implicación:** aunque nuestro proyecto no implementará IoT, conviene dejar previsto (como mejora) un registro de **eventos/lecturas del vehículo** (kilometraje, nivel de combustible/batería) al menos en las inspecciones.

### 4.5 Suscripciones y renting frente al alquiler tradicional

- Localiza ofrece en su ecosistema *Localiza Meoo* (auto nuevo por suscripción "con todo incluido") y *Localiza Zarp* (planes para conductores de aplicaciones) . En Colombia, Localiza Rent a Car cubre alquiler desde 1 día hasta 12 meses y Renting Colombia ofrece renta desde 36 meses . Enterprise también lista en su sitio colombiano opciones como alquileres de largo plazo, solo de ida y suscripción.
- **Implicación:** el contrato debe poder representar **distintas modalidades** (corta duración, mensual, suscripción). Para el proyecto, un atributo `modalidad` y planes de membresía cubren el alcance.

### 4.6 Alquiler entre particulares (*peer-to-peer*) y agregadores

- Turo es un mercado donde propietarios (anfitriones) alquilan sus vehículos a viajeros; opera en EE. UU., Canadá (varias provincias), Reino Unido, Australia y Francia. **No aparece Colombia** en su lista oficial de países. También se observa volatilidad en el sector: según Turo, Getaround salió de los mercados de EE. UU. y Reino Unido y hoy opera solo en algunos países europeos.
- Los agregadores (Rentcars, Alkilautos) comparan ofertas de muchas rentadoras en una sola búsqueda.
- **Implicación:** para nuestro alcance, la plataforma será una rentadora con flota propia. Pero el modelo P2P sugiere una decisión de diseño: si el vehículo tiene un **propietario** (empresa o particular), la tabla de vehículos puede referenciar a un propietario. Se decidirá en la Etapa 2.

## 5. Análisis de herramientas existentes en el mercado

Se eligieron tres referentes que cubren tres modelos de negocio distintos, para poder contrastar:

1. **Localiza Rent a Car (Colombia):** rentadora tradicional con flota propia, líder estimado del mercado colombiano.
2. **Turo:** mercado *peer-to-peer* (referencia internacional; **no opera en Colombia**).
3. **Rentcars y Alkilautos:** agregadores/comparadores que no poseen flota.

Además, se usan como ejemplos puntuales las políticas de otras rentadoras que operan en Colombia (Alamo/Enterprise, Alquicarros, Autoalquilados).

### 5.1 Localiza Rent a Car

**Descripción.** Empresa brasileña fundada en 1973 y descrita como la mayor rentadora de Latinoamérica; opera en Brasil y otros ocho países, incluida Colombia. Su app declara una flota superior a 600 mil autos (cifra de la compañía para su operación global) y permite hacer, ver y modificar reservas y buscar agencias . En Colombia, la operación es una franquicia a cargo de Renting Colombia S.A.S., con sede en Medellín .

**Tipos de usuario.** Persona natural (viajero, ocasional), cliente frecuente (programa Fidelidad), persona jurídica y aseguradoras (con la figura arrendatario/usuario), y conductores de aplicaciones (Zarp).

**Modelo de precios y membresías.**
- Tarifa dinámica por ciudad, fecha, gama y días.
- Programa de fidelidad de tres niveles (Verde, Gold, Platinum) con puntos y recálculo anual.
- Alquiler mensual como opción de ahorro (mencionado en el sitio) y suscripción con Meoo.

**Funcionalidades clave.** Reserva en línea y app, búsqueda de agencias, categorías de vehículos (desde compactos hasta camionetas 4x4 de siete pasajeros), alquiler de adicionales, conductor adicional, manejo de multas, información sobre pico y placa, accidentes y hurto, licencia extranjera.

**Reglas visibles en sus políticas.** Pago con tarjeta de crédito propia de ciertas franquicias, con cupo, y cobro automático a la tarjeta si un pago queda pendiente; conductor adicional inscrito en el contrato con cargo.

**Fortalezas.** Cobertura nacional y presencia en aeropuertos, ecosistema (alquiler, suscripción, venta de seminuevos), programa de fidelidad estructurado.

**Debilidades / riesgos (inferencia).** Exigencia estricta de tarjeta de crédito (barrera para usuarios sin ella); tarifa dinámica puede generar percepción de opacidad; la reserva garantiza una categoría "o similar", lo que puede generar diferencias con lo esperado.

**Entidades/datos que se pueden inferir (inferencia):** Cliente (persona natural y jurídica), Usuario autorizado, Conductor adicional, Licencia, Reserva, Contrato, Categoría (gama), Vehículo, Agencia, Ciudad, Tarifa (dinámica), Adicionales, Seguro/Cobertura, Garantía (tarjeta), Pago, Multa, Siniestro (accidente/hurto), Programa de fidelidad (nivel, puntos, beneficios), Modalidad (corto plazo/mensual/suscripción).

### 5.2 Turo

**Descripción.** Mercado de carsharing donde los propietarios (anfitriones) publican sus vehículos y los viajeros (invitados) los reservan. Opera en EE. UU., Australia, Francia, Reino Unido y varias provincias y territorios de Canadá . Ofrece reserva, procesamiento de pagos, opciones de seguro y soporte .

**Tipos de usuario.** Anfitrión (propietario, puede ser un particular o una flota) e invitado (conductor).

**Modelo de precios y membresías.**
- El precio del viaje es la tarifa diaria del vehículo para las fechas elegidas menos descuentos definidos por el anfitrión; además hay una comisión de la plataforma que es un porcentaje del precio y varía según cada viaje.
- El invitado puede elegir un plan de protección que limita lo que pagaría por daños elegibles; no es obligatorio adquirirlo. Los planes no cubren daños interiores ni mecánicos.
- El anfitrión elige un plan de ganancias: a mayor porcentaje que recibe, mayor su responsabilidad por daños. Según una fuente secundaria, desde enero de 2026 los planes son 60, 75 y 90 (nombres por porcentaje de ingresos del anfitrión); esto debe contrastarse con el centro de ayuda oficial antes de citarlo en la sustentación.
- Desde marzo de 2025, Turo dejó de cobrar comisión en reservas mensuales en la mayoría de mercados, y ofrece una herramienta de precios dinámicos con alertas cuando el precio del anfitrión supera en 20 % o más el recomendado.
- Desde el 31 de marzo de 2026, en ciertas ciudades de EE. UU. el porcentaje del anfitrión varía según qué tan anticipada sea la reserva.

**Funcionalidades clave.** Reservas con precio total visible, entrega del vehículo, monitoreo y desbloqueo remoto en algunos vehículos, depósitos por daños (el centro de ayuda describe montos de USD 500 y USD 3.000 según la gravedad), reembolso de depósito de seguridad tras el viaje si no hay costos, seguros fuera de viaje para anfitriones a través de aliados.

**Fortalezas.** Variedad de vehículos, precios transparentes, herramientas para anfitriones (precios dinámicos), modelo con poca inversión en flota propia.

**Debilidades.** Complejidad de seguros y exclusiones (interior, mecánico, uso comercial, fuera de ruta); reparto de riesgo entre anfitrión y plataforma no siempre intuitivo; comisiones que dependen de múltiples variables y que hacen difícil calcular la ganancia real del anfitrión; no disponible en Colombia.

**Entidades/datos que se pueden inferir (inferencia):** Usuario, Anfitrión, Invitado, Vehículo (con propietario), Publicación/Anuncio, Disponibilidad del anuncio, Descuentos del anfitrión, Reserva/Viaje, Plan de protección (invitado), Plan de ganancias (anfitrión), Comisión, Depósito de seguridad, Reclamo por daños, Pago, Reseña, Dispositivo de acceso remoto.

### 5.3 Agregadores: Rentcars y Alkilautos

**Descripción.** Rentcars es una app que muestra opciones de alquiler económico en el destino y compara compañías como Localiza, Hertz, Alamo, Avis, Budget, Europcar, Sixt, Enterprise, entre otras; está disponible en varios idiomas, incluido español de Colombia. Alkilautos es una plataforma que permite comparar vehículos, precios, beneficios y condiciones de diferentes compañías en una sola búsqueda, con precios finales transparentes y promociones.

**Tipos de usuario.** Viajeros y usuarios ocasionales; las rentadoras actúan como proveedores.

**Modelo de precios y membresías.** El agregador no fija el precio: muestra el de cada proveedor. Rentcars relanzó un programa de lealtad (RentRewards) con cashback visible en las ofertas .

**Funcionalidades clave.** Búsqueda comparativa, filtros, reserva a través del proveedor, información de requisitos (por ejemplo, edad mínima del conductor, que en Bogotá la mayoría de rentadoras pone en 21 años).

**Fortalezas.** Comparación transparente, amplio catálogo, reserva anticipada con mejores ofertas.

**Debilidades (inferencia).** Dependencia de la información de cada proveedor; las condiciones (garantías, seguros, edad) siguen siendo las de la rentadora, por lo que el usuario debe revisarlas; la plataforma no controla la disponibilidad real.

**Entidades/datos que se pueden inferir (inferencia):** Proveedor (rentadora), Oferta/Tarifa por proveedor, Categoría estandarizada, Ciudad/Sede, Reserva (con proveedor), Cliente, Programa de lealtad/cashback, Condiciones del proveedor (edad mínima, garantía).

