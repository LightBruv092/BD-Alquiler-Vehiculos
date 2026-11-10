-- =====================================================================
-- 02_datos_prueba.sql
-- Datos de prueba: al menos 5 registros por tabla (incluidas las de
-- subtipo CARRO/MOTO y PERSONA_NATURAL/EMPRESA, que también deben
-- cumplir el mínimo por separado).
-- =====================================================================
USE alquiler_vehiculos;
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------------
-- MÓDULO A: FLOTA Y SEDES
-- --------------------------------------------------------------------

INSERT INTO ciudad (id_ciudad, nombre, departamento) VALUES
  (1,'Bucaramanga','Santander'),
  (2,'Bogotá','Cundinamarca'),
  (3,'Medellín','Antioquia'),
  (4,'Cali','Valle del Cauca'),
  (5,'Cartagena','Bolívar');

INSERT INTO sede (id_sede, id_ciudad, nombre, via, barrio, indicaciones, horario_apertura, horario_cierre, es_aeropuerto, estado) VALUES
  (10,1,'Aeropuerto Palonegro','Km 14 vía Lebrija','Zona Aeroportuaria','Frente a la terminal de llegadas','06:00:00','20:00:00',TRUE,'ACTIVA'),
  (11,1,'Cabecera','Calle 36 # 24-56','Cabecera del Llano',NULL,'07:00:00','19:00:00',FALSE,'ACTIVA'),
  (12,2,'Aeropuerto El Dorado','Av. El Dorado','Fontibón','Puente aéreo, local 12','05:30:00','22:00:00',TRUE,'ACTIVA'),
  (13,3,'Poblado','Cra 43A # 10-15','El Poblado',NULL,'07:00:00','19:00:00',FALSE,'ACTIVA'),
  (14,4,'Centro','Av. 6N # 23-45','Centro',NULL,'07:00:00','18:00:00',FALSE,'ACTIVA'),
  (15,5,'Centro Histórico','Calle del Arsenal # 8-30','Centro','Cerca al Castillo San Felipe','07:00:00','19:00:00',FALSE,'ACTIVA');

INSERT INTO sede_telefono (id_sede, telefono) VALUES
  (10,'6076344000'),(10,'6076344001'),(11,'6076451122'),
  (12,'6013456789'),(13,'6044567890'),(14,'6025678901'),(15,'6056789012');

INSERT INTO enlazar (id_sede_origen, id_sede_destino, valor_recargo) VALUES
  (10,12,180000),(12,10,180000),(10,13,220000),
  (13,14,210000),(14,15,260000),(11,12,150000);

INSERT INTO empleado (id_empleado, id_sede, id_supervisor, tipo_documento, numero_documento, nombres, apellidos, cargo, fecha_ingreso, estado) VALUES
  (30,10,NULL,'CC','91234501','Carlos','Ruiz','GERENTE_SEDE','2022-02-01','ACTIVO'),
  (31,10,30,'CC','91234502','Laura','Gómez','ASESOR','2023-05-15','ACTIVO'),
  (32,10,30,'CC','91234503','Pedro','Martínez','INSPECTOR','2023-08-20','ACTIVO'),
  (33,12,NULL,'CC','91234504','Marta','Díaz','GERENTE_SEDE','2021-11-10','ACTIVO'),
  (34,12,33,'CC','91234505','Jorge','Pérez','ASESOR','2024-01-12','ACTIVO'),
  (35,13,NULL,'CC','91234506','Sofía','León','ASESOR','2023-03-03','ACTIVO');

INSERT INTO categoria (id_categoria, codigo, nombre, descripcion, clase_vehiculo, edad_minima, licencia_requerida, monto_garantia) VALUES
  (1,'ECO-01','Económico','Autos compactos de bajo consumo','CARRO',21,'B1',1500000),
  (2,'SUV-01','SUV','Camionetas familiares 5 puestos','CARRO',23,'B1',2500000),
  (3,'PICK-01','Pickup 4x4','Camionetas doble cabina','CARRO',25,'B1',3000000),
  (4,'VAN-01','Van 7 pasajeros','Vans para grupos y empresas','CARRO',23,'B2',2800000),
  (5,'MOT-01','Moto urbana','Motos de bajo cilindraje','MOTO',18,'A2',600000);

INSERT INTO modelo (id_modelo, marca, nombre) VALUES
  (1,'Renault','Kwid'),
  (2,'Chevrolet','Spark GT'),
  (3,'Toyota','Fortuner'),
  (4,'Nissan','Frontier'),
  (5,'Renault','Duster'),
  (6,'Hyundai','H1'),
  (7,'AKT','NKD 125'),
  (8,'Yamaha','XTZ 150');

-- VEHICULO: 7 carros (ids 100-106) + 5 motos (ids 107-111) = 12 vehículos.
-- clase_vehiculo lo asigna automáticamente el trigger trg_vehiculo_clase_bi
-- a partir de la categoría, así que no se incluye en el INSERT.
INSERT INTO vehiculo (id_vehiculo, id_categoria, id_modelo, id_sede_actual, placa, vin, anio_modelo, color, tipo_energia, km_actual, estado_operativo, fecha_adquisicion) VALUES
  (100,1,1,10,'ABC123','9BWZZZ377VT004251',2024,'Blanco','GASOLINA',15200,'ACTIVO','2024-01-10'),
  (101,1,2,11,'ABC124','9BWZZZ377VT004252',2023,'Rojo','GASOLINA',28750,'ACTIVO','2023-06-15'),
  (102,2,5,10,'ABC125','9BWZZZ377VT004253',2025,'Gris','GASOLINA',4300,'ACTIVO','2025-02-01'),
  (103,2,3,12,'ABC126','9BWZZZ377VT004254',2024,'Negro','HIBRIDO',19800,'ACTIVO','2024-03-20'),
  (104,3,4,12,'ABC127','9BWZZZ377VT004255',2023,'Blanco','DIESEL',41200,'ACTIVO','2023-04-05'),
  (105,4,6,13,'ABC128','9BWZZZ377VT004256',2022,'Azul','DIESEL',58900,'EN_MANTENIMIENTO','2022-09-12'),
  (106,1,1,14,'ABC129','9BWZZZ377VT004257',2025,'Blanco','ELECTRICO',1250,'ACTIVO','2025-07-01'),
  (107,5,7,10,'XYZ001',NULL,2024,'Negro','GASOLINA',8200,'ACTIVO','2024-05-10'),
  (108,5,7,11,'XYZ002',NULL,2023,'Rojo','GASOLINA',12600,'ACTIVO','2023-10-18'),
  (109,5,8,12,'XYZ003',NULL,2024,'Blanco','GASOLINA',6400,'ACTIVO','2024-08-22'),
  (110,5,8,13,'XYZ004',NULL,2022,'Azul','GASOLINA',22100,'ACTIVO','2022-12-01'),
  (111,5,7,15,'XYZ005',NULL,2025,'Negro','GASOLINA',900,'ACTIVO','2025-09-05');

INSERT INTO carro (id_vehiculo, num_puertas, capacidad_pasajeros, transmision, capacidad_maletero_l, traccion) VALUES
  (100,5,5,'MANUAL',290,'4X2'),
  (101,5,5,'MANUAL',285,'4X2'),
  (102,5,5,'AUTOMATICA',445,'4X2'),
  (103,5,7,'AUTOMATICA',716,'4X4'),
  (104,4,5,'MANUAL',1080,'4X4'),
  (105,4,10,'MANUAL',NULL,'4X2'),
  (106,5,5,'AUTOMATICA',300,'4X2');

INSERT INTO moto (id_vehiculo, cilindraje_cc, tipo_moto) VALUES
  (107,125,'URBANA'),
  (108,125,'URBANA'),
  (109,150,'DEPORTIVA'),
  (110,150,'DEPORTIVA'),
  (111,125,'URBANA');

INSERT INTO mantenimiento (id_mantenimiento, id_vehiculo, tipo, descripcion, fecha_inicio, fecha_fin_estimada, fecha_fin_real, km_al_ingreso, costo) VALUES
  (60,100,'PREVENTIVO','Cambio de aceite y filtros','2026-09-01 08:00:00','2026-09-01 12:00:00','2026-09-01 11:30:00',14800,180000),
  (61,102,'PREVENTIVO','Revisión de frenos','2026-08-15 09:00:00','2026-08-15 13:00:00','2026-08-15 12:45:00',3900,220000),
  (62,104,'CORRECTIVO','Cambio de amortiguadores','2026-07-10 08:00:00','2026-07-11 17:00:00','2026-07-11 16:00:00',40500,980000),
  (63,105,'CORRECTIVO','Revisión sistema eléctrico','2026-10-28 08:00:00','2026-11-08 17:00:00',NULL,58900,NULL),
  (64,107,'PREVENTIVO','Cambio de aceite y revisión general','2026-09-20 09:00:00','2026-09-20 11:00:00','2026-09-20 10:40:00',8000,95000);

-- --------------------------------------------------------------------
-- MÓDULO B: CLIENTES Y MEMBRESÍAS
-- --------------------------------------------------------------------

-- CLIENTE: 8 persona_natural (200-207) + 5 empresa (208-212) = 13.
INSERT INTO cliente (id_cliente, correo, fecha_registro, estado) VALUES
  (200,'laura.gomez.cliente@correo.com','2025-11-15 10:00:00','ACTIVO'),
  (201,'andres.rojas@correo.com','2025-12-02 09:30:00','ACTIVO'),
  (202,'maria.fernandez@correo.com','2025-06-20 14:10:00','ACTIVO'),
  (203,'juan.ramirez@correo.com','2026-01-05 11:45:00','ACTIVO'),
  (204,'camila.suarez@correo.com','2024-03-10 08:20:00','ACTIVO'),
  (205,'felipe.castro@correo.com','2026-02-14 16:00:00','ACTIVO'),
  (206,'diana.moreno@correo.com','2025-09-01 10:30:00','ACTIVO'),
  (207,'oscar.vargas@correo.com','2026-04-22 12:15:00','ACTIVO'),
  (208,'compras@transandinos.com.co','2025-01-20 09:00:00','ACTIVO'),
  (209,'logistica@construsan.com.co','2025-04-11 10:00:00','ACTIVO'),
  (210,'flota@turismosantander.com','2025-07-30 11:30:00','ACTIVO'),
  (211,'administracion@eventoscolombia.co','2026-02-01 09:15:00','ACTIVO'),
  (212,'compras@agroexportcol.com','2025-10-05 13:00:00','ACTIVO');

INSERT INTO cliente_telefono (id_cliente, telefono) VALUES
  (200,'3001234567'),(200,'6076123456'),
  (201,'3109876543'),
  (202,'3201112233'),
  (203,'3157778899'),
  (204,'3012223344'),
  (208,'6076700000'),
  (209,'6013456000'),
  (210,'6076711111');

-- EMPRESA antes que PERSONA_NATURAL (ver nota de la Etapa 4).
INSERT INTO empresa (id_cliente, nit, razon_social, contacto_nombre) VALUES
  (208,'900123456-7','Transportes Andinos S.A.S.','Marta Gómez'),
  (209,'900234567-1','Construsan Ingeniería Ltda.','Hernán Ríos'),
  (210,'900345678-2','Turismo Santander S.A.S.','Patricia Luna'),
  (211,'900456789-3','Eventos Colombia S.A.','Camilo Reyes'),
  (212,'900567890-4','AgroExport Colombia S.A.S.','Beatriz Niño');

INSERT INTO persona_natural (id_cliente, id_empresa, tipo_documento, numero_documento, nombres, apellidos, fecha_nacimiento) VALUES
  (200,NULL,'CC','1098765432','Laura','Gómez','1995-04-12'),
  (201,NULL,'CC','1087654321','Andrés','Rojas','1990-08-25'),
  (202,NULL,'CC','1076543210','María','Fernández','1988-01-30'),
  (203,NULL,'CE','4456789','Juan','Ramírez','1999-11-03'),
  (204,NULL,'CC','1065432109','Camila','Suárez','1993-06-18'),
  (205,NULL,'CC','1054321098','Felipe','Castro','2002-09-09'),
  (206,208,'CC','1043210987','Diana','Moreno','1991-02-14'),
  (207,209,'CC','1032109876','Óscar','Vargas','1985-12-01');

INSERT INTO licencia (id_cliente, categoria, numero_licencia, fecha_expedicion, fecha_vencimiento, pais_expedicion) VALUES
  (200,'B1','68001098765','2018-05-10','2029-05-10','Colombia'),
  (201,'B1','68001087654','2015-03-22','2027-03-22','Colombia'),
  (202,'A2','68001076543','2010-07-01','2026-12-15','Colombia'),
  (203,'B1','68001076544','2020-01-15','2030-01-15','Colombia'),
  (204,'B1','68001065432','2016-09-09','2028-09-09','Colombia'),
  (204,'A2','68001065433','2019-02-20','2027-02-20','Colombia'),
  (205,'A2','68001054321','2021-10-05','2027-10-05','Colombia'),
  (206,'B1','68001043210','2017-04-14','2027-04-14','Colombia'),
  (207,'B1','68001032109','2012-06-30','2026-12-30','Colombia');

INSERT INTO plan_membresia (id_plan, nombre, aplica_a, descuento_pct, puntos_minimos, beneficios, estado) VALUES
  (1,'BRONCE','PERSONA',0,0,'Acceso a promociones generales.','VIGENTE'),
  (2,'PLATA','PERSONA',10,1000,'10% de descuento y check-in prioritario.','VIGENTE'),
  (3,'ORO','PERSONA',15,3000,'15% de descuento, un conductor adicional gratis al año.','VIGENTE'),
  (4,'PLATINO','AMBOS',20,6000,'20% de descuento, upgrade de categoría sujeto a disponibilidad.','VIGENTE'),
  (5,'CORPORATIVO','EMPRESA',12,0,'12% de descuento y facturación consolidada mensual.','VIGENTE');

INSERT INTO membresia (id_membresia, id_cliente, id_plan, fecha_inicio, fecha_fin, estado) VALUES
  (1,200,1,'2025-01-10','2025-12-31','VENCIDA'),
  (2,200,2,'2026-01-10',NULL,'ACTIVA'),
  (3,201,2,'2026-02-15',NULL,'ACTIVA'),
  (4,202,3,'2025-11-01',NULL,'ACTIVA'),
  (5,203,1,'2026-03-01',NULL,'ACTIVA'),
  (6,208,5,'2025-01-20',NULL,'ACTIVA');

INSERT INTO movimiento_puntos (id_cliente, consecutivo, fecha, puntos, motivo, id_contrato) VALUES
  (200,1,'2026-01-15 10:00:00',30,'ALQUILER',NULL),
  (200,2,'2026-06-02 09:00:00',25,'ALQUILER',NULL),
  (201,1,'2026-06-10 10:00:00',50,'ALQUILER',NULL),
  (202,1,'2025-11-05 11:00:00',800,'ALQUILER',NULL),
  (202,2,'2026-03-01 09:30:00',-500,'REDENCION',NULL),
  (203,1,'2026-03-10 10:00:00',40,'ALQUILER',NULL);

-- --------------------------------------------------------------------
-- MÓDULO C: TARIFAS Y RESERVAS
-- --------------------------------------------------------------------

INSERT INTO temporada (id_temporada, nombre, fecha_inicio, fecha_fin, prioridad) VALUES
  (1,'Regular 2026','2026-01-01','2026-12-31',0),
  (2,'Semana Santa 2026','2026-03-28','2026-04-05',10),
  (3,'Vacaciones Mitad de Año 2026','2026-06-15','2026-07-15',10),
  (4,'Diciembre 2026','2026-12-01','2026-12-31',20),
  (5,'Feria de Bucaramanga 2026','2026-09-16','2026-09-27',15);

INSERT INTO tarifa (id_categoria, id_ciudad, id_temporada, valor_dia) VALUES
  (1,1,1,95000),
  (1,1,5,120000),
  (2,1,1,180000),
  (2,2,1,195000),
  (3,2,1,230000),
  (4,3,1,210000),
  (5,1,1,55000),
  (5,4,1,50000);

-- RESERVA: 9 reservas con distintos estados.
INSERT INTO reserva (id_reserva, id_cliente, id_categoria, id_sede_recogida, id_sede_devolucion_prevista, codigo_reserva, fecha_creacion, fecha_hora_recogida, fecha_hora_devolucion_prevista, estado, canal_origen, descuento_aplicado_pct, valor_dia_pactado, fecha_cancelacion) VALUES
  (500,200,1,10,10,'R-2026-0500','2026-10-01 09:00:00','2026-10-15 10:00:00','2026-10-18 10:00:00','CUMPLIDA','APP',10,85500,NULL),
  (501,201,2,10,12,'R-2026-0501','2026-10-02 11:00:00','2026-10-20 09:00:00','2026-10-24 09:00:00','CUMPLIDA','WEB',10,162000,NULL),
  (502,202,5,10,10,'R-2026-0502','2026-10-03 08:30:00','2026-10-22 08:00:00','2026-10-25 08:00:00','CUMPLIDA','APP',15,46750,NULL),
  (503,203,1,11,11,'R-2026-0503','2026-10-28 10:00:00','2026-11-10 09:00:00','2026-11-14 09:00:00','CONFIRMADA','MOSTRADOR',0,95000,NULL),
  (504,204,3,12,12,'R-2026-0504','2026-10-05 12:00:00','2026-10-25 11:00:00','2026-10-28 11:00:00','CUMPLIDA','WEB',0,230000,NULL),
  (505,205,5,13,13,'R-2026-0505','2026-10-06 09:00:00','2026-10-27 09:00:00','2026-10-29 09:00:00','CUMPLIDA','APP',0,52000,NULL),
  (506,206,4,13,13,'R-2026-0506','2026-10-07 10:00:00','2026-11-20 09:00:00','2026-11-25 09:00:00','CONFIRMADA','MOSTRADOR',12,184800,NULL),
  (507,207,1,14,14,'R-2026-0507','2026-10-08 08:00:00','2026-10-12 10:00:00','2026-10-14 10:00:00','CANCELADA','WEB',0,95000,'2026-10-11 08:00:00'),
  (508,205,5,15,15,'R-2026-0508','2026-10-09 09:30:00','2026-10-30 09:00:00','2026-11-01 09:00:00','NO_SHOW','APP',0,55000,NULL);

-- --------------------------------------------------------------------
-- MÓDULO D: CONTRATOS Y FINANZAS
-- --------------------------------------------------------------------

-- CONTRATO: 6 contratos (5 cerrados + 1 abierto). El trigger
-- trg_contrato_sin_solape permite varios CERRADO sobre el mismo vehículo
-- pero solo uno ABIERTO a la vez.
INSERT INTO contrato (id_contrato, id_reserva, id_vehiculo, id_empleado, id_sede_devolucion_real, numero_contrato, modalidad, fecha_hora_entrega, fecha_hora_devolucion_real, estado) VALUES
  (900,500,100,31,10,'C-2026-0900','CORTO_PLAZO','2026-10-15 10:10:00','2026-10-18 09:50:00','CERRADO'),
  (901,501,102,31,12,'C-2026-0901','CORTO_PLAZO','2026-10-20 09:05:00','2026-10-24 10:30:00','CERRADO'),
  (902,502,107,31,10,'C-2026-0902','CORTO_PLAZO','2026-10-22 08:10:00','2026-10-25 08:05:00','CERRADO'),
  (903,504,104,34,12,'C-2026-0903','CORTO_PLAZO','2026-10-25 11:05:00','2026-10-28 13:30:00','CERRADO'),
  (904,505,110,35,13,'C-2026-0904','CORTO_PLAZO','2026-10-27 09:10:00','2026-10-29 09:00:00','CERRADO'),
  (905,503,101,31,NULL,'C-2026-0905','CORTO_PLAZO','2026-11-10 09:05:00',NULL,'ABIERTO');

INSERT INTO conductor_autorizado (id_contrato, id_cliente, es_principal, cargo_dia_pactado) VALUES
  (900,200,TRUE,0),
  (901,201,TRUE,0),
  (901,204,FALSE,15000),
  (902,202,TRUE,0),
  (903,204,TRUE,0),
  (904,205,TRUE,0),
  (905,203,TRUE,0),
  (905,206,FALSE,15000);

INSERT INTO servicio_adicional (id_servicio, nombre, tipo, descripcion, valor_dia, deducible, estado) VALUES
  (1,'Seguro Todo Riesgo','COBERTURA','Cobertura total de daños, deducible reducido.',45000,300000,'VIGENTE'),
  (2,'Silla para bebé','EQUIPO','Silla homologada para niños de 9 a 18 kg.',15000,NULL,'VIGENTE'),
  (3,'GPS portátil','EQUIPO','Navegador GPS con mapas de Colombia.',12000,NULL,'VIGENTE'),
  (4,'Internet WiFi portátil','EQUIPO','Router 4G con datos ilimitados.',18000,NULL,'VIGENTE'),
  (5,'Baúl de techo','EQUIPO','Baúl de 400 litros para equipaje adicional.',20000,NULL,'VIGENTE');

INSERT INTO contrato_servicio (id_contrato, id_servicio, cantidad, valor_dia_pactado) VALUES
  (900,1,1,45000),
  (901,2,1,15000),
  (901,3,1,12000),
  (903,1,1,45000),
  (904,3,1,12000),
  (905,4,1,18000);

-- INSPECCION: entrega (y devolución para los 5 contratos cerrados) = 11 filas.
INSERT INTO inspeccion (id_contrato, tipo, id_empleado, fecha_hora, km_lectura, nivel_energia_pct, observaciones) VALUES
  (900,'ENTREGA',32,'2026-10-15 10:10:00',14800,100,'Vehículo en buen estado, tanque lleno.'),
  (900,'DEVOLUCION',32,'2026-10-18 09:50:00',15200,40,'Rayón leve en puerta trasera izquierda.'),
  (901,'ENTREGA',32,'2026-10-20 09:05:00',4200,100,'Sin novedades.'),
  (901,'DEVOLUCION',32,'2026-10-24 10:30:00',4780,20,'Devuelto con tanque casi vacío.'),
  (902,'ENTREGA',32,'2026-10-22 08:10:00',8100,100,'Moto sin rayones.'),
  (902,'DEVOLUCION',32,'2026-10-25 08:05:00',8340,65,'Sin novedades.'),
  (903,'ENTREGA',34,'2026-10-25 11:05:00',41000,100,'Pickup revisada, sin daños previos.'),
  (903,'DEVOLUCION',34,'2026-10-28 13:30:00',41550,30,'Golpe en parachoques trasero.'),
  (904,'ENTREGA',35,'2026-10-27 09:10:00',21950,100,'Sin novedades.'),
  (904,'DEVOLUCION',35,'2026-10-29 09:00:00',22180,55,'Sin novedades.'),
  (905,'ENTREGA',31,'2026-11-10 09:05:00',28700,100,'Sin novedades, contrato en curso.');

INSERT INTO dano (id_contrato, tipo_inspeccion, nro_item, zona_vehiculo, descripcion, gravedad, costo_estimado) VALUES
  (900,'DEVOLUCION',1,'LATERAL_IZQ','Rayón superficial en puerta trasera izquierda','LEVE',150000),
  (903,'DEVOLUCION',1,'TRASERA','Golpe con fisura en el parachoques trasero','MODERADO',620000),
  (903,'ENTREGA',1,'LLANTAS','Desgaste normal en banda de rodadura','LEVE',NULL),
  (900,'ENTREGA',1,'INTERIOR','Mancha pequeña en tapete del conductor','LEVE',NULL),
  (901,'DEVOLUCION',1,'OTRO','Olor a cigarrillo en el habitáculo','LEVE',50000);

INSERT INTO garantia (id_garantia, id_contrato, monto_retenido, franquicia, ultimos_4_digitos, codigo_autorizacion, fecha_retencion, fecha_liberacion, monto_cobrado, estado) VALUES
  (700,900,1500000,'VISA','4321','AUT-100233','2026-10-15 10:00:00','2026-10-18 10:15:00',150000,'COBRADA_PARCIAL'),
  (701,901,2500000,'MASTERCARD','9087','AUT-100234','2026-10-20 09:00:00','2026-10-24 11:00:00',0,'LIBERADA'),
  (702,902,600000,'VISA','1122','AUT-100235','2026-10-22 08:00:00','2026-10-25 08:30:00',0,'LIBERADA'),
  (703,903,3000000,'DINERS','5566','AUT-100236','2026-10-25 11:00:00','2026-10-28 14:00:00',620000,'COBRADA_PARCIAL'),
  (704,904,600000,'VISA','3344','AUT-100237','2026-10-27 09:00:00','2026-10-29 09:30:00',0,'LIBERADA'),
  (705,905,1500000,'AMEX','7788','AUT-100238','2026-11-10 09:00:00',NULL,0,'RETENIDA');

INSERT INTO cargo (id_cargo, id_reserva, id_contrato_dano, tipo_inspeccion_dano, nro_item_dano, tipo, descripcion, valor, fecha_registro) VALUES
  (800,507,NULL,NULL,NULL,'CANCELACION','Cancelación con menos de 24 horas de anticipación.',95000,'2026-10-11 08:00:00'),
  (801,508,NULL,NULL,NULL,'NO_SHOW','Cliente no se presentó a recoger el vehículo.',55000,'2026-10-30 10:00:00'),
  (802,900,900,'DEVOLUCION',1,'DANO','Reparación de rayón en puerta trasera izquierda.',150000,'2026-10-18 10:00:00'),
  (803,903,903,'DEVOLUCION',1,'DANO','Reparación de parachoques trasero con fisura.',620000,'2026-10-28 14:00:00'),
  (804,901,NULL,NULL,NULL,'COMBUSTIBLE','Devolución con menos del 25% de combustible.',60000,'2026-10-24 10:40:00');

INSERT INTO pago (id_pago, id_reserva, fecha_hora, valor, metodo, concepto, referencia_transaccion, estado) VALUES
  (600,500,'2026-10-01 09:10:00',128250,'TARJETA_CREDITO','ANTICIPO','TX-88421','APLICADO'),
  (601,500,'2026-10-18 10:00:00',128250,'TARJETA_CREDITO','SALDO','TX-88430','APLICADO'),
  (602,501,'2026-10-02 11:10:00',324000,'TARJETA_CREDITO','ANTICIPO','TX-88422','APLICADO'),
  (603,501,'2026-10-24 11:00:00',324000,'TARJETA_CREDITO','SALDO','TX-88431','APLICADO'),
  (604,502,'2026-10-03 08:40:00',70125,'TARJETA_DEBITO','ANTICIPO','TX-88423','APLICADO'),
  (605,502,'2026-10-25 08:30:00',70125,'TARJETA_DEBITO','SALDO','TX-88432','APLICADO'),
  (606,504,'2026-10-05 12:10:00',345000,'TRANSFERENCIA','ANTICIPO','TX-88424','APLICADO'),
  (607,504,'2026-10-28 14:00:00',345000,'TRANSFERENCIA','SALDO','TX-88433','APLICADO'),
  (608,505,'2026-10-06 09:10:00',52000,'TARJETA_CREDITO','ANTICIPO','TX-88425','APLICADO'),
  (609,505,'2026-10-29 09:30:00',52000,'TARJETA_CREDITO','SALDO','TX-88434','APLICADO'),
  (610,507,'2026-10-08 08:10:00',95000,'TARJETA_CREDITO','CARGO_ADICIONAL','TX-88426','APLICADO'),
  (611,508,'2026-10-09 09:40:00',55000,'TARJETA_DEBITO','CARGO_ADICIONAL','TX-88427','APLICADO');

INSERT INTO factura (id_factura, id_contrato, numero_factura, fecha_emision, subtotal, impuesto) VALUES
  (950,900,'FAC-000900','2026-10-18 10:20:00',256500,48735),
  (951,901,'FAC-000901','2026-10-24 11:10:00',648000,123120),
  (952,902,'FAC-000902','2026-10-25 08:40:00',140250,26647.5),
  (953,903,'FAC-000903','2026-10-28 14:10:00',690000,131100),
  (954,904,'FAC-000904','2026-10-29 09:40:00',104000,19760);

SET FOREIGN_KEY_CHECKS = 1;
