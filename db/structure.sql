/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_address` (
  `address_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `company` varchar(40) NOT NULL,
  `address_1` varchar(128) NOT NULL,
  `address_2` varchar(128) NOT NULL,
  `city` varchar(128) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `country_id` int NOT NULL DEFAULT '0',
  `zone_id` int NOT NULL DEFAULT '0',
  `custom_field` text NOT NULL,
  PRIMARY KEY (`address_id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_api`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_api` (
  `api_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `key` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`api_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_api_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_api_ip` (
  `api_ip_id` int NOT NULL AUTO_INCREMENT,
  `api_id` int NOT NULL,
  `ip` varchar(40) NOT NULL,
  PRIMARY KEY (`api_ip_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_api_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_api_session` (
  `api_session_id` int NOT NULL AUTO_INCREMENT,
  `api_id` int NOT NULL,
  `session_id` varchar(32) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`api_session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_attribute` (
  `attribute_id` int NOT NULL AUTO_INCREMENT,
  `attribute_group_id` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_attribute_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_attribute_description` (
  `attribute_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`attribute_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_attribute_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_attribute_group` (
  `attribute_group_id` int NOT NULL AUTO_INCREMENT,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`attribute_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_attribute_group_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_attribute_group_description` (
  `attribute_group_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`attribute_group_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_banner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_banner` (
  `banner_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`banner_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_banner_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_banner_image` (
  `banner_image_id` int NOT NULL AUTO_INCREMENT,
  `banner_id` int NOT NULL,
  `language_id` int NOT NULL,
  `title` varchar(64) NOT NULL,
  `link` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`banner_image_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_cheque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_cheque` (
  `cheque_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `cashbox_user_id` int NOT NULL,
  `cashbox_warehouse_id` int NOT NULL DEFAULT '0',
  `cashbox_requisites_id` int NOT NULL DEFAULT '0',
  `sum` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `checkbox_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cashbox_work_shift_id` int NOT NULL DEFAULT '0',
  `cashbox_report_id` int NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`cheque_id`),
  KEY `order_id` (`order_id`),
  KEY `cashbox_user_id` (`cashbox_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_report` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL DEFAULT '0',
  `cashbox_user_id` int NOT NULL,
  `z_report_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_requisites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_requisites` (
  `requisites_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`requisites_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_code` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `login` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `checkbox_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `auto_close_time` time DEFAULT NULL,
  `access_token` text COLLATE utf8mb4_unicode_ci,
  `date_access_token_update` datetime DEFAULT NULL,
  `customer_id` int NOT NULL DEFAULT '0',
  `warehouse_id` int NOT NULL DEFAULT '0',
  `requisites_id` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_warehouse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_warehouse` (
  `warehouse_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_cashbox_work_shift`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_cashbox_work_shift` (
  `work_shift_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL DEFAULT '0',
  `cashbox_user_id` int NOT NULL,
  `checkbox_shift_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date_added` datetime NOT NULL,
  `date_start` datetime NOT NULL,
  `date_end` datetime DEFAULT NULL,
  PRIMARY KEY (`work_shift_id`),
  KEY `cashbox_user_id` (`cashbox_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `image` varchar(255) DEFAULT NULL,
  `parent_id` int NOT NULL DEFAULT '0',
  `top` tinyint(1) NOT NULL,
  `column` int NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  `production_period` int NOT NULL DEFAULT '0',
  `banner_id` int NOT NULL DEFAULT '0',
  `image_table_size` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_category_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_category_description` (
  `category_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `advertising_product_name` varchar(255) DEFAULT NULL,
  `description_table_size` text,
  PRIMARY KEY (`category_id`,`language_id`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_category_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_category_filter` (
  `category_id` int NOT NULL,
  `filter_id` int NOT NULL,
  PRIMARY KEY (`category_id`,`filter_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_category_path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_category_path` (
  `category_id` int NOT NULL,
  `path_id` int NOT NULL,
  `level` int NOT NULL,
  PRIMARY KEY (`category_id`,`path_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_category_to_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_category_to_store` (
  `category_id` int NOT NULL,
  `store_id` int NOT NULL,
  PRIMARY KEY (`category_id`,`store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon` (
  `coupon_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `code` varchar(20) NOT NULL,
  `type` char(1) NOT NULL,
  `discount` decimal(15,4) NOT NULL,
  `logged` tinyint(1) NOT NULL,
  `shipping` tinyint(1) NOT NULL,
  `total` decimal(15,4) NOT NULL,
  `date_start` date NOT NULL DEFAULT '0000-00-00',
  `date_end` date NOT NULL DEFAULT '0000-00-00',
  `uses_total` int NOT NULL,
  `uses_customer` varchar(11) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`coupon_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon_category` (
  `coupon_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`coupon_id`,`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon_category_exclude`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon_category_exclude` (
  `coupon_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`coupon_id`,`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon_history` (
  `coupon_history_id` int NOT NULL AUTO_INCREMENT,
  `coupon_id` int NOT NULL,
  `order_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`coupon_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon_product` (
  `coupon_product_id` int NOT NULL AUTO_INCREMENT,
  `coupon_id` int NOT NULL,
  `product_id` int NOT NULL,
  PRIMARY KEY (`coupon_product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_coupon_product_exclude`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_coupon_product_exclude` (
  `coupon_id` int NOT NULL,
  `product_id` int NOT NULL,
  PRIMARY KEY (`coupon_id`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_crosssell_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_crosssell_item` (
  `crosssell_item_id` int NOT NULL AUTO_INCREMENT,
  `type` enum('product','category') NOT NULL,
  `target_id` int NOT NULL,
  `discount` decimal(5,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`crosssell_item_id`),
  UNIQUE KEY `type_target` (`type`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_crosssell_sort`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_crosssell_sort` (
  `product_id` int NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_custom_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_custom_field` (
  `custom_field_id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  `value` text NOT NULL,
  `validation` varchar(255) NOT NULL,
  `location` varchar(10) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`custom_field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_custom_field_customer_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_custom_field_customer_group` (
  `custom_field_id` int NOT NULL,
  `customer_group_id` int NOT NULL,
  `required` tinyint(1) NOT NULL,
  PRIMARY KEY (`custom_field_id`,`customer_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_custom_field_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_custom_field_description` (
  `custom_field_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`custom_field_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_custom_field_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_custom_field_value` (
  `custom_field_value_id` int NOT NULL AUTO_INCREMENT,
  `custom_field_id` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`custom_field_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_custom_field_value_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_custom_field_value_description` (
  `custom_field_value_id` int NOT NULL,
  `language_id` int NOT NULL,
  `custom_field_id` int NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`custom_field_value_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `customer_group_id` int NOT NULL,
  `store_id` int NOT NULL DEFAULT '0',
  `language_id` int NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(9) NOT NULL,
  `cart` text,
  `wishlist` text,
  `newsletter` tinyint(1) NOT NULL DEFAULT '0',
  `address_id` int NOT NULL DEFAULT '0',
  `custom_field` text NOT NULL,
  `ip` varchar(40) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `safe` tinyint(1) NOT NULL,
  `token` text NOT NULL,
  `code` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_activity` (
  `customer_activity_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `key` varchar(64) NOT NULL,
  `data` text NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_activity_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_approval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_approval` (
  `customer_approval_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `type` varchar(9) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_approval_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_group` (
  `customer_group_id` int NOT NULL AUTO_INCREMENT,
  `approval` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`customer_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_group_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_group_description` (
  `customer_group_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`customer_group_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_history` (
  `customer_history_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `comment` text NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_ip` (
  `customer_ip_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_ip_id`),
  KEY `ip` (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_login` (
  `customer_login_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(96) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `total` int NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`customer_login_id`),
  KEY `email` (`email`),
  KEY `ip` (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_online`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_online` (
  `ip` varchar(40) NOT NULL,
  `customer_id` int NOT NULL,
  `url` text NOT NULL,
  `referer` text NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_reward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_reward` (
  `customer_reward_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL DEFAULT '0',
  `order_id` int NOT NULL DEFAULT '0',
  `description` text NOT NULL,
  `points` int NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_reward_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_search`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_search` (
  `customer_search_id` int NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `language_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `category_id` int DEFAULT NULL,
  `sub_category` tinyint(1) NOT NULL,
  `description` tinyint(1) NOT NULL,
  `products` int NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_search_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_customer_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_customer_transaction` (
  `customer_transaction_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `order_id` int NOT NULL,
  `description` text NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`customer_transaction_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_download`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_download` (
  `download_id` int NOT NULL AUTO_INCREMENT,
  `filename` varchar(160) NOT NULL,
  `mask` varchar(128) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`download_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_download_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_download_description` (
  `download_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`download_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_faq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_faq` (
  `faq_id` int NOT NULL AUTO_INCREMENT,
  `author` varchar(64) NOT NULL DEFAULT '',
  `email` varchar(96) NOT NULL DEFAULT '',
  `comment` text,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`faq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_faq_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_faq_description` (
  `faq_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`faq_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_filter` (
  `filter_id` int NOT NULL AUTO_INCREMENT,
  `filter_group_id` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`filter_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_filter_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_filter_description` (
  `filter_id` int NOT NULL,
  `language_id` int NOT NULL,
  `filter_group_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`filter_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_filter_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_filter_group` (
  `filter_group_id` int NOT NULL AUTO_INCREMENT,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`filter_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_filter_group_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_filter_group_description` (
  `filter_group_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`filter_group_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_information` (
  `information_id` int NOT NULL AUTO_INCREMENT,
  `bottom` int NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`information_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_information_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_information_description` (
  `information_id` int NOT NULL,
  `language_id` int NOT NULL,
  `title` varchar(64) NOT NULL,
  `description` mediumtext NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL,
  PRIMARY KEY (`information_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_information_to_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_information_to_store` (
  `information_id` int NOT NULL,
  `store_id` int NOT NULL,
  PRIMARY KEY (`information_id`,`store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_instagram`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_instagram` (
  `instagram_id` bigint NOT NULL,
  `media_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `media_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `caption` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `permalink` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`instagram_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_manufacturer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_manufacturer` (
  `manufacturer_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`manufacturer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_manufacturer_to_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_manufacturer_to_store` (
  `manufacturer_id` int NOT NULL,
  `store_id` int NOT NULL,
  PRIMARY KEY (`manufacturer_id`,`store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_marketing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_marketing` (
  `marketing_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `description` text NOT NULL,
  `code` varchar(64) NOT NULL,
  `clicks` int NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`marketing_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_mono_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_mono_orders` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `InvoiceId` varchar(50) DEFAULT NULL,
  `OrderId` int DEFAULT NULL,
  `SecretKey` varchar(51) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  `amount` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `createdDate` datetime DEFAULT NULL,
  `modifiedDate` datetime DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_novaposhta_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_novaposhta_document` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `carrier` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `ref` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `api_key` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `number` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cost` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `status_code` int NOT NULL DEFAULT '0',
  `recipient_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `redelivery` tinyint(1) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  `date_scheduled` date DEFAULT NULL,
  `date_payed_keeping` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `number` (`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_novaposhta_warehouse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_novaposhta_warehouse` (
  `ref` varchar(36) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `category_of_warehouse` varchar(32) NOT NULL DEFAULT '',
  `city_ref` varchar(36) NOT NULL DEFAULT '',
  `city_description` varchar(255) NOT NULL DEFAULT '',
  `weight` int NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ref`),
  KEY `city_ref` (`city_ref`),
  KEY `city_description` (`city_description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_option` (
  `option_id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`option_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_option_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_option_description` (
  `option_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`option_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_option_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_option_value` (
  `option_value_id` int NOT NULL AUTO_INCREMENT,
  `option_id` int NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`option_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_option_value_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_option_value_description` (
  `option_value_id` int NOT NULL,
  `language_id` int NOT NULL,
  `option_id` int NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`option_value_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `invoice_no` int NOT NULL DEFAULT '0',
  `invoice_prefix` varchar(26) NOT NULL,
  `store_id` int NOT NULL DEFAULT '0',
  `store_name` varchar(64) NOT NULL,
  `store_url` varchar(255) NOT NULL,
  `customer_id` int NOT NULL DEFAULT '0',
  `customer_group_id` int NOT NULL DEFAULT '0',
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `custom_field` text NOT NULL,
  `payment_firstname` varchar(32) NOT NULL,
  `payment_lastname` varchar(32) NOT NULL,
  `payment_company` varchar(60) NOT NULL,
  `payment_address_1` varchar(128) NOT NULL,
  `payment_address_2` varchar(128) NOT NULL,
  `payment_city` varchar(128) NOT NULL,
  `payment_postcode` varchar(10) NOT NULL,
  `payment_country` varchar(128) NOT NULL,
  `payment_country_id` int NOT NULL,
  `payment_zone` varchar(128) NOT NULL,
  `payment_zone_id` int NOT NULL,
  `payment_address_format` text NOT NULL,
  `payment_custom_field` text NOT NULL,
  `payment_method` varchar(128) NOT NULL,
  `payment_code` varchar(128) NOT NULL,
  `shipping_firstname` varchar(32) NOT NULL,
  `shipping_lastname` varchar(32) NOT NULL,
  `shipping_company` varchar(40) NOT NULL,
  `shipping_address_1` varchar(128) NOT NULL,
  `shipping_address_2` varchar(128) NOT NULL,
  `shipping_city` varchar(128) NOT NULL,
  `shipping_postcode` varchar(10) NOT NULL,
  `shipping_country` varchar(128) NOT NULL,
  `shipping_country_id` int NOT NULL,
  `shipping_zone` varchar(128) NOT NULL,
  `shipping_zone_id` int NOT NULL,
  `shipping_address_format` text NOT NULL,
  `shipping_custom_field` text NOT NULL,
  `shipping_method` varchar(128) NOT NULL,
  `shipping_code` varchar(128) NOT NULL,
  `comment` text NOT NULL,
  `total` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `order_status_id` int NOT NULL DEFAULT '0',
  `affiliate_id` int NOT NULL,
  `commission` decimal(15,4) NOT NULL,
  `marketing_id` int NOT NULL,
  `tracking` varchar(64) NOT NULL,
  `language_id` int NOT NULL,
  `currency_id` int NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_value` decimal(15,8) NOT NULL DEFAULT '1.00000000',
  `ip` varchar(40) NOT NULL,
  `forwarded_ip` varchar(40) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `accept_language` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  `order_source_id` int NOT NULL DEFAULT '0',
  `date_remind` datetime DEFAULT NULL,
  `prepayment` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `instagram` varchar(128) NOT NULL DEFAULT '',
  `birthday_day` int NOT NULL DEFAULT '0',
  `birthday_month` int NOT NULL DEFAULT '0',
  `shipping_house` varchar(32) NOT NULL DEFAULT '',
  `shipping_flat` varchar(32) NOT NULL DEFAULT '',
  `callback` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  `date_shipping` date DEFAULT NULL,
  PRIMARY KEY (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_option` (
  `order_option_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `order_product_id` int NOT NULL,
  `product_option_id` int NOT NULL,
  `product_option_value_id` int NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `type` varchar(32) NOT NULL,
  PRIMARY KEY (`order_option_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_product` (
  `order_product_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `model` varchar(64) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `total` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `tax` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `reward` int NOT NULL,
  `crosssell` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`order_product_id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_source` (
  `order_source_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`order_source_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_status` (
  `order_status_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL,
  `name` varchar(32) NOT NULL,
  `color` varchar(7) NOT NULL DEFAULT '',
  PRIMARY KEY (`order_status_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_status_log` (
  `order_status_log_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  `old_status_id` int NOT NULL,
  `new_status_id` int NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`order_status_log_id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_total`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_total` (
  `order_total_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `code` varchar(32) NOT NULL,
  `title` varchar(255) NOT NULL,
  `value` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `sort_order` int NOT NULL,
  PRIMARY KEY (`order_total_id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_order_voucher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_order_voucher` (
  `order_voucher_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `voucher_id` int NOT NULL,
  `description` varchar(255) NOT NULL,
  `code` varchar(10) NOT NULL,
  `from_name` varchar(64) NOT NULL,
  `from_email` varchar(96) NOT NULL,
  `to_name` varchar(64) NOT NULL,
  `to_email` varchar(96) NOT NULL,
  `voucher_theme_id` int NOT NULL,
  `message` text NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  PRIMARY KEY (`order_voucher_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_partner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_partner` (
  `partner_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) NOT NULL,
  `name` varchar(128) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `feed_url` varchar(255) DEFAULT NULL,
  `feed_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `vendor_name` varchar(128) DEFAULT NULL,
  `default_quantity` int NOT NULL DEFAULT '5',
  `notes` text,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`partner_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_partner_category_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_partner_category_map` (
  `partner_category_map_id` int NOT NULL AUTO_INCREMENT,
  `partner_id` int NOT NULL,
  `category_id` int NOT NULL,
  `size_name` varchar(64) DEFAULT NULL,
  `external_id` varchar(64) DEFAULT NULL,
  `external_name` varchar(255) DEFAULT NULL,
  `percent_supply` decimal(8,2) DEFAULT NULL,
  `percent_sale` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`partner_category_map_id`),
  KEY `partner_id` (`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_partner_product_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_partner_product_map` (
  `partner_product_map_id` int NOT NULL AUTO_INCREMENT,
  `partner_id` int NOT NULL,
  `product_id` int NOT NULL,
  `size_name` varchar(255) DEFAULT NULL,
  `external_id` varchar(255) NOT NULL DEFAULT '',
  `external_name` varchar(255) NOT NULL DEFAULT '',
  `price_supply` decimal(15,4) DEFAULT NULL,
  `price_sale` decimal(15,4) DEFAULT NULL,
  PRIMARY KEY (`partner_product_map_id`),
  KEY `partner_id` (`partner_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_post` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `image` varchar(255) NOT NULL DEFAULT '',
  `big_image` varchar(255) NOT NULL DEFAULT '',
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `date_available` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_post_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_post_category` (
  `post_category_id` int NOT NULL AUTO_INCREMENT,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`post_category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_post_category_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_post_category_description` (
  `post_category_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`post_category_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_post_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_post_description` (
  `post_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `meta_title` varchar(255) NOT NULL DEFAULT '',
  `meta_description` varchar(255) NOT NULL DEFAULT '',
  `image_alt` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`post_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_post_to_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_post_to_category` (
  `post_id` int NOT NULL,
  `post_category_id` int NOT NULL,
  PRIMARY KEY (`post_id`,`post_category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_privatbank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_privatbank` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL DEFAULT '0',
  `appcode` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `card` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `amount` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cardamount` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `rest` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `terminal` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `trandate` date NOT NULL,
  `trantime` time NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `show_status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`payment_id`),
  KEY `appcode` (`appcode`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `model` varchar(64) NOT NULL,
  `sku` varchar(64) NOT NULL,
  `upc` varchar(12) NOT NULL,
  `ean` varchar(14) NOT NULL,
  `jan` varchar(13) NOT NULL,
  `isbn` varchar(17) NOT NULL,
  `mpn` varchar(64) NOT NULL,
  `location` varchar(128) NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `stock_status_id` int NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `manufacturer_id` int NOT NULL,
  `shipping` tinyint(1) NOT NULL DEFAULT '1',
  `price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `points` int NOT NULL DEFAULT '0',
  `tax_class_id` int NOT NULL,
  `date_available` date NOT NULL DEFAULT '0000-00-00',
  `weight` decimal(15,8) NOT NULL DEFAULT '0.00000000',
  `weight_class_id` int NOT NULL DEFAULT '0',
  `length` decimal(15,8) NOT NULL DEFAULT '0.00000000',
  `width` decimal(15,8) NOT NULL DEFAULT '0.00000000',
  `height` decimal(15,8) NOT NULL DEFAULT '0.00000000',
  `length_class_id` int NOT NULL DEFAULT '0',
  `subtract` tinyint(1) NOT NULL DEFAULT '1',
  `minimum` int NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `viewed` int NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_attribute` (
  `product_id` int NOT NULL,
  `attribute_id` int NOT NULL,
  `language_id` int NOT NULL,
  `text` text NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_color`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_color` (
  `product_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`product_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_description` (
  `product_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `tag` text NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL,
  `table_size` text,
  `variant` text,
  `notice` text,
  `model_info` varchar(255) DEFAULT NULL,
  `characteristics` text,
  PRIMARY KEY (`product_id`,`language_id`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_filter` (
  `product_id` int NOT NULL,
  `filter_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`filter_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_image` (
  `product_image_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_image_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_label` (
  `label_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `background_color` varchar(16) NOT NULL DEFAULT '',
  `text_color` varchar(16) NOT NULL DEFAULT '',
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`label_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_manual_pin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_manual_pin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_type` varchar(50) NOT NULL,
  `group_key` varchar(100) NOT NULL,
  `position` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `group_key` (`group_type`,`group_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_option` (
  `product_option_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `option_id` int NOT NULL,
  `value` text NOT NULL,
  `required` tinyint(1) NOT NULL,
  PRIMARY KEY (`product_option_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_option_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_option_value` (
  `product_option_value_id` int NOT NULL AUTO_INCREMENT,
  `product_option_id` int NOT NULL,
  `product_id` int NOT NULL,
  `option_id` int NOT NULL,
  `option_value_id` int NOT NULL,
  `quantity` int NOT NULL,
  `subtract` tinyint(1) NOT NULL,
  `price` decimal(15,4) NOT NULL,
  `price_prefix` varchar(1) NOT NULL,
  `points` int NOT NULL,
  `points_prefix` varchar(1) NOT NULL,
  `weight` decimal(15,8) NOT NULL,
  `weight_prefix` varchar(1) NOT NULL,
  `pre_order_quantity` int NOT NULL DEFAULT '0',
  `date_available` date DEFAULT NULL,
  PRIMARY KEY (`product_option_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_order_snapshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_order_snapshot` (
  `snapshot_id` int NOT NULL AUTO_INCREMENT,
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`snapshot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_order_snapshot_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_order_snapshot_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `snapshot_id` int NOT NULL,
  `product_id` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `snapshot_id` (`snapshot_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_related`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_related` (
  `product_id` int NOT NULL,
  `related_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`related_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_related_color`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_related_color` (
  `product_id` int NOT NULL,
  `related_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`related_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_related_variant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_related_variant` (
  `product_id` int NOT NULL,
  `related_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`related_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_special`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_special` (
  `product_special_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `customer_group_id` int NOT NULL,
  `priority` int NOT NULL DEFAULT '1',
  `price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `date_start` date NOT NULL DEFAULT '0000-00-00',
  `date_end` date NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`product_special_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_to_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_to_category` (
  `product_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`category_id`),
  KEY `category_id` (`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_to_download`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_to_download` (
  `product_id` int NOT NULL,
  `download_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`download_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_to_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_to_label` (
  `product_id` int NOT NULL,
  `label_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`label_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_product_to_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_product_to_store` (
  `product_id` int NOT NULL,
  `store_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`,`store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL DEFAULT '',
  `telephone` varchar(32) NOT NULL DEFAULT '',
  `question` text NOT NULL,
  `date_added` datetime NOT NULL,
  `city` varchar(128) NOT NULL DEFAULT '',
  `comment` text,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `date_question` date DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_remarketing_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_remarketing_orders` (
  `order_id` int NOT NULL,
  `first_referrer` varchar(255) NOT NULL DEFAULT '',
  `last_referrer` varchar(255) NOT NULL DEFAULT '',
  `utm_source` varchar(255) NOT NULL DEFAULT '',
  `utm_medium` varchar(255) NOT NULL DEFAULT '',
  `utm_campaign` varchar(255) NOT NULL DEFAULT '',
  `utm_content` varchar(255) NOT NULL DEFAULT '',
  `utm_term` varchar(255) NOT NULL DEFAULT '',
  `utm_referrer` varchar(255) NOT NULL DEFAULT '',
  `success_page` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ga4` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `facebook` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `facebook_lead` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `esputnik` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `telegram` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `tiktok` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_return`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_return` (
  `return_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `product` varchar(255) NOT NULL,
  `model` varchar(64) NOT NULL,
  `quantity` int NOT NULL,
  `opened` tinyint(1) NOT NULL,
  `return_reason_id` int NOT NULL,
  `return_action_id` int NOT NULL,
  `return_status_id` int NOT NULL,
  `comment` text,
  `date_ordered` date NOT NULL DEFAULT '0000-00-00',
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`return_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_return_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_return_action` (
  `return_action_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`return_action_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_return_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_return_history` (
  `return_history_id` int NOT NULL AUTO_INCREMENT,
  `return_id` int NOT NULL,
  `return_status_id` int NOT NULL,
  `notify` tinyint(1) NOT NULL,
  `comment` text NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`return_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_return_reason`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_return_reason` (
  `return_reason_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`return_reason_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_return_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_return_status` (
  `return_status_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL DEFAULT '0',
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`return_status_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `author` varchar(64) NOT NULL,
  `text` text NOT NULL,
  `rating` int NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`review_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_review_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_review_image` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `review_id` int NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` tinyint NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`image_id`),
  KEY `idx_review_id` (`review_id`),
  KEY `idx_review_status` (`review_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_search_preset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_search_preset` (
  `preset_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`preset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_seo_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_seo_url` (
  `seo_url_id` int NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `language_id` int NOT NULL,
  `query` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  PRIMARY KEY (`seo_url_id`),
  KEY `query` (`query`),
  KEY `keyword` (`keyword`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_setting` (
  `setting_id` int NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL DEFAULT '0',
  `code` varchar(128) NOT NULL,
  `key` varchar(128) NOT NULL,
  `value` text NOT NULL,
  `serialized` tinyint(1) NOT NULL,
  PRIMARY KEY (`setting_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_sms_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_sms_log` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL DEFAULT '0',
  `pre_order_id` int NOT NULL DEFAULT '0',
  `phone` varchar(32) NOT NULL,
  `text` text NOT NULL,
  `response` text NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`message_id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_statistics` (
  `statistics_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL,
  `value` decimal(15,4) NOT NULL,
  PRIMARY KEY (`statistics_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int DEFAULT NULL,
  `unit` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'шт.',
  `stock` decimal(10,2) NOT NULL DEFAULT '0.00',
  `min_stock` decimal(10,2) NOT NULL DEFAULT '0.00',
  `used_for` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `supplier_id` int DEFAULT NULL,
  `price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_supplier` (`supplier_id`),
  KEY `idx_stock_alert` (`stock`,`min_stock`),
  CONSTRAINT `fk_stock_item_category` FOREIGN KEY (`category_id`) REFERENCES `dd_stock_categories` (`category_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_stock_item_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `dd_stock_suppliers` (`supplier_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_id` int DEFAULT NULL,
  `username` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `action` enum('use','restock','add','edit','delete') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stock_before` decimal(10,2) DEFAULT NULL,
  `stock_after` decimal(10,2) DEFAULT NULL,
  `comment` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_item` (`item_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_date` (`date_added`),
  KEY `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production` (
  `production_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'clothing',
  `min_total` int NOT NULL DEFAULT '50',
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`production_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_categories` (
  `production_id` int NOT NULL,
  `oc_category_id` int NOT NULL,
  `name_filter` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `match_exact` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`production_id`,`oc_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_component_bom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_component_bom` (
  `bom_id` int NOT NULL AUTO_INCREMENT,
  `component_id` int NOT NULL,
  `size_id` int DEFAULT NULL,
  `item_id` int NOT NULL,
  `qty_per_unit` decimal(12,4) NOT NULL,
  PRIMARY KEY (`bom_id`),
  KEY `component_id` (`component_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_component_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_component_stock` (
  `component_id` int NOT NULL,
  `size_id` int NOT NULL,
  `stock` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`component_id`,`size_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_components` (
  `component_id` int NOT NULL AUTO_INCREMENT,
  `production_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`component_id`),
  KEY `production_id` (`production_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `production_id` int NOT NULL,
  `size_id` int NOT NULL,
  `size_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  `username` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `stage` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `stock_before` decimal(12,3) NOT NULL,
  `stock_after` decimal(12,3) NOT NULL,
  `comment` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `production_id` (`production_id`,`date_added`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_products` (
  `production_id` int NOT NULL,
  `product_id` int NOT NULL,
  PRIMARY KEY (`production_id`,`product_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_sewn_bom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_sewn_bom` (
  `bom_id` int NOT NULL AUTO_INCREMENT,
  `production_id` int NOT NULL,
  `size_id` int DEFAULT NULL,
  `component_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `qty_per_unit` decimal(12,4) NOT NULL,
  PRIMARY KEY (`bom_id`),
  KEY `production_id` (`production_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_production_sizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_production_sizes` (
  `size_id` int NOT NULL AUTO_INCREMENT,
  `production_id` int NOT NULL,
  `size_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `cut_stock` decimal(12,3) NOT NULL DEFAULT '0.000',
  `sewn_stock` decimal(12,3) NOT NULL DEFAULT '0.000',
  `sort_order` int NOT NULL DEFAULT '0',
  `oc_option_value_id` int DEFAULT NULL,
  PRIMARY KEY (`size_id`),
  KEY `production_id` (`production_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_status` (
  `stock_status_id` int NOT NULL AUTO_INCREMENT,
  `language_id` int NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`stock_status_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_stock_suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_stock_suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `categories` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_subscribe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_subscribe` (
  `subscribe_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(96) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`subscribe_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_upload`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_upload` (
  `upload_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`upload_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `user_group_id` int NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(9) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `image` varchar(255) NOT NULL,
  `code` varchar(40) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_user_group` (
  `user_group_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `permission` text NOT NULL,
  PRIMARY KEY (`user_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_voucher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_voucher` (
  `voucher_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `code` varchar(10) NOT NULL,
  `from_name` varchar(64) NOT NULL,
  `from_email` varchar(96) NOT NULL,
  `to_name` varchar(64) NOT NULL,
  `to_email` varchar(96) NOT NULL,
  `voucher_theme_id` int NOT NULL,
  `message` text NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`voucher_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_voucher_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_voucher_history` (
  `voucher_history_id` int NOT NULL AUTO_INCREMENT,
  `voucher_id` int NOT NULL,
  `order_id` int NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`voucher_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_voucher_theme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_voucher_theme` (
  `voucher_theme_id` int NOT NULL AUTO_INCREMENT,
  `image` varchar(255) NOT NULL,
  PRIMARY KEY (`voucher_theme_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_voucher_theme_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_voucher_theme_description` (
  `voucher_theme_id` int NOT NULL,
  `language_id` int NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`voucher_theme_id`,`language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dd_warehouse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dd_warehouse` (
  `warehouse_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `description` text NOT NULL,
  `contact` varchar(128) NOT NULL DEFAULT '',
  `telephone` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(128) NOT NULL DEFAULT '',
  `address` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(64) NOT NULL DEFAULT '',
  `image` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`warehouse_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_competitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_competitor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `site_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price_regex` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_competitor_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_competitor_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competitor_id` int NOT NULL,
  `product_id` int NOT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_price` decimal(15,2) DEFAULT NULL,
  `last_checked_at` datetime DEFAULT NULL,
  `last_error` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_erp_competitor_link_competitor_product` (`competitor_id`,`product_id`),
  KEY `ix_erp_competitor_link_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_competitor_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_competitor_price` (
  `id` int NOT NULL AUTO_INCREMENT,
  `link_id` int NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `source` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'auto',
  `checked_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_erp_competitor_price_link` (`link_id`,`checked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_order_manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_order_manager` (
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  `assigned_by_user_id` int NOT NULL,
  `assigned_at` datetime NOT NULL,
  PRIMARY KEY (`order_id`),
  KEY `ix_erp_order_manager_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_production_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_production_location` (
  `id` int NOT NULL AUTO_INCREMENT,
  `size_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_erp_production_location_size_warehouse` (`size_id`,`warehouse_id`),
  KEY `ix_erp_production_location_warehouse` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_production_transfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_production_transfer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `production_id` int NOT NULL,
  `size_id` int NOT NULL,
  `from_warehouse_id` int DEFAULT NULL,
  `to_warehouse_id` int DEFAULT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `comment` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_id` int NOT NULL,
  `username` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_erp_production_transfer_model` (`production_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_purchase_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_purchase_order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int NOT NULL,
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_by_user_id` int NOT NULL,
  `created_at` datetime NOT NULL,
  `ordered_at` datetime DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_erp_purchase_order_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_purchase_order_line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_purchase_order_line` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `received_quantity` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`id`),
  KEY `ix_erp_purchase_order_line_order` (`order_id`),
  KEY `ix_erp_purchase_order_line_item` (`item_id`),
  CONSTRAINT `fk_erp_purchase_order_line_order` FOREIGN KEY (`order_id`) REFERENCES `erp_purchase_order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_shipment_sender`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_shipment_sender` (
  `shipment_id` int NOT NULL,
  `sender_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by_user_id` int NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`shipment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_stock_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_stock_location` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_erp_stock_location_item_warehouse` (`item_id`,`warehouse_id`),
  KEY `ix_erp_stock_location_warehouse` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_stock_transfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_stock_transfer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `from_warehouse_id` int DEFAULT NULL,
  `to_warehouse_id` int DEFAULT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `comment` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_id` int NOT NULL,
  `username` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_erp_stock_transfer_item` (`item_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `erp_user_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `erp_user_login` (
  `user_id` int NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `security_stamp` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

INSERT INTO `schema_migrations` (version) VALUES
('20261120000001');

