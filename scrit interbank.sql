use master
go
CREATE DATABASE InterbankApp;
GO
USE InterbankApp;
GO

-- =============================================
-- 1. TABLAS INDEPENDIENTES (CATÁLOGOS Y BASE)
-- =============================================

CREATE TABLE clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(15) NOT NULL UNIQUE,
    nombres VARCHAR(50) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    celular VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL
);

CREATE TABLE tipos_cuenta (
    id_tipo_cuenta INT IDENTITY(1,1) PRIMARY KEY,
    nombre_tipo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE tipos_moneda (
    id_tipo_moneda INT IDENTITY(1,1) PRIMARY KEY,
    codigo_iso VARCHAR(3) NOT NULL,
    nombre_moneda VARCHAR(20) NOT NULL,
    simbolo VARCHAR(5) NOT NULL
);

CREATE TABLE empresas_servicio (
    id_empresa INT IDENTITY(1,1) PRIMARY KEY,
    nombre_empresa VARCHAR(50) NOT NULL,
    rubro VARCHAR(30) NOT NULL,
    ruc VARCHAR(11) NOT NULL UNIQUE
);

-- =============================================
-- 2. TABLAS DEPENDIENTES DE NIVEL 1
-- =============================================

-- Relación 1:1 con clientes (FK + UNIQUE)
CREATE TABLE autenticaciones (
    id_autenticacion INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    clave_web_hash VARCHAR(255) NOT NULL,
    estado_bloqueo BIT NOT NULL DEFAULT 0,
    ultimo_acceso DATETIME,
    CONSTRAINT FK_autenticaciones_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT UQ_autenticaciones_cliente UNIQUE (id_cliente)
);

-- Relación 1:N con clientes
CREATE TABLE tarjetas (
    id_tarjeta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    numero_tarjeta_enmascarado VARCHAR(19) NOT NULL,
    tipo_tarjeta VARCHAR(20) NOT NULL,
    linea_credito DECIMAL(12,2),
    saldo_deuda DECIMAL(12,2),
    compras_internet_activas BIT NOT NULL DEFAULT 1,
    compras_exterior_activas BIT NOT NULL DEFAULT 0,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_tarjetas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relación 1:N con clientes
CREATE TABLE contactos (
    id_contacto INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    nombre_alias VARCHAR(50) NOT NULL,
    numero_cuenta_celular VARCHAR(24) NOT NULL,
    banco_destino VARCHAR(30) NOT NULL,
    tipo_contacto VARCHAR(15) NOT NULL,
    CONSTRAINT FK_contactos_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relación 1:N con clientes
CREATE TABLE solicitudes_atencion (
    id_solicitud INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo_solicitud VARCHAR(30) NOT NULL,
    detalle VARCHAR(MAX) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_solicitudes_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relación 1:N con clientes
CREATE TABLE operaciones (
    id_operacion INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo_operacion VARCHAR(30) NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    monto_total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_operaciones_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relación 1:N con clientes, tipos_cuenta y tipos_moneda
CREATE TABLE cuentas (
    id_cuenta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_tipo_cuenta INT NOT NULL,
    id_tipo_moneda INT NOT NULL,
    numero_cuenta VARCHAR(20) NOT NULL UNIQUE,
    cci VARCHAR(24) NOT NULL UNIQUE,
    saldo_disponible DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_cuentas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT FK_cuentas_tipos_cuenta FOREIGN KEY (id_tipo_cuenta) REFERENCES tipos_cuenta(id_tipo_cuenta),
    CONSTRAINT FK_cuentas_tipos_moneda FOREIGN KEY (id_tipo_moneda) REFERENCES tipos_moneda(id_tipo_moneda)
);

-- Doble relación 1:N con tipos_moneda (origen y destino)
CREATE TABLE tipos_cambio (
    id_tipo_cambio INT IDENTITY(1,1) PRIMARY KEY,
    id_tipo_moneda_origen INT NOT NULL,
    id_tipo_moneda_destino INT NOT NULL,
    precio_compra DECIMAL(8,4) NOT NULL,
    precio_venta DECIMAL(8,4) NOT NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_tipocambio_moneda_origen FOREIGN KEY (id_tipo_moneda_origen) REFERENCES tipos_moneda(id_tipo_moneda),
    CONSTRAINT FK_tipocambio_moneda_destino FOREIGN KEY (id_tipo_moneda_destino) REFERENCES tipos_moneda(id_tipo_moneda)
);

-- =============================================
-- 3. TABLAS DEPENDIENTES DE NIVEL 2 (DETALLES Y MOVIMIENTOS)
-- =============================================

-- Relación 1:1 con operaciones (FK + UNIQUE)
CREATE TABLE constancias (
    id_constancia INT IDENTITY(1,1) PRIMARY KEY,
    id_operacion INT NOT NULL,
    codigo_constancia VARCHAR(30) NOT NULL UNIQUE,
    canal_emision VARCHAR(20) NOT NULL,
    fecha_emision DATETIME NOT NULL DEFAULT GETDATE(),
    detalle_json VARCHAR(MAX),
    CONSTRAINT FK_constancias_operaciones FOREIGN KEY (id_operacion) REFERENCES operaciones(id_operacion),
    CONSTRAINT UQ_constancias_operacion UNIQUE (id_operacion)
);

-- Relación 1:N con cuentas
CREATE TABLE movimientos (
    id_movimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_cuenta INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    descripcion VARCHAR(150) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    tipo_movimiento VARCHAR(15) NOT NULL,
    saldo_resultante DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_movimientos_cuentas FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);

-- Relación 1:N con cuentas
CREATE TABLE alcancias (
    id_alcancia INT IDENTITY(1,1) PRIMARY KEY,
    id_cuenta INT NOT NULL,
    nombre_meta VARCHAR(50) NOT NULL,
    monto_objetivo DECIMAL(12,2) NOT NULL,
    monto_ahorrado DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_alcancias_cuentas FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);

-- Relación con operaciones, cuentas (origen y destino) y tipos_moneda
CREATE TABLE transferencias (
    id_transferencia INT IDENTITY(1,1) PRIMARY KEY,
    id_operacion INT NOT NULL,
    id_cuenta_origen INT NOT NULL,
    id_cuenta_destino INT NOT NULL,
    id_tipo_moneda INT NOT NULL,
    tipo_transferencia VARCHAR(20) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_transferencias_operaciones FOREIGN KEY (id_operacion) REFERENCES operaciones(id_operacion),
    CONSTRAINT FK_transferencias_cuenta_origen FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
    CONSTRAINT FK_transferencias_cuenta_destino FOREIGN KEY (id_cuenta_destino) REFERENCES cuentas(id_cuenta),
    CONSTRAINT FK_transferencias_tipos_moneda FOREIGN KEY (id_tipo_moneda) REFERENCES tipos_moneda(id_tipo_moneda)
);

-- Relación con operaciones, cuentas (origen) y empresas_servicio
CREATE TABLE pagos_servicios (
    id_pago_servicio INT IDENTITY(1,1) PRIMARY KEY,
    id_operacion INT NOT NULL,
    id_cuenta_origen INT NOT NULL,
    id_empresa INT NOT NULL,
    codigo_suministro VARCHAR(30) NOT NULL,
    monto_pago DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_pagos_operaciones FOREIGN KEY (id_operacion) REFERENCES operaciones(id_operacion),
    CONSTRAINT FK_pagos_cuenta_origen FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
    CONSTRAINT FK_pagos_empresas FOREIGN KEY (id_empresa) REFERENCES empresas_servicio(id_empresa)
);

-- Relación con operaciones y cuentas (origen)
CREATE TABLE pagos_plin (
    id_pago_plin INT IDENTITY(1,1) PRIMARY KEY,
    id_operacion INT NOT NULL,
    id_cuenta_origen INT NOT NULL,
    celular_destino VARCHAR(15) NOT NULL,
    nombre_destino VARCHAR(100) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    concepto VARCHAR(100),
    CONSTRAINT FK_plin_operaciones FOREIGN KEY (id_operacion) REFERENCES operaciones(id_operacion),
    CONSTRAINT FK_plin_cuenta_origen FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta)
);

-- Relación con operaciones y cuentas (origen)
CREATE TABLE retiros_sin_tarjeta (
    id_retiro_sin_tarjeta INT IDENTITY(1,1) PRIMARY KEY,
    id_operacion INT NOT NULL,
    id_cuenta_origen INT NOT NULL,
    clave_cobro_hash VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    celular_beneficiario VARCHAR(15) NOT NULL,
    fecha_expiracion DATETIME NOT NULL,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT FK_retiros_operaciones FOREIGN KEY (id_operacion) REFERENCES operaciones(id_operacion),
    CONSTRAINT FK_retiros_cuenta_origen FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta)
);
GO

