<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20191122175149 extends AbstractMigration
{
    public function getDescription() : string
    {
        return 'Runtime based contests';
    }

    public function up(Schema $schema) : void
    {
        $this->abortIf($this->connection->getDatabasePlatform()->getName() !== 'mysql', 'Migration can only be executed safely on \'mysql\'.');

        $this->addSql('ALTER TABLE scorecache ADD runtime_restricted DOUBLE PRECISION NOT NULL, ADD runtime_public DOUBLE PRECISION NOT NULL');
        $this->addSql('ALTER TABLE contest ADD order_by_runtime TINYINT(1) NOT NULL');
        $this->addSql('ALTER TABLE rankcache ADD totalruntime_restricted DOUBLE PRECISION NOT NULL, ADD totalruntime_public DOUBLE PRECISION NOT NULL');
    }

    public function down(Schema $schema) : void
    {
        $this->abortIf($this->connection->getDatabasePlatform()->getName() !== 'mysql', 'Migration can only be executed safely on \'mysql\'.');

        $this->addSql('ALTER TABLE scorecache DROP runtime_restricted, DROP runtime_public');
        $this->addSql('ALTER TABLE contest DROP order_by_runtime');
        $this->addSql('ALTER TABLE rankcache DROP totalruntime_restricted, DROP totalruntime_public');
    }
}
