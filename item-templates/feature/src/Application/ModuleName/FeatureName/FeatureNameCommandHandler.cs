using Application.Abstractions.Messaging;
using SharedKernel;

namespace Application.ModuleName.FeatureName;

#if (hasResponseType)
internal sealed class FeatureNameCommandHandler : ICommandHandler<FeatureNameCommand, ResponseType>
{
    public Task<Result<ResponseType>> Handle(FeatureNameCommand command, CancellationToken cancellationToken)
    {
        // Inject the dependencies you need (for example IApplicationDbContext) through the primary constructor
        // and replace this placeholder with the use case logic.
        return Task.FromResult(Result.Failure<ResponseType>(
            Error.Failure("ModuleName.FeatureName.NotImplemented", "FeatureName is not implemented yet.")));
    }
}
#else
internal sealed class FeatureNameCommandHandler : ICommandHandler<FeatureNameCommand>
{
    public Task<Result> Handle(FeatureNameCommand command, CancellationToken cancellationToken)
    {
        // Inject the dependencies you need (for example IApplicationDbContext) through the primary constructor
        // and replace this placeholder with the use case logic.
        return Task.FromResult(Result.Failure(
            Error.Failure("ModuleName.FeatureName.NotImplemented", "FeatureName is not implemented yet.")));
    }
}
#endif
