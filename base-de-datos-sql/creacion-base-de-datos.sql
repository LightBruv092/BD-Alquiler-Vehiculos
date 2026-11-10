-- =====================================================================
-- Plataforma de Gestión de Alquiler de Vehículos
-- =====================================================================

DROP DATABASE IF EXISTS alquiler_vehiculos;
CREATE DATABASE alquiler_vehiculos
  CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE alquiler_vehiculos;

SET sql_mode = 'STRICT_ALL_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- =====================================================================
-- MÓDULO A: FLOTA Y SEDES
-- =====================================================================

-- CIUDAD (fuerte) -------------------------------------------------------
CREATE TABLE ciudad (
  id_ciudad     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(60)  NOT NULL,
  departamento  VARCHAR(60)  NOT NULL,
  CONSTRAINT uq_ciudad UNIQUE (nombre, departamento)
) ENGINE=InnoDB;

-- SEDE (fuerte) -----------------------------------------------------------
CREATE TABLE sede (
  id_sede           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_ciudad         INT UNSIGNED NOT NULL,
  nombre            VARCHAR(80)  NOT NULL,
  via               VARCHAR(80)  NOT NULL,
  barrio            VARCHAR(60)  NOT NULL,
  indicaciones      VARCHAR(120) NULL,
  horario_apertura  TIME         NOT NULL,
  horario_cierre    TIME         NOT NULL,
  es_aeropuerto     BOOLEAN      NOT NULL DEFAULT FALSE,
  estado            ENUM('ACTIVA','INACTIVA') NOT NULL DEFAULT 'ACTIVA',
  CONSTRAINT uq_sede UNIQUE (id_ciudad, nombre),
  CONSTRAINT chk_sede_horario CHECK (horario_cierre > horario_apertura),
  CONSTRAINT fk_sede_ciudad FOREIGN KEY (id_ciudad)
    REFERENCES ciudad (id_ciudad) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- SEDE_TELEFONO (tabla de atributo multivaluado SEDE.telefono) ------------
CREATE TABLE sede_telefono (
  id_sede   INT UNSIGNED NOT NULL,
  telefono  VARCHAR(15)  NOT NULL,
  PRIMARY KEY (id_sede, telefono),
  CONSTRAINT fk_sede_telefono_sede FOREIGN KEY (id_sede)
    REFERENCES sede (id_sede) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ENLAZAR (relación recursiva N:M sobre SEDE: recargo por retorno) --------
CREATE TABLE enlazar (
  id_sede_origen   INT UNSIGNED NOT NULL,
  id_sede_destino  INT UNSIGNED NOT NULL,
  valor_recargo    DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_sede_origen, id_sede_destino),
  CONSTRAINT chk_enlazar_distintas CHECK (id_sede_origen <> id_sede_destino),
  CONSTRAINT chk_enlazar_valor CHECK (valor_recargo >= 0),
  -- ON UPDATE RESTRICT (no CASCADE) porque MySQL no permite combinar un
  -- CHECK sobre una columna con una acción referencial que pueda
  -- modificarla (ON UPDATE CASCADE o SET NULL); id_sede es un id
  -- autoincremental que en la práctica nunca se actualiza, así que esto
  -- no quita funcionalidad real.
  CONSTRAINT fk_enlazar_origen FOREIGN KEY (id_sede_origen)
    REFERENCES sede (id_sede) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_enlazar_destino FOREIGN KEY (id_sede_destino)
    REFERENCES sede (id_sede) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;

-- EMPLEADO (fuerte, con FK recursiva a sí misma) ---------------------------
CREATE TABLE empleado (
  id_empleado       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_sede           INT UNSIGNED NOT NULL,
  id_supervisor     INT UNSIGNED NULL,
  tipo_documento    ENUM('CC','CE','PASAPORTE') NOT NULL,
  numero_documento  VARCHAR(20) NOT NULL,
  nombres           VARCHAR(60) NOT NULL,
  apellidos         VARCHAR(60) NOT NULL,
  cargo             ENUM('ASESOR','INSPECTOR','GERENTE_SEDE','ADMINISTRADOR') NOT NULL,
  fecha_ingreso     DATE NOT NULL,
  estado            ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  CONSTRAINT uq_empleado_doc UNIQUE (tipo_documento, numero_documento),
  CONSTRAINT fk_empleado_sede FOREIGN KEY (id_sede)
    REFERENCES sede (id_sede) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_empleado_supervisor FOREIGN KEY (id_supervisor)
    REFERENCES empleado (id_empleado) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CATEGORIA (fuerte) -------------------------------------------------------
CREATE TABLE categoria (
  id_categoria        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo              VARCHAR(10) NOT NULL UNIQUE,
  nombre              VARCHAR(60) NOT NULL,
  descripcion         VARCHAR(200) NULL,
  clase_vehiculo      ENUM('CARRO','MOTO') NOT NULL,
  edad_minima         TINYINT UNSIGNED NOT NULL,
  licencia_requerida  ENUM('A1','A2','B1','B2','B3','C1','C2','C3') NOT NULL,
  monto_garantia      DECIMAL(12,2) NOT NULL,
  CONSTRAINT chk_categoria_edad CHECK (edad_minima BETWEEN 18 AND 30),
  CONSTRAINT chk_categoria_garantia CHECK (monto_garantia >= 0)
) ENGINE=InnoDB;

-- MODELO (fuerte) -----------------------------------------------------------
CREATE TABLE modelo (
  id_modelo  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  marca      VARCHAR(40) NOT NULL,
  nombre     VARCHAR(60) NOT NULL,
  CONSTRAINT uq_modelo UNIQUE (marca, nombre)
) ENGINE=InnoDB;

-- VEHICULO (fuerte, supertipo de la jerarquia CARRO/MOTO) -------------------
CREATE TABLE vehiculo (
  id_vehiculo        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_categoria       INT UNSIGNED NOT NULL,
  id_modelo          INT UNSIGNED NOT NULL,
  id_sede_actual     INT UNSIGNED NOT NULL,
  placa              VARCHAR(7)  NOT NULL UNIQUE,
  vin                VARCHAR(17) NULL UNIQUE,
  anio_modelo        SMALLINT UNSIGNED NOT NULL,
  color              VARCHAR(30) NOT NULL,
  tipo_energia       ENUM('GASOLINA','DIESEL','HIBRIDO','ELECTRICO','GAS') NOT NULL,
  km_actual          INT UNSIGNED NOT NULL DEFAULT 0,
  estado_operativo   ENUM('ACTIVO','EN_MANTENIMIENTO','DADO_DE_BAJA') NOT NULL DEFAULT 'ACTIVO',
  fecha_adquisicion  DATE NOT NULL,
  clase_vehiculo     ENUM('CARRO','MOTO') NOT NULL,
  CONSTRAINT chk_vehiculo_anio CHECK (anio_modelo BETWEEN 1990 AND 2100),
  CONSTRAINT fk_vehiculo_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vehiculo_modelo FOREIGN KEY (id_modelo)
    REFERENCES modelo (id_modelo) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vehiculo_sede FOREIGN KEY (id_sede_actual)
    REFERENCES sede (id_sede) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CARRO (subtipo de VEHICULO, estrategia superclase+subclases) --------------
CREATE TABLE carro (
  id_vehiculo           INT UNSIGNED PRIMARY KEY,
  num_puertas           TINYINT UNSIGNED NOT NULL,
  capacidad_pasajeros   TINYINT UNSIGNED NOT NULL,
  transmision           ENUM('MANUAL','AUTOMATICA') NOT NULL,
  capacidad_maletero_l  SMALLINT UNSIGNED NULL,
  traccion              ENUM('4X2','4X4') NULL,
  CONSTRAINT chk_carro_puertas CHECK (num_puertas BETWEEN 2 AND 6),
  CONSTRAINT fk_carro_vehiculo FOREIGN KEY (id_vehiculo)
    REFERENCES vehiculo (id_vehiculo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- MOTO (subtipo de VEHICULO) -------------------------------------------------
CREATE TABLE moto (
  id_vehiculo     INT UNSIGNED PRIMARY KEY,
  cilindraje_cc   SMALLINT UNSIGNED NOT NULL,
  tipo_moto       ENUM('URBANA','DEPORTIVA','TODOTERRENO','SCOOTER') NOT NULL,
  CONSTRAINT fk_moto_vehiculo FOREIGN KEY (id_vehiculo)
    REFERENCES vehiculo (id_vehiculo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- MANTENIMIENTO (fuerte) -----------------------------------------------------
CREATE TABLE mantenimiento (
  id_mantenimiento    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_vehiculo         INT UNSIGNED NOT NULL,
  tipo                ENUM('PREVENTIVO','CORRECTIVO') NOT NULL,
  descripcion         VARCHAR(200) NOT NULL,
  fecha_inicio        DATETIME NOT NULL,
  fecha_fin_estimada  DATETIME NOT NULL,
  fecha_fin_real      DATETIME NULL,
  km_al_ingreso       INT UNSIGNED NOT NULL,
  costo               DECIMAL(10,2) NULL,
  CONSTRAINT chk_mant_fechas CHECK (fecha_fin_estimada >= fecha_inicio),
  CONSTRAINT fk_mantenimiento_vehiculo FOREIGN KEY (id_vehiculo)
    REFERENCES vehiculo (id_vehiculo) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- MÓDULO B: CLIENTES Y MEMBRESÍAS
-- =====================================================================

-- CLIENTE (fuerte, supertipo de la jerarquia PERSONA_NATURAL/EMPRESA) -------
CREATE TABLE cliente (
  id_cliente      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  correo          VARCHAR(120) NOT NULL UNIQUE,
  fecha_registro  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado          ENUM('ACTIVO','SUSPENDIDO','INACTIVO') NOT NULL DEFAULT 'ACTIVO'
) ENGINE=InnoDB;

-- CLIENTE_TELEFONO (tabla de atributo multivaluado CLIENTE.telefono) --------
CREATE TABLE cliente_telefono (
  id_cliente  INT UNSIGNED NOT NULL,
  telefono    VARCHAR(15) NOT NULL,
  PRIMARY KEY (id_cliente, telefono),
  CONSTRAINT fk_cliente_telefono_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- EMPRESA (subtipo de CLIENTE) se crea antes que PERSONA_NATURAL porque
-- esta última tiene una FK opcional hacia EMPRESA (TRABAJAR_PARA).
CREATE TABLE empresa (
  id_cliente       INT UNSIGNED PRIMARY KEY,
  nit              VARCHAR(15)  NOT NULL UNIQUE,
  razon_social     VARCHAR(120) NOT NULL,
  contacto_nombre  VARCHAR(100) NOT NULL,
  CONSTRAINT fk_empresa_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- PERSONA_NATURAL (subtipo de CLIENTE) --------------------------------------
CREATE TABLE persona_natural (
  id_cliente        INT UNSIGNED PRIMARY KEY,
  id_empresa        INT UNSIGNED NULL,
  tipo_documento    ENUM('CC','CE','PASAPORTE') NOT NULL,
  numero_documento  VARCHAR(20) NOT NULL,
  nombres           VARCHAR(60) NOT NULL,
  apellidos         VARCHAR(60) NOT NULL,
  fecha_nacimiento  DATE NOT NULL,
  CONSTRAINT uq_persona_doc UNIQUE (tipo_documento, numero_documento),
  CONSTRAINT fk_persona_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_persona_empresa FOREIGN KEY (id_empresa)
    REFERENCES empresa (id_cliente) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- LICENCIA (débil de PERSONA_NATURAL) ---------------------------------------
CREATE TABLE licencia (
  id_cliente          INT UNSIGNED NOT NULL,
  categoria           ENUM('A1','A2','B1','B2','B3','C1','C2','C3') NOT NULL,
  numero_licencia     VARCHAR(20) NOT NULL,
  fecha_expedicion    DATE NOT NULL,
  fecha_vencimiento   DATE NOT NULL,
  pais_expedicion     VARCHAR(40) NOT NULL DEFAULT 'Colombia',
  PRIMARY KEY (id_cliente, categoria),
  CONSTRAINT chk_licencia_fechas CHECK (fecha_vencimiento > fecha_expedicion),
  CONSTRAINT fk_licencia_persona FOREIGN KEY (id_cliente)
    REFERENCES persona_natural (id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- PLAN_MEMBRESIA (fuerte) ----------------------------------------------------
CREATE TABLE plan_membresia (
  id_plan          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(40) NOT NULL UNIQUE,
  aplica_a         ENUM('PERSONA','EMPRESA','AMBOS') NOT NULL,
  descuento_pct    DECIMAL(5,2) NOT NULL,
  puntos_minimos   INT UNSIGNED NOT NULL DEFAULT 0,
  beneficios       VARCHAR(300) NULL,
  estado           ENUM('VIGENTE','RETIRADO') NOT NULL DEFAULT 'VIGENTE',
  CONSTRAINT chk_plan_descuento CHECK (descuento_pct BETWEEN 0 AND 100)
) ENGINE=InnoDB;

-- MEMBRESIA (asociativa con PK propia: CLIENTE x PLAN_MEMBRESIA en el tiempo)
CREATE TABLE membresia (
  id_membresia  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente    INT UNSIGNED NOT NULL,
  id_plan       INT UNSIGNED NOT NULL,
  fecha_inicio  DATE NOT NULL,
  fecha_fin     DATE NULL,
  estado        ENUM('ACTIVA','VENCIDA','CANCELADA') NOT NULL DEFAULT 'ACTIVA',
  CONSTRAINT uq_membresia UNIQUE (id_cliente, id_plan, fecha_inicio),
  CONSTRAINT chk_membresia_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
  CONSTRAINT fk_membresia_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_membresia_plan FOREIGN KEY (id_plan)
    REFERENCES plan_membresia (id_plan) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- MÓDULO C: TARIFAS Y RESERVAS
-- =====================================================================

-- TEMPORADA (fuerte) ---------------------------------------------------------
CREATE TABLE temporada (
  id_temporada  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(60) NOT NULL,
  fecha_inicio  DATE NOT NULL,
  fecha_fin     DATE NOT NULL,
  prioridad     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT chk_temporada_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- TARIFA (relación ternaria CATEGORIA x CIUDAD x TEMPORADA) -----------------
CREATE TABLE tarifa (
  id_categoria   INT UNSIGNED NOT NULL,
  id_ciudad      INT UNSIGNED NOT NULL,
  id_temporada   INT UNSIGNED NOT NULL,
  valor_dia      DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_categoria, id_ciudad, id_temporada),
  CONSTRAINT chk_tarifa_valor CHECK (valor_dia > 0),
  CONSTRAINT fk_tarifa_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tarifa_ciudad FOREIGN KEY (id_ciudad)
    REFERENCES ciudad (id_ciudad) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tarifa_temporada FOREIGN KEY (id_temporada)
    REFERENCES temporada (id_temporada) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RESERVA (fuerte) ------------------------------------------------------------
CREATE TABLE reserva (
  id_reserva                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente                      INT UNSIGNED NOT NULL,
  id_categoria                    INT UNSIGNED NOT NULL,
  id_sede_recogida                INT UNSIGNED NOT NULL,
  id_sede_devolucion_prevista     INT UNSIGNED NOT NULL,
  codigo_reserva                  VARCHAR(12) NOT NULL UNIQUE,
  fecha_creacion                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_hora_recogida              DATETIME NOT NULL,
  fecha_hora_devolucion_prevista   DATETIME NOT NULL,
  estado                           ENUM('CONFIRMADA','CUMPLIDA','CANCELADA','NO_SHOW') NOT NULL DEFAULT 'CONFIRMADA',
  canal_origen                     ENUM('WEB','APP','MOSTRADOR','TELEFONO','COMPARADOR') NOT NULL,
  descuento_aplicado_pct           DECIMAL(5,2) NOT NULL DEFAULT 0,
  valor_dia_pactado                DECIMAL(10,2) NOT NULL,
  fecha_cancelacion                DATETIME NULL,
  CONSTRAINT chk_reserva_fechas CHECK (fecha_hora_devolucion_prevista > fecha_hora_recogida),
  CONSTRAINT chk_reserva_valor CHECK (valor_dia_pactado > 0),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reserva_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reserva_sede_recogida FOREIGN KEY (id_sede_recogida)
    REFERENCES sede (id_sede) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reserva_sede_devolucion FOREIGN KEY (id_sede_devolucion_prevista)
    REFERENCES sede (id_sede) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- MÓDULO D: CONTRATOS Y FINANZAS
-- =====================================================================

-- CONTRATO (fuerte) ------------------------------------------------------------
CREATE TABLE contrato (
  id_contrato                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_reserva                  INT UNSIGNED NOT NULL UNIQUE,
  id_vehiculo                 INT UNSIGNED NOT NULL,
  id_empleado                 INT UNSIGNED NOT NULL,
  id_sede_devolucion_real     INT UNSIGNED NULL,
  numero_contrato              VARCHAR(15) NOT NULL UNIQUE,
  modalidad                    ENUM('CORTO_PLAZO','MENSUAL','SUSCRIPCION') NOT NULL DEFAULT 'CORTO_PLAZO',
  fecha_hora_entrega           DATETIME NOT NULL,
  fecha_hora_devolucion_real   DATETIME NULL,
  estado                        ENUM('ABIERTO','CERRADO') NOT NULL DEFAULT 'ABIERTO',
  CONSTRAINT chk_contrato_fechas CHECK (fecha_hora_devolucion_real IS NULL
    OR fecha_hora_devolucion_real >= fecha_hora_entrega),
  CONSTRAINT fk_contrato_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva (id_reserva) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_vehiculo FOREIGN KEY (id_vehiculo)
    REFERENCES vehiculo (id_vehiculo) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_empleado FOREIGN KEY (id_empleado)
    REFERENCES empleado (id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_sede_devolucion FOREIGN KEY (id_sede_devolucion_real)
    REFERENCES sede (id_sede) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- MOVIMIENTO_PUNTOS (débil de CLIENTE) ----------------------------------------
CREATE TABLE movimiento_puntos (
  id_cliente    INT UNSIGNED NOT NULL,
  consecutivo   INT UNSIGNED NOT NULL,
  fecha         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  puntos        INT NOT NULL,
  motivo        ENUM('ALQUILER','REDENCION','AJUSTE','BONO') NOT NULL,
  id_contrato   INT UNSIGNED NULL,
  PRIMARY KEY (id_cliente, consecutivo),
  CONSTRAINT chk_movpuntos_valor CHECK (puntos <> 0),
  CONSTRAINT fk_movpuntos_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_movpuntos_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CONDUCTOR_AUTORIZADO (asociativa N:M: CONTRATO x PERSONA_NATURAL) -----------
CREATE TABLE conductor_autorizado (
  id_contrato         INT UNSIGNED NOT NULL,
  id_cliente          INT UNSIGNED NOT NULL,
  es_principal        BOOLEAN NOT NULL DEFAULT FALSE,
  cargo_dia_pactado   DECIMAL(10,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_contrato, id_cliente),
  CONSTRAINT chk_conductor_cargo CHECK (cargo_dia_pactado >= 0),
  CONSTRAINT fk_conductor_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_conductor_persona FOREIGN KEY (id_cliente)
    REFERENCES persona_natural (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- SERVICIO_ADICIONAL (fuerte) --------------------------------------------------
CREATE TABLE servicio_adicional (
  id_servicio   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80) NOT NULL UNIQUE,
  tipo          ENUM('COBERTURA','EQUIPO') NOT NULL,
  descripcion   VARCHAR(200) NULL,
  valor_dia     DECIMAL(10,2) NOT NULL,
  deducible     DECIMAL(10,2) NULL,
  estado        ENUM('VIGENTE','RETIRADO') NOT NULL DEFAULT 'VIGENTE',
  CONSTRAINT chk_servicio_valor CHECK (valor_dia >= 0)
) ENGINE=InnoDB;

-- CONTRATO_SERVICIO (asociativa N:M: CONTRATO x SERVICIO_ADICIONAL) -----------
CREATE TABLE contrato_servicio (
  id_contrato         INT UNSIGNED NOT NULL,
  id_servicio         INT UNSIGNED NOT NULL,
  cantidad            TINYINT UNSIGNED NOT NULL DEFAULT 1,
  valor_dia_pactado   DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_contrato, id_servicio),
  CONSTRAINT chk_contserv_cantidad CHECK (cantidad >= 1),
  CONSTRAINT fk_contserv_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_contserv_servicio FOREIGN KEY (id_servicio)
    REFERENCES servicio_adicional (id_servicio) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- INSPECCION (débil de CONTRATO) -----------------------------------------------
CREATE TABLE inspeccion (
  id_contrato         INT UNSIGNED NOT NULL,
  tipo                ENUM('ENTREGA','DEVOLUCION') NOT NULL,
  id_empleado         INT UNSIGNED NOT NULL,
  fecha_hora          DATETIME NOT NULL,
  km_lectura          INT UNSIGNED NOT NULL,
  nivel_energia_pct   TINYINT UNSIGNED NOT NULL,
  observaciones       VARCHAR(300) NULL,
  PRIMARY KEY (id_contrato, tipo),
  CONSTRAINT chk_inspeccion_energia CHECK (nivel_energia_pct BETWEEN 0 AND 100),
  CONSTRAINT fk_inspeccion_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_inspeccion_empleado FOREIGN KEY (id_empleado)
    REFERENCES empleado (id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DANO (débil de INSPECCION; débil de una débil) -------------------------------
CREATE TABLE dano (
  id_contrato      INT UNSIGNED NOT NULL,
  tipo_inspeccion  ENUM('ENTREGA','DEVOLUCION') NOT NULL,
  nro_item         SMALLINT UNSIGNED NOT NULL,
  zona_vehiculo    ENUM('FRONTAL','TRASERA','LATERAL_IZQ','LATERAL_DER','TECHO','INTERIOR','LLANTAS','OTRO') NOT NULL,
  descripcion      VARCHAR(200) NOT NULL,
  gravedad         ENUM('LEVE','MODERADO','GRAVE') NOT NULL,
  costo_estimado   DECIMAL(10,2) NULL,
  PRIMARY KEY (id_contrato, tipo_inspeccion, nro_item),
  CONSTRAINT fk_dano_inspeccion FOREIGN KEY (id_contrato, tipo_inspeccion)
    REFERENCES inspeccion (id_contrato, tipo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- GARANTIA (fuerte) ---------------------------------------------------------------
CREATE TABLE garantia (
  id_garantia           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_contrato           INT UNSIGNED NOT NULL,
  monto_retenido        DECIMAL(12,2) NOT NULL,
  franquicia            ENUM('VISA','MASTERCARD','DINERS','AMEX') NOT NULL,
  ultimos_4_digitos     CHAR(4) NOT NULL,
  codigo_autorizacion   VARCHAR(20) NULL,
  fecha_retencion       DATETIME NOT NULL,
  fecha_liberacion      DATETIME NULL,
  monto_cobrado         DECIMAL(12,2) NOT NULL DEFAULT 0,
  estado                ENUM('RETENIDA','LIBERADA','COBRADA_PARCIAL','COBRADA_TOTAL') NOT NULL DEFAULT 'RETENIDA',
  CONSTRAINT chk_garantia_montos CHECK (monto_cobrado >= 0 AND monto_cobrado <= monto_retenido),
  CONSTRAINT fk_garantia_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CARGO (fuerte; puede originarse de un dano, de forma opcional) -----------------
CREATE TABLE cargo (
  id_cargo               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_reserva             INT UNSIGNED NOT NULL,
  id_contrato_dano       INT UNSIGNED NULL,
  tipo_inspeccion_dano   ENUM('ENTREGA','DEVOLUCION') NULL,
  nro_item_dano          SMALLINT UNSIGNED NULL,
  tipo                   ENUM('CANCELACION','NO_SHOW','DEVOLUCION_TARDIA','RETORNO_OTRA_SEDE',
                                'DANO','MULTA_TRANSITO','COMBUSTIBLE','LIMPIEZA','OTRO') NOT NULL,
  descripcion            VARCHAR(200) NOT NULL,
  valor                  DECIMAL(10,2) NOT NULL,
  fecha_registro         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_cargo_valor CHECK (valor > 0),
  CONSTRAINT uq_cargo_dano UNIQUE (id_contrato_dano, tipo_inspeccion_dano, nro_item_dano),
  CONSTRAINT fk_cargo_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva (id_reserva) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cargo_dano FOREIGN KEY (id_contrato_dano, tipo_inspeccion_dano, nro_item_dano)
    REFERENCES dano (id_contrato, tipo_inspeccion, nro_item) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- PAGO (fuerte) ---------------------------------------------------------------------
CREATE TABLE pago (
  id_pago                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_reserva               INT UNSIGNED NOT NULL,
  fecha_hora               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valor                    DECIMAL(12,2) NOT NULL,
  metodo                   ENUM('EFECTIVO','TARJETA_CREDITO','TARJETA_DEBITO','TRANSFERENCIA') NOT NULL,
  concepto                 ENUM('ANTICIPO','SALDO','CARGO_ADICIONAL') NOT NULL,
  referencia_transaccion   VARCHAR(40) NULL,
  estado                   ENUM('APLICADO','ANULADO') NOT NULL DEFAULT 'APLICADO',
  CONSTRAINT chk_pago_valor CHECK (valor > 0),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva (id_reserva) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- FACTURA (fuerte) ------------------------------------------------------------------
CREATE TABLE factura (
  id_factura       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_contrato      INT UNSIGNED NOT NULL UNIQUE,
  numero_factura   VARCHAR(20) NOT NULL UNIQUE,
  fecha_emision    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal         DECIMAL(12,2) NOT NULL,
  impuesto         DECIMAL(12,2) NOT NULL,
  CONSTRAINT chk_factura_montos CHECK (subtotal >= 0 AND impuesto >= 0),
  CONSTRAINT fk_factura_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- ÍNDICES ADICIONALES (columnas usadas con frecuencia en WHERE/JOIN que
-- no quedaron indexadas automáticamente por ser PK/FK/UNIQUE)
-- =====================================================================
CREATE INDEX ix_vehiculo_estado        ON vehiculo (estado_operativo);
CREATE INDEX ix_reserva_fechas         ON reserva (fecha_hora_recogida, fecha_hora_devolucion_prevista);
CREATE INDEX ix_reserva_estado         ON reserva (estado);
CREATE INDEX ix_contrato_estado        ON contrato (estado);
CREATE INDEX ix_cliente_estado         ON cliente (estado);
CREATE INDEX ix_mantenimiento_vehiculo_fechas ON mantenimiento (id_vehiculo, fecha_inicio, fecha_fin_estimada);

-- =====================================================================
-- TRIGGERS
-- =====================================================================
DELIMITER $$

-- RN-10: la clase del vehiculo debe coincidir con la clase de su categoria.
-- En vez de pedirle el dato al usuario, lo tomamos de CATEGORIA al insertar,
-- así eliminamos el riesgo de inconsistencia (ver Informe_Normalizacion.docx,
-- sección 3FN, punto "VEHICULO.clase_vehiculo").
CREATE TRIGGER trg_vehiculo_clase_bi
BEFORE INSERT ON vehiculo
FOR EACH ROW
BEGIN
  DECLARE v_clase ENUM('CARRO','MOTO');
  SELECT clase_vehiculo INTO v_clase FROM categoria WHERE id_categoria = NEW.id_categoria;
  SET NEW.clase_vehiculo = v_clase;
END$$

CREATE TRIGGER trg_vehiculo_clase_bu
BEFORE UPDATE ON vehiculo
FOR EACH ROW
BEGIN
  DECLARE v_clase ENUM('CARRO','MOTO');
  SELECT clase_vehiculo INTO v_clase FROM categoria WHERE id_categoria = NEW.id_categoria;
  SET NEW.clase_vehiculo = v_clase;
END$$

-- RN-33: a lo sumo un conductor principal por contrato.
CREATE TRIGGER trg_conductor_un_principal
BEFORE INSERT ON conductor_autorizado
FOR EACH ROW
BEGIN
  DECLARE v_cuantos INT;
  IF NEW.es_principal = TRUE THEN
    SELECT COUNT(*) INTO v_cuantos
      FROM conductor_autorizado
      WHERE id_contrato = NEW.id_contrato AND es_principal = TRUE;
    IF v_cuantos > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El contrato ya tiene un conductor principal (RN-33).';
    END IF;
  END IF;
END$$

-- RN-11/RN-12 (versión simplificada): un vehículo no puede tener dos
-- contratos ABIERTOS al mismo tiempo.
CREATE TRIGGER trg_contrato_sin_solape
BEFORE INSERT ON contrato
FOR EACH ROW
BEGIN
  DECLARE v_cuantos INT;
  IF NEW.estado = 'ABIERTO' THEN
    SELECT COUNT(*) INTO v_cuantos
      FROM contrato
      WHERE id_vehiculo = NEW.id_vehiculo AND estado = 'ABIERTO';
    IF v_cuantos > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehículo ya tiene un contrato abierto (RN-11/RN-12).';
    END IF;
  END IF;
END$$

DELIMITER ;
