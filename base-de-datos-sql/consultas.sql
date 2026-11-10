-- =====================================================================
-- 10 consultas representativas
-- =====================================================================
USE alquiler_vehiculos;

-- ---------------------------------------------------------------------
-- 1) Disponibilidad: vehículos libres de una categoría en una ciudad,
--    para un rango de fechas dado.
-- ---------------------------------------------------------------------
SELECT
  v.id_vehiculo, v.placa, m.marca, m.nombre AS modelo, s.nombre AS sede
FROM vehiculo v
JOIN categoria cat ON cat.id_categoria = v.id_categoria
JOIN modelo m       ON m.id_modelo = v.id_modelo
JOIN sede s          ON s.id_sede = v.id_sede_actual
JOIN ciudad c         ON c.id_ciudad = s.id_ciudad
WHERE cat.codigo = 'MOT-01'
  AND c.nombre = 'Bucaramanga'
  AND v.estado_operativo = 'ACTIVO'
  AND NOT EXISTS (
        SELECT 1 FROM contrato co
        WHERE co.id_vehiculo = v.id_vehiculo AND co.estado = 'ABIERTO')
  AND NOT EXISTS (
        SELECT 1
        FROM reserva r JOIN contrato co2 ON co2.id_reserva = r.id_reserva
        WHERE co2.id_vehiculo = v.id_vehiculo AND r.estado = 'CONFIRMADA'
          AND r.fecha_hora_recogida < '2026-11-25 00:00:00'
          AND r.fecha_hora_devolucion_prevista > '2026-11-20 00:00:00');

-- ---------------------------------------------------------------------
-- 2) Ingresos por tipo de cliente (ocasional / frecuente / empresarial),
--    a partir de los pagos efectivamente aplicados .
-- ---------------------------------------------------------------------
SELECT
  CASE
    WHEN e.id_cliente IS NOT NULL THEN 'EMPRESARIAL'
    WHEN EXISTS (SELECT 1 FROM membresia m
                 WHERE m.id_cliente = r.id_cliente AND m.estado = 'ACTIVA') THEN 'FRECUENTE'
    ELSE 'OCASIONAL'
  END AS tipo_comercial,
  COUNT(DISTINCT p.id_reserva) AS reservas_pagadas,
  SUM(p.valor) AS ingresos_totales
FROM pago p
JOIN reserva r     ON r.id_reserva = p.id_reserva
LEFT JOIN empresa e ON e.id_cliente = r.id_cliente
WHERE p.estado = 'APLICADO'
GROUP BY tipo_comercial
ORDER BY ingresos_totales DESC;

-- ---------------------------------------------------------------------
-- 3) Historial completo de reservas y contratos de un cliente .
-- ---------------------------------------------------------------------
SELECT
  r.id_reserva, r.codigo_reserva, r.estado AS estado_reserva,
  r.fecha_hora_recogida, r.fecha_hora_devolucion_prevista,
  cat.nombre AS categoria,
  co.numero_contrato, co.estado AS estado_contrato,
  f.numero_factura, (f.subtotal + f.impuesto) AS total_pagado
FROM reserva r
JOIN categoria cat      ON cat.id_categoria = r.id_categoria
LEFT JOIN contrato co    ON co.id_reserva = r.id_reserva
LEFT JOIN factura f      ON f.id_contrato = co.id_contrato
WHERE r.id_cliente = 200
ORDER BY r.fecha_hora_recogida;

-- ---------------------------------------------------------------------
-- 4) Los 5 vehículos más rentados (más contratos cerrados), con sus
--    kilómetros recorridos totales.
-- ---------------------------------------------------------------------
SELECT
  v.id_vehiculo, v.placa, m.marca, m.nombre AS modelo,
  COUNT(co.id_contrato) AS veces_rentado,
  SUM(di.km_lectura - ei.km_lectura) AS km_totales_generados
FROM vehiculo v
JOIN modelo m ON m.id_modelo = v.id_modelo
JOIN contrato co ON co.id_vehiculo = v.id_vehiculo
LEFT JOIN inspeccion ei ON ei.id_contrato = co.id_contrato AND ei.tipo = 'ENTREGA'
LEFT JOIN inspeccion di ON di.id_contrato = co.id_contrato AND di.tipo = 'DEVOLUCION'
WHERE co.estado = 'CERRADO'
GROUP BY v.id_vehiculo, v.placa, m.marca, m.nombre
ORDER BY veces_rentado DESC, km_totales_generados DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- 5) Utilización de la flota por sede: vehículos activos vs. vehículos
--    con al menos un contrato cerrado en lo corrido .
-- ---------------------------------------------------------------------
SELECT
  s.nombre AS sede,
  COUNT(DISTINCT v.id_vehiculo) AS vehiculos_en_sede,
  COUNT(DISTINCT co.id_vehiculo) AS vehiculos_con_alquiler,
  ROUND(100 * COUNT(DISTINCT co.id_vehiculo) / COUNT(DISTINCT v.id_vehiculo), 1) AS pct_utilizacion
FROM sede s
JOIN vehiculo v ON v.id_sede_actual = s.id_sede
LEFT JOIN contrato co ON co.id_vehiculo = v.id_vehiculo AND co.estado = 'CERRADO'
GROUP BY s.id_sede, s.nombre
ORDER BY pct_utilizacion DESC;

-- ---------------------------------------------------------------------
-- 6) Top 5 clientes por saldo de puntos acumulado (fidelización).
-- ---------------------------------------------------------------------
SELECT
  pn.nombres, pn.apellidos,
  COALESCE((SELECT SUM(mp.puntos) FROM movimiento_puntos mp
            WHERE mp.id_cliente = pn.id_cliente), 0) AS saldo_puntos,
  pm.nombre AS plan_actual
FROM persona_natural pn
LEFT JOIN membresia mb       ON mb.id_cliente = pn.id_cliente AND mb.estado = 'ACTIVA'
LEFT JOIN plan_membresia pm  ON pm.id_plan = mb.id_plan
ORDER BY saldo_puntos DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- 7) Ingresos por categoría de vehículo y ciudad, usando las facturas
--    emitidas (ayuda a decidir en qué ciudad reforzar cada categoría).
-- ---------------------------------------------------------------------
SELECT
  cat.nombre AS categoria, c.nombre AS ciudad,
  COUNT(f.id_factura) AS contratos_facturados,
  SUM(f.subtotal + f.impuesto) AS ingresos
FROM factura f
JOIN contrato co ON co.id_contrato = f.id_contrato
JOIN reserva r    ON r.id_reserva = co.id_reserva
JOIN categoria cat ON cat.id_categoria = r.id_categoria
JOIN sede s        ON s.id_sede = r.id_sede_recogida
JOIN ciudad c      ON c.id_ciudad = s.id_ciudad
GROUP BY cat.nombre, c.nombre
ORDER BY ingresos DESC;

-- ---------------------------------------------------------------------
-- 8) Vehículos actualmente en mantenimiento, con el motivo y los días
--    que llevan fuera de servicio (operación diaria de flota).
-- ---------------------------------------------------------------------
SELECT
  v.placa, m.marca, m.nombre AS modelo, mt.tipo, mt.descripcion,
  mt.fecha_inicio, DATEDIFF(CURDATE(), mt.fecha_inicio) AS dias_en_taller
FROM mantenimiento mt
JOIN vehiculo v ON v.id_vehiculo = mt.id_vehiculo
JOIN modelo m   ON m.id_modelo = v.id_modelo
WHERE mt.fecha_fin_real IS NULL
ORDER BY dias_en_taller DESC;

-- ---------------------------------------------------------------------
-- 9) Monto generado por cada tipo de cargo (cancelación, retraso, daño,
--    combustible...), para ver cuál penalización es más frecuente/costosa.
-- ---------------------------------------------------------------------
SELECT
  tipo, COUNT(*) AS cantidad, SUM(valor) AS valor_total, ROUND(AVG(valor),0) AS valor_promedio
FROM cargo
GROUP BY tipo
ORDER BY valor_total DESC;

-- ---------------------------------------------------------------------
-- 10) Clientes con licencia próxima a vencer (60 días), para que el
--     área comercial les avise antes de su próxima reserva.
-- ---------------------------------------------------------------------
SELECT
  pn.nombres, pn.apellidos, c.correo, l.categoria, l.fecha_vencimiento,
  DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias_para_vencer
FROM licencia l
JOIN persona_natural pn ON pn.id_cliente = l.id_cliente
JOIN cliente c ON c.id_cliente = pn.id_cliente
WHERE l.fecha_vencimiento <= DATE_ADD(CURDATE(), INTERVAL 60 DAY)
ORDER BY dias_para_vencer;
