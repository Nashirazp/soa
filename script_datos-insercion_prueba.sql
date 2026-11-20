USE InterbankApp;
GO

--DATOS INSERTADOS
-- =============================================
-- 1. CATÁLOGOS E INDEPENDIENTES
-- =============================================

INSERT INTO tipos_moneda (codigo_iso, nombre_moneda, simbolo) VALUES
('PEN', 'Sol Peruano', 'S/'),
('USD', 'Dólar Estadounidense', '$');

INSERT INTO tipos_cuenta (nombre_tipo, descripcion) VALUES
('Cuenta Simple', 'Cuenta de ahorros sin costo de mantenimiento'),
('Cuenta Corriente', 'Cuenta para movimientos frecuentes y empresas');

INSERT INTO empresas_servicio (nombre_empresa, rubro, ruc) VALUES
('Luz del Sur', 'Electricidad', '20331898008'),
('Sedapal', 'Agua y Saneamiento', '20100152356'),
('Movistar Perú', 'Telecomunicaciones', '20100017491');

-- 5 Clientes (Integrantes del grupo: IDs del 1 al 5)
INSERT INTO clientes (tipo_documento, numero_documento, nombres, apellido_paterno, apellido_materno, correo, celular, estado) VALUES
('DNI', '71234501', 'Hector', 'Lozada', 'Ojeda', 'hector.lozada@email.com', '987654301', 'ACTIVO'),
('DNI', '71234502', 'Yamely Lyan', 'Machacca', 'Zenayuca', 'yamely.machacca@email.com', '987654302', 'ACTIVO'),
('DNI', '71234503', 'Mateo Fabian', 'Mercado', 'Torres', 'mateo.mercado@email.com', '987654303', 'ACTIVO'),
('DNI', '71234504', 'Rodrigo Ruben', 'Zevallos', 'Leiva', 'rodrigo.zevallos@email.com', '987654304', 'ACTIVO'),
('DNI', '71234505', 'Steffany Nashira', 'Zurita', 'Palomino', 'steffany.zurita@email.com', '987654305', 'ACTIVO');

-- =============================================
-- 2. TABLAS DEPENDIENTES DE NIVEL 1
-- =============================================

-- Autenticaciones (1 a 1 con cada integrante)
INSERT INTO autenticaciones (id_cliente, clave_web_hash, estado_bloqueo, ultimo_acceso) VALUES
(1, 'hash_clave_hector_abc123', 0, GETDATE()),
(2, 'hash_clave_yamely_def456', 0, GETDATE()),
(3, 'hash_clave_mateo_ghi789', 0, GETDATE()),
(4, 'hash_clave_rodrigo_jkl012', 0, GETDATE()),
(5, 'hash_clave_steffany_mno345', 0, GETDATE());

-- Tipos de cambio (Doble relación con tipos_moneda: 1=PEN, 2=USD)
INSERT INTO tipos_cambio (id_tipo_moneda_origen, id_tipo_moneda_destino, precio_compra, precio_venta) VALUES
(2, 1, 3.7200, 3.7650), -- Dólar a Sol
(1, 2, 3.7200, 3.7650); -- Sol a Dólar

-- Cuentas (IDs 1 al 5 en Soles para cada integrante + ID 6 en Dólares para Hector)
INSERT INTO cuentas (id_cliente, id_tipo_cuenta, id_tipo_moneda, numero_cuenta, cci, saldo_disponible, estado) VALUES
(1, 1, 1, '8983001000001', '00389801300100000145', 2500.00, 'ACTIVA'),
(2, 1, 1, '8983001000002', '00389801300100000246', 1800.50, 'ACTIVA'),
(3, 1, 1, '8983001000003', '00389801300100000347', 3200.00, 'ACTIVA'),
(4, 2, 1, '8983001000004', '00389801300100000448', 1500.00, 'ACTIVA'),
(5, 1, 1, '8983001000005', '00389801300100000549', 4100.75, 'ACTIVA'),
(1, 1, 2, '8983002000006', '00389801300200000650', 500.00, 'ACTIVA');

-- Tarjetas (1 por cada integrante)
INSERT INTO tarjetas (id_cliente, numero_tarjeta_enmascarado, tipo_tarjeta, linea_credito, saldo_deuda, compras_internet_activas, compras_exterior_activas, estado) VALUES
(1, '4213-5501-8892-1001', 'DEBITO', NULL, NULL, 1, 0, 'ACTIVA'),
(2, '4557-8812-4410-1002', 'CREDITO', 5000.00, 450.00, 1, 1, 'ACTIVA'),
(3, '4213-5504-7731-1003', 'DEBITO', NULL, NULL, 1, 0, 'ACTIVA'),
(4, '4557-8819-6625-1004', 'CREDITO', 8000.00, 1200.00, 1, 0, 'ACTIVA'),
(5, '4213-5509-3348-1005', 'DEBITO', NULL, NULL, 0, 0, 'ACTIVA');


-- Contactos (1 por integrante para pruebas de Plin o transferencias entre ustedes)
INSERT INTO contactos (id_cliente, nombre_alias, numero_cuenta_celular, banco_destino, tipo_contacto) VALUES
(1, 'Yamely Plin', '987654302', 'Interbank', 'PLIN'),
(2, 'Mateo Cuenta', '8983001000003', 'Interbank', 'CUENTA'),
(3, 'Rodrigo Plin', '987654304', 'Interbank', 'PLIN'),
(4, 'Steffany Cuenta', '8983001000005', 'Interbank', 'CUENTA'),
(5, 'Hector Plin', '987654301', 'Interbank', 'PLIN');

-- Solicitudes de atención (2 ejemplos para GET)
INSERT INTO solicitudes_atencion (id_cliente, tipo_solicitud, detalle, estado) VALUES
(1, 'CONSULTA', 'Consulta sobre límite diario de transferencias', 'ATENDIDA'),
(2, 'RECLAMO', 'Cobro duplicado en consumo de tarjeta de crédito', 'EN_PROCESO');

-- Operaciones cabecera (4 operaciones base para enlazar los 4 tipos de transacciones)
INSERT INTO operaciones (id_cliente, tipo_operacion, monto_total, estado) VALUES
(1, 'TRANSFERENCIA', 200.00, 'COMPLETADA'),
(2, 'PAGO_SERVICIO', 85.50, 'COMPLETADA'),
(3, 'PAGO_PLIN', 50.00, 'COMPLETADA'),
(4, 'RETIRO_SIN_TARJETA', 100.00, 'PENDIENTE');

-- =============================================
-- 3. TABLAS DEPENDIENTES DE NIVEL 2
-- =============================================

-- Constancias (1 a 1 con las 4 operaciones)
INSERT INTO constancias (id_operacion, codigo_constancia, canal_emision, detalle_json) VALUES
(1, 'CONST-2026-0001', 'APP_MOVIL', '{"destino":"8983001000002","moneda":"PEN"}'),
(2, 'CONST-2026-0002', 'APP_MOVIL', '{"empresa":"Luz del Sur","suministro":"11223344"}'),
(3, 'CONST-2026-0003', 'APP_MOVIL', '{"celular":"987654304","concepto":"Almuerzo"}'),
(4, 'CONST-2026-0004', 'APP_MOVIL', '{"beneficiario":"987654305","cajero":"ATM"}');

-- Movimientos (1 movimiento inicial por cada cuenta principal)
INSERT INTO movimientos (id_cuenta, descripcion, monto, tipo_movimiento, saldo_resultante) VALUES
(1, 'Transferencia enviada a Yamely Machacca', -200.00, 'CARGO', 2500.00),
(2, 'Pago servicio Luz del Sur', -85.50, 'CARGO', 1800.50),
(3, 'Envío Plin a Rodrigo Zevallos', -50.00, 'CARGO', 3200.00),
(4, 'Abono de sueldo', 1500.00, 'ABONO', 1500.00),
(5, 'Depósito en ventanilla', 4100.75, 'ABONO', 4100.75);

-- Alcancías (2 metas de ahorro)
INSERT INTO alcancias (id_cuenta, nombre_meta, monto_objetivo, monto_ahorrado, estado) VALUES
(1, 'Viaje a Cusco', 2000.00, 500.00, 'ACTIVA'),
(3, 'Fondo de Emergencia', 5000.00, 1200.00, 'ACTIVA');

-- Transferencias (Enlazada a id_operacion = 1: Hector -> Yamely)
INSERT INTO transferencias (id_operacion, id_cuenta_origen, id_cuenta_destino, id_tipo_moneda, tipo_transferencia, monto) VALUES
(1, 1, 2, 1, 'MISMO_BANCO', 200.00);

-- Pagos de servicios (Enlazada a id_operacion = 2: Yamely -> Luz del Sur)
INSERT INTO pagos_servicios (id_operacion, id_cuenta_origen, id_empresa, codigo_suministro, monto_pago) VALUES
(2, 2, 1, '11223344', 85.50);

-- Pagos Plin (Enlazada a id_operacion = 3: Mateo -> Rodrigo)
INSERT INTO pagos_plin (id_operacion, id_cuenta_origen, celular_destino, nombre_destino, monto, concepto) VALUES
(3, 3, '987654304', 'Rodrigo Ruben Zevallos Leiva', 50.00, 'Almuerzo');

-- Retiros sin tarjeta (Enlazada a id_operacion = 4: Rodrigo -> Steffany)
INSERT INTO retiros_sin_tarjeta (id_operacion, id_cuenta_origen, clave_cobro_hash, monto, celular_beneficiario, fecha_expiracion, estado) VALUES
(4, 4, 'hash_pin_4829', 100.00, '987654305', DATEADD(HOUR, 24, GETDATE()), 'PENDIENTE');
GO


--===========================================
USE InterbankApp;
GO
--Verificar datos

-- =============================================
-- 1. TABLAS INDEPENDIENTES (CATÁLOGOS Y BASE)
-- =============================================
SELECT * FROM clientes;
SELECT * FROM tipos_cuenta;
SELECT * FROM tipos_moneda;
SELECT * FROM empresas_servicio;

-- =============================================
-- 2. TABLAS DEPENDIENTES DE NIVEL 1
-- =============================================
SELECT * FROM autenticaciones;
SELECT * FROM tarjetas;
SELECT * FROM contactos;
SELECT * FROM solicitudes_atencion;
SELECT * FROM operaciones;
SELECT * FROM cuentas;
SELECT * FROM tipos_cambio;

-- =============================================
-- 3. TABLAS DEPENDIENTES DE NIVEL 2
-- =============================================
SELECT * FROM constancias;
SELECT * FROM movimientos;
SELECT * FROM alcancias;
SELECT * FROM transferencias;
SELECT * FROM pagos_servicios;
SELECT * FROM pagos_plin;
SELECT * FROM retiros_sin_tarjeta;
GO




