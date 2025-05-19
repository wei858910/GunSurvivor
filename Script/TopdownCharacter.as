class ATopdownCharacter : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCapsuleComponent CapsuleComp;
    default CapsuleComp.SetCapsuleHalfHeight(12.0);
    default CapsuleComp.SetCapsuleRadius(10.5);
    default CapsuleComp.SetCollisionProfileName(n"Pawn");

    UPaperFlipbook IdleFlipbook;

    default IdleFlipbook = Cast<UPaperFlipbook>(LoadObject(nullptr, "/Game/Assets/Flipbooks/Flipbook_PlayerIdle.Flipbook_PlayerIdle"));

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent CharacterFlipbook;
    default CharacterFlipbook.SetFlipbook(IdleFlipbook);
    default CharacterFlipbook.SetCollisionProfileName(n"NoCollision");

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
};