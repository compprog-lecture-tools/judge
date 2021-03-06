<?php declare(strict_types=1);

namespace App\Utils\Scoreboard;

use App\Entity\Team;

class TeamScore
{
    /**
     * @var Team
     */
    public $team;

    /**
     * @var int
     */
    public $numPoints = 0;

    /**
     * @var float[]
     */
    public $solveTimes = [];

    /**
     * @var int
     */
    public $rank = 0;

    /**
     * @var int
     */
    public $totalTime;

    /**
     * @var float
     */
    public $totalRuntime = 0.0;


    /**
     * @var bool
     */
    public $active;

    /**
     * TeamScore constructor.
     * @param Team $team
     */
    public function __construct(Team $team)
    {
        $this->team      = $team;
        $this->totalTime = $team->getPenalty();
        $this->active    = false;
    }
}
