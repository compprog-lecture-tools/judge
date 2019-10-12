<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20191012114952 extends AbstractMigration
{
    public function getDescription() : string
    {
        return '';
    }

    public function up(Schema $schema) : void
    {
        $this->addSql(<<<SQL
INSERT INTO `configuration` (`name`, `value`, `type`, `public`, `category`, `description`) VALUES
    ('clar_enable', '1', 'bool', '1', 'Clarification', 'Enable clarifications?');
SQL
        );
    }

    public function down(Schema $schema) : void
    {
        $this->addSql("DELETE FROM configuration WHERE name = 'clar_enable'");
    }
}
