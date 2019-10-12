<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20191010172913 extends AbstractMigration
{
    public function getDescription() : string
    {
        return 'Add show source to teams setting';
    }

    public function up(Schema $schema) : void
    {
        $this->addSql(<<<SQL
INSERT INTO `configuration` (`name`, `value`, `type`, `public`, `category`, `description`) VALUES
    ('show_source_to_teams', '0', 'bool', '1', 'Display', 'Allow teams to view the source code of their own submissions');
SQL
        );
    }

    public function down(Schema $schema) : void
    {
        $this->addSql("DELETE FROM configuration WHERE name = 'show_source_to_teams'");
    }
}
