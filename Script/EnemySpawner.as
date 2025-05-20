class AEnemySpawner : AActor
{
    UPROPERTY()
    TSubclassOf<AEnemy> EnemyClass = AEnemy;

    UPROPERTY()
    float SpawnTime = 1.0;

    UPROPERTY()
    float SpwanDistance = 400.0;

    UPROPERTY()
    int32 TotalEnemyCount = 0;

    UPROPERTY()
    int32 DifficultySpikeInterval = 10;

    UPROPERTY()
    float SpawnTimeInimumLimit = 0.5;

    UPROPERTY()
    float DecreaseSpawnTimeByEveryInterval = 0.05;

    ATopdownCharacter Player;

    AGunSurvivorsGameMode MyGameMode;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MyGameMode = Cast<AGunSurvivorsGameMode>(Gameplay::GetGameMode());

        if (!IsValid(Player))
        {
            Player = Cast<ATopdownCharacter>(Gameplay::GetActorOfClass(ATopdownCharacter));
            if (IsValid(Player))
            {
                Player.PlayerDiedEvent.AddUFunction(this, n"OnPlayerDead");
            }
        }
        StartSpawning();
    }

    void StartSpawning()
    {
        System::SetTimer(this, n"OnSpawnTimeout", SpawnTime, true);
    }

    UFUNCTION()
    void OnSpawnTimeout()
    {
        SpawnEnemy();
    }

    void StopSpawning()
    {
        System::ClearTimer(this, "OnSpawnTimeout");
    }

    void SpawnEnemy()
    {
        // 随机位置 生成敌人
        FVector RandomPosition = Math::VRand();
        RandomPosition.Y = 0.0;
        RandomPosition.Normalize();
        RandomPosition *= SpwanDistance;
        FVector EnemyLocation = GetActorLocation() + RandomPosition;
        AEnemy  Enemy = SpawnActor(EnemyClass, EnemyLocation);
        SetupEnemy(Enemy);

        // 增加难度
        ++TotalEnemyCount;

        if ((TotalEnemyCount % DifficultySpikeInterval) == 0)
        {
            if (SpawnTime > SpawnTimeInimumLimit)
            {
                SpawnTime -= DecreaseSpawnTimeByEveryInterval;
                if (SpawnTime < SpawnTimeInimumLimit)
                {
                    SpawnTime = SpawnTimeInimumLimit;
                }
                StopSpawning();
                StartSpawning();
            }
        }
    }

    void SetupEnemy(AEnemy Enemy)
    {
        if (IsValid(Enemy))
        {
            Enemy.Player = Player;
            Enemy.bCanFollow = true;
            Enemy.EnemyDiedEvent.AddUFunction(this, n"OnEnemyDied");
        }
    }

    UFUNCTION()
    private void OnEnemyDied()
    {
        int ScoreToAdd = 10;
        if (IsValid(MyGameMode))
        {
            MyGameMode.AddScore(ScoreToAdd);
        }
    }

    UFUNCTION()
    private void OnPlayerDead()
    {
        StopSpawning();

        TArray<AActor> EnemyArray;

        Gameplay::GetAllActorsOfClass(AEnemy, EnemyArray);

        for (auto EnemyItem : EnemyArray)
        {
            AEnemy Enemy = Cast<AEnemy>(EnemyItem);
            if (IsValid(Enemy))
            {
                if (Enemy.bIsAlive)
                {
                    Enemy.bCanFollow = false;
                }
            }
        }

        if (IsValid(MyGameMode))
        {
            MyGameMode.RestartGame();
        }
    }
};