<?php


namespace App\DataFixtures\Hpi;


use App\Entity\Role;
use App\Entity\Team;
use App\Entity\TeamCategory;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;

abstract class AbstractSetupFixture extends Fixture
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
     * Adds a user (and associated team) with the password equivalent to the username.
     */
    protected function addDevUser(ObjectManager $manager, string $name) {
        $roleRepo = $manager->getRepository(Role::class);
        $adminRole = $roleRepo->findOneBy(['dj_role' => 'admin']);
        $juryRole = $roleRepo->findOneBy(['dj_role' => 'jury']);
        $teamRole = $roleRepo->findOneBy(['dj_role' => 'team']);
        $category = $manager->getRepository(TeamCategory::class)->findOneBy(['name' => 'Participants']);
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
}
