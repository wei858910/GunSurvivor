
event void FPlayerDiedEvent();

class ATopdownCharacter : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCapsuleComponent CapsuleComp;
    default CapsuleComp.SetCapsuleHalfHeight(12.0);
    default CapsuleComp.SetCapsuleRadius(10.5);
    default CapsuleComp.SetCollisionProfileName(n"Pawn");

    UPROPERTY()
    UPaperFlipbook IdleFlipbook;
    default IdleFlipbook = Cast<UPaperFlipbook>(LoadObject(nullptr, "/Game/Assets/Flipbooks/Flipbook_PlayerIdle.Flipbook_PlayerIdle"));

    UPROPERTY()
    UPaperFlipbook RunFlipbook;
    default RunFlipbook = Cast<UPaperFlipbook>(LoadObject(nullptr, "/Game/Assets/Flipbooks/Flipbook_PlayerRun.Flipbook_PlayerRun"));

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent CharacterFlipbook;
    default CharacterFlipbook.SetFlipbook(IdleFlipbook);
    default CharacterFlipbook.SetCollisionProfileName(n"NoCollision");

    UPROPERTY(DefaultComponent)
    USceneComponent GunParent;

    UPROPERTY(DefaultComponent, Attach = GunParent)
    UPaperSpriteComponent GunSpriteComponent;
    default GunSpriteComponent.SetSprite(Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Assets/Sprites/Gun/sGun_Sprite.sGun_Sprite")));
    default GunSpriteComponent.SetCollisionProfileName(n"NoCollision");
    default GunSpriteComponent.TranslucentSortPriority = 5;

    UPROPERTY(DefaultComponent, Attach = GunSpriteComponent)
    USceneComponent BulletSpawnPosition;

    UPROPERTY(Category = "Input")
    UInputMappingContext InputMappingContext;
    default InputMappingContext = Cast<UInputMappingContext>(LoadObject(nullptr, "/Game/Input/IMC_GunServivors.IMC_GunServivors"));

    UPROPERTY(Category = "Input")
    UInputAction MoveAction;
    default MoveAction = Cast<UInputAction>(LoadObject(nullptr, "/Game/Input/IA_Move.IA_Move"));

    UPROPERTY(Category = "Input")
    UInputAction ShootAction;
    default ShootAction = Cast<UInputAction>(LoadObject(nullptr, "/Game/Input/IA_Shoot.IA_Shoot"));

    UPROPERTY(DefaultComponent, Category = "Input")
    UEnhancedInputComponent InputComponent;

    UPROPERTY()
    FVector2D HorizontalLimits = FVector2D(-135., 135.);

    UPROPERTY()
    FVector2D VerticalLimits = FVector2D(-130., 130.);

    UPROPERTY()
    TSubclassOf<ABullet> BulletClass;
    default BulletClass = ABullet;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float MovementSpeed = 100.0;

    UPROPERTY(BlueprintReadWrite)
    FVector2D MovementDirection = FVector2D::ZeroVector;

    UPROPERTY()
    bool bCanMove = true;

    UPROPERTY()
    bool bCanShoot = true;

    UPROPERTY()
    bool bIsAlive = true;

    UPROPERTY()
    float ShootCooldownDuration = 0.3;

    FPlayerDiedEvent PlayerDiedEvent;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CapsuleComp.OnComponentBeginOverlap.AddUFunction(this, n"OnOverlapBegin");

        APlayerController PlayerController = Cast<APlayerController>(Controller);
        if (IsValid(PlayerController))
        {
            PlayerController.bShowMouseCursor = true;
            InputComponent = UEnhancedInputComponent::Create(PlayerController);
            PlayerController.PushInputComponent(InputComponent);
            UEnhancedInputLocalPlayerSubsystem EnhancedInputSystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController);
            if (IsValid(EnhancedInputSystem))
            {
                EnhancedInputSystem.AddMappingContext(InputMappingContext, 0, FModifyContextOptions());
                InputComponent.BindAction(MoveAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"Move"));
                InputComponent.BindAction(MoveAction, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"MoveCompleted"));
                InputComponent.BindAction(ShootAction, ETriggerEvent::Started, FEnhancedInputActionHandlerDynamicSignature(this, n"Shoot"));
                InputComponent.BindAction(ShootAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"Shoot"));
            }
        }
    }

    UFUNCTION()
    private void OnOverlapBegin(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        AEnemy Enemy = Cast<AEnemy>(OtherActor);
        if (IsValid(Enemy) && Enemy.bIsAlive)
        {
            if (bIsAlive)
            {
                bIsAlive = false;
                bCanMove = false;
                bCanShoot = false;

                PlayerDiedEvent.Broadcast();
            }
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // 移动 Player
        if (bCanMove)
        {
            if (MovementDirection.Size() > 0.0)
            {
                if (MovementDirection.Size() > 1.0)
                {
                    MovementDirection.Normalize();
                }
                FVector2D DistanceToMove = MovementDirection * MovementSpeed * DeltaSeconds;
                FVector   CurrentLocation = GetActorLocation();
                FVector   NewLocation = CurrentLocation + FVector(DistanceToMove.X, 0.0, DistanceToMove.Y);
                if (!IsInMapBoundsHorizontal(NewLocation.X))
                {
                    NewLocation -= FVector(DistanceToMove.X, 0.0, 0.0);
                }

                if (!IsInMapBoundsVertical(NewLocation.Z))
                {
                    NewLocation -= FVector(0.0, 0.0, DistanceToMove.Y);
                }
                SetActorLocation(NewLocation);
            }
        }

        // 旋转 Gun
        APlayerController PlayerController = Cast<APlayerController>(Controller);
        if (IsValid(PlayerController))
        {
            FVector MouseWorldLocation, MouseWorldDirection;
            PlayerController.DeprojectMousePositionToWorld(MouseWorldLocation, MouseWorldDirection);
            FVector  CurrentLocation = GetActorLocation();
            FVector  Start = FVector(CurrentLocation.X, 0.0, CurrentLocation.Z);
            FVector  Target = FVector(MouseWorldLocation.X, 0.0, MouseWorldLocation.Z);
            FRotator GunParentRotator = FRotator::MakeFromX(Target - Start);
            GunParent.SetRelativeRotation(GunParentRotator);
        }
    }

    UFUNCTION()
    private void Move(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        FVector2D MoveVector = ActionValue.GetAxis2D();
        if (bCanMove)
        {
            MovementDirection = MoveVector;
            CharacterFlipbook.SetFlipbook(RunFlipbook);
            if (MoveVector.X != 0.0)
            {
                float X = MoveVector.X > 0.0 ? 1.0 : -1.0;
                CharacterFlipbook.SetWorldScale3D(FVector(X, 1.0, 1.0));
            }
        }
    }

    UFUNCTION()
    private void MoveCompleted(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        MovementDirection = FVector2D::ZeroVector;
        CharacterFlipbook.SetFlipbook(IdleFlipbook);
    }

    UFUNCTION()
    private void Shoot(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (bCanShoot)
        {
            bCanShoot = false;

            // 生成子弹
            if (IsValid(BulletClass))
            {
                ABullet Bullet = SpawnActor(BulletClass, BulletSpawnPosition.WorldLocation);
                if (IsValid(Bullet))
                {
                    APlayerController PlayerController = Cast<APlayerController>(Controller);
                    if (IsValid(PlayerController))
                    {
                        FVector MouseWorldLocation, MouseWorldDirection;
                        PlayerController.DeprojectMousePositionToWorld(MouseWorldLocation, MouseWorldDirection);
                        FVector   CurrentLocation = GetActorLocation();
                        FVector2D BulletDirection = FVector2D(MouseWorldLocation.X - CurrentLocation.X, MouseWorldLocation.Z - CurrentLocation.Z);
                        BulletDirection.Normalize();
                        Bullet.Launch(BulletDirection, 1000.0);
                    }
                }
            }
            System::SetTimer(this, n"OnShootCooldownTimeout", ShootCooldownDuration, false);
        }
    }

    bool IsInMapBoundsHorizontal(float XPos)
    {
        return (XPos > HorizontalLimits.X) && (XPos < HorizontalLimits.Y);
    }

    bool IsInMapBoundsVertical(float YPos)
    {
        return (YPos > VerticalLimits.X) && (YPos < VerticalLimits.Y);
    }

    UFUNCTION()
    void OnShootCooldownTimeout()
    {
        bCanShoot = true;
    }
};