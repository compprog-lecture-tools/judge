<?php


namespace App\DataFixtures\Hpi;


use App\Entity\Configuration;
use App\Entity\Language;
use App\Entity\TeamCategory;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

/**
 * Sets up the settings and language settings for an HPI setup.
 *
 * @package App\DataFixtures\Hpi
 */
class HpiSettingsFixture extends Fixture
{
    private static $settings = [
        'lazy_eval_results' => 1,
        'clar_enable' => 0,
        'show_pending' => 1,
        'show_flags' => 0,
        'show_affiliations' => 0,
        'show_affiliation_logos' => 0,
        'show_sample_output' => 1,
        'show_limits_on_team_page' => 1,
        'show_source_to_teams' => 1,
        'registration_category_name' => 'Participants',
    ];

    /**
     * @inheritDoc
     */
    public function load(ObjectManager $manager)
    {
        if ($manager->getRepository(TeamCategory::class)->findOneBy(['name' => 'Participants']) === null) {
            $participants = new TeamCategory();
            $participants->setName('Participants');
            $manager->persist($participants);
        }

        # TODO: this way of doing it does not work anymore?
        #$configRepo = $manager->getRepository(Configuration::class);
        #foreach (self::$settings as $name => $value) {
            #$configRepo->findOneBy(['name' => $name])->setValue($value);
        #}

        $langRepo = $manager->getRepository(Language::class);
        $langRepo->find('cpp')->setAllowSubmit(false);
        $langRepo->find('c')->setAllowSubmit(false);
        $langRepo->find('cpp17')->setAllowSubmit(true)->setExtensions(['cpp']);
        $langRepo->find('py3')->setAllowSubmit(true)->setExtensions(['py']);
        $langRepo->find('java')->setAllowSubmit(true);

        $manager->flush();
    }
}
