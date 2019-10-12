<?php


namespace App\DataFixtures\Hpi;


use App\Entity\Role;
use App\Entity\Team;
use App\Entity\TeamCategory;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\Persistence\ObjectManager;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;

/**
 * Sets up convenience features for a judge development setup.
 *
 * This does not set up any problems or contests, the example fixture should
 * be used for that (i.e. not setting DJ_SETUP_BARE to 1).
 *
 * @package App\DataFixtures\Hpi
 */
class HpiJudgeDevSetup extends Fixture
{
    /**
     * @var UserPasswordEncoderInterface
     */
    protected $passwordEncoder;

    /**
     * HpiJudgeDevSetup constructor.
     * @param UserPasswordEncoderInterface $passwordEncoder
     */
    public function __construct(UserPasswordEncoderInterface $passwordEncoder)
    {
        $this->passwordEncoder = $passwordEncoder;
    }

    /**
     * @inheritDoc
     */
    public function load(ObjectManager $manager)
    {
        $roleRepo = $manager->getRepository(Role::class);
        $adminRole = $roleRepo->findOneBy(['dj_role' => 'admin']);
        $juryRole = $roleRepo->findOneBy(['dj_role' => 'jury']);
        $teamRole = $roleRepo->findOneBy(['dj_role' => 'team']);
        $category = $manager->getRepository(TeamCategory::class)->findOneBy(['name' => 'Participants']);
        foreach (['test', 'test2', 'test3', 'test4'] as $name) {
            $user = new User();
            $encoded = $this->passwordEncoder->encodePassword($user, $name);
            $team = new Team();
            $user
                ->setUsername($name)
                ->setName($name)
                ->setPassword($encoded)
                ->addUserRole($adminRole)
                ->addUserRole($juryRole)
                ->addUserRole($teamRole)
                ->setTeam($team);
            $team
                ->addUser($user)
                ->setName($name)
                ->setCategory($category);
            $manager->persist($user);
            $manager->persist($team);
        }

        $manager->flush();
    }
}
