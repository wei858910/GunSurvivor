class AGunSurvivorsGameMode : AGameModeBase
{
    UClass PlayerPawnClass;
    default PlayerPawnClass = Cast<UClass>(LoadObject(nullptr, "/Game/BP/BP_Player.BP_Player_C"));

    default DefaultPawnClass = PlayerPawnClass;

    UPROPERTY()
    int32 Score = 0;

    UPROPERTY()
    TSubclassOf<UGameHUD> WidgetClass = Cast<UClass>(LoadObject(nullptr, "/Game/BP/BP_GameHUD.BP_GameHUD_C"));

    UGameHUD HUD;

    UPROPERTY()
    float TimeBeforeRestart = 0.3;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SetScore(0);
        if (IsValid(WidgetClass))
        {
            APlayerController PC = Gameplay::GetPlayerController(0);
            if (IsValid(PC))
            {
                UUserWidget Widget = WidgetBlueprint::CreateWidget(WidgetClass, PC);
                HUD = Cast<UGameHUD>(Widget); // 假设 Widget 是 UGameHU
                if (IsValid(HUD))
                {
                    HUD.SetScore(0);     // 假设 SetScore 是 UGameHUD 中的一个函数
                    HUD.AddToViewport(); // 将 Widget 添加到视口
                }
            }
        }
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
        if (IsValid(HUD))
        {
            HUD.SetScore(NewScore);
        }
    }

    void RestartGame()
    {
        System::SetTimer(this, n"OnRestartGameTimeout", 1., false, InitialStartDelay = TimeBeforeRestart);
    }

    UFUNCTION()
    private void OnRestartGameTimeout()
    {
        Gameplay::OpenLevel(n"MainLevel");
    }
};