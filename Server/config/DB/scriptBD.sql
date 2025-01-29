create database if not exists Distribuidor;
use distribuidor;

-- 🔴 Eliminar tablas si existen
DROP TABLE IF EXISTS Movimiento_Stock;
DROP TABLE IF EXISTS Stock;
DROP TABLE IF EXISTS Lote;
DROP TABLE IF EXISTS Lote_Configuracion;
DROP TABLE IF EXISTS Producto;

-- 🔴 Eliminar procedimientos y funciones si existen
DROP PROCEDURE IF EXISTS CalcularUnidadesLote;
DROP FUNCTION IF EXISTS EstadoStock;
-- 🟢 Tabla de productos
CREATE TABLE Producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    costo_S_Iva DECIMAL(10, 2) NOT NULL,
    costo_C_Iva DECIMAL(10, 2) NOT NULL,
    rentabilidad DECIMAL(5, 2) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    margen DECIMAL(5, 2) NOT NULL,
    tipo_envase ENUM('botella', 'lata', 'envase_retornable', 'otro') NOT NULL,
    capacidad_ml INT,
    stock_optimo INT NOT NULL,
    stock_minimo INT NOT NULL
);

-- 🟢 Tabla de stock
CREATE TABLE Stock (
    id_stock INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL UNIQUE,
    cantidad_disponible INT NOT NULL DEFAULT 0,
    ultima_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- 🟢 Tabla de configuraciones de lote
CREATE TABLE Lote_Configuracion (
    id_configuracion INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(255) NOT NULL,
    cantidad_pallets INT NOT NULL,
    bases_por_pallet INT NOT NULL,
    fardos_por_base INT NOT NULL,
    botellas_por_fardo INT NOT NULL
);

-- 🟢 Tabla de lotes con detalles de ingreso
CREATE TABLE Lote (
    id_lote INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_configuracion INT NOT NULL,
    codigo_lote VARCHAR(50) UNIQUE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    costo_lote DECIMAL(10, 2) NOT NULL,
    total_unidades INT NOT NULL,
    cantidad_pallets INT NOT NULL DEFAULT 0,
    cantidad_bases INT NOT NULL DEFAULT 0,
    cantidad_fardos INT NOT NULL DEFAULT 0,
    cantidad_botellas INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_configuracion) REFERENCES Lote_Configuracion(id_configuracion)
);

-- 🟢 Tabla de movimientos de stock
CREATE TABLE Movimiento_Stock (
    id_movimiento INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento DATETIME DEFAULT NOW(),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);
-- 🟢 Procedimiento para calcular unidades en un lote basado en la configuración
DELIMITER //

CREATE PROCEDURE CalcularUnidadesLote(
    IN p_id_configuracion INT,
    IN p_cantidad_pallets INT,
    IN p_cantidad_bases INT,
    IN p_cantidad_fardos INT,
    IN p_cantidad_botellas INT,
    OUT p_total_botellas INT
)
BEGIN
    DECLARE v_pallets INT;
    DECLARE v_bases INT;
    DECLARE v_fardos INT;
    DECLARE v_botellas INT;

    -- Obtener la configuración del lote
    SELECT cantidad_pallets, bases_por_pallet, fardos_por_base, botellas_por_fardo
    INTO v_pallets, v_bases, v_fardos, v_botellas
    FROM Lote_Configuracion
    WHERE id_configuracion = p_id_configuracion;

    -- Calcular el total de botellas basado en la jerarquía establecida
    SET p_total_botellas = 
        (p_cantidad_pallets * v_bases * v_fardos * v_botellas) +
        (p_cantidad_bases * v_fardos * v_botellas) +
        (p_cantidad_fardos * v_botellas) +
        p_cantidad_botellas;
END //

DELIMITER ;

-- 🟢 Función para verificar el estado del stock
DELIMITER //

CREATE FUNCTION EstadoStock(p_id_producto INT) 
RETURNS VARCHAR(50) 
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(50);
    DECLARE stock_actual INT;
    DECLARE stock_minimo INT;
    DECLARE stock_optimo INT;

    SELECT s.cantidad_disponible, p.stock_minimo, p.stock_optimo 
    INTO stock_actual, stock_minimo, stock_optimo 
    FROM Stock s
    JOIN Producto p ON s.id_producto = p.id_producto
    WHERE s.id_producto = p_id_producto;

    IF stock_actual < stock_minimo THEN
        SET estado = '🔴 Stock Bajo';
    ELSEIF stock_actual BETWEEN stock_minimo AND stock_optimo THEN
        SET estado = '🟢 Stock Óptimo';
    ELSE
        SET estado = '🟡 Stock Alto';
    END IF;

    RETURN estado;
END //

DELIMITER ;
-- 🟢 Insertar configuraciones de lote
INSERT INTO Lote_Configuracion (descripcion, cantidad_pallets, bases_por_pallet, fardos_por_base, botellas_por_fardo)
VALUES 
('Estandar (1 pallet = 3 bases, 1 base = 4 fardos, 1 fardo = 8 botellas)', 1, 3, 4, 8);

-- 🟢 Insertar un producto
INSERT INTO Producto (nombre, marca, costo_S_Iva, costo_C_Iva, rentabilidad, precio, margen, tipo_envase, capacidad_ml, stock_optimo, stock_minimo)
VALUES ('Coca-Cola', 'Coca-Cola', 50.00, 60.50, 20.00, 72.60, 20.00, 'botella', 1000, 200, 100);
SET @id_configuracion = 1;
SET @cantidad_pallets = 2;
SET @cantidad_bases = 1;
SET @cantidad_fardos = 0;
SET @cantidad_botellas = 5;

CALL CalcularUnidadesLote(@id_configuracion, @cantidad_pallets, @cantidad_bases, @cantidad_fardos, @cantidad_botellas, @total_botellas);

INSERT INTO Lote (id_producto, id_configuracion, codigo_lote, fecha_vencimiento, costo_lote, total_unidades, cantidad_pallets, cantidad_bases, cantidad_fardos, cantidad_botellas)
VALUES (1, @id_configuracion, 'L20240302-D', '2025-02-20', 62000.00, @total_botellas, @cantidad_pallets, @cantidad_bases, @cantidad_fardos, @cantidad_botellas);

INSERT INTO Stock (id_producto, cantidad_disponible)
VALUES (1, @total_botellas)
ON DUPLICATE KEY UPDATE cantidad_disponible = cantidad_disponible + @total_botellas;

INSERT INTO Movimiento_Stock (id_producto, tipo_movimiento, cantidad)
VALUES (1, 'entrada', @total_botellas);
-- 📌 Ver lotes registrados con sus configuraciones



UPDATE Producto 
SET stock_optimo = 1000 
WHERE id_producto= 1;

-- Definir la configuración del lote
SET @id_configuracion = 1;  -- Configuración estándar: 1 pallet = 3 bases, 1 base = 4 fardos, 1 fardo = 8 botellas
SET @cantidad_pallets = 5;  -- Insertamos 5 pallets
SET @cantidad_bases = 0;    -- No se ingresan bases directamente
SET @cantidad_fardos = 0;   -- No se ingresan fardos directamente
SET @cantidad_botellas = 0; -- No se ingresan botellas sueltas

-- Calcular la cantidad total de botellas para 5 pallets
CALL CalcularUnidadesLote(@id_configuracion, @cantidad_pallets, @cantidad_bases, @cantidad_fardos, @cantidad_botellas, @total_botellas);

-- Insertar el nuevo lote con el total de botellas calculado
INSERT INTO Lote (id_producto, id_configuracion, codigo_lote, fecha_vencimiento, costo_lote, total_unidades, cantidad_pallets, cantidad_bases, cantidad_fardos, cantidad_botellas)
VALUES (1, @id_configuracion, 'L20240305-E', '2025-06-15', 125000.00, @total_botellas, @cantidad_pallets, @cantidad_bases, @cantidad_fardos, @cantidad_botellas);

-- Actualizar el stock sumando las nuevas unidades
INSERT INTO Stock (id_producto, cantidad_disponible)
VALUES (1, @total_botellas)
ON DUPLICATE KEY UPDATE cantidad_disponible = cantidad_disponible + @total_botellas;

-- Registrar el movimiento de stock
INSERT INTO Movimiento_Stock (id_producto, tipo_movimiento, cantidad)
VALUES (1, 'entrada', @total_botellas);


SELECT 
    p.nombre AS producto,
    l.codigo_lote,
    lc.descripcion AS configuracion,
    l.fecha_vencimiento,
    l.total_unidades,
    l.cantidad_pallets,
    l.cantidad_bases,
    l.cantidad_fardos,
    l.cantidad_botellas
FROM Producto p
JOIN Lote l ON p.id_producto = l.id_producto
JOIN Lote_Configuracion lc ON l.id_configuracion = lc.id_configuracion;

-- 📌 Ver stock actual
SELECT p.nombre, s.cantidad_disponible, EstadoStock(p.id_producto) AS estado_stock
FROM Producto p JOIN Stock s ON p.id_producto = s.id_producto;

-- 📌 Ver movimientos de stock
SELECT p.nombre, ms.tipo_movimiento, ms.cantidad, ms.fecha_movimiento
FROM Movimiento_Stock ms JOIN Producto p ON ms.id_producto = p.id_producto;

