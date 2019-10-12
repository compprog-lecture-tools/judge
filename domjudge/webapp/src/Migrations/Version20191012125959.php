<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;
use Symfony\Component\DependencyInjection\ContainerAwareInterface;
use Symfony\Component\DependencyInjection\ContainerAwareTrait;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20191012125959 extends AbstractMigration implements ContainerAwareInterface
{
    use ContainerAwareTrait;

    public function getDescription() : string
    {
        return 'Add C++17 language';
    }

    public function up(Schema $schema) : void
    {
        $this->addSql(<<<SQL
INSERT INTO `executable` (`execid`, `description`, `type`) VALUES
    ('cpp17', 'cpp17', 'compile');
SQL
        );

        $zipFile = sprintf(
            '%s/files/defaultdata/cpp17.zip',
            $this->container->getParameter('domjudge.sqldir')
        );
        $content = strtoupper(bin2hex(file_get_contents($zipFile)));
        $this->addSql(
            sprintf(
                "UPDATE executable SET zipfile = 0x%s, md5sum = :md5sum WHERE execid = 'cpp17'",
                $content
            ),
            [ ':md5sum' => md5_file($zipFile) ]
        );

        $this->addSql(<<<SQL
INSERT INTO `language` (`langid`, `externalid`, `name`, `extensions`, `require_entry_point`, `entry_point_description`, `allow_submit`, `allow_judge`, `time_factor`, `compile_script`) VALUES
    ('cpp17', 'cpp17', 'C++17', '[]', 0, NULL, 0, 1, 1, 'cpp17');
SQL
        );
    }

    public function down(Schema $schema) : void
    {
        $this->addSql("DELETE FROM `language` FROM langid = 'cpp17'");
        $this->addSql("DELETE FROM `executable` FROM execid = 'cpp17'");
    }
}
