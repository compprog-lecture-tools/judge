<?php declare(strict_types=1);

namespace App\Utils\Scoreboard;

class ScoreboardMatrixItem
{
    /**
     * @var bool
     */
    public $isCorrect;

    /**
     * @var bool
     */
    public $isFirst;

    /**
     * @var int
     */
    public $numSubmissions;

    /**
     * @var int
     */
    public $numSubmissionsPending;

    /**
     * @var float|string
     */
    public $time;

    /**
     * @var int
     */
    public $penaltyTime;

    /**
     * @var float
     */
    public $runtime;

    /**
     * ScoreboardMatrixItem constructor.
     * @param bool $isCorrect
     * @param bool $isFirst
     * @param int $numSubmissions
     * @param int $numSubmissionsPending
     * @param float|string $time
     * @param int $penaltyTime
     * @param float $runtime
     */
    public function __construct(
        bool $isCorrect,
        bool $isFirst,
        int $numSubmissions,
        int $numSubmissionsPending,
        $time,
        int $penaltyTime,
        float $runtime
    ) {
        $this->isCorrect             = $isCorrect;
        $this->isFirst               = $isFirst;
        $this->numSubmissions        = $numSubmissions;
        $this->numSubmissionsPending = $numSubmissionsPending;
        $this->time                  = $time;
        $this->penaltyTime           = $penaltyTime;
        $this->runtime               = $runtime;
    }
}
