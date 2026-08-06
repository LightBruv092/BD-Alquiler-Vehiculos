# Proyecto: Plataforma de Alquiler y Gestión de Vehículos

## 1. Descripción del Proyecto

Sistema de base de datos para una plataforma digital que gestione el alquiler de vehículos, permitiendo reservas completamente digitales, seguimiento en tiempo real y servicios adicionales integrados.

## 2. Objetivos Principales

- Automatizar el proceso de reserva y alquiler de vehículos
- Proporcionar disponibilidad en tiempo real
- Facilitar la gestión de flota vehicular
- Implementar seguimiento GPS y telemetría
- Ofrecer múltiples opciones de pago
- Mejorar la experiencia del usuario mediante una plataforma digital moderna

## 3. Conceptos Importantes y Relevantes

### Operativos
- **Alquiler de vehículo**: Contrato de arrendamiento temporal
- **Mantenimiento de vehículo**: Control y registro de servicios preventivos y correctivos
- **Disponibilidad de vehículo**: Estado actual del vehículo en el sistema
- **Tiempo de alquiler**: Duración del período de arrendamiento
- **Pago del alquiler**: Transacción monetaria por servicio
- **Solicitud del alquilador**: Petición de arrendamiento del cliente
- **Lavado de vehículos**: Servicio de limpieza pre y post-alquiler

## 4. Tendencias del Mercado

- Reservas completamente digitales
- Alquiler por diferentes períodos (horas, días, semanas, meses)
- GPS y telemetría precisa
- Variedad de vehículos (híbridos o eléctricos)
- Inspección digital (fotos/video al inicio y fin)
- Precios dinámicos según demanda
- Múltiples destinos y ubicaciones
- Servicios adicionales (seguros, conductores, accesorios)

## 5. Herramientas Competidoras en el Mercado

- **LataM Airlines**: Modelo de viajes integrados
- **Kayak**: Comparador de opciones y precios

---

# 6. Modelo de Base de Datos

## 6.1 Diagrama Entidad-Relación (Conceptual)

```
┌─────────────────┐         ┌──────────────────┐
│    USUARIO      │         │    VEHÍCULO      │
├─────────────────┤         ├──────────────────┤
│ id_usuario (PK) │         │ id_vehiculo (PK) │
│ nombre          │         │ placa            │
│ email           │         │ modelo           │
│ telefono        │         │ año              │
│ documento       │         │ tipo             │
│ fecha_registro  │         │ combustible      │
│ estado          │         │ estado           │
└─────────────────┘         │ ubicacion_id(FK) │
        │                   └──────────────────┘
        │ Realiza                  │
        │                      Es inspeccionado
        │                          │
        ├──────────────┐           │
        │              │           │
    ┌───┴──────────────┴───┐   ┌───┴──────────────┐
    │    RESERVA           │   │   INSPECCIÓN     │
    ├──────────────────────┤   ├──────────────────┤
    │ id_reserva (PK)      │   │ id_inspeccion(PK)│
    │ usuario_id (FK)      │   │ vehiculo_id(FK)  │
    │ vehiculo_id (FK)     │   │ fecha_inspeccion │
    │ fecha_inicio         │   │ estado_vehiculo  │
    │ fecha_fin            │   │ fotos            │
    │ estado_reserva       │   │ observaciones    │
    │ total_precio         │   │ inspeccionador   │
    └──────────────────────┘   └──────────────────┘
        │
        └────────────┬──────────────┐
                     │              │
            ┌────────┴─────┐    ┌───┴──────────┐
            │    PAGO      │    │   SERVICIO   │
            ├──────────────┤    │  ADICIONAL   │
            │ id_pago (PK) │    ├──────────────┤
            │ reserva_id(FK)   │ id_servicio(PK)
            │ monto        │    │ tipo_servicio
            │ metodo       │    │ precio       │
            │ fecha_pago   │    │ descripcion  │
            │ estado       │    └──────────────┘
            └──────────────┘

┌─────────────────────┐    ┌────────────────────┐
│     UBICACIÓN       │    │    MANTENIMIENTO   │
├─────────────────────┤    ├────────────────────┤
│ id_ubicacion (PK)   │    │ id_mantenimiento(PK)
│ ciudad              │    │ vehiculo_id (FK)   │
│ direccion           │    │ fecha_mantenimiento│
│ latitud             │    │ tipo_mantenimiento │
│ longitud            │    │ descripcion        │
│ telefono            │    │ costo              │
│ estado              │    │ proximo_servicio   │
└─────────────────────┘    └────────────────────┘
```

## 6.2 Descripción de Tablas Principales

### Tabla: USUARIO
Almacena información de clientes y administradores del sistema.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_usuario | INT (PK) | Identificador único |
| nombre | VARCHAR(150) | Nombre completo |
| email | VARCHAR(100) | Correo electrónico único |
| telefono | VARCHAR(20) | Número de contacto |
| documento | VARCHAR(20) | Documento de identidad |
| contraseña_hash | VARCHAR(255) | Contraseña encriptada |
| fecha_registro | DATETIME | Fecha de creación de cuenta |
| rol | ENUM | Cliente, Admin, Operador |
| estado | ENUM | Activo, Inactivo, Bloqueado |
| metodos_pago | JSON | Métodos de pago guardados |

### Tabla: VEHÍCULO
Registro de la flota disponible para alquiler.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_vehiculo | INT (PK) | Identificador único |
| placa | VARCHAR(10) | Placa vehicular única |
| marca | VARCHAR(50) | Marca del vehículo |
| modelo | VARCHAR(50) | Modelo específico |
| año | YEAR | Año de fabricación |
| tipo_vehiculo | ENUM | Auto, SUV, Van, etc. |
| combustible | ENUM | Gasolina, Diésel, Híbrido, Eléctrico |
| capacidad_pasajeros | INT | Número de pasajeros |
| estado | ENUM | Disponible, Alquilado, Mantenimiento, Inactivo |
| ubicacion_id | INT (FK) | Ubicación actual |
| precio_diario | DECIMAL | Tarifa base diaria |
| precio_horario | DECIMAL | Tarifa por hora |
| fecha_adquisicion | DATE | Cuando se agregó a flota |
| kilometraje | INT | Kilómetros actuales |
| gps_activo | BOOLEAN | Tiene GPS integrado |
| foto_principal | VARCHAR(255) | URL de imagen |

### Tabla: RESERVA
Contrato de alquiler entre usuario y vehículo.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_reserva | INT (PK) | Identificador único |
| usuario_id | INT (FK) | Usuario que hace la reserva |
| vehiculo_id | INT (FK) | Vehículo reservado |
| fecha_inicio | DATETIME | Cuándo comienza el alquiler |
| fecha_fin | DATETIME | Cuándo termina el alquiler |
| ubicacion_retiro | INT (FK) | Dónde se retira el vehículo |
| ubicacion_devolucion | INT (FK) | Dónde se devuelve |
| estado_reserva | ENUM | Confirmada, Cancelada, Completada, En progreso |
| total_precio | DECIMAL | Precio total del alquiler |
| deposito_seguridad | DECIMAL | Monto de caución |
| kilometraje_inicial | INT | KM al retirar |
| fecha_creacion | DATETIME | Cuándo se creó la reserva |
| comentarios | TEXT | Notas adicionales |

### Tabla: PAGO
Registro de transacciones monetarias.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_pago | INT (PK) | Identificador único |
| reserva_id | INT (FK) | Reserva asociada |
| usuario_id | INT (FK) | Usuario que paga |
| monto | DECIMAL | Cantidad pagada |
| metodo_pago | ENUM | Tarjeta, Transferencia, Efectivo, Digital |
| referencia_transaccion | VARCHAR(100) | ID externo de pago |
| estado_pago | ENUM | Pendiente, Completado, Rechazado, Reembolsado |
| fecha_pago | DATETIME | Cuándo se procesó |
| descripcion | TEXT | Detalle del pago |

### Tabla: INSPECCIÓN
Registro de estado del vehículo al inicio y fin.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_inspeccion | INT (PK) | Identificador único |
| reserva_id | INT (FK) | Reserva asociada |
| vehiculo_id | INT (FK) | Vehículo inspeccionado |
| tipo_inspeccion | ENUM | Entrada, Salida |
| fecha_inspeccion | DATETIME | Cuándo se realizó |
| estado_general | VARCHAR(255) | Descripción del estado |
| gasolina | VARCHAR(50) | Nivel de combustible |
| daños_identificados | TEXT | Listado de daños |
| fotos | JSON | URLs de imágenes |
| inspeccionador_id | INT (FK) | Quién realizó la inspección |
| firma_digital | VARCHAR(255) | Confirmación digital |

### Tabla: SERVICIO_ADICIONAL
Servicios opcionales ofrecidos con los alquileres.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_servicio | INT (PK) | Identificador único |
| tipo_servicio | VARCHAR(100) | Tipo de servicio |
| descripcion | TEXT | Detalle del servicio |
| precio | DECIMAL | Costo del servicio |
| disponible | BOOLEAN | Si está disponible |
| ejemplos | VARCHAR(255) | Ej: Seguro adicional, GPS, Asiento niño |

### Tabla: MANTENIMIENTO
Control de servicios de mantenimiento de vehículos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_mantenimiento | INT (PK) | Identificador único |
| vehiculo_id | INT (FK) | Vehículo mantenido |
| fecha_mantenimiento | DATETIME | Cuándo se realizó |
| tipo_mantenimiento | ENUM | Preventivo, Correctivo, Cambio aceite, etc. |
| descripcion | TEXT | Detalles del servicio |
| costo | DECIMAL | Costo del mantenimiento |
| proveedor | VARCHAR(150) | Taller o proveedor |
| proximo_mantenimiento | DATE | Próxima fecha sugerida |
| estado | ENUM | Completado, En progreso, Pendiente |

### Tabla: UBICACIÓN
Sucursales o puntos de retiro y devolución.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_ubicacion | INT (PK) | Identificador único |
| ciudad | VARCHAR(100) | Ciudad |
| direccion | VARCHAR(255) | Dirección completa |
| latitud | DECIMAL(10,8) | Coordenada GPS |
| longitud | DECIMAL(11,8) | Coordenada GPS |
| telefono | VARCHAR(20) | Teléfono de contacto |
| horario_apertura | TIME | Hora de apertura |
| horario_cierre | TIME | Hora de cierre |
| capacidad_vehiculos | INT | Cuántos vehículos caben |
| estado | ENUM | Activa, Inactiva |

---

## 6.3 Relaciones Principales

- **USUARIO** (1) -----> (*) **RESERVA**
- **VEHÍCULO** (1) -----> (*) **RESERVA**
- **RESERVA** (1) -----> (*) **PAGO**
- **RESERVA** (1) -----> (*) **INSPECCIÓN**
- **VEHÍCULO** (1) -----> (*) **MANTENIMIENTO**
- **UBICACIÓN** (1) -----> (*) **VEHÍCULO**
- **USUARIO** (1) -----> (*) **PAGO**

---

## 7. Consultas SQL Importantes

### Disponibilidad de vehículos
```sql
SELECT v.* FROM VEHÍCULO v
WHERE v.estado = 'Disponible' 
  AND v.ubicacion_id = ?
  AND v.id_vehiculo NOT IN (
    SELECT vehiculo_id FROM RESERVA 
    WHERE estado_reserva IN ('Confirmada', 'En progreso')
      AND (
        (fecha_inicio <= ? AND fecha_fin >= ?)
        OR (fecha_inicio <= ? AND fecha_fin >= ?)
      )
  );
```

### Historial de alquileres por usuario
```sql
SELECT r.*, v.modelo, v.placa, u.direccion
FROM RESERVA r
JOIN VEHÍCULO v ON r.vehiculo_id = v.id_vehiculo
JOIN UBICACIÓN u ON r.ubicacion_retiro = u.id_ubicacion
WHERE r.usuario_id = ?
ORDER BY r.fecha_inicio DESC;
```

### Ingresos por período
```sql
SELECT 
  DATE(p.fecha_pago) as fecha,
  SUM(p.monto) as ingresos_diarios,
  COUNT(DISTINCT p.reserva_id) as reservas
FROM PAGO p
WHERE p.estado_pago = 'Completado'
  AND p.fecha_pago BETWEEN ? AND ?
GROUP BY DATE(p.fecha_pago)
ORDER BY fecha DESC;
```

---

## 8. Consideraciones de Seguridad

- Encriptación de contraseñas con bcrypt o similar
- Tokens JWT para autenticación
- Validación de datos en entrada
- Copias de seguridad regulares
- Auditoría de cambios en registros sensibles
- Cumplimiento de LGPD/GDPR

## 9. Mejoras Futuras

- Integración con sistemas de pago (Stripe, PayPal)
- Geolocalización en tiempo real
- Notificaciones push
- Calificación y reseñas de usuarios
- Programa de lealtad
- Analytics avanzado
- Integración con seguros

## 10. Stack Tecnológico Sugerido

- **Base de Datos**: PostgreSQL o MySQL
- **Backend**: Node.js/Express, Python/Django o Java/Spring
- **Frontend**: React, Vue.js o Angular
- **APIs**: REST o GraphQL
- **Autenticación**: OAuth 2.0, JWT
- **Mapas**: Google Maps API, Mapbox
- **Pagos**: Stripe, PayPal, Mercado Pago

---

**Versión**: 1.0  
**Última actualización**: Agosto 2026  
**Autor**: Equipo de Desarrollo
