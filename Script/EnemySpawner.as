class AEnemySpawner : AActor
{
    UPROPERTY()
    TSubclassOf<AEnemy> EnemyClass = AEnemy;

    UPROPERTY()
    float SpawnTime = 1.0;

    UPROPERTY()
    float SpwanDistance = 400.0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
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
        FVector RandomPosition = Math::VRand();
        RandomPosition.Y = 0.0;
        RandomPosition.Normalize();
        RandomPosition *= SpwanDistance;
        FVector EnemyLocation = GetActorLocation() + RandomPosition;
        AEnemy  Enemy = SpawnActor(EnemyClass, EnemyLocation);
    }
};