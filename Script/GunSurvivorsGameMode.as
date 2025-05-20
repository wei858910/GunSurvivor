class AGunSurvivorsGameMode : AGameModeBase
{
    UClass PlayerPawnClass;
    default PlayerPawnClass = Cast<UClass>(LoadObject(nullptr, "/Game/BP/BP_Player.BP_Player_C"));

    default DefaultPawnClass = PlayerPawnClass;

    UPROPERTY()
    int32 Score = 0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SetScore(0);
    }

    void SetScore(int32 NewScore)
    {
        if (NewScore > 0)
        {
            Score = NewScore;
        }
    }

    void AddScore(int32 Increment)
    {
        int32 NewScore = Score + Increment;
        SetScore(NewScore);
        Print(f"Score: {NewScore}");
    }
};