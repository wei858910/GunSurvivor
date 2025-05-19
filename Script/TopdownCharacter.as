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

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float MovementSpeed = 100.0;

    UPROPERTY(BlueprintReadWrite)
    FVector2D MovementDirection = FVector2D::ZeroVector;

    UPROPERTY()
    bool bCanMove = true;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        APlayerController PlayerController = Cast<APlayerController>(Controller);
        if (IsValid(PlayerController))
        {
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

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
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
    }

    bool IsInMapBoundsHorizontal(float XPos)
    {
        return (XPos > HorizontalLimits.X) && (XPos < HorizontalLimits.Y);
    }

    bool IsInMapBoundsVertical(float YPos)
    {
        return (YPos > VerticalLimits.X) && (YPos < VerticalLimits.Y);
    }
};