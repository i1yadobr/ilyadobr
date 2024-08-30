CREATE DATABASE IF NOT EXISTS `feedback`;
USE `feedback`;


CREATE TABLE IF NOT EXISTS `connection` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `ckey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `computerid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `eams_ban_provider` (
  `ip_as` varchar(255) NOT NULL,
  `ip_isp` varchar(255) NOT NULL,
  `ip_org` varchar(255) NOT NULL,
  `ip_country` varchar(255) NOT NULL,
  `ip_countryCode` varchar(255) NOT NULL,
  `ip_region` varchar(255) NOT NULL,
  `ip_regionCode` varchar(255) NOT NULL,
  `ip_city` varchar(255) NOT NULL,
  `ip_lat` float(7,2) NOT NULL,
  `ip_lon` float(7,2) NOT NULL,
  `ip_timezone` varchar(255) NOT NULL,
  `ip_zip` varchar(255) NOT NULL,
  `ip_reverse` varchar(255) NOT NULL,
  `ip_mobile` bit(1) NOT NULL,
  `ip_proxy` bit(1) NOT NULL,
  `type` bit(1) NOT NULL,
  `priority` bit(1) NOT NULL,
  `ckey` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `eams_cache` (
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `ss13_admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `rank` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Administrator',
  `flags` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ss13_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` varchar(18) NOT NULL,
  `log` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ss13_ban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int NOT NULL,
  `rounds` int DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_reason` text,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  `server_id` varchar(32) NOT NULL,
  PRIMARY KEY (`id`,`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;


CREATE TABLE IF NOT EXISTS `ss13_iaa_approved` (
  `ckey` varchar(32) NOT NULL,
  `approvals` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `ss13_iaa_jobban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fakeid` varchar(6) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `iaa_ckey` varchar(32) NOT NULL,
  `other_ckeys` text NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) NOT NULL,
  `creation_time` datetime NOT NULL,
  `resolve_time` datetime DEFAULT NULL,
  `resolve_comment` text,
  `resolve_ckey` varchar(32) DEFAULT NULL,
  `cancel_time` datetime DEFAULT NULL,
  `cancel_comment` text,
  `cancel_ckey` varchar(32) DEFAULT NULL,
  `status` varchar(32) NOT NULL,
  `expiration_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `ss13_player` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `lastadminrank` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `ss13_watch` (
  `ckey` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;


CREATE TABLE IF NOT EXISTS `library` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` text NOT NULL,
  `title` text NOT NULL,
  `content` text NOT NULL,
  `category` text NOT NULL,
  `deleted` int DEFAULT NULL,
  `author_ckey` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;


CREATE TABLE IF NOT EXISTS `art_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `title` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `deleted` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;


CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) NOT NULL,
  `race` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `whitelist_ckey` (
  `ckey` varchar(50) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
