class AEnemy : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCapsuleComponent CapsuleComponent;
    default CapsuleComponent.SetCapsuleHalfHeight(12.0);
    default CapsuleComponent.SetCapsuleRadius(12.0);

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent EnemyFlipbookComponent;
    default EnemyFlipbookComponent.SetCollisionProfileName(n"NoCollision");
    default EnemyFlipbookComponent.TranslucentSortPriority = 1;
    default EnemyFlipbookComponent.SetFlipbook(Cast<UPaperFlipbook>(LoadObject(nullptr, "/Game/Assets/Flipbooks/Flipbook_EnemyRun.Flipbook_EnemyRun")));

    UPROPERTY()
    ATopdownCharacter Player;

    UPROPERTY()
    bool bIsAlive = true;

    UPROPERTY()
    bool bCanFollow = true;

    UPROPERTY()
    float MovementSpeed = 50.0;

    UPROPERTY()
    float StopDistance = 20.0;

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
        if (bIsAlive && bCanFollow && IsValid(Player))
        {
            // 移动 Enemy 到 Player
            FVector CurrentLocation = GetActorLocation();
            FVector PlayerLocation = Player.GetActorLocation();
            FVector DirectionToPlayer = PlayerLocation - CurrentLocation;
            float   DistanceToPlayer = DirectionToPlayer.Size();
            if (DistanceToPlayer >= StopDistance)
            {
                DirectionToPlayer.Normalize();
                FVector NewLocation = CurrentLocation + DirectionToPlayer * MovementSpeed * DeltaSeconds;
                SetActorLocation(NewLocation);
            }

            // 翻转 Enemy 朝向 Player
            float FlipX = EnemyFlipbookComponent.GetWorldScale().X;
            if (PlayerLocation.X - CurrentLocation.X >= 0.0)
            {
                if (FlipX < 0.0)
                {
                    EnemyFlipbookComponent.SetWorldScale3D(FVector(1.0, 1.0, 1.0));
                }
            }
            else
            {
                if (FlipX > 0.0)
                {
                    EnemyFlipbookComponent.SetWorldScale3D(FVector(-1.0, 1.0, 1.0));
                }
            }
        }
    }
};