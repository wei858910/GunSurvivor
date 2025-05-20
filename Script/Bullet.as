class ABullet : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent SphereComponent;
    default SphereComponent.SetSphereRadius(6.0);
    default SphereComponent.SetCollisionProfileName(n"OverlapAllDynamic");

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent BulletSpriteComponent;
    default BulletSpriteComponent.SetSprite(Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Assets/Sprites/Gun/sBullet_Sprite.sBullet_Sprite")));
    default BulletSpriteComponent.SetCollisionProfileName(n"NoCollision");
    default BulletSpriteComponent.TranslucentSortPriority = 10;

    UPROPERTY()
    FVector2D MovementDirection = FVector2D::ZeroVector;

    UPROPERTY()
    float MovementSpeed = 300.0;

    UPROPERTY()
    bool bIsLauched = false;

    UPROPERTY()
    bool bIsEnable = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SphereComponent.OnComponentBeginOverlap.AddUFunction(this, n"OnOverlapBegin");
    }

    UFUNCTION()
    private void OnOverlapBegin(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        AEnemy Enemy = Cast<AEnemy>(OtherActor);
        if (IsValid(Enemy) && Enemy.bIsAlive)
        {
            DisableBullet();
        }
    }

    void DisableBullet()
    {
        if (bIsEnable)
            return;
        bIsEnable = true;
        SphereComponent.SetCollisionEnabled(ECollisionEnabled::NoCollision);
        BulletSpriteComponent.DestroyComponent(BulletSpriteComponent);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (bIsLauched)
        {
            FVector2D DistanceToMove = MovementDirection * MovementSpeed * DeltaSeconds;
            FVector   CurrentLocation = GetActorLocation();
            FVector   NewLocation = CurrentLocation + FVector(DistanceToMove.X, 0., DistanceToMove.Y);
            SetActorLocation(NewLocation);
        }
    }

    void Launch(FVector2D Direction, float Speed = 300.0)
    {
        if (bIsLauched)
            return;

        bIsLauched = true;

        MovementDirection = Direction;
        MovementSpeed = Speed;
        float DeleteTime = 10.0;
        System::SetTimer(this, n"OnDeleteTimerTimeout", DeleteTime, false);
    }

    UFUNCTION()
    void OnDeleteTimerTimeout()
    {
        DestroyActor();
    }
};