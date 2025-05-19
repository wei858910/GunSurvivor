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
    FVector2D MovementDirection = FVector2D::UnitVector;

    UPROPERTY()
    float MovementSpeed = 300.0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        FVector2D DistanceToMove = MovementDirection * MovementSpeed * DeltaSeconds;
        FVector   CurrentLocation = GetActorLocation();
        FVector   NewLocation = CurrentLocation + FVector(DistanceToMove.X, 0., DistanceToMove.Y);
        SetActorLocation(NewLocation);
    }
};