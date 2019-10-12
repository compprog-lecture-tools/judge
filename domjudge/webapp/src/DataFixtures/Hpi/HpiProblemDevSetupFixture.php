<?php


namespace App\DataFixtures\Hpi;


use App\Entity\Contest;
use App\Entity\User;
use Doctrine\Common\Persistence\ObjectManager;

/**
 * Sets up convenience features for a problem development setup.
 *
 * @package App\DataFixtures\Hpi
 */
class HpiProblemDevSetupFixture extends AbstractSetupFixture
{
    /**
     * @inheritDoc
     */
    public function load(ObjectManager $manager)
    {
        $this->addDevUser($manager, 'test');

        $testingContest = new Contest();
        $testingContest
            ->setExternalid('testing')
            ->setName('Testing contest')
            ->setShortname('testing')
            ->setStarttimeString('2000-01-01 01:00:00 Europe/Amsterdam')
            ->setActivatetimeString('2000-01-01 01:00:00 Europe/Amsterdam')
            ->setFreezetimeString('2040-01-01 01:00:00 Europe/Amsterdam')
            ->setEndtimeString('2040-01-01 01:00:00 Europe/Amsterdam')
            ->setUnfreezetimeString('2040-01-01 01:00:00 Europe/Amsterdam')
            ->setDeactivatetimeString('2040-01-01 01:00:00 Europe/Amsterdam');
        $manager->persist($testingContest);

        // Set the judgehost password to 'password'. This allows the judgehost
        // container to connect without any further configuration
        $judgehostUser = $manager->getRepository(User::class)->findOneBy(['username' => 'judgehost']);
        $encoded = $this->passwordEncoder->encodePassword($judgehostUser, 'password');
        $judgehostUser->setPassword($encoded);

        $manager->flush();
    }
}
