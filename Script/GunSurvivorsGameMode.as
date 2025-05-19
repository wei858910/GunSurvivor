class AGunSurvivorsGameMode : AGameModeBase
{
    UClass PlayerPawnClass;
    default PlayerPawnClass = Cast<UClass>(LoadObject(nullptr, "/Game/BP/BP_Player.BP_Player_C"));

    default DefaultPawnClass = PlayerPawnClass;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
};