class UGameHUD : UUserWidget
{
    UPROPERTY(BindWidget)
    UTextBlock ScoreText;

    void SetScore(int32 NewScore)
    {
        ScoreText.SetText(FText::FromString(f"Score: {NewScore}"));
    }
};