class AEnemy : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCapsuleComponent CapsuleComponent;
    default CapsuleComponent.SetCapsuleHalfHeight(12.0);
    default CapsuleComponent.SetCapsuleRadius(12.0);

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent EnemyFlipbookComponent;
    default EnemyFlipbookComponent.SetCollisionProfileName(n"NoCollision");
    default EnemyFlipbookComponent.TranslucentSortPriority = 0;
    default EnemyFlipbookComponent.SetFlipbook(Cast<UPaperFlipbook>(LoadObject(nullptr, "/Game/Assets/Flipbooks/Flipbook_EnemyRun.Flipbook_EnemyRun")));

    UPROPERTY()
    ATopdownCharacter Player;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        if (!IsValid(Player))
        {
            Player = Cast<ATopdownCharacter>(Gameplay::GetActorOfClass(ATopdownCharacter));
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        
    }


};