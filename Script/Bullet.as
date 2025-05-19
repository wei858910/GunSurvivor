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

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
};