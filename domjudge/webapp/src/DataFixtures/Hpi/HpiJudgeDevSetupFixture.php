<?php


namespace App\DataFixtures\Hpi;


use Doctrine\Persistence\ObjectManager;

/**
 * Sets up convenience features for a judge development setup.
 *
 * This does not set up any problems or contests, the example fixture should
 * be used for that (i.e. not setting DJ_DB_INSTALL_BARE to 1).
 *
 * @package App\DataFixtures\Hpi
 */
class HpiJudgeDevSetupFixture extends AbstractSetupFixture
{

    /**
     * @inheritDoc
     */
    public function load(ObjectManager $manager)
    {
        foreach (['test', 'test2', 'test3', 'test4'] as $name) {
            $this->addDevUser($manager, $name);
        }

        $manager->flush();
    }
}
