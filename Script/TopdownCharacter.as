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

    UFUNCTION()
    private void Move(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        FVector2D MoveVector = ActionValue.GetAxis2D();
        // Print("Move: " + MoveVector.ToString());
    }

    UFUNCTION()
    private void MoveCompleted(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        PrintWarning("Move Completed");
    }

    UFUNCTION()
    private void Shoot(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        Print("Shoot");
    }
};