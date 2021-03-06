<?php declare(strict_types=1);

namespace App\Utils\Scoreboard;

class ProblemSummary
{
    /**
     * @var int[]
     */
    public $numSubmissions = [];

    /**
     * @var int[]
     */
    public $numSubmissionsPending = [];

    /**
     * @var int[]
     */
    public $numSubmissionsCorrect = [];

    /**
     * @var float[]
     */
    public $bestTimes = [];

    /**
     * for each sortorder, the runtime of the fastest correct solution
     * @var float[]
     */
    protected $bestRuntimes = [];

    /**
     * @param int $sortorder
     * @param int $numSubmissions
     * @param int $numSubmissionsPending
     * @param int $numSubmissionsCorrect
     */
    public function addSubmissionCounts(
        int $sortorder,
        int $numSubmissions,
        int $numSubmissionsPending,
        int $numSubmissionsCorrect
    ) {
        if (!isset($this->numSubmissions[$sortorder])) {
            $this->numSubmissions[$sortorder] = 0;
        }
        if (!isset($this->numSubmissionsPending[$sortorder])) {
            $this->numSubmissionsPending[$sortorder] = 0;
        }
        if (!isset($this->numSubmissionsCorrect[$sortorder])) {
            $this->numSubmissionsCorrect[$sortorder] = 0;
        }
        $this->numSubmissions[$sortorder]        += $numSubmissions;
        $this->numSubmissionsPending[$sortorder] += $numSubmissionsPending;
        $this->numSubmissionsCorrect[$sortorder] += $numSubmissionsCorrect;
    }

    /**
     * Get the best time in minutes for the given sortorder
     * @param int $sortorder
     * @return int|null
     */
    public function getBestTimeInMinutes(int $sortorder)
    {
        if (isset($this->bestTimes[$sortorder])) {
            return ((int)($this->bestTimes[$sortorder] / 60));
        }
        return null;
    }

    /**
     * @param int   $sortorder
     * @param float $bestTime
     */
    public function updateBestTime(int $sortorder, $bestTime)
    {
        $this->bestTimes[$sortorder] = $bestTime;
    }

    /**
     * @param int   $sortorder
     * @return float
     */
    public function getBestRuntime(int $sortorder): float
    {
        return $this->bestRuntimes[$sortorder] ?? INF;
    }

    /**
     * update fastest runtime if given time is
     * a new record for this problem/sortorder
     * @param int   $sortorder
     * @param float $runTime
     */
    public function updateBestRuntime(int $sortorder, $runtime)
    {
        if ($runtime < $this->getBestRuntime($sortorder)) {
            $this->bestRuntimes[$sortorder] = $runtime;
        }
    }
}
