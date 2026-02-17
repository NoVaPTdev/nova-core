-- ============================================================
-- NOVA Framework - Database Schema
-- Execute este ficheiro na tua base de dados antes de iniciar
-- ============================================================

-- Tabela de utilizadores
CREATE TABLE IF NOT EXISTS `nova_users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL UNIQUE,
    `license` VARCHAR(60) DEFAULT NULL,
    `steam` VARCHAR(60) DEFAULT NULL,
    `discord` VARCHAR(60) DEFAULT NULL,
    `name` VARCHAR(50) NOT NULL DEFAULT 'Unknown',
    `group` VARCHAR(50) NOT NULL DEFAULT 'user',
    `banned` TINYINT(1) NOT NULL DEFAULT 0,
    `ban_reason` TEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de personagens
CREATE TABLE IF NOT EXISTS `nova_characters` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `citizenid` VARCHAR(10) NOT NULL UNIQUE,
    `firstname` VARCHAR(50) NOT NULL DEFAULT '',
    `lastname` VARCHAR(50) NOT NULL DEFAULT '',
    `dateofbirth` VARCHAR(20) NOT NULL DEFAULT '01/01/2000',
    `gender` TINYINT(1) NOT NULL DEFAULT 0,
    `nationality` VARCHAR(50) NOT NULL DEFAULT 'Português',
    `phone` VARCHAR(15) DEFAULT NULL,
    `cash` INT NOT NULL DEFAULT 5000,
    `bank` INT NOT NULL DEFAULT 10000,
    `black_money` INT NOT NULL DEFAULT 0,
    `job` VARCHAR(50) NOT NULL DEFAULT 'desempregado',
    `job_grade` INT NOT NULL DEFAULT 0,
    `job_duty` TINYINT(1) NOT NULL DEFAULT 0,
    `gang` VARCHAR(50) NOT NULL DEFAULT 'none',
    `gang_grade` INT NOT NULL DEFAULT 0,
    `position` TEXT DEFAULT NULL,
    `inventory` LONGTEXT DEFAULT NULL,
    `metadata` TEXT DEFAULT NULL,
    `skin` LONGTEXT DEFAULT NULL,
    `is_dead` TINYINT(1) NOT NULL DEFAULT 0,
    `last_played` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `nova_users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de empregos
CREATE TABLE IF NOT EXISTS `nova_jobs` (
    `name` VARCHAR(50) NOT NULL PRIMARY KEY,
    `label` VARCHAR(50) NOT NULL,
    `type` VARCHAR(50) DEFAULT NULL,
    `default_duty` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de graus de emprego
CREATE TABLE IF NOT EXISTS `nova_job_grades` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job_name` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `label` VARCHAR(50) NOT NULL,
    `salary` INT NOT NULL DEFAULT 0,
    `is_boss` TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (`job_name`) REFERENCES `nova_jobs`(`name`) ON DELETE CASCADE,
    UNIQUE KEY `job_grade` (`job_name`, `grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de gangs
CREATE TABLE IF NOT EXISTS `nova_gangs` (
    `name` VARCHAR(50) NOT NULL PRIMARY KEY,
    `label` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de graus de gang
CREATE TABLE IF NOT EXISTS `nova_gang_grades` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `gang_name` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `label` VARCHAR(50) NOT NULL,
    `is_boss` TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (`gang_name`) REFERENCES `nova_gangs`(`name`) ON DELETE CASCADE,
    UNIQUE KEY `gang_grade` (`gang_name`, `grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de veículos
CREATE TABLE IF NOT EXISTS `nova_vehicles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(10) NOT NULL,
    `vehicle` VARCHAR(50) NOT NULL,
    `plate` VARCHAR(10) NOT NULL UNIQUE,
    `garage` VARCHAR(50) NOT NULL DEFAULT 'main',
    `state` TINYINT(4) NOT NULL DEFAULT 1,
    `mods` LONGTEXT DEFAULT NULL,
    `fuel` INT NOT NULL DEFAULT 100,
    `body` FLOAT NOT NULL DEFAULT 1000.0,
    `engine` FLOAT NOT NULL DEFAULT 1000.0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`citizenid`) REFERENCES `nova_characters`(`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de propriedades
CREATE TABLE IF NOT EXISTS `nova_properties` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(10) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `coords` TEXT DEFAULT NULL,
    `type` VARCHAR(50) NOT NULL DEFAULT 'house',
    `locked` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`citizenid`) REFERENCES `nova_characters`(`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DADOS PADRÃO
-- ============================================================

-- Empregos padrão
INSERT IGNORE INTO `nova_jobs` (`name`, `label`, `type`, `default_duty`) VALUES
    ('desempregado', 'Desempregado', NULL, 1),
    ('policia', 'Polícia', 'law', 0),
    ('ambulancia', 'Ambulância', 'medical', 0),
    ('mecanico', 'Mecânico', NULL, 0),
    ('taxista', 'Taxista', NULL, 0),
    ('reporter', 'Repórter', NULL, 0),
    ('advogado', 'Advogado', NULL, 0),
    ('imobiliaria', 'Imobiliária', NULL, 0);

-- Graus de emprego padrão
INSERT IGNORE INTO `nova_job_grades` (`job_name`, `grade`, `label`, `salary`, `is_boss`) VALUES
    -- Desempregado
    ('desempregado', 0, 'Desempregado', 100, 0),
    -- Polícia
    ('policia', 0, 'Cadete', 1500, 0),
    ('policia', 1, 'Agente', 2000, 0),
    ('policia', 2, 'Sargento', 2500, 0),
    ('policia', 3, 'Subintendente', 3000, 0),
    ('policia', 4, 'Comandante', 4000, 1),
    -- Ambulância
    ('ambulancia', 0, 'Estagiário', 1500, 0),
    ('ambulancia', 1, 'Paramédico', 2000, 0),
    ('ambulancia', 2, 'Médico', 2500, 0),
    ('ambulancia', 3, 'Cirurgião', 3000, 0),
    ('ambulancia', 4, 'Diretor', 4000, 1),
    -- Mecânico
    ('mecanico', 0, 'Aprendiz', 1200, 0),
    ('mecanico', 1, 'Mecânico', 1800, 0),
    ('mecanico', 2, 'Chefe de Oficina', 2500, 1),
    -- Taxista
    ('taxista', 0, 'Motorista', 1000, 0),
    ('taxista', 1, 'Gerente', 1800, 1),
    -- Repórter
    ('reporter', 0, 'Estagiário', 1000, 0),
    ('reporter', 1, 'Jornalista', 1500, 0),
    ('reporter', 2, 'Editor-Chefe', 2500, 1),
    -- Advogado
    ('advogado', 0, 'Estagiário', 1200, 0),
    ('advogado', 1, 'Advogado', 2000, 0),
    ('advogado', 2, 'Sócio', 3000, 1),
    -- Imobiliária
    ('imobiliaria', 0, 'Agente', 1200, 0),
    ('imobiliaria', 1, 'Gerente', 2000, 1);

-- Gangs padrão
INSERT IGNORE INTO `nova_gangs` (`name`, `label`) VALUES
    ('none', 'Nenhuma'),
    ('ballas', 'Ballas'),
    ('vagos', 'Vagos'),
    ('families', 'Families'),
    ('marabunta', 'Marabunta Grande'),
    ('lost', 'The Lost MC');

-- Graus de gang padrão
INSERT IGNORE INTO `nova_gang_grades` (`gang_name`, `grade`, `label`, `is_boss`) VALUES
    -- Nenhuma
    ('none', 0, 'Membro', 0),
    -- Ballas
    ('ballas', 0, 'Recruta', 0),
    ('ballas', 1, 'Soldado', 0),
    ('ballas', 2, 'Veterano', 0),
    ('ballas', 3, 'Braço Direito', 0),
    ('ballas', 4, 'Líder', 1),
    -- Vagos
    ('vagos', 0, 'Recruta', 0),
    ('vagos', 1, 'Soldado', 0),
    ('vagos', 2, 'Veterano', 0),
    ('vagos', 3, 'Braço Direito', 0),
    ('vagos', 4, 'Líder', 1),
    -- Families
    ('families', 0, 'Recruta', 0),
    ('families', 1, 'Soldado', 0),
    ('families', 2, 'Veterano', 0),
    ('families', 3, 'Braço Direito', 0),
    ('families', 4, 'Líder', 1),
    -- Marabunta Grande
    ('marabunta', 0, 'Recruta', 0),
    ('marabunta', 1, 'Soldado', 0),
    ('marabunta', 2, 'Veterano', 0),
    ('marabunta', 3, 'Braço Direito', 0),
    ('marabunta', 4, 'Líder', 1),
    -- The Lost MC
    ('lost', 0, 'Prospect', 0),
    ('lost', 1, 'Membro', 0),
    ('lost', 2, 'Enforcer', 0),
    ('lost', 3, 'Vice-Presidente', 0),
    ('lost', 4, 'Presidente', 1);
