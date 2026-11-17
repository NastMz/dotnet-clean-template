using FluentValidation;

namespace Application.ModuleName.FeatureName;

internal sealed class FeatureNameCommandValidator : AbstractValidator<FeatureNameCommand>
{
    public FeatureNameCommandValidator()
    {
        RuleFor(c => c.Id).NotEmpty();
    }
}
